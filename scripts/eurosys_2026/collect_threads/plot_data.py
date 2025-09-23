#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.lines import Line2D

sns.set_theme()
row = 2
col = 2
fig, axes = plt.subplots(row, col, figsize=(12, 12))  

def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.json_normalize(data, sep='.')
    
    df_single = df[df["run_cfg.numa_policy"] == 4]
    df_dual = df[df["run_cfg.numa_policy"] == 1]
    
    # Determine unique fills for consistent coloring
    unique_fills = sorted(df["run_cfg.fill_factor"].unique())
    palette = sns.color_palette("tab10", n_colors=len(unique_fills))
    
    # Plot Single Socket - Find
    ax = axes[0][0]
    sns.lineplot(
        data=df_single,
        x="run_cfg.numThreads",
        y="get_mops",
        hue="run_cfg.fill_factor",
        marker="o",
        ax=ax,
        palette=palette
    )
    ax.set_title("Single socket")
    ax.set_xlabel("Number of Threads")
    ax.set_ylabel("Find Mops")
    
    # Plot Single Socket - Set
    ax = axes[0][1]
    sns.lineplot(
        data=df_single,
        x="run_cfg.numThreads",
        y="set_mops",
        hue="run_cfg.fill_factor",
        marker="o",
        ax=ax,
        palette=palette
    )
    ax.set_title("Single socket")
    ax.set_xlabel("Number of Threads")
    ax.set_ylabel("Set Mops")

    # Plot Dual Socket - Find
    ax = axes[1][0]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.numThreads",
        y="get_mops",
        hue="run_cfg.fill_factor",
        marker="o",
        ax=ax,
        palette=palette
    )
    ax.set_title("Dual socket")
    ax.set_xlabel("Number of Threads")
    ax.set_ylabel("Find Mops")
    
    # Plot Dual Socket - Set
    ax = axes[1][1]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.numThreads",
        y="set_mops",
        hue="run_cfg.fill_factor",
        marker="o",
        ax=ax,
        palette=palette
    )
    ax.set_title("Dual socket")
    ax.set_xlabel("Number of Threads")
    ax.set_ylabel("Set Mops")

    # Create single flat legend above subplots
    handles, labels = axes[0][0].get_legend_handles_labels()
    fig.legend(
        handles,
        labels,
        title="Table Fill",
        fontsize=8,
        loc="upper center",
        ncol=len(labels)
    )

    # Remove legends from subplots
    for ax_row in axes:
        for ax in ax_row:
            ax.get_legend().remove()

    # Leave space for the top legend
    plt.tight_layout(rect=[0, 0, 1, .98])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)
