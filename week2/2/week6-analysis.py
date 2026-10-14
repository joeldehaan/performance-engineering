#!/usr/bin/env python3
import csv
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter, NullFormatter

THREADS_CSV = "omp-threads.csv"
AFFINITY_CSV = "omp-affinity.csv"

NOMINAL_BW = 51.2e3   # MB/s, theoretical peak of the memory system (Table 1 of the week-2 report)

KERNELS = ["Copy", "Scale", "Add", "Triad"]
BINDS = ["true", "false", "master", "close", "spread"]

colors = {
    "Copy": "tab:blue",
    "Scale": "tab:orange",
    "Add": "tab:green",
    "Triad": "tab:red",
}
# different markers keep the kernels apart where their curves (nearly) coincide
markers = {"Copy": "o", "Scale": "s", "Add": "^", "Triad": "D"}


def size_label(n):
    """Title label (mathtext): 1024 -> $N = 1024$, 33554432 -> $N = 2^{25}$"""
    k = int(round(np.log2(n)))
    if 2**k == n and n > 1024:
        return r"$N = 2^{" + str(k) + r"}$"
    return r"$N = " + str(n) + r"$"


def read_csv(path, key):
    """data[array_size][kernel][key value] -> list of rates (inf / nan rows are dropped)"""
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    with open(path, newline="") as f:
        for row in csv.DictReader(f):
            rate = float(row["rate_mbps"])
            if not np.isfinite(rate):
                continue
            k = row[key]
            k = int(k) if key == "threads" else k
            data[int(row["array_size"])][row["kernel"]][k].append(rate)
    return data


def max_rate(per_kernel):
    return max(r for rates in per_kernel.values() for rs in rates.values() for r in rs)


# ---------- (a) bandwidth vs number of threads ----------
threads = read_csv(THREADS_CSV, "threads")

for N in sorted(threads):
    Ts = sorted({T for kernel in KERNELS for T in threads[N][kernel]})
    spacing = 0.12      # horizontal offset between the kernels

    # --- rate: every run as a dot, the median per thread count as a line ---
    fig, ax = plt.subplots(figsize=(8, 6))

    for i, kernel in enumerate(KERNELS):
        color, marker = colors[kernel], markers[kernel]
        offset = (i - (len(KERNELS) - 1) / 2) * spacing

        ax.scatter([T + offset for T in Ts for _ in threads[N][kernel][T]],
                   [r for T in Ts for r in threads[N][kernel][T]],
                   color=color, marker=marker, alpha=0.3, s=8)
        ax.plot([T + offset for T in Ts],
                [np.median(threads[N][kernel][T]) for T in Ts],
                color=color, marker=marker, linewidth=1.2, markersize=5, label=kernel)

    ax.axhline(NOMINAL_BW, label="nominal memory bandwidth", c="k")

    ax.set_title(r"STREAM bandwidth vs number of threads (" + size_label(N) + ")")
    ax.set_xlabel("Number of threads")
    ax.set_ylabel("Rate (MB/s)")
    ax.set_xticks(Ts)
    ax.set_ylim(0, 1.25 * max(NOMINAL_BW, max_rate(threads[N])))   # head-room for the legend
    ax.grid(True, which="both", linestyle="--", alpha=0.4)
    ax.legend(loc="upper right", ncol=3)

    plt.tight_layout()
    plt.savefig(f"omp-threads-N{N}.pdf")

    # --- speed-up of the median rate with respect to one thread ---
    fig, ax = plt.subplots(figsize=(8, 6))

    for kernel in KERNELS:
        median = np.array([np.median(threads[N][kernel][T]) for T in Ts])
        ax.plot(Ts, median / median[0], color=colors[kernel], marker=markers[kernel],
                linewidth=1.2, markersize=5, label=kernel)
    ax.plot(Ts, np.asarray(Ts) / Ts[0], color="gray", linestyle="--", linewidth=0.8,
            label="linear scaling")

    ax.set_title(r"STREAM speed-up vs number of threads (" + size_label(N) + ")")
    ax.set_xlabel("Number of threads")
    ax.set_ylabel("Median rate / median rate with 1 thread")
    ax.set_xticks(Ts)
    ax.set_yscale("log", base=2)
    ax.yaxis.set_major_formatter(FuncFormatter(lambda v, _: f"{v:g}"))
    ax.yaxis.set_minor_formatter(NullFormatter())
    ax.grid(True, which="both", linestyle="--", alpha=0.4)
    ax.legend()

    plt.tight_layout()
    plt.savefig(f"omp-speedup-N{N}.pdf")

    print(f"\nN = {N}: median rate (MB/s) per number of threads")
    print("threads " + " ".join(f"{k:>10}" for k in KERNELS))
    for T in Ts:
        print(f"{T:>7} " + " ".join(f"{np.median(threads[N][k][T]):>10.0f}" for k in KERNELS))


# ---------- (b) affinity ----------
affinity = read_csv(AFFINITY_CSV, "proc_bind")

for N in sorted(affinity):
    fig, ax = plt.subplots(figsize=(8, 6))

    binds = [b for b in BINDS if b in affinity[N]["Copy"]]
    x = np.arange(len(binds))
    width = 0.8 / len(KERNELS)

    medians, lowest, highest = {}, [], []
    for i, kernel in enumerate(KERNELS):
        values = [np.asarray(affinity[N][kernel][b]) for b in binds]
        median = np.array([np.median(v) for v in values])
        minimum = np.array([np.min(v) for v in values])
        maximum = np.array([np.max(v) for v in values])
        medians[kernel] = median
        lowest.append(minimum.min())
        highest.append(maximum.max())
        offset = (i - (len(KERNELS) - 1) / 2) * width
        ax.bar(x + offset, median, width, color=colors[kernel], alpha=0.8, label=kernel,
               yerr=[median - minimum, maximum - median], capsize=2,
               error_kw={"linewidth": 0.8})

    ax.axhline(NOMINAL_BW, label="nominal memory bandwidth", c="k")

    ax.set_yscale("log")
    ax.set_ylim(10 ** np.floor(np.log10(min(lowest))),             # bottom: decade below the data
                3 * max(NOMINAL_BW, max(highest)))                 # top: head-room for the legend

    ax.set_title(r"STREAM bandwidth vs thread affinity (" + size_label(N) + ")")
    ax.set_xlabel("OMP_PROC_BIND")
    ax.set_ylabel("Rate (MB/s)")
    ax.set_xticks(x)
    ax.set_xticklabels(binds)
    ax.grid(True, which="both", axis="y", linestyle="--", alpha=0.4)
    ax.legend(loc="upper right", ncol=3)

    plt.tight_layout()
    plt.savefig(f"omp-affinity-N{N}.pdf")

    print(f"\nN = {N}: median rate (MB/s) per OMP_PROC_BIND")
    print("bind    " + " ".join(f"{k:>10}" for k in KERNELS))
    for j, b in enumerate(binds):
        print(f"{b:<7} " + " ".join(f"{medians[k][j]:>10.0f}" for k in KERNELS))
