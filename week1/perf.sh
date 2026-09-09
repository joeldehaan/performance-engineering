#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

CXX="g++"
SRC="main.cc"
PROG="./prog"

# Optimization levels
OPT_LEVELS=("O0" "O2" "O3")

# Extra compiler flags
CXXFLAGS=(
    "-std=c++17"
    "-g"
    "-fno-omit-frame-pointer"
)

# perf sampling frequency
PERF_FREQ=10000

# Number of trials
TRIES=5

# Function to measure
SYMBOL="operator*<double>"


# ============================================================
# Compile
# ============================================================

compile()
{
    local OPT="$1"

    echo
    echo "============================================================"
    echo "Compiling -${OPT}"
    echo "============================================================"

    "$CXX" \
        "${CXXFLAGS[@]}" \
        "-${OPT}" \
        "$SRC" \
        -o "$PROG"

    echo "Compilation complete."
}


# ============================================================
# Get total CPU time in ns
# ============================================================

get_cpu_time_ns()
{
    local N="$1"
    local TMP

    TMP=$(mktemp)

    perf stat \
        -e cpu-clock:u \
        "$PROG" "$N" \
        >/dev/null 2>"$TMP"

    # perf stat normally produces something like:
    #
    #     123.45 msec cpu-clock
    #
    # Convert seconds/milliseconds/microseconds to ns.

    awk '
    /cpu-clock/ {

        value=$1
        unit=$2

        gsub(",", "", value)

        if (unit == "sec")
            printf "%.0f\n", value * 1000000000

        else if (unit == "msec")
            printf "%.0f\n", value * 1000000

        else if (unit == "usec")
            printf "%.0f\n", value * 1000

        else if (unit == "nsec")
            printf "%.0f\n", value

        exit
    }
    ' "$TMP"

    rm -f "$TMP"
}


# ============================================================
# Get operator Self percentage
# ============================================================

get_operator_percent()
{
    local REPORT="$1"

    echo "$REPORT" |
    awk -v symbol="$SYMBOL" '
        index($0, symbol) {

            # The first percentage column is Self when
            # --no-children is used.

            for (i = 1; i <= NF; i++) {

                if ($i ~ /^[0-9]+\.[0-9]+%$/) {

                    x=$i
                    gsub("%", "", x)

                    print x
                    exit
                }
            }
        }
    '
}


# ============================================================
# Measure one benchmark
# ============================================================

measure()
{
    local N="$1"

    rm -f perf.data

    # --------------------------------------------------------
    # First get total CPU time
    # --------------------------------------------------------

    local TOTAL_NS

    TOTAL_NS=$(get_cpu_time_ns "$N")

    if [[ -z "$TOTAL_NS" ]]; then
        echo "ERROR: Could not obtain cpu-clock time" >&2
        return 1
    fi


    # --------------------------------------------------------
    # Record samples
    # --------------------------------------------------------

    perf record \
        -q \
        -o perf.data \
        -e cpu-clock:u \
        -F "$PERF_FREQ" \
        --call-graph fp \
        "$PROG" "$N" \
        >/dev/null


    # --------------------------------------------------------
    # Generate report
    # --------------------------------------------------------

    local REPORT

    REPORT=$(
        perf report \
            --stdio \
            -i perf.data \
            --no-children \
            --percent-limit 0 \
            2>/dev/null
    )


    # --------------------------------------------------------
    # Find Self percentage of operator
    # --------------------------------------------------------

    local PERCENT

    PERCENT=$(get_operator_percent "$REPORT")


    if [[ -z "$PERCENT" ]]; then
        echo "0"
        return
    fi


    # --------------------------------------------------------
    # Convert percentage -> ns
    # --------------------------------------------------------

    awk \
        -v total="$TOTAL_NS" \
        -v percent="$PERCENT" \
        'BEGIN {
            printf "%.0f\n", total * percent / 100.0
        }'
}


# ============================================================
# Main benchmark
# ============================================================

for OPT in "${OPT_LEVELS[@]}"; do

    compile "$OPT"

    CSV="results_${OPT}.csv"

    echo "N,try1,try2,try3,try4,try5" > "$CSV"

    echo
    echo "============================================================"
    echo "Benchmarking -${OPT}"
    echo "============================================================"

    for N in $(seq 1 100); do

        printf "N=%3d  " "$N"

        VALUES=()

        for TRY in $(seq 1 "$TRIES"); do

            VALUE=$(measure "$N")

            VALUES+=("$VALUE")

            printf "%10s ns  " "$VALUE"
        done

        echo

        printf "%d" "$N" >> "$CSV"

        for VALUE in "${VALUES[@]}"; do
            printf ",%s" "$VALUE" >> "$CSV"
        done

        printf "\n" >> "$CSV"

    done

    rm -f perf.data

done

echo
echo "Done."
echo
echo "Generated:"
echo "  results_O0.csv"
echo "  results_O2.csv"
echo "  results_O3.csv"
