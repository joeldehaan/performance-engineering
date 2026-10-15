#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:-../src/*.cc}"
CSV="${2:-results.csv}"
COMPILER="${CXX:-g++}"

REPEATS=5
MAX_EXP=14
BUILD_DIR="benchmark_build"

mkdir -p "$BUILD_DIR"
echo "N,time" > "$CSV"

for ((k = 0; k <= MAX_EXP; k++)); do
    N=$((1 << k))
    EXE="$BUILD_DIR/program_N${N}"

    echo "========================================"
    echo "Compiling NX=$N, NY=$N"

  # Compile with dimensions defined as preprocessor macros.
    "$COMPILER" -std=c++26 -march=native -ffast-math -O3 -DNX="$N" -DNY="$N" \
        ../src/*.cc -o "$EXE" -flto

    echo "Running $REPEATS trials for N=$N"

    for ((trial = 1; trial <= REPEATS; trial++)); do
        # perf_counter_ns uses a monotonic high-resolution timer.
        elapsed=$(python3 - "$EXE" <<'PY'
import subprocess
import sys
import time

exe = sys.argv[1]

start = time.perf_counter_ns()
subprocess.run(
    [exe],
    stdout=subprocess.DEVNULL,
    check=True,
)
end = time.perf_counter_ns()

print(f"{(end - start) / 1e9:.9f}")
PY
        )

        echo "$N,$elapsed" >> "$CSV"
        printf "N=%-6s trial=%d time=%s s\n" \
            "$N" "$trial" "$elapsed"
    done
done

echo "========================================"
echo "Benchmark complete: $CSV"
```
