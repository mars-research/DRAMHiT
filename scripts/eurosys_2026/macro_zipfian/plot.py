#!/bin/python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import os
import glob

# Directory containing results
results_dir = "results"
csv_files = sorted(glob.glob(os.path.join(results_dir, "*.csv")))
labels = [os.path.splitext(os.path.basename(f))[0] for f in csv_files]

print("CSV files:", csv_files)
print("Labels:", labels)


# Set Seaborn style
sns.set(style="whitegrid")

# Create subplots: 1 row, 2 columns
fig, axes = plt.subplots(1, 2, figsize=(10, 6))

# Colors / line styles
colors = sns.color_palette("tab10", n_colors=len(csv_files))

for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    axes[0].plot(df['skew'], df['set_mops'], label=labels[i],
                 color=colors[i], marker='o')
axes[0].set_xlabel("Skew")
axes[0].set_ylabel("Set Mops")
axes[0].set_title("Skew vs Set Mops")
axes[0].legend()

for i, csv_file in enumerate(csv_files):
    df = pd.read_csv(csv_file)
    axes[1].plot(df['skew'], df['get_mops'], label=labels[i],
                 color=colors[i], marker='o')
axes[1].set_xlabel("Skew")
axes[1].set_ylabel("Find Mops")
axes[1].set_title("Skew vs Find Mops")
axes[1].legend()

# Adjust layout and save figure
plt.tight_layout()
plt.savefig("new_zipfian.png", dpi=300)


