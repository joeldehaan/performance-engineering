#!/usr/bin/env python3
"""Plot measured cycles/element against the theoretical prediction.

Usage:  python3 plot_results.py [results.csv] [output.pdf]
Needs:  matplotlib   (pip install matplotlib   or   sudo dnf install python3-matplotlib)

Theory used (edit the constants below for another CPU):

    c_theory(U) = max( L / U , c_min )

    c      cycles per element
    L      latency of the instruction on the dependency chain (cycles)
    U      number of independent accumulators (= unroll factor)
    c_min  1 / T, where T = how many of these instructions the CPU can
           start per cycle (throughput bound)
"""
import csv
import sys

import matplotlib
matplotlib.use("Agg")            # no display needed, we only write a file
import matplotlib.pyplot as plt

from matplotlib.ticker import NullFormatter, ScalarFormatter

import numpy as np

# ---------------- Zen 2 parameters (Ryzen 5 4500U) ----------------------
LATENCY_ADD = 3        # vaddsd latency, cycles
LATENCY_FMA = 5        # vfmadd231sd latency, cycles
THROUGHPUT = 2         # FP instructions that can start per cycle (2 pipes)
N_VECTOR_REGS = 16     # architectural vector registers (no AVX-512)
# ------------------------------------------------------------------------

csv_file = "results.csv"
pdf_file = "unrolling_results.pdf"

data = {0: {}, 1: {}}            # data[fma][U] = value
with open(csv_file, newline="") as f:
    reader = csv.reader(f)
    header = next(reader)
    for row in reader:
        data[int(row[0])][int(row[1])] = float(row[2])

def theory(u, latency):
    return max(latency / u, 1.0 / THROUGHPUT)

def draw(ax, fma, title, latency):
    us = sorted(data[fma])
    ys = [data[fma][u] for u in us]

    ax.plot(us, ys, "o", color="tab:blue", markersize=4, label="Data")
    
    U = np.linspace(1, max(us) + 1, 500)
    ax.plot(U, [theory(u, latency) for u in U], "-",
                color="tab:red", markersize=3,
                label=r"Model")

    ax.set_title(title)
    ax.set_xlabel("Unroll Factor")
    ax.set_ylabel("Cycles/Element")

    ax.set_yscale("log")

    ax.set_xlim(0, max(us) + 1)
    ax.set_ylim(0.4, 6)

    ax.set_yticks([0.5, 0.6, 0.8, 1, 1.5, 2, 3, 4, 5])
    ax.yaxis.set_major_formatter(ScalarFormatter())
    ax.yaxis.set_minor_formatter(NullFormatter())

    ax.legend(fontsize=8)

fig, axes = plt.subplots(2, 1, figsize=(8, 10))

draw(axes[0], 0, "Without FMA", LATENCY_ADD)
draw(axes[1], 1, "With FMA", LATENCY_FMA)

fig.suptitle("Benchmark Results")
fig.tight_layout()
fig.savefig(pdf_file)

