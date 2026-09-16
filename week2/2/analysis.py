#!/usr/bin/env python3
import csv
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt

CSV_PATH = "stream-results.csv"

data = defaultdict(lambda: {"x": [], "y": []})

with open(CSV_PATH, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        kernel = row["kernel"]
        data[kernel]["x"].append(int(row["array_size"]))
        data[kernel]["y"].append(float(row["rate_mbps"]))

colors = {
    "Copy": "tab:blue",
    "Scale": "tab:orange",
    "Add": "tab:green",
    "Triad": "tab:red",
}

fig, ax = plt.subplots(figsize=(8, 6))

ax.set_title("STREAM bandwidth vs array size")
ax.set_xlabel("Array size (elements)")
ax.set_ylabel("Rate (MB/s)")
ax.set_xscale("log")
ax.set_yscale("log")

ax.axhline(51.2e3, label="nominal memory bandwidth", c='k')
ax.axhline(322945.58, label="measured L3 bandwidth", c='r')
ax.axvline(8*1024**2/8/2, label="L3 cache size (Copy/Scale)")
ax.axvline(8*1024**2/8/3, label="L3 cache size (Add/Triad)")


for kernel, points in data.items():
    ax.scatter(points["x"], points["y"], label=kernel,
               color=colors.get(kernel), alpha=.4, s=2)


ax.legend()
ax.grid(True, which="both", linestyle="--", alpha=0.4)

plt.tight_layout()
plt.savefig("stream-bandwidth.pdf")
fig, ax1 = plt.subplots(figsize=(8, 6))

# Plot median + min/max for each kernel
for kernel, points in data.items():

    # Group rates by array size
    grouped = defaultdict(list)

    for N, rate in zip(points["x"], points["y"]):
        grouped[N].append(rate)

    Ns = sorted(grouped.keys())

    median = []
    minimum = []
    maximum = []

    for N in Ns:
        values = np.asarray(grouped[N])

        median.append(np.median(values))
        minimum.append(np.min(values))
        maximum.append(np.max(values))

    Ns = np.asarray(Ns)
    median = np.asarray(median)
    minimum = np.asarray(minimum)
    maximum = np.asarray(maximum)

    color = colors.get(kernel)

    # Variability envelope
    ax1.fill_between(
        Ns,
        minimum,
        maximum,
        color=color,
        alpha=0.15,
        linewidth=0,
    )

    # Min/max boundaries
    ax1.plot(
        Ns,
        minimum,
        color=color,
        linestyle="--",
        linewidth=0.8,
        alpha=0.6,
    )

    ax1.plot(
        Ns,
        maximum,
        color=color,
        linestyle="--",
        linewidth=0.8,
        alpha=0.6,
    )

    # Central value
    ax1.plot(
        Ns,
        median,
        color=color,
        linewidth=2,
        marker="o",
        markersize=3,
        label=kernel,
    )

ax1.set_title("STREAM benchmark central values and variability")
ax1.set_xlabel("Array size (elements)")
ax1.set_ylabel("Rate (MB/s)")
ax1.set_xscale("log")
ax1.set_yscale("log")
ax1.grid(True, which="both", linestyle="--", alpha=0.4)

ax1.legend()
ax1.grid(
    True,
    which="both",
    linestyle="--",
    alpha=0.4,
)

plt.tight_layout()
plt.savefig("stream-bandwidth-ranges.pdf")

fig, ax2 = plt.subplots(figsize=(8, 6))


ax2.plot(Ns,
        (maximum - minimum) / median,
        color=color,
        linestyle="--",
        linewidth=0.8,
        alpha=0.6,
    )

ax2.set_title("STREAM benchmark variability")
ax2.set_xlabel("Array size (elements)")
ax2.set_ylabel("range / median (no units)")
ax2.set_xscale("log")
ax2.set_yscale("log")
ax2.grid(True, which="both", linestyle="--", alpha=0.4)

plt.savefig("stream-bandwidth-variance.pdf")
