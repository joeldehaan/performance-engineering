#!/usr/bin/env bash
# STREAM with OpenMP, unmodified stream/stream.c:
#   (a) bandwidth vs number of threads      -> omp-threads.csv
#   (b) effect of OMP_PROC_BIND (all cores) -> omp-affinity.csv
# each for a small array (N = 1024, fits in L1D) and a large one (N = 2^25, far beyond the LLC).
#
# Why the LD_PRELOAD clock: stream.c times every kernel call with gettimeofday (1 us resolution),
# but one call on 1024 elements takes less than that, so the stock output is quantised or "inf".
# The shim below replaces gettimeofday with a clock that runs 1000x fast (1 returned microsecond =
# 1 real nanosecond). STREAM then sees times 1000x too long; this script divides them by 1000 again
# and recomputes the rate from the printed "Min time". The same clock is used for every run, so
# small and large N are measured the same way.
#
# Usage:  bash stream-omp.sh
# Quick test: RUNS=2 LARGE_N=4194304 bash stream-omp.sh

STREAM_SRC=${STREAM_SRC:-stream/stream.c}      # your original file, not modified
SMALL_N=${SMALL_N:-1024}
LARGE_N=${LARGE_N:-$((1 << 25))}
NTIMES_SMALL=${NTIMES_SMALL:-100}   # STREAM keeps the best of NTIMES-1 calls
NTIMES_LARGE=${NTIMES_LARGE:-10}
RUNS=${RUNS:-10}                    # runs per configuration
RUN_TIMEOUT=${RUN_TIMEOUT:-300}     # seconds per run; a run that hits this is dropped and reported
SCALE=1000                          # clock speed-up, must match the shim below
MAXT=${MAXT:-$(nproc)}

OUT_A="omp-threads.csv"
OUT_B="omp-affinity.csv"
SHIM="$PWD/libfineclock.so"

# ---------- the clock shim ----------
cat > fineclock.c <<'EOF'
#define _GNU_SOURCE
#include <time.h>
#include <sys/time.h>
/* 1 returned microsecond = 1 real nanosecond (clock runs 1000x fast), counted from the first call. */
int gettimeofday(struct timeval *tv, void *tz)
{
    static long long origin = -1;
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    long long ns = (long long) ts.tv_sec * 1000000000LL + ts.tv_nsec;
    if (origin < 0) origin = ns;
    long long fake_us = ns - origin + 1000000LL;   /* offset keeps the value positive and away from 0 */
    tv->tv_sec  = fake_us / 1000000LL;
    tv->tv_usec = fake_us % 1000000LL;
    return 0;
}
EOF
gcc -shared -fPIC -O2 -o "$SHIM" fineclock.c || exit 1

# ---------- the benchmark binaries (stream.c itself is compiled as is) ----------
gcc -fopenmp -O2 -DSTREAM_ARRAY_SIZE=$SMALL_N -DNTIMES=$NTIMES_SMALL "$STREAM_SRC" -o stream_small || exit 1
gcc -fopenmp -O2 -DSTREAM_ARRAY_SIZE=$LARGE_N -DNTIMES=$NTIMES_LARGE "$STREAM_SRC" -o stream_large || exit 1

# parse N : rate recomputed from the printed "Min time" (4th field, in fake seconds)
#   real time = min_time / SCALE ;  rate [MB/s] = 1e-6 * bytes / real time ;  bytes = 8 * N * (2 or 3)
parse() {
    awk -v s=$SCALE -v n=$1 '
        /^(Copy|Scale|Add|Triad):/ {
            k = $1; gsub(":", "", k)
            bytes = ((k=="Copy" || k=="Scale") ? 2 : 3) * 8 * n
            if ($4 > 0) printf "%s,%.1f\n", k, 1e-6 * bytes / ($4 / s)
        }'
}

# sanity check: with the shim active, a run must yield four finite rates
OMP_NUM_THREADS=1 timeout 60 env LD_PRELOAD="$SHIM" ./stream_small | parse $SMALL_N | wc -l | grep -qx 4 \
    || { echo "ERROR: LD_PRELOAD clock shim has no effect (got no usable Min time)"; exit 1; }

# run_cfg CSV PREFIX BIN N : RUNS runs with the OMP_* variables currently exported.
run_cfg() {
    local csv=$1 prefix=$2 bin=$3 n=$4 out
    for ((r=1; r<=RUNS; r++)); do
        out=$(timeout --foreground "$RUN_TIMEOUT" env LD_PRELOAD="$SHIM" ./"$bin") \
            || echo "  run $r failed or timed out (>${RUN_TIMEOUT}s)" >&2
        echo "$out" | parse "$n" | sed "s/^/$prefix,/" >> "$csv"
    done
}

SIZES="$SMALL_N:stream_small $LARGE_N:stream_large"
TOTAL=$(( 2 * (MAXT + 5) ))
DONE=0
SECONDS=0
progress() {  # $1 = label of the configuration that just finished
    DONE=$((DONE + 1))
    printf '[%s] %2d/%d  %-34s elapsed %dm%02ds\n' "$(date +%H:%M:%S)" "$DONE" "$TOTAL" "$1" $((SECONDS/60)) $((SECONDS%60))
}

# ---------- (a) bandwidth vs number of threads (default affinity) ----------
echo "array_size,threads,kernel,rate_mbps" > "$OUT_A"
unset OMP_PROC_BIND OMP_PLACES
for pair in $SIZES; do
    n=${pair%%:*}; bin=${pair##*:}
    for ((T=1; T<=MAXT; T++)); do
        export OMP_NUM_THREADS=$T
        run_cfg "$OUT_A" "$n,$T" "$bin" "$n"
        progress "(a) N=$n threads=$T"
    done
done

# ---------- (b) affinity, all cores ----------
# OMP_PLACES=cores makes master/close/spread meaningful (one place per core); it is irrelevant for "false".
echo "array_size,proc_bind,threads,kernel,rate_mbps" > "$OUT_B"
export OMP_NUM_THREADS=$MAXT OMP_PLACES=cores
for pair in $SIZES; do
    n=${pair%%:*}; bin=${pair##*:}
    for BIND in true false master close spread; do
        export OMP_PROC_BIND=$BIND
        run_cfg "$OUT_B" "$n,$BIND,$MAXT" "$bin" "$n"
        progress "(b) N=$n proc_bind=$BIND"
    done
done

rm -f stream_small stream_large fineclock.c "$SHIM"
echo "Done in $((SECONDS/60))m$((SECONDS%60))s: $OUT_A, $OUT_B"
