#!/usr/bin/env python3
import csv
from collections import defaultdict
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

