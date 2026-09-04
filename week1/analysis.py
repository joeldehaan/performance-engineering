import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# --- Load data ---
df = pd.read_csv("system.csv")

# strip non-num chars
df["y"] = df["y"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)

x = df["x"].to_numpy()
y = df["y"].to_numpy()

"""
def model(x, a1, a2, x0, k, c):
    # a(x) transitions sigmoidally from a1 to a2 at x0, with rate k
    a = a1 + (a2 - a1) / (1 + np.exp(-k * (x - x0)))
    return a * x**3 + c
"""

def model(x, a, p, c):
    return a * x**p + c

# --- Fit curve ---
# p0 = [3, 4000]
popt, pcov = curve_fit(model, x, y, sigma=y,            # weight residuals relative to y's magnitude
    absolute_sigma=False,
    maxfev=10000)
perr = np.sqrt(np.diag(pcov))  # parameter uncertainties

print("Fitted parameters:", popt)
print("Parameter errors:  ", perr)

# --- Plot ---
x_fit = np.linspace(x.min(), x.max(), 500)
y_fit = model(x_fit, *popt)

fig, ax = plt.subplots(figsize=(7, 5))
ax.scatter(x, y, s=5, color="black", label="Data")
ax.plot(x_fit, y_fit, color="crimson", lw=2, label="Fit")
ax.set_xlabel("x")
ax.set_ylabel("y")

plt.xscale("log")
plt.yscale("log")

ax.set_title("Data with Curve Fit")
ax.legend()
fig.tight_layout()
plt.savefig("fit_plot.png", dpi=200)
plt.show()

