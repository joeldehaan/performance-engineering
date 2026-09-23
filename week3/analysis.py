#!/usr/bin/env python3

import pandas as pd 
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

def AI(N: int) -> float:
    return N / 32

def gflopss(N, time):
    return (2 * N**3 / time)

def main():
    results = []

    for olevel in range(4):
        results.append(create_plot_roofline(olevel))
    
    df = pd.DataFrame(results)
    with open("fit-results.tex", "w") as f:
        f.write(df.to_latex(index=False, escape=False))

def format_val_err(val, err, sig_figs_err=1):
    if err == 0 or np.isnan(err):
        return f"{val:.3g}"
    # Find the order of magnitude of the error
    exponent = int(np.floor(np.log10(abs(err))))
    # Round error to sig_figs_err significant figures
    decimal_places = -exponent + (sig_figs_err - 1)
    decimal_places = max(decimal_places, 0)
    val_rounded = round(val, decimal_places)
    err_rounded = round(err, decimal_places)
    return f"${val_rounded:.{decimal_places}f} \\pm {err_rounded:.{decimal_places}f}$"

def create_plot_roofline(olevel):

    NR_ITERS = 15

    # --- Load data ---
    df = pd.read_csv(f"../week1/steady-O{olevel}.csv")

    N = df.iloc[:, 0].to_numpy()
    runs = df.iloc[:, 1:1 + NR_ITERS].to_numpy()

    # --- Convert latency to GFLOP/s ---
    gflops = np.array([
        gflopss(N, runs[:, i])
        for i in range(NR_ITERS)
    ]).T

    # --- Arithmetic intensity ---
    arithmetic_intensity = AI(N)

    # Median GFLOP/s over iterations
    gflops_median = np.median(gflops, axis=1)

    # --- Plot ---
    fig, ax = plt.subplots(figsize=(9, 5))

    # Individual measurements
    for i in range(NR_ITERS):
        ax.scatter(
            arithmetic_intensity,
            gflops[: ,i],
            s=5,
            c="k",
            alpha=0.5,
        )

    ax.plot(arithmetic_intensity, 51.2 * arithmetic_intensity, "--", color = "red", label = r"B_{mem} * AI")
    ax.plot(arithmetic_intensity, [4 for _ in arithmetic_intensity], "--", color = "red", label = r"B_{fp}")

    # Median performance
    order = np.argsort(arithmetic_intensity)

    # ax.plot(
    #     arithmetic_intensity[order],
    #     gflops_median[order],
    #     "--",
    #     color="crimson",
    #     lw=2,
    # )

    ax.set_xlabel("arithmetic intensity (FLOP/byte)")
    ax.set_ylabel("GFLOP/s")

    ax.set_xscale("log")
    ax.set_yscale("log")

    ax.set_title(f"Roofline at O{olevel}")

    fig.tight_layout()
    plt.savefig(f"roofline-O{olevel}.pdf")
    plt.close(fig)


if __name__ == "__main__":
    main()
