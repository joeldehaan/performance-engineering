import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# ---------------- Load ----------------
df = pd.read_csv('results.csv')
df = df[df['iterations'] > 0].copy()   # drop non-converged

g = df.groupby('Nx').agg({
    'time':       'mean',
    'iterations': 'mean',
}).reset_index()

N = g['Nx'].values

# ---------------- Analytical model ----------------
def flops_per_iter(N):
    I = (N - 2) * (N - 2)
    return 9 * I + 4 * (2 * N - 4) + 2

def bytes_per_run(N):
    # read v (N^2) + read f (interior) + write v (N^2), all as doubles (8 bytes)
    I = (N - 2) * (N - 2)
    return 8.0 * (2 * N * N + I)

g['flops_per_iter'] = [flops_per_iter(n) for n in N]
g['total_flops']    = g['flops_per_iter'] * g['iterations']
g['bytes']          = [bytes_per_run(n) for n in N]

g['ai']             = g['total_flops'] / g['bytes']          # FLOP / Byte
g['flops_per_sec']  = g['total_flops'] / g['time']           # FLOP / s

print(g[['Nx','iterations','time','ai','flops_per_sec']].to_string(index=False))

# ---------------- Roofline ----------------
# Set these to your hardware's real peaks.
#   fp64_peak_flops: e.g. from lscpu (base GHz) x cores x FMA x 2 (mul+add)
#                    for AVX-512 FP64, per core: 2 FMA/cycle x 8 doubles x 2 = 32 FLOP/cycle
#   peak_bw: measure with a STREAM triad.
fp64_peak_flops = 50e9     # <-- EDIT: e.g. 50 GFLOP/s FP64
peak_bw         = 20e9     # <-- EDIT: e.g. 20 GB/s DRAM

ai_axis = np.logspace(-3, 3, 400)
roof    = np.minimum(fp64_peak_flops, peak_bw * ai_axis)

# ---------------- Plot 1: Roofline ----------------
plt.figure(figsize=(8, 6))
plt.loglog(ai_axis, roof, 'k--', label='Roofline')
plt.loglog(g['ai'], g['flops_per_sec'], 'ro-', label='Achieved')
for _, r in g.iterrows():
    plt.annotate(f"N={int(r['Nx'])}",
                 (r['ai'], r['flops_per_sec']),
                 textcoords="offset points", xytext=(0, 6),
                 ha='center', fontsize=8)
plt.xlabel('Arithmetic Intensity (FLOP/Byte)')
plt.ylabel('Performance (FLOP/s)')
plt.title('Roofline (analytical AI)')
plt.grid(True, which='both', ls='--', alpha=0.4)
plt.legend()
plt.tight_layout()
plt.savefig('roofline.png', dpi=150)

# ---------------- Plot 2: Time vs N ----------------
plt.figure(figsize=(8, 6))
plt.loglog(g['Nx'], g['time'], 'bo-')
# reference slopes to see the scaling
n = g['Nx'].values
t = g['time'].values
for p, style in [(2, ':'), (4, '-.'), (6, '--')]:
    ref = t[0] * (n / n[0])**p
    plt.loglog(n, ref, style, color='gray', alpha=0.6,
               label=f'$O(N^{p})$')
plt.xlabel('N  (NX = NY)')
plt.ylabel('Time (s)')
plt.title('Time vs N')
plt.grid(True, which='both', ls='--', alpha=0.4)
plt.legend()
plt.tight_layout()
plt.savefig('time_vs_N.png', dpi=150)

plt.show()
