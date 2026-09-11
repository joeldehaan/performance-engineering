#!/usr/bin/env python3
import csv
from collections import defaultdict
import matplotlib.pyplot as plt

CSV_PATH = "stream_results.csv"

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
for kernel, points in data.items():
    ax.scatter(points["x"], points["y"], label=kernel,
               color=colors.get(kernel), alpha=0.7, s=20)

ax.set_xlabel("Array size (elements)")
ax.set_ylabel("Rate (MB/s)")
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_title("STREAM bandwidth vs array size")
ax.legend()
ax.grid(True, which="both", linestyle="--", alpha=0.4)

plt.tight_layout()
plt.savefig("stream_bandwidth.pdf")

