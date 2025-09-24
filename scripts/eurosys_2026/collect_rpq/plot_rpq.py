#!/usr/bin/env python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <csv_file>")
    sys.exit(1)

csv_file = sys.argv[1]

# Load CSV into DataFrame
df = pd.read_csv(csv_file)

# Compute derived metrics
df["occupancy_rate"] = (df["unc_m_rpq_occupancy_pch0"] + df["unc_m_rpq_occupancy_pch1"])/ df["duration"]
df["insert_rate"] = (df["unc_m_rpq_inserts.pch0"] + df["unc_m_rpq_inserts.pch1"])/ df["duration"]

sns.set_theme(style="whitegrid")

plt.rcParams.update({
    #"font.family": "monospace",   # or "sans-serif", "monospace", "DejaVu Sans", etc.
    "font.size": 12,          # default size for everything
    "axes.titlesize": 14,     # title font size
    "axes.labelsize": 12,     # x/y label size
    "xtick.labelsize": 10,    # x tick label size
    "ytick.labelsize": 10,    # y tick label size
})
# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(12, 4), constrained_layout=True)



    
# for ax in axes:
#     sns.despine(ax=ax)  # removes top and right by default
#     ax.spines["bottom"].set_visible(False)  # remove x=0 spine
#     ax.spines["left"].set_visible(False)    # remove y=0 spine
    
# Bandwidth
sns.lineplot(data=df, x="num_threads", y="bw", marker="o", ax=axes[0])
axes[0].set_ylabel("Bandwidth (GB/s)")
axes[0].set_xlabel("Number of Threads")

# RPQ Occupancy
sns.lineplot(data=df, x="num_threads", y="occupancy_rate", marker="o", ax=axes[1])
axes[1].set_ylabel("RPQ Occupancy/Cycle")
axes[1].set_xlabel("Number of Threads")

# RPQ Inserts
sns.lineplot(data=df, x="num_threads", y="insert_rate", marker="o", ax=axes[2])
axes[2].set_ylabel("RPQ Allocated/Cycle")
axes[2].set_xlabel("Number of Threads")

for ax in axes:
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    ax.grid(True, which="major", axis="both", linestyle="--")

#plt.tight_layout()  # leave space for suptitle
plt.savefig("rpq.pdf")

