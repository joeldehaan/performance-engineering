#!/usr/bin/env python3

import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

def main():
    results = []

    for olevel in range(4):
        results.append(create_plot(olevel))
    
    df = pd.DataFrame(results)
    with open("fit-results-perf.tex", "w") as f:
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

def create_plot(olevel):

    
    NR_ITERS = 15

    # --- Load data ---
    df = pd.read_csv(f"results_O{olevel}.csv")
    x = df.iloc[:, 0].to_numpy()
    runs = df.iloc[:, 1:1+NR_ITERS].to_numpy()  # shape (n_x, 5)
    
    def model(x, a, c):
        return 2*x**3/a + c
    
    
    # --- Fit curve ---
    y_median = np.median(runs, axis=1)

    mask = y_median > 0
    x_clean = x[mask]
    y_clean = y_median[mask]


    popt, pcov = curve_fit(model, x_clean, y_clean, sigma=y_clean,
        absolute_sigma=False,
        maxfev=10000
    )
    
    perr = np.sqrt(np.diag(pcov))  # parameter uncertainties
    
    print("Fitted parameters:", popt)
    print("Parameter errors:  ", perr)

    row = {"O-level": olevel}
    for name, val, err in zip(["$a$ (GFLOP/s)", "$c$ (ns)"], popt, perr):
        row[name] = format_val_err(val, err)
    
    # --- Plot ---
    x_fit = np.linspace(10, x.max(), 300)
    y_fit = model(x_fit, *popt)
    
    # --- Build boxplot ---
    fig, ax = plt.subplots(figsize=(9, 5))
    
    data_per_x = [row for row in runs]  # list of 5-value arrays, one per x
    
    
    
    ax.plot(x_fit, y_fit, color="crimson", lw=2)
    
    for n, y in enumerate(runs.T):
        ax.scatter(x, y, s=.25, c='k') #, label=f"iteration #{n+1}")
    
    ax.set_xlabel("matrix rank (dimensionless)")
    ax.set_ylabel("latency (ns)")
    
    ax.set_xscale("log")
    ax.set_yscale("log")

    ax.set_ylim(1e6, 1e10)
    
    
    ax.set_title(f"Perf at O{olevel}")
    
    plt.savefig(f"perf-O{olevel}.pdf")

    return row

if __name__ == "__main__":
    main()


