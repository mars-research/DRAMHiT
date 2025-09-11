#!/bin/python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# CSV files
csv_files = [
    "simd_bucket_linear_reprobes.csv",
    "simd_bucket_uniform_reprobes.csv",
    "branched_bucket_linear_reprobes.csv",
    "branched_no_bucket_linear_reprobes.csv"
]

# Labels for each file (for the legend)
labels = [
    "SIMD Bucket Linear",
    "SIMD Bucket Uniform",
    "Branched Bucket Linear",
    "Branched No Bucket Linear"
]

# Set Seaborn style
sns.set(style="whitegrid")

# Create subplots: 1 row, 2 columns
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Colors / line styles
colors = sns.color_palette("tab10", n_colors=len(csv_files))
linestyles = ['-', '--', '-.', ':']

# Plot 1: fill vs reprobe_factor
for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    axes[0].plot(df['fill'], df['reprobe_factor'], label=labels[i],
                 color=colors[i], linestyle=linestyles[i], marker='o')
axes[0].set_xlabel("Fill Factor (%)")
axes[0].set_ylabel("Reprobe Factor")
axes[0].set_title("Fill Factor vs Reprobe Factor")
axes[0].legend()

# Plot 2: fill vs mops
for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    axes[1].plot(df['fill'], df['mops'], label=labels[i],
                 color=colors[i], linestyle=linestyles[i], marker='o')
axes[1].set_xlabel("Fill Factor (%)")
axes[1].set_ylabel("MOPS")
axes[1].set_title("Fill Factor vs MOPS")
axes[1].legend()

# Adjust layout and save figure
plt.tight_layout()
plt.savefig("fill_vs_reprobe_mops.png", dpi=300)
