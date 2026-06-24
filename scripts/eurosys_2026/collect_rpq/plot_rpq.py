#!/usr/bin/env python3
import os
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <csv_file1> [<csv_file2> ...]")
    sys.exit(1)

# List to hold individual DataFrames
dfs = []

for csv_file in sys.argv[1:]:
    # Load CSV into DataFrame
    df = pd.read_csv(csv_file)

    # Compute derived metrics
    df["occupancy_rate"] = (
        df["unc_m_rpq_occupancy_pch0"] + df["unc_m_rpq_occupancy_pch1"]
    ) / df["duration"]
    df["insert_rate"] = (
        df["unc_m_rpq_inserts.pch0"] + df["unc_m_rpq_inserts.pch1"]
    ) / df["duration"]

    # Extract instruction type from the filename (e.g., "read.csv" -> "read")
    instruction_type = os.path.splitext(os.path.basename(csv_file))[0]
    df["instruction_type"] = instruction_type

    dfs.append(df)

# Combine all data into a single DataFrame
combined_df = pd.concat(dfs, ignore_index=True)

sns.set_theme(style="whitegrid")

plt.rcParams.update(
    {
        # "font.family": "monospace",   # or "sans-serif", "monospace", "DejaVu Sans", etc.
        "font.size": 12,  # default size for everything
        "axes.titlesize": 14,  # title font size
        "axes.labelsize": 12,  # x/y label size
        "xtick.labelsize": 10,  # x tick label size
        "ytick.labelsize": 10,  # y tick label size
    }
)

# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(15, 5), constrained_layout=True)

# Common kwargs:
# hue="instruction_type" gives a different color to each CSV (read, pf_l1, etc.)
# style="access_pattern" gives a different line style/marker for random vs sequential
plot_kwargs = {
    "data": combined_df,
    "x": "num_threads",
    "hue": "instruction_type",
    "style": "access_pattern",
    "markers": True,
    "dashes": True,  # Changed to True so random/sequential have distinct line styles
}

# Bandwidth
sns.lineplot(y="bw", ax=axes[0], **plot_kwargs)
axes[0].set_ylabel("Bandwidth (GB/s)")
axes[0].set_xlabel("Number of Threads")
axes[0].set_title("Bandwidth Scaling")

# RPQ Occupancy
sns.lineplot(y="occupancy_rate", ax=axes[1], **plot_kwargs)
axes[1].set_ylabel("RPQ Occupancy/Cycle")
axes[1].set_xlabel("Number of Threads")
axes[1].set_title("RPQ Occupancy")

# RPQ Inserts
sns.lineplot(y="insert_rate", ax=axes[2], **plot_kwargs)
axes[2].set_ylabel("RPQ Allocated/Cycle")
axes[2].set_xlabel("Number of Threads")
axes[2].set_title("RPQ Inserts")

for ax in axes:
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    ax.grid(True, which="major", axis="both", linestyle="--")

plt.savefig("rpq.png")
print("Plot successfully saved to rpq.png")
