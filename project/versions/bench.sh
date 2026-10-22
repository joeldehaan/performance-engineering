#!/bin/bash
# Builds every program in this directory with several sets of compiler flags, times
# each program a few times and writes median ± max deviation from the median to table.tex.

export LC_ALL=C    # decimal points instead of commas in date, sort and awk

runs=5    # odd, so the median is a single run
configs=(neither marchnative fastmath both)

declare -A flags=(
    [neither]=""
    [marchnative]="-march=native"
    [fastmath]="-ffast-math"
    [both]="-march=native -ffast-math"
)

declare -A labels=(
    [neither]="none"
    [marchnative]='\texttt{-march=native}'
    [fastmath]='\texttt{-ffast-math}'
    [both]="both"
)

programs=(original refactor red-black simd)

# reads one run time per line, prints "$median \pm deviation$" with the deviation
# rounded to one significant digit and the median to the same decimal place
format_statistics='
{ times[NR] = $1 }
END {
    median = times[(NR + 1) / 2]
    deviation = median - times[1]
    if (times[NR] - median > deviation) {
        deviation = times[NR] - median
    }

    exponent = log(deviation) / log(10)
    magnitude = int(exponent)
    if (exponent < magnitude) {
        magnitude -= 1
    }
    decimals = (magnitude < 0) ? -magnitude : 0

    number = "%." decimals "f"
    printf("$" number " \\pm " number "$", median, deviation)
}'

declare -A results

for config in "${configs[@]}"; do
    # -B rebuilds everything: make only checks timestamps, not changed flags
    CXXFLAGS="${flags[$config]}" make -B > /dev/null

    for program in "${programs[@]}"; do
        times=()
        for ((run = 0; run < runs; ++run)); do
            start=$(date +%s.%N)
            ./"$program" > /dev/null
            end=$(date +%s.%N)
            times+=("$(awk -v start="$start" -v end="$end" 'BEGIN { print end - start }')")
        done

        results[$program,$config]=$(printf '%s\n' "${times[@]}" | sort -g | awk "$format_statistics")
        echo "$config $program: ${results[$program,$config]}"
    done
done

columns="l"
header="Program"
for config in "${configs[@]}"; do
    columns+="c"
    header+=" & ${labels[$config]}"
done

{
    echo '\begin{table}[h]'
    echo '    \centering'
    echo "    \\begin{tabular}{$columns}"
    echo '        \hline'
    echo "        $header \\\\"
    echo '        \hline'
    for program in "${programs[@]}"; do
        row="$program"
        for config in "${configs[@]}"; do
            row+=" & ${results[$program,$config]}"
        done
        echo "        $row \\\\"
    done
    echo '        \hline'
    echo '    \end{tabular}'
    echo "    \\caption{Median run time in seconds over $runs runs, with the maximum deviation from the median.}"
    echo '\end{table}'
} > table.tex
