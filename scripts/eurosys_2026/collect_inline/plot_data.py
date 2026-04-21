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

    df = pd.DataFrame(data)
    df = pd.json_normalize(data, sep=".")

    df_single = df[df["run_cfg.numa_policy"] == 4]
    df_dual = df[df["run_cfg.numa_policy"] == 1]
    datasets = [df_single, df_dual]
    for df in datasets:
        df["normalized_ops"] = df["uops_dispatched.port_2_3_10"] / df["find_ops"]
        df["relative_mem_uops"] = (
            df["uops_dispatched.port_2_3_10"] / df["uops_issued.any"]
        )
    # Set Seaborn style
    sns.set_theme()

    row = 2
    col = 3
    fig, axes = plt.subplots(row, col, figsize=(15, 7))

    cnt = 0

    # Plot 1: Throughput
    for df in datasets:
        rax = axes[cnt]
        ax = rax[0]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="get_mops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_title("Throughput")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")

        MODE = ""
        if cnt == 0:
            MODE = "Single Socket"
        else:
            MODE = "Dual Socket"
        ax.text(
            0.1,
            1.2,
            MODE,  # (x,y) in axes coords
            transform=ax.transAxes,  # relative to the axis
            ha="right",
            va="top",
            fontsize=12,
            fontweight="bold",
        )

        ax = rax[1]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="normalized_ops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_title("mem uops/find")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Memory Uops/Find")

        ax = rax[2]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="relative_mem_uops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_title("Relative Mem Uops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops / All Uops")
        cnt += 1

    # Legend
    unique_ids = df["identifier"].unique()
    palette = sns.color_palette(n_colors=len(unique_ids))
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]
    fig.legend(fontsize=8, handles=custom_lines, loc="upper center", ncol=3)
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
