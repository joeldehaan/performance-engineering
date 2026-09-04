import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# --- Load data ---
df = pd.read_csv("system.csv")
x = df.iloc[:, 0].to_numpy()
runs = df.iloc[:, 1:6].to_numpy()  # shape (n_x, 5)

def model(x, a, p, c):
    return a * x**p + c

# --- Fit curve ---
y = np.median(runs, axis=1)
popt, pcov = curve_fit(model, x, y, sigma=y,
    absolute_sigma=False,
    maxfev=10000)
perr = np.sqrt(np.diag(pcov))  # parameter uncertainties

print("Fitted parameters:", popt)
print("Parameter errors:  ", perr)

# --- Plot ---
x_fit = np.linspace(x.min(), x.max(), 500)
y_fit = model(x_fit, *popt)

# --- Build boxplot ---
fig, ax = plt.subplots(figsize=(9, 5))

data_per_x = [row for row in runs]  # list of 5-value arrays, one per x

bp = ax.boxplot(
    data_per_x,
    positions=x,
    widths=(x.max() - x.min()) * 0.02,  # scale width to your x spacing
    manage_ticks=False,
    patch_artist=True,
)

for patch in bp['boxes']:
    patch.set_facecolor("lightblue")

fig, ax = plt.subplots(figsize=(7, 5))
ax.scatter(x, y, s=5, color="black", label="Data")
ax.plot(x_fit, y_fit, color="crimson", lw=2, label="Fit")
ax.set_xlabel("matrix rank")
ax.set_ylabel("latency (ns)")

plt.xscale("log")
plt.yscale("log")

ax.legend()

ax.set_title("test")
fig.tight_layout()
plt.savefig("boxplot.png", dpi=200)
plt.show()


'''
# strip non-num chars
df["run1"] = df["run1"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)
df["run2"] = df["run1"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)
df["run2"] = df["run1"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)
df["run1"] = df["run1"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)
df["run1"] = df["run1"].str.replace(r"[^\d.]+$", "", regex=True).astype(float)

'''
