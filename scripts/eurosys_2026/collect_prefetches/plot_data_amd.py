#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D
import matplotlib as mpl

rc_fonts = {
    "text.usetex": True,  # still valid
    "font.family": "serif",
    "font.serif": ["Linux Libertine O"],  # your preferred font
    "font.weight": "bold",
}
mpl.rcParams.update(rc_fonts)
sns.set_context("paper")

palette = sns.color_palette("rocket", n_colors=5)[::-1]
sns.set_palette(palette)
sns.set_theme(style="whitegrid", palette=palette)

counters = [
    "ls_alloc_mab_count",
    "ls_mab_alloc.all_allocations",
    #"de_dis_dispatch_token_stalls1.load_queue_rsrc_stall",
]

def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    df = pd.DataFrame(data)
    df = pd.json_normalize(data, sep=".")

    df_single = df[df["run_cfg.numa_policy"] == 1]
    # RECOMMENT ME IN FOR DUAL SOCKET NUMBERS
    # df_dual = df[df["run_cfg.numa_policy"] == 1]
    df_dual = df[df["run_cfg.numa_policy"] == -1]


    # Dynamically build datasets list based on what is actually present or wanted
    datasets = []
    modes = []
    if not df_single.empty:
        datasets.append(df_single)
        modes.append("Single Socket")
    if not df_dual.empty:
        datasets.append(df_dual)
        modes.append("Dual Socket")

    for df_set in datasets:
        df_set["normalized_mab_size"] = df_set["ls_alloc_mab_count"] / df_set["cycles"]
        df_set["normalized_mab_alloc_count"] = df_set["ls_mab_alloc.all_allocations"] / df_set["find_ops"]
        df_set["run_cfg.fill_factor"] = pd.to_numeric(df_set["run_cfg.fill_factor"])

    # Force absolute white backgrounds and clear custom style parameter overrides
    sns.set_theme(
        style="whitegrid",
        rc={
            "axes.facecolor": "white",
            "figure.facecolor": "white",
            "grid.color": "#e0e0e0",
        },
    )

    row = len(datasets)
    col = 3
    # Make the figure taller (5.0) if only 1 row is drawn to prevent squishing
    fig, axes = plt.subplots(row, col, figsize=(15, 5.0 if row == 1 else 3.5 * row))

    unique_ids = datasets[0]["identifier"].str.split("-").str[0].unique()
    # palette = sns.color_palette(n_colors=len(unique_ids))

    cnt = 0

    for df_set in datasets:
        # Handle 1D vs 2D array unpacking gracefully depending on row count
        rax = axes[cnt] if row > 1 else axes
        ax = rax[0]
        df_set["prefetch_id"] = df_set["identifier"].str.split("-").str[0]

        sns.lineplot(
            data=df_set,
            x="run_cfg.fill_factor",
            y="get_mops",
            hue="prefetch_id",
            palette=palette,
            marker="o",
            legend=False,
            ax=ax,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Performance")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")

        # --- Single / Dual Socket text label removed from here ---

        ax = rax[1]

        sns.lineplot(
            data=df_set,
            x="run_cfg.fill_factor",
            y="normalized_mab_size",
            legend=False,
            hue="prefetch_id",
            palette=palette,
            marker="o",
            ax=ax,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Mab Size per cycle")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mab_Size/Cycle")

        ax = rax[2]
        sns.lineplot(
            data=df_set,
            x="run_cfg.fill_factor",
            y="normalized_mab_alloc_count",
            legend=False,
            hue="prefetch_id",
            palette=palette,
            marker="o",
            ax=ax,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Mab Entry Allocated Per Find")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mab_Alloc/Find")
        cnt += 1

    # Flatten axes array to style every subplot uniformly
    for ax in axes.flat if row > 1 else axes:
        ax.grid(True, which="major", axis="both", linestyle="--")
        ticks = ax.get_yticks()
        if len(ticks) > 1:
            step_value = ticks[1] - ticks[0]
            ymin, ymax = ax.get_ylim()
            remainder = ymax % step_value
            if remainder != 0:
                ax.set_ylim(0, ymax + (step_value - remainder))
            else:
                ax.set_ylim(bottom=0)

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]

    # Added bbox_to_anchor to snap the legend tightly above the plots
    fig.legend(
        fontsize=11,
        handles=custom_lines,
        loc="lower center",
        bbox_to_anchor=(0.5, 0.92 if row == 1 else 0.95),
        ncol=len(unique_ids),
        frameon=False
    )

    # Reclaimed the top padding whitespace safely
    plt.tight_layout(rect=[0, 0, 1, 0.93 if row == 1 else 0.96])

    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)
