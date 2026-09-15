#!/bin/bash

NR_ITERS=10

N=${1:-$NR_ITERS}

run_max() {
    local domain=$1
    local best=0
    for i in $(seq 1 "$N"); do
        bw=$(likwid-bench -t load -w "${domain}:2MB:3" | grep "MByte/s:" | awk '{print $2}')
        echo "  ${domain} run $i: ${bw} MByte/s" >&2
        if (( $(echo "$bw > $best" | bc -l) )); then
            best=$bw
        fi
    done
    echo "$best"
}

echo "Running domain C0 ($N iterations)..." >&2
BW0=$(run_max C0)
echo "Running domain C1 ($N iterations)..." >&2
BW1=$(run_max C1)

echo "L3 domain 0 max: ${BW0} MByte/s"
echo "L3 domain 1 max: ${BW1} MByte/s"

TOTAL=$(echo "$BW0 + $BW1" | bc)
echo "Total L3 bandwidth (sum of maxima): ${TOTAL} MByte/s"

