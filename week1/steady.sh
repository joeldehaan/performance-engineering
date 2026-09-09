#!/usr/bin/env bash
set -euo pipefail

# --- hardcoded input ---
SRC="./steady.cc"          # <-- edit this to the actual path of your .cc file
BIN="/tmp/steady-bin"      # scratch location for the compiled binary
CXX="${CXX:-g++}"          # override with CXX=clang++ ./run_steady.sh if you want
CPU="0"                    # <-- CPU core to pin the run to (taskset -c argument)
EXTRA_FLAGS="-std=c++26"  # <-- additional compiler flags, applied at every -O level

if ! command -v taskset &> /dev/null; then
    echo "Error: taskset not found (install util-linux)" >&2
    exit 1
fi

if [[ ! -f "$SRC" ]]; then
    echo "Error: source file not found: $SRC" >&2
    exit 1
fi

for n in 0 1 2 3; do
    "$CXX" -O"${n}" ${EXTRA_FLAGS} -o "$BIN" "$SRC"
    taskset -c "$CPU" "$BIN" > "steady-O${n}.csv"
done


