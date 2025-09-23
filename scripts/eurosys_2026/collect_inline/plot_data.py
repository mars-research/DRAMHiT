#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.lines import Line2D




def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)
    df = pd.json_normalize(data, sep='.')

    # Filter on numa_policy
    df = df[df["run_cfg.numa_policy"] == 4]

    # Derived metrics
    df["normalized_ops"] = df["uops_dispatched.port_2_3_10"] / df["find_ops"]
    df["relative_mem_uops"] = df["uops_dispatched.port_2_3_10"] / df["uops_issued.any"]

    # Set Seaborn style
    sns.set_theme()

    row = 1
    col = 3
    fig, axes = plt.subplots(row, col, figsize=(12, 3))

    # Plot 1: Throughput
    ax = axes[0]
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="identifier",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title("Single Socket - Throughput")
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Find Mops")

    # Plot 2: Normalized ops
    ax = axes[1]
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="normalized_ops",
        hue="identifier",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title("Single Socket - mem uops/find")
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Memory Uops/Find")

    # Plot 3: Relative memory uops
    ax = axes[2]
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="relative_mem_uops",
        hue="identifier",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title("Single Socket - Relative Mem Uops")
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Mem Uops / All Uops")

    # Legend
    unique_ids = df["identifier"].unique()
    palette = sns.color_palette(n_colors=len(unique_ids))
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]
    fig.legend(
        fontsize=8,
        handles=custom_lines,
        loc="upper center",
        ncol=3
    )

    plt.tight_layout(rect=[0, 0, 1, 0.90])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)
        

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)
