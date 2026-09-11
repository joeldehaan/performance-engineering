#!/usr/bin/env bash

OUT_TEX="mem-info.tex"

SOCKETS=$(lscpu | grep -m1 "^Socket(s):" | awk '{print $NF}')

DMI_MEM=$(dmidecode -t memory)

POPULATED_BLOCKS=$(awk 'BEGIN{RS="\n\n"} /Memory Device/ && /Size: [0-9]/ {print}' <<< "$DMI_MEM")

MEM_TYPE=$(echo "$POPULATED_BLOCKS" | awk -F': ' '/^\tType:/{print $2; exit}' | awk '{print $1}')
MEM_SPEED=$(echo "$POPULATED_BLOCKS" | awk -F': ' '/Configured Memory Speed:/{print $2; exit}' | awk '{print $1}')
DATA_WIDTH_BITS=$(echo "$POPULATED_BLOCKS" | awk -F': ' '/^\tData Width:/{print $2; exit}' | awk '{print $1}')
BUS_WIDTH_BYTES=$(awk -v w="$DATA_WIDTH_BITS" 'BEGIN{printf "%.0f", w/8}')
POPULATED_DIMMS=$(echo "$DMI_MEM" | grep -c $'^\tSize: [0-9]')
TOTAL_MEM_GB=$(awk '/MemTotal/{printf "%.1f", $2/1024/1024}' /proc/meminfo)

CHANNELS=$(echo "$DMI_MEM" | awk -F': ' '/^\tLocator:/{print $2}' | grep -oE '[A-Za-z]?DIMM[_-]?[A-Za-z]' | grep -oE '[A-Za-z]$' | sort -u | wc -l)
if [[ "$CHANNELS" -eq 0 ]]; then
    CHANNELS=$(echo "$DMI_MEM" | awk -F': ' '/^\tBank Locator:/{print $2}' | grep -oE 'CHANNEL [A-Za-z]' | grep -oE '[A-Za-z]$' | sort -u | wc -l)
fi

PEAK_PER_SOCKET=$(awk -v c="$CHANNELS" -v s="$MEM_SPEED" -v b="$BUS_WIDTH_BYTES" 'BEGIN{printf "%.1f", c*s*b/1000}')
PEAK_TOTAL=$(awk -v p="$PEAK_PER_SOCKET" -v n="$SOCKETS" 'BEGIN{printf "%.1f", p*n}')

cat > "$OUT_TEX" <<EOF
\begin{table}[h]
    \centering
    \begin{tabular}{lr}
        \toprule
        \textbf{Parameter} & \textbf{Value} \\\\
        \midrule
        Sockets                  & ${SOCKETS} \\\\
        Channels per socket      & ${CHANNELS} \\\\
        Populated DIMM slots     & ${POPULATED_DIMMS} \\\\
        Memory type              & ${MEM_TYPE} \\\\
	Memory speed             & ${MEM_SPEED}\,MHz \\\\
        Data bus width           & ${DATA_WIDTH_BITS}\,bits (${BUS_WIDTH_BYTES}\,bytes) \\\\
        Total installed memory   & ${TOTAL_MEM_GB}\,GiB \\\\
        \midrule
        Peak bandwidth 	         & ${PEAK_TOTAL}\,GB/s \\\\
        \bottomrule
    \end{tabular}
    \caption{System memory configuration and theoretical peak bandwidth}
    \label{tab:mem-bandwidth}
\end{table}
EOF

