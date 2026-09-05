import pandas as pd
import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# --- Load data ---
df = pd.read_csv("steady_O2.csv")
x = df.iloc[:, 0].to_numpy()
runs = df.iloc[:, 1:6].to_numpy()  # shape (n_x, 5)

def model(x, a, c):
    return a*x**2 + c

'''

def model(logx, a, b, c):
    x = np.exp(logx)
    return np.log(a*x**3 + b*x**2 + c)
'''


# --- Fit curve ---
y_median = np.median(runs, axis=1)
# popt, pcov = curve_fit(model, x[70:], y_median[70:], sigma=y_median[70:],
popt, pcov = curve_fit(model, x[:40], y_median[:40], sigma=y_median[:40],
    absolute_sigma=False,
    maxfev=10000,
    bounds=(
        [0, 0],
        [np.inf, np.inf]
    ),
)

perr = np.sqrt(np.diag(pcov))  # parameter uncertainties

print("Fitted parameters:", popt)
print("Parameter errors:  ", perr)

# --- Plot ---
x_fit = np.linspace(x.min(), x.max(), 500)
y_fit = model(x_fit, *popt)

# --- Build boxplot ---
fig, ax = plt.subplots(figsize=(9, 5))

data_per_x = [row for row in runs]  # list of 5-value arrays, one per x



ax.plot(x_fit, y_fit, color="crimson", lw=2)

for n, y in enumerate(runs.T):
    ax.scatter(x, y, s=.25, label=f"iteration #{n+1}")

ax.set_xlabel("matrix rank (dimensionless)")
ax.set_ylabel("latency (ns)")

plt.xscale("log")
plt.yscale("log")

ax.legend()

ax.set_title("test")
# fig.tight_layout()
plt.savefig("boxplot.svg")


