#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

counters = [
    "ls_alloc_mab_count",
    "de_no_dispatch_per_slot.backend_stalls",
]


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)

    df = pd.json_normalize(data, sep=".")

    df = df[df["run_cfg.numa_policy"] == 4]
    df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])
    df["prefetch_id"] = df["identifier"].str.split("-").str[0]

    # Set Seaborn style
    sns.set_theme()

    row = 1
    col = 3
    plot_w = 4
    fig, axes = plt.subplots(row, col, figsize=(col * plot_w, row * plot_w))
    cnt = 0

    ax = axes[cnt]
    cnt += 1
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="prefetch_id",
        marker="o",
        legend=False,
        ax=ax,
    )
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Get Mops")

    for counter in counters:
        df[counter] = df[counter] / df["find_ops"]
        ax = axes[cnt]
        cnt += 1
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y=counter,
            hue="prefetch_id",
            marker="o",
            legend=False,
            ax=ax,
        )
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel(counter)

    unique_ids = df["prefetch_id"].unique()
    palette = sns.color_palette(n_colors=len(unique_ids))

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]

    for ax in axes:
        ax.grid(True, which="major", axis="both", linestyle="--")
        ticks = ax.get_yticks()
        if len(ticks) > 1:
            step_value = ticks[1] - ticks[0]
            ymin, ymax = ax.get_ylim()
            remainder = ymax % step_value
            if remainder != 0:
                ax.set_ylim(ymin, ymax + remainder)

    fig.legend(
        fontsize=8, handles=custom_lines, loc="upper center", ncol=len(unique_ids)
    )

    plt.tight_layout(rect=[0, 0, 1, 0.95])

    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)
