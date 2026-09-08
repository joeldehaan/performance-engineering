#!/bin/bash

# Compile with flags to prevent inlining
for n in 1, 2, 3; do

    g++ -O"${n}" -std=c++26 "$@" -g -o matmul_debug perf.cc

    # Function name to trace - CHANGE THIS
    FUNCTION_NAME=

    echo "Running perf ftrace with 10 repetitions..."
    echo "Function: $FUNCTION_NAME"

    # Run perf ftrace with repeat option
    perf ftrace -r 10 -T "$FUNCTION_NAME" ./matmul_debug 2>&1 | tee ftrace_output_O"${n}".txt
done
