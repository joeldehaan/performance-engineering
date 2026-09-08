#!/bin/bash

# Compile with flags to prevent inlining
g++ "$@" -g  -o matmul_debug perf.cc

# Function name to trace - CHANGE THIS
FUNCTION_NAME="your_function_name"  # CHANGE THIS

echo "Running perf ftrace with 10 repetitions..."
echo "Function: $FUNCTION_NAME"
echo ""

# Run perf ftrace with repeat option
perf ftrace -r 10 -T "$FUNCTION_NAME" ./matmul_debug 2>&1 | tee ftrace_output.txt
