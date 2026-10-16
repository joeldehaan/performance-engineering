#!/usr/bin/env bash
# Strong scaling: fixed total problem size, increasing thread count.
# Output: strong-scaling.csv with the columns threads,run1,...,runN (wall time in seconds).
#
# Every setting can be overridden from the environment, e.g.
#   THREAD_COUNTS="1 2 4 8 16" REPETITIONS=7 ./strong_scaling.sh
set -euo pipefail
export LC_ALL=C   # '.' as decimal separator in EPOCHREALTIME and awk

BUILD_COMMAND="${BUILD_COMMAND:-make -B}"   # -B: rebuild unconditionally, make does not track NX/NY changes
BINARY="${BINARY:-./main}"
PROGRAM_ARGS="${PROGRAM_ARGS:-}"
GRID_NX="${GRID_NX:-1024}"
GRID_NY="${GRID_NY:-514}"                    # interior rows = GRID_NY - 2, large enough to split over many threads
THREAD_COUNTS="${THREAD_COUNTS:-1 2 4 8}"
REPETITIONS="${REPETITIONS:-5}"
OUTPUT_FILE="${OUTPUT_FILE:-strong-scaling.csv}"
METADATA_FILE="${OUTPUT_FILE%.csv}.meta.txt"

# Pin the OpenMP runtime so that runs are comparable
export OMP_DYNAMIC=false
export OMP_PROC_BIND=close
export OMP_PLACES=cores

write_metadata()
{
    {
        echo "date:            $(date --iso-8601=seconds)"
        echo "host:            $(hostname)"
        echo "cpu:             $(lscpu | sed -n 's/^Model name:[[:space:]]*//p')"
        echo "logical cores:   $(nproc --all)"
        echo "compiler:        $(${CXX:-g++} --version | head -n 1)"
        echo "git commit:      $(git rev-parse HEAD 2>/dev/null || echo n/a)"
        echo "git dirty:       $(git status --porcelain 2>/dev/null | wc -l) changed files"
        echo "source sha256:   $(sha256sum main.cc | cut -d' ' -f1)"
        echo "grid:            nx=${GRID_NX} ny=${GRID_NY}"
        echo "thread counts:   ${THREAD_COUNTS}"
        echo "repetitions:     ${REPETITIONS}"
        echo "program args:    ${PROGRAM_ARGS}"
        echo "OMP_PROC_BIND:   ${OMP_PROC_BIND}"
        echo "OMP_PLACES:      ${OMP_PLACES}"
    } > "${METADATA_FILE}"
}

write_header()
{
    local header="threads"
    for ((repetition = 1; repetition <= REPETITIONS; ++repetition)); do
        header+=",run${repetition}"
    done
    echo "${header}" > "${OUTPUT_FILE}"
}

# Wall time of one run in seconds
time_run()
{
    local const_threads="$1"
    local start="${EPOCHREALTIME}"
    # shellcheck disable=SC2086
    OMP_NUM_THREADS="${const_threads}" "${BINARY}" ${PROGRAM_ARGS} > /dev/null
    local end="${EPOCHREALTIME}"
    awk -v start="${start}" -v end="${end}" 'BEGIN { printf "%.6f\n", end - start }'
}

mkdir -p "$(dirname "${OUTPUT_FILE}")"
write_metadata
${BUILD_COMMAND} NX="${GRID_NX}" NY="${GRID_NY}"

write_header
for threads in ${THREAD_COUNTS}; do
    time_run "${threads}" > /dev/null   # warm-up run, discarded
    row="${threads}"
    for ((repetition = 1; repetition <= REPETITIONS; ++repetition)); do
        seconds="$(time_run "${threads}")"
        row+=",${seconds}"
        echo "threads=${threads} run=${repetition} t=${seconds}s"
    done
    echo "${row}" >> "${OUTPUT_FILE}"
done

echo
cat "${OUTPUT_FILE}"
echo "written to ${OUTPUT_FILE} (settings in ${METADATA_FILE})"
