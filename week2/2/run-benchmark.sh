#!/usr/bin/env bash

STREAM_SRC="stream/stream.c"
MIN_SIZE=1
MAX_SIZE=50000000

GROWTH_FACTOR=1.5

RUNS_PER_SIZE=10
OUT_CSV="stream-results.csv"

echo "array_size,kernel,rate_mbps" > "$OUT_CSV"

SIZE=$MIN_SIZE
while [[ $SIZE -le $MAX_SIZE ]]; do
    BIN="stream_${SIZE}"
    gcc -fopenmp -O2 -DSTREAM_ARRAY_SIZE=$SIZE "$STREAM_SRC" -o "$BIN"

    for ((run=1; run<=RUNS_PER_SIZE; run++)); do
        ./"$BIN" | awk -v size="$SIZE" '
            /^(Copy|Scale|Add|Triad):/ {
                gsub(":", "", $1)
                print size","$1","$2
            }' >> "$OUT_CSV"
    done

    rm -f "$BIN"
    # SIZE=$((SIZE * GROWTH_FACTOR))
    # SIZE=$((SIZE + 100000))
    SIZE=$(awk -v s="$SIZE" -v g="$GROWTH_FACTOR" 'BEGIN{printf "%.0f", s*g}')
done

