#!/usr/bin/env bash

set -uo pipefail
trap 'echo "ERROR: script failed at line $LINENO" >&2' ERR

MODEL_NAME=$(lscpu | grep -m1 "Model name:" | sed 's/Model name:\s*//')
MAX_GHZ=$(awk -v mhz="$(lscpu | grep -m1 "CPU max MHz:" | sed 's/CPU max MHz:\s*//')" 'BEGIN{printf "%.3f", mhz/1000}')

L1D=$(lscpu | grep -m1 "L1d cache:" | sed 's/L1d cache:\s*//')
L2=$(lscpu | grep -m1 "L2 cache:" | sed 's/L2 cache:\s*//')
L3=$(lscpu | grep -m1 "L3 cache:" | sed 's/L3 cache:\s*//')

# Escape LaTeX special characters (mainly underscores, which show up in
# some CPU model names) so the table compiles cleanly.
escape_latex() {
    echo "$1" | sed -e 's/_/\\_/g' -e 's/&/\\&/g' -e 's/%/\\%/g'
}

MODEL_NAME_ESC=$(escape_latex "$MODEL_NAME")

cat <<EOF
\begin{table}[htbp]
    \centering
    \begin{tabular}{ll}
        \toprule
        Property & Value \\\\
        \midrule
        Model name       & $MODEL_NAME_ESC \\\\
        Peak clock (GHz) & $MAX_GHZ \\\\
        L1d cache        & $L1D \\\\
        L2 cache         & $L2 \\\\
        L3 cache         & $L3 \\\\
        \bottomrule
    \end{tabular}
    \caption{System properties}
    \label{tab:system-properties}
\end{table}
EOF

