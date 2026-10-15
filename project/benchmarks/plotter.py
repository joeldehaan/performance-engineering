#!/usr/bin/env python3

import argparse

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ITERATIONS = 200_000
FLOPS_PER_POINT = 6
BYTES_PER_POINT = 24


def main():
    parser = argparse.ArgumentParser(
        description="Plot Jacobi arithmetic intensity vs. performance."
    )
    parser.add_argument(
        "csv", nargs="?", default="results.csv",
        help="CSV with columns N,time; time in seconds"
    )
    parser.add_argument(
        "--bytes-per-point", type=float, default=BYTES_PER_POINT,
        help="Estimated bytes transferred per interior point update"
    )
    parser.add_argument(
        "--output", default="roofline.png",
        help="Output plot filename"
    )
    args = parser.parse_args()

    df = pd.read_csv(args.csv)

    if not {"N", "time"}.issubset(df.columns):
        raise ValueError("CSV must contain exactly the required columns N,time.")

    # if (df["N"] <= 2).any() or (df["time"] <= 0).any():
    #     raise ValueError("N must be > 2 and time must be positive.")

    # Number of interior point updates over all iterations.
    updates = (df["N"] - 2) ** 2 * ITERATIONS

    # Estimated total floating-point operations and memory traffic.
    df["FLOPs"] = FLOPS_PER_POINT * updates
    df["Bytes"] = args.bytes_per_point * updates

    # Roofline coordinates.
    df["intensity"] = df["FLOPs"] / df["Bytes"]
    df["performance"] = df["FLOPs"] / df["time"] / 1e9

    print(df["FLOPs"])

    # Average repeated runs for each N.
    summary = df.groupby("N").agg(
        intensity=("intensity", "mean"),
        performance=("performance", "mean"),
        std=("performance", "std"),
        runs=("performance", "count"),
    )

    fig, ax = plt.subplots(figsize=(8, 6))

    ax.scatter(
        summary["intensity"],
        summary["performance"],
        s=55,
        label="Mean performance"
    )

    for n, row in summary.iterrows():
        ax.annotate(
            str(int(n)),
            (row["intensity"], row["performance"]),
            xytext=(5, 5),
            textcoords="offset points",
            fontsize=8,
        )

    # ax.set_xscale("log")
    # ax.set_yscale("log")
    ax.set_xlabel("Arithmetic intensity (FLOPs/byte)")
    ax.set_ylabel("Performance (GFLOP/s)")
    ax.set_title("Jacobi Solver: Roofline-Style Plot")
    ax.grid(True, which="both", linestyle="--", alpha=0.35)
    ax.legend()
    fig.tight_layout()
    fig.savefig(args.output, dpi=200)

    print(summary.to_string())
    print(f"\nSaved plot to {args.output}")


if __name__ == "__main__":
    main()
