```bash
#!/bin/bash

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

EXEC="./matrix_benchmark"
FUNCTION="matrix_multiply"
TRIALS=10

# Compile with profiling enabled.
# -O0 prevents the compiler from optimizing/inlining the
# matrix multiplication function away.
for n in 1 2 3; do
    g++ -O"${n}" -pg -o "$EXEC" "$SOURCE"

    if [ $? -ne 0 ]; then
        echo "Compilation failed."
        exit 1
    fi

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
            "$EXEC" "$test" > /dev/null

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
            TIME=$(gprof "$EXEC" gmon.out | \
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

        # N progression:
        #
        # N < 300   -> N + 1
        # N < 700   -> N + 10
        # N < 2000  -> N + 100
        #
        if [ "$test" -lt 300 ]; then
            ((test++))
        elif [ "$test" -lt 700 ]; then
            ((test+=10))
        elif [ "$test" -lt 2000 ]; then
            ((test+=100))
        else
            break
        fi
    done

    echo
    echo "# Benchmark complete"
    ```
done