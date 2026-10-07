#!/usr/bin/env bash
# Sweep block sizes B = 1, 2, 4, ..., 2^15, compile main.cc with -DBLOCK_SIZE=<B>,
# run Cachegrind, and write the D1 read misses to table.csv.

set -euo pipefail

SRC="main.cc"
N=32768          # 2^15, fixed
MAX_B=32768      # 2^15
OUT="table.csv"

# L1D model: 32 KB, 8-way, 64-byte lines. Change to match your machine.
D1="196608,8,64"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "block_size,d1_read_misses" > "$OUT"

B=1
while (( B <= MAX_B )); do
    exe="$tmpdir/main_B${B}"
    cgout="$tmpdir/cg_B${B}.out"

    echo "B=$B: compiling..." >&2
    g++ -O2 -g -DBLOCK_SIZE="$B" -DN="$N" "$SRC" -o "$exe"

    echo "B=$B: running cachegrind..." >&2
    valgrind --tool=cachegrind --cache-sim=yes --D1="$D1" \
             --cachegrind-out-file="$cgout" "$exe" > /dev/null 2> "$tmpdir/valgrind_B${B}.log"

    # Find the D1mr column in the "events:" line and read that field
    # from the "summary:" line (total D1 read misses).
    misses="$(awk '
        /^events:/  { for (i = 2; i <= NF; i++) if ($i == "D1mr") col = i }
        /^summary:/ { print $col }
    ' "$cgout")"

    if [[ -z "$misses" ]]; then
        echo "Could not parse D1mr for B=$B" >&2
        exit 1
    fi

    echo "$B,$misses" >> "$OUT"
    B=$(( B * 2 ))
done

echo "Done. Results in $OUT" >&2
