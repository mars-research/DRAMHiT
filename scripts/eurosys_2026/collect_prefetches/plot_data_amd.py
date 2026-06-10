#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

COUNTERS = [
    "ls_alloc_mab_count",
    "de_no_dispatch_per_slot.backend_stalls",
    "ls_mab_alloc.all_allocations",
]

MARKERS = [
    "o",  # circle
    "s",  # square
    "^",  # triangle up
    "v",  # triangle down
    "D",  # diamond
    "P",  # plus filled
    "X",  # x filled
    "<",  # triangle left
    ">",  # triangle right
    "*",  # star
    "h",  # hexagon
    "8",  # octagon
]

DASH_PATTERNS = [
    (),                     # solid
    (4, 1),
    (2, 1),
    (6, 2),
    (1, 1),
    (8, 2),
    (3, 2, 1, 2),
    (5, 1, 1, 1),
    (2, 2, 2, 2),
    (10, 3),
    (1, 3),
    (4, 2, 1, 2),
]


def plot_metric(ax, df, y_col, unique_ids, palette, marker_map, dash_map):
    for idx, uid in enumerate(unique_ids):
        subset = (
            df[df["prefetch_id"] == uid]
            .sort_values("run_cfg.fill_factor")
        )

        line, = ax.plot(
            subset["run_cfg.fill_factor"],
            subset[y_col],
            color=palette[idx],
            marker=marker_map[uid],
            linewidth=2.5,
            markersize=8,
            label=uid,
        )

        if dash_map[uid]:
            line.set_dashes(dash_map[uid])


def plot_json(json_file, output_file):
    with open(json_file, "r") as f:
        data = json.load(f)

    df = pd.json_normalize(data, sep=".")

    df = df[df["run_cfg.numa_policy"] == 1]
    df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])

    df["prefetch_id"] = df["identifier"].str.split("-").str[0]

    sns.set_theme(
        style="whitegrid",
        rc={
            "axes.facecolor": "white",
            "figure.facecolor": "white",
            "grid.color": "#e0e0e0",
        },
    )

    unique_ids = sorted(df["prefetch_id"].unique())

    palette = sns.color_palette(
        "rocket",
        n_colors=len(unique_ids)
    )

    marker_map = {
        uid: MARKERS[i % len(MARKERS)]
        for i, uid in enumerate(unique_ids)
    }

    dash_map = {
        uid: DASH_PATTERNS[i % len(DASH_PATTERNS)]
        for i, uid in enumerate(unique_ids)
    }

    row = 1
    col = 4
    plot_w = 4

    fig, axes = plt.subplots(
        row,
        col,
        figsize=(col * plot_w, row * plot_w),
    )

    cnt = 0

    # ------------------------------------------------------------------
    # Get MOPS
    # ------------------------------------------------------------------

    ax = axes[cnt]
    cnt += 1

    plot_metric(
        ax,
        df,
        "get_mops",
        unique_ids,
        palette,
        marker_map,
        dash_map,
    )

    ax.set_ylim(bottom=0)
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Get Mops")

    # ------------------------------------------------------------------
    # Counters
    # ------------------------------------------------------------------

    for counter in COUNTERS:
        
        if counter == "ls_alloc_mab_count" or counter == "de_no_dispatch_per_slot.backend_stalls":
            df[counter] = df[counter] / df["cycles"]
        else:
            df[counter] = df[counter] / df["find_ops"]
        # df[counter] = df[counter] / df["find_ops"]

        ax = axes[cnt]
        cnt += 1

        plot_metric(
            ax,
            df,
            counter,
            unique_ids,
            palette,
            marker_map,
            dash_map,
        )

        ax.set_ylim(bottom=0)
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel(counter)

    # ------------------------------------------------------------------
    # Axis formatting
    # ------------------------------------------------------------------

    for ax in axes:
        ax.grid(
            True,
            which="major",
            axis="both",
            linestyle="--",
            alpha=0.7,
        )

        ticks = ax.get_yticks()

        if len(ticks) > 1:
            step_value = ticks[1] - ticks[0]
            ymin, ymax = ax.get_ylim()

            remainder = ymax % step_value

            if remainder != 0:
                ax.set_ylim(
                    0,
                    ymax + (step_value - remainder),
                )
            else:
                ax.set_ylim(bottom=0)

    # ------------------------------------------------------------------
    # Legend
    # ------------------------------------------------------------------

    custom_lines = []

    for i, uid in enumerate(unique_ids):
        legend_line = Line2D(
            [0],
            [0],
            color=palette[i],
            marker=marker_map[uid],
            linewidth=2.5,
            label=uid,
        )

        if dash_map[uid]:
            legend_line.set_dashes(dash_map[uid])

        custom_lines.append(legend_line)

    fig.legend(
        handles=custom_lines,
        loc="upper center",
        ncol=min(len(unique_ids), 6),
        fontsize=8,
    )

    plt.tight_layout(rect=[0, 0, 1, 0.95])

    plt.savefig(
        output_file,
        dpi=300,
        bbox_inches="tight",
    )

    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(
            "Usage: python plot_dramhit.py <input.json> <output.png>"
        )
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]

    plot_json(json_file, output_file)