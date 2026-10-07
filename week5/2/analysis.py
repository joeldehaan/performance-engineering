import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

N = 2**15

df = pd.read_csv("table.csv")

B = np.geomspace(1, 2*N, 1000)
model = (N**2 / 8) * (1 + 1 / B)

fig, ax = plt.subplots()
ax.plot(B, model, label="model")
ax.scatter(df["block_size"], df["d1_read_misses"], color="C1", label="cachegrind data")
ax.axvline(192*1024/8, label="L1d size", c='r')

ax.set_xlabel("block size B")
ax.set_xscale("log", base=2)
ax.set_ylabel("cache misses")
ax.legend()
fig.savefig("plot.png", dpi=350)
