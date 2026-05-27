#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    df = pd.json_normalize(data, sep=".")

    df_single = df[df["run_cfg.numa_policy"] == 4]
    # df_dual = df[df["run_cfg.numa_policy"] == 1]
    df_dual = df[df["run_cfg.numa_policy"] == -999]
    
    # Filter out empty dataframes completely from the tracking list
    all_datasets = [df_single, df_dual]
    active_datasets = [d for d in all_datasets if not d.empty]
    
    if not active_datasets:
        print("[Error] No data found for single or dual socket configurations.")
        sys.exit(1)
    
    for dataset in active_datasets:
        dataset["normalized_ops"] = dataset["uops_dispatched.port_2_3_10"] / dataset["find_ops"]
        dataset["relative_mem_uops"] = (
            dataset["uops_dispatched.port_2_3_10"] / dataset["uops_issued.any"]
        )

    # Configure a clean academic style: white background with light gray gridlines
    sns.set_theme(style="whitegrid", rc={
        "grid.color": "#e0e0e0",
        "grid.linestyle": "--",
        "axes.edgecolor": "#7f7f7f",
        "axes.linewidth": 1.0
    })

    # Dynamically scale grid row size based on active datasets
    num_rows = len(active_datasets)
    num_cols = 3
    
    # Adjust overall figure height proportionally
    fig_height = 4.5 if num_rows == 1 else 9
    fig, axes = plt.subplots(num_rows, num_cols, figsize=(15, fig_height))

    # Force axes array to be 2D even if there's only 1 row to keep index looping uniform
    if num_rows == 1:
        axes = [axes]

    for cnt, dataset in enumerate(active_datasets):
        rax = axes[cnt]
        
        # Plot 1: Throughput
        ax = rax[0]
        sns.lineplot(
            data=dataset,
            x="run_cfg.fill_factor",
            y="get_mops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Throughput")
        ax.set_xlabel("Fill Factor (%)")
        ax.set_ylabel("Find Mops (million/sec)")

        # Plot 2: Mem Uops per Find
        ax = rax[1]
        sns.lineplot(
            data=dataset,
            x="run_cfg.fill_factor",
            y="normalized_ops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("mem uops/find")
        ax.set_xlabel("Fill Factor (%)")
        ax.set_ylabel("Memory Uops / Find")

        # Plot 3: Relative Mem Uops
        ax = rax[2]
        sns.lineplot(
            data=dataset,
            x="run_cfg.fill_factor",
            y="relative_mem_uops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Relative Mem Uops")
        ax.set_xlabel("Fill Factor (%)")
        ax.set_ylabel("Mem Uops / All Uops")

    # Aggregate identifiers safely across whatever active dataframes are present
    combined_df = pd.concat(active_datasets)
    unique_ids = sorted(combined_df["identifier"].unique())
    palette = sns.color_palette(n_colors=len(unique_ids))
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]
    
    # Push layout spacer down depending on single or multi-row layout bounds
    rect_top = 0.85 if num_rows == 1 else 0.92
    
    fig.legend(fontsize=9, handles=custom_lines, loc="upper center", ncol=4, frameon=True, edgecolor="#7f7f7f")
    plt.tight_layout(rect=[0, 0, 1, rect_top])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)