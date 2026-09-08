#!/bin/bash

#!/usr/bin/env bash
set -euo pipefail

# --- hardcoded input ---
SRC="./gmon.cc"          # <-- edit this to the actual path of your .cc file
BIN="/tmp/gmon_bin"      # scratch location for the compiled binary
CXX="${CXX:-g++}"          # override with CXX=clang++ ./run_steady.sh if you want
CPU="0"                    # <-- CPU core to pin the run to (taskset -c argument)
EXTRA_FLAGS="-std=c++26 -pg"  # <-- additional compiler flags, applied at every -O level


# Usage:
#   ./benchmark.sh matrix.cpp [starting_N]
#
# Assumptions:
#   - The program takes N as argv[1]
#   - Matrix multiplication function is called matrix_multiply
#   - g++ and gprof are available

SOURCE="gmon.cc"
START_N="1"

if [ -z "$SOURCE" ]; then
    echo "Usage: $0 matrix.cpp "
    exit 1
fi

# FUNCTION="matrix_multiply"
TRIALS=10

# Compile with profiling enabled.
# -O0 prevents the compiler from optimizing/inlining the
# matrix multiplication function away.
for n in 1 2 3; do
    "$CXX" -O"${n}" ${EXTRA_FLAGS} -o "$BIN" "$SRC"

    if [ $? -ne 0 ]; then
        echo "Compilation failed."
        exit 1
    fi

    LINE_NUM=$(nm -C "$BIN" | grep -n "Matrix<double> operator\*<double>(Matrix<double> const&, Matrix<double> const&)" | cut -d: -f1)
    FUNCTION=$(nm "$BIN" | sed -n "${LINE_NUM}p" | awk '{print $3}')

    echo "# Matrix multiplication benchmark"
    echo "# Function: $FUNCTION"
    echo "# Trials per N: $TRIALS"
    echo "# Columns: N trial self_seconds"
    echo

    test="$START_N"

    while true; do

        # Stop after N >= 2000
        if [ "$test" -ge 2000 ]; then
            break
        fi

        for ((trial=1; trial<=TRIALS; trial++)); do

            # Remove profiling data from previous run.
            rm -f gmon.out

            # Run the program.
            "$BIN" "$test" > /dev/null

            if [ ! -f gmon.out ]; then
                echo "ERROR: gmon.out was not generated for N=$test trial=$trial" >&2
                continue
            fi

            # Extract "self seconds" for matrix_multiply.
            #
            # gprof flat-profile format:
            #
            # % time  cumulative  self  self   total
            #         seconds     seconds calls ms/call ms/call name
            #
            # Therefore $3 is self seconds.
            TIME=$(gprof "$BIN" gmon.out | \
                awk -v func="$FUNCTION" '$0 ~ func {
                    print $3
                    exit
                }')

            if [ -z "$TIME" ]; then
                echo "ERROR: Could not find $FUNCTION in gprof output" >&2
                TIME="NaN"
            fi

            printf "%d %d %s\n" "$test" "$trial" "$TIME"
	
	done
        if [ "$test" -lt 300 ]; then
            ((test++))
	fi
        
    done

    echo
    echo "# Benchmark complete"

done
