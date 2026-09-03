import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# --- Load data ---
df = pd.read_csv("out.csv")

# strip non-num chars
df["y"] = df["y"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)

x = df["x"].to_numpy()
y = df["y"].to_numpy()

# --- Define model function ---
def model(x, a, c):
    return a * x**3 + c

# --- Fit curve ---
p0 = [1, 1]  # initial guesses
popt, pcov = curve_fit(model, x, y, p0=p0)
perr = np.sqrt(np.diag(pcov))  # parameter uncertainties

print("Fitted parameters:", popt)
print("Parameter errors:  ", perr)

# --- Plot ---
x_fit = np.linspace(x.min(), x.max(), 500)
y_fit = model(x_fit, *popt)

fig, ax = plt.subplots(figsize=(7, 5))
ax.scatter(x, y, s=20, color="black", label="Data")
ax.plot(x_fit, y_fit, color="crimson", lw=2, label="Fit")
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title("Data with Curve Fit")
ax.legend()
fig.tight_layout()
plt.savefig("fit_plot.png", dpi=200)
plt.show()

