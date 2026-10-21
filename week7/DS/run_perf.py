#!/usr/bin/env python3
"""Run the task-1c benchmark under perf stat and write LaTeX tables.

Usage: python3 run_perf.py [--repeats N] [--output table.tex]

Compiles bench.cpp (next to this script), measures every variant with
perf stat and writes per-sort counter values to a LaTeX file
(needs \\usepackage{booktabs}).

If perf supports --control, only the sorts are counted. Otherwise each
variant is also run with --init-only and that baseline is subtracted.
"""

import argparse
import math
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT_DIRECTORY = Path(__file__).resolve().parent
SOURCE_FILE = SCRIPT_DIRECTORY / "bench.cpp"
BINARY_FILE = SCRIPT_DIRECTORY / "bench"

# Sorts per program run; small sorts are fast, so they are repeated more.
REPETITIONS = {
    "small-original": 1000,
    "small-optimized": 1000,
    "big-original": 2,
    "big-optimized": 1000,
}

# Run in separate groups so that no hardware counters are multiplexed.
EVENT_GROUPS = [
    ["task-clock", "cycles:u", "instructions:u", "branch-misses:u"],
    ["L1-dcache-loads:u", "L1-dcache-load-misses:u", "LLC-loads:u", "LLC-load-misses:u"],
]

ROWS = [
    ("Time per sort (ms)", "task-clock"),
    ("Cycles", "cycles"),
    ("Instructions", "instructions"),
    ("Branch misses", "branch-misses"),
    ("L1d loads", "L1-dcache-loads"),
    ("L1d load misses", "L1-dcache-load-misses"),
    ("L1d miss rate (\\%)", "derived:l1-miss-rate"),
    ("LLC loads", "LLC-loads"),
    ("LLC load misses", "LLC-load-misses"),
    ("LLC miss rate (\\%)", "derived:llc-miss-rate"),
]

COMPARISONS = [
    ("Small", "small-original", "small-optimized",
     "reordered fields and \\texttt{alignas(64)} ($2^{14}$ elements)"),
    ("Big", "big-original", "big-optimized",
     "split into \\texttt{BigMeta} and \\texttt{BigArray} ($2^{13}$ elements of $2^{13}$ doubles)"),
]


def compile_benchmark():
    compiler = os.environ.get("CXX", "g++")  # needs C++26 support: GCC >= 14 or Clang >= 17
    command = [compiler, "-std=c++26", "-O2", "-Wno-psabi", "-o", str(BINARY_FILE), str(SOURCE_FILE)]
    subprocess.run(command, check=True)


def perf_supports_control():
    result = subprocess.run(["perf", "stat", "-h"], capture_output=True, text=True)
    return "--control" in result.stdout + result.stderr


def base_event_name(perf_event_name):
    """Map 'cycles:u' or 'cpu_core/cycles/u' to 'cycles'."""
    name = re.sub(r"^cpu_\w+/", "", perf_event_name.strip())
    return re.sub(r"(/[a-zA-Z]*|:[a-zA-Z]+)$", "", name)


def parse_perf_output(text):
    """Return {event: (mean value, relative error in %)} from perf -x';'."""
    results = {}
    for line in text.splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split(";")
        if len(fields) < 3:
            continue
        name = base_event_name(fields[2])
        try:
            value = float(fields[0].replace(",", "."))
        except ValueError:
            results.setdefault(name, (None, None))
            continue
        error = None
        if len(fields) > 3 and fields[3].strip().endswith("%"):
            error = float(fields[3].strip().rstrip("%").replace(",", "."))
        previous_value, previous_error = results.get(name, (0.0, None))
        # Hybrid CPUs report one line per core type: add them up.
        total = (previous_value or 0.0) + value
        results[name] = (total, max(filter(None, [error, previous_error]), default=None))
    return results


def run_perf(arguments, events, repeats, control_files=None):
    with tempfile.TemporaryDirectory() as directory:
        output_file = Path(directory) / "perf.txt"
        command = ["perf", "stat", "-x", ";", "-r", str(repeats), "-o", str(output_file),
                   "-e", ",".join(events)]
        # Force a decimal point: perf follows the locale (e.g. "0,12" in nl_NL).
        environment = dict(os.environ, LC_ALL="C")
        if control_files is not None:
            control_fifo, ack_fifo = control_files
            command += ["-D", "-1", "--control", f"fifo:{control_fifo},{ack_fifo}"]
            environment["PERF_CTL_FIFO"] = str(control_fifo)
            environment["PERF_ACK_FIFO"] = str(ack_fifo)
        command += [str(BINARY_FILE)] + arguments
        result = subprocess.run(command, env=environment, capture_output=True, text=True)
        if result.returncode != 0:
            sys.exit(f"perf failed:\n{' '.join(command)}\n{result.stderr}")
        return parse_perf_output(output_file.read_text())


