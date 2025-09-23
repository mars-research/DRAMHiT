#!/bin/python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# CSV files
csv_files = [
    "results/dramhit_2023.csv",
    "results/dramhit_2025.csv",
    "results/CLHT.csv",
    "results/GROWT.csv"
]

# Labels for each file (for the legend)
labels = [
    "dramhit23",
    "dramhit25",
    "CLHT",
    "GROWT"
]

# Set Seaborn style
sns.set_theme()

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Colors / line styles
colors = sns.color_palette("tab10", n_colors=len(csv_files))
linestyles = ["solid", '-', '--', '-.', ':']

# Plot 1: fill vs set_mops
for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    sns.lineplot(
        data=df,
        x="fill", y="set_mops",
        label=labels[i],
        color=colors[i],
        linestyle=linestyles[i],
        marker="o",
        ax=axes[0]
    )
axes[0].set_xlabel("Fill Factor (%)")
axes[0].set_ylabel("Insert Mops")
axes[0].set_title("Fill Factor vs Insert Mops")

# Plot 2: fill vs get_mops
for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    sns.lineplot(
        data=df,
        x="fill", y="get_mops",
        label=labels[i],
        color=colors[i],
        linestyle=linestyles[i],
        marker="o",
        ax=axes[1]
    )
axes[1].set_xlabel("Fill Factor (%)")
axes[1].set_ylabel("Find Mops")
axes[1].set_title("Fill Factor vs Find Mops")

# Remove per-axis legends
for ax in axes:
    ax.legend().remove()

# Create a single figure-level legend
handles, labels = axes[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="upper center", ncol=len(csv_files))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("new_macro_uniform.png", dpi=300)


