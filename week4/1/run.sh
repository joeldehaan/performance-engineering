#!/usr/bin/env bash
# Usage: bash run.sh            (expects sqsum.cpp in the same folder)
set -euo pipefail

SRC=${SRC:-sqsum.cpp}
N=2048                      # elements per call (16 KiB, fits in L1d)
CALLS=500000                # calls per run
REPS=5                      # repeat every setting, keep the minimum
CORE=2                      # CPU core the benchmark is pinned to
UNROLLS=($(seq 1 32))       # every unroll factor from 1 to 32
UNIT="cycles/element"

mkdir build/

# ---- Run one binary REPS times, print the minimum ----------------------
measure() {
  local bin=$1 best="" v r
  for ((r = 0; r < REPS; r++)); do
    # perf prints its CSV to stderr; the program's own output is discarded.
    v=$(perf stat -x, -e cycles taskset -c "$CORE" "$bin" 2>&1 >/dev/null |
        awk -F, -v w="$((N * CALLS))" '$3 ~ /cycles/ { printf "%.4f", $1 / w }')
    if [[ -z $best ]] || awk -v a="$v" -v b="$best" 'BEGIN { exit !(a < b) }'; then
      best=$v
    fi
  done
  echo "$best"
}

echo "fma,unroll,cycles/element" > results.csv

printf '%-5s %-7s %s\n' "FMA" "U" "cycles/element (min of $REPS runs)"

for fma in 0 1; do
  for u in "${UNROLLS[@]}"; do
    flags=(-std=c++26 -O2 -fno-tree-vectorize -ffp-contract=off -march=native
           -DUNROLL=$u -DN=$N -DCALLS=$CALLS)
    ((fma)) && flags+=(-DUSE_FMA)

    g++ "${flags[@]}"      "$SRC" -o "build/bench_fma${fma}_u${u}"

    val=$(measure "build/bench_fma${fma}_u${u}")
    printf '%-5s %-7s %s\n' "$fma" "$u" "$val"
    echo "$fma,$u,$val" >> results.csv
  done
done

rm -r build/

