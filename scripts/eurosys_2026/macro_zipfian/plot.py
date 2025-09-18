#!/bin/python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# CSV files
csv_files = [
    "results/dramhit_2023.csv",
    "results/dramhit_2025.csv",
#    "results/CLHT.csv",
    "results/GROWT.csv"
]

# Labels for each file (for the legend)
labels = [
    "dramhit23",
    "dramhit25",
#    "CLHT",
    "GROWT"
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
    axes[0].plot(df['skew'], df['set_mops'], label=labels[i],
                 color=colors[i], linestyle=linestyles[i], marker='o')
axes[0].set_xlabel("Skew")
axes[0].set_ylabel("Set Mops")
axes[0].set_title("Skew vs Set Mops")
axes[0].legend()

# Plot 2: fill vs mops
for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    axes[1].plot(df['skew'], df['get_mops'], label=labels[i],
                 color=colors[i], linestyle=linestyles[i], marker='o')
axes[1].set_xlabel("Skew")
axes[1].set_ylabel("Find Mops")
axes[1].set_title("Skew vs Find Mops")
axes[1].legend()

# Adjust layout and save figure
plt.tight_layout()
plt.savefig("snoop.png", dpi=300)


