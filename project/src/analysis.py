import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(8, 5))
ax.set_xscale('log')
ax.set_yscale('log')

df = pd.read_csv("data-null.csv", header=None)
xa, ya = df.iloc[:, 0], df.iloc[:, 1]
# ax.scatter(x, y, label="null", s=.1)

df = pd.read_csv("data.csv", header=None)
xb, yb = df.iloc[:, 0], df.iloc[:, 1]

ax.scatter(xa, np.abs(ya - yb))

print(ya - yb)

ax.legend()
fig.savefig("plot.png", dpi=350)