def measure_with_control(variant, events, repeats):
    with tempfile.TemporaryDirectory() as directory:
        control_fifo = Path(directory) / "control.fifo"
        ack_fifo = Path(directory) / "ack.fifo"
        os.mkfifo(control_fifo)
        os.mkfifo(ack_fifo)
        arguments = [variant, str(REPETITIONS[variant])]
        return run_perf(arguments, events, repeats, (control_fifo, ack_fifo))


def subtract_baseline(full, baseline):
    difference = {}
    for name, (value, error) in full.items():
        baseline_value = baseline.get(name, (None, None))[0]
        if value is None or baseline_value is None:
            difference[name] = (None, None)
        else:
            difference[name] = (value - baseline_value, None)
    return difference


def measure_with_subtraction(variant, events, repeats):
    arguments = [variant, str(REPETITIONS[variant])]
    full = run_perf(arguments, events, repeats)
    baseline = run_perf(arguments + ["--init-only"], events, repeats)
    return subtract_baseline(full, baseline)


def measure_variant(variant, repeats, use_control):
    counters = {}
    for events in EVENT_GROUPS:
        print(f"  {variant}: {', '.join(events)}", flush=True)
        if use_control:
            counters.update(measure_with_control(variant, events, repeats))
        else:
            counters.update(measure_with_subtraction(variant, events, repeats))
    sorts = REPETITIONS[variant]
    return {name: (None if value is None else value / sorts, error)
            for name, (value, error) in counters.items()}


def ratio(numerator, denominator, scale=1.0):
    if numerator is None or denominator in (None, 0):
        return None
    return scale * numerator / denominator


def row_value(counters, key):
    def value(name):
        return counters.get(name, (None, None))[0]

    if key == "derived:l1-miss-rate":
        return ratio(value("L1-dcache-load-misses"), value("L1-dcache-loads"), 100.0), None
    if key == "derived:llc-miss-rate":
        return ratio(value("LLC-load-misses"), value("LLC-loads"), 100.0), None
    return counters.get(key, (None, None))


def format_number(value):
    if value is None:
        return "n/a"
    if value != 0 and (abs(value) >= 1e3 or abs(value) < 1e-2):
        exponent = int(math.floor(math.log10(abs(value))))
        mantissa = value / 10 ** exponent
        return f"${mantissa:.2f}\\cdot10^{{{exponent}}}$"
    return f"{value:.3g}"


def latex_table(title, description, original, optimized, repeats, use_control):
    method = ("counters enabled only during the sorts (perf \\texttt{--control})"
              if use_control else
              "an initialisation-only run subtracted")
    caption = [
        f"\\caption{{{title}: perf counters per sort, original layout versus "
        f"{description}. Means over {repeats} runs with {method}.}}",
        f"\\label{{tab:perf-{title.lower()}}}",
    ]
    lines = [
        "\\begin{table}[htbp]",
        "\\centering",
        "\\begin{tabular}{lrrr}",
        "\\toprule",
        "Counter & Original & Optimized & Original/Optimized \\\\",
        "\\midrule",
    ]
    for label, key in ROWS:
        original_value = row_value(original, key)[0]
        optimized_value = row_value(optimized, key)[0]
        change = ratio(original_value, optimized_value)
        if original_value is None or optimized_value is None or change is None:
            continue
        lines.append(f"{label} & {format_number(original_value)} & "
                     f"{format_number(optimized_value)} & {format_number(change)} \\\\")
    lines += ["\\bottomrule", "\\end{tabular}"] + caption + ["\\end{table}", ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repeats", type=int, default=3, help="perf stat -r value")
    parser.add_argument("--output", default="table.tex", help="LaTeX output file")
    options = parser.parse_args()

    compile_benchmark()
    use_control = perf_supports_control()
    print("perf --control supported" if use_control
          else "perf --control not supported: subtracting init-only runs")

    measurements = {}
    for variant in REPETITIONS:
        measurements[variant] = measure_variant(variant, options.repeats, use_control)

    tables = [latex_table(title, description, measurements[original],
                          measurements[optimized], options.repeats, use_control)
              for title, original, optimized, description in COMPARISONS]
    Path(options.output).write_text("\n".join(tables))
    print("\n".join(tables))
    print(f"Written to {options.output}")


if __name__ == "__main__":
    main()
