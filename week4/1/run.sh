#!/usr/bin/env bash
# Usage: bash run.sh            (expects sqsum.cpp in the same folder)
set -euo pipefail

SRC=${SRC:-sqsum.cpp}
N=2048                      # elements per call (16 KiB, fits in L1d)
CALLS=500000                # calls per run
REPS=5                      # repeat every setting, keep the minimum
CORE=2                      # CPU core the benchmark is pinned to
UNROLLS=($(seq 1 32))       # every unroll factor from 1 to 32

mkdir -p build asm

# ---- Documentation of the system used ---------------------------------
{
  echo "Date: $(date)"
  g++ --version | head -1
  lscpu | grep -E 'Model name|CPU\(s\)|MHz|L1d|L2|L3'
  echo "Governor: $(cat /sys/devices/system/cpu/cpu${CORE}/cpufreq/scaling_governor 2>/dev/null || echo unknown)"
  echo "Flags: -std=c++26 -O2 -fno-tree-vectorize -ffp-contract=off -march=native"
  echo "N=$N CALLS=$CALLS REPS=$REPS pinned to core $CORE"
} | tee system_info.txt

# ---- Is perf usable (hardware cycle counter)? --------------------------
use_perf=0
if command -v perf >/dev/null 2>&1 &&
   perf stat -x, -e cycles true 2>&1 | grep -qE '^[0-9]+,'; then
  use_perf=1
  UNIT="cycles/element"
else
  UNIT="ns/element"
  echo "WARNING: perf cycle counter not available -> falling back to ns/element." >&2
  echo "         (try: sudo dnf install perf; sudo sysctl kernel.perf_event_paranoid=1)" >&2
fi

# ---- Run one binary REPS times, print the minimum ----------------------
measure() {
  local bin=$1 best="" v r
  for ((r = 0; r < REPS; r++)); do
    if ((use_perf)); then
      # perf prints its CSV to stderr; the program's own output is discarded.
      v=$(perf stat -x, -e cycles taskset -c "$CORE" "$bin" 2>&1 >/dev/null |
          awk -F, -v w="$((N * CALLS))" '$3 ~ /cycles/ { printf "%.4f", $1 / w }')
    else
      v=$(taskset -c "$CORE" "$bin" | awk '{ print $1 }')
    fi
    if [[ -z $best ]] || awk -v a="$v" -v b="$best" 'BEGIN { exit !(a < b) }'; then
      best=$v
    fi
  done
  echo "$best"
}

echo "fma,unroll,$UNIT" > results.csv
printf '\n%-5s %-7s %s\n' "FMA" "U" "$UNIT (min of $REPS runs)"

for fma in 0 1; do
  for u in "${UNROLLS[@]}"; do
    flags=(-std=c++26 -O2 -fno-tree-vectorize -ffp-contract=off -march=native
           -DUNROLL=$u -DN=$N -DCALLS=$CALLS)
    ((fma)) && flags+=(-DUSE_FMA)

    g++ "${flags[@]}" -S "$SRC" -o "asm/sqsum_fma${fma}_u${u}.s"   # for inspection
    g++ "${flags[@]}"      "$SRC" -o "build/bench_fma${fma}_u${u}"

    val=$(measure "build/bench_fma${fma}_u${u}")
    printf '%-5s %-7s %s\n' "$fma" "$u" "$val"
    echo "$fma,$u,$val" >> results.csv
  done
done

echo
echo "Saved: results.csv, system_info.txt, assembly in asm/"
