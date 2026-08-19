#!/usr/bin/env python3

import json
import sys
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D
import matplotlib as mpl

def configure_style():
    """Configures the base matplotlib fonts and seaborn style."""
    rc_fonts = {
        "text.usetex": True,
        "font.family": "serif",
        "font.serif": ["Linux Libertine O"],
        "font.weight": "bold",
    }
    mpl.rcParams.update(rc_fonts)
    sns.set_context("paper")
    sns.set_style("whitegrid")


def configure_palette(len):
    """Generates a reversed rocket palette and sets it as the global default."""

    custom_palette = sns.color_palette("rocket", n_colors=len)[::-1]
    sns.set_palette(custom_palette)
    return custom_palette

def get_subplots(num_row,num_col):
    """Generate 4by4 plots """
    plot_w = 4
    plot_h = 4
    fig_width = num_col * plot_w
    fig_height = num_row * plot_h
    fig, axes = plt.subplots(num_row, num_col, figsize=(fig_width, fig_height))
    return fig, axes


counters = [
    "ls_dispatch.ld_dispatch",
    "ls_dispatch.store_dispatch",
    # "de_no_dispatch_per_slot.backend_stalls", # number of ops unable to dispatch b/c backend (accumulate per cycle)
]

def plot_json(json_file, output_file):
    # Apply base text and style configs
    configure_style()

    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)
    df = pd.json_normalize(data, sep=".")

    # Filter on numa_policy
    df = df[df["run_cfg.numa_policy"] == 1]

    # Find unique IDs and set the global palette
    unique_ids = df["identifier"].unique()
    custom_palette = configure_palette(len(unique_ids))

    row = 1
    col = 1 + len(counters)
    cnt = 0
    fig, axes = get_subplots(row, col)

    ax = axes[cnt]
    cnt += 1

    # No need to pass palette=... here anymore!
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="identifier",
        marker="o",
        legend=False,
        ax=ax,
    )
    ax.set_xlabel("fill factor")
    ax.set_ylabel("get mops")

    for counter in counters:

        if counter == "de_no_dispatch_per_slot.backend_stalls":
            df[counter] = df[counter] / df["cycles"]
        else:
            df[counter] = df[counter] / df["find_ops"]
        ax = axes[cnt]
        cnt += 1

        # No need to pass palette=... here either!
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y=counter,
            hue="identifier",
            marker="o",
            legend=False,
            ax=ax,
        )
        ax.set_xlabel("fill factor")
        ax.set_ylabel(counter)

    for ax in axes:
        ax.grid(True, which="major", axis="both", linestyle="--")
        ticks = ax.get_yticks()
        if len(ticks) > 1:
            step_value = ticks[1] - ticks[0]
            ymin, ymax = ax.get_ylim()
            remainder = ymax % step_value
            if remainder != 0:
                ax.set_ylim(ymin, ymax + remainder)

    # Legend - we use the custom_palette returned by our function to map the colors
    custom_lines = [
        Line2D([0], [0], color=custom_palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]
    fig.legend(fontsize=8, handles=custom_lines, loc="upper center", ncol=4)

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
