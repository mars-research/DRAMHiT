#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

# EDIT ME: Spot to rename legend identifiers (X to Y)
# If an identifier is not found here, it defaults to its original name.
LEGEND_REMAP = {
    "base+2prefetch": "linear",
    "base+bucket+2prefetch": "linear+bucket",
    "base+simd+bucket+2prefetch": "linear+bucket+simd",
    "base+simd+bucket+2prefetch+uniform": "linear+bucket+simd+uniform",
    "base+2prefetch+uniform": "linear+uniform",
}


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)
    df = pd.json_normalize(data, sep=".")

    df_single = df[df["run_cfg.numa_policy"] == 4].copy()
    # df_dual = df[df["run_cfg.numa_policy"] == 1].copy()
    df_dual = df[df["run_cfg.numa_policy"] == -999].copy()

    def make_identifier(build_cfg: str) -> str:
        # Parse into dict
        bcfg = dict(part.split("=", 1) for part in build_cfg.split("-"))
        ret = ""
        if bcfg["DRAMHiT_VARIANT"] == "2025":
            ret += "base"
        elif bcfg["DRAMHiT_VARIANT"] == "2025_INLINE":
            ret += "inline"

        for k in bcfg.keys():
            if k == "BUCKETIZATION" and bcfg[k] == "ON":
                ret += "+bucket"
            elif k == "BRANCH" and bcfg[k] == "simd":
                ret += "+simd"
            elif k == "UNIFORM_PROBING" and bcfg[k] == "ON":
                ret += "+uniform"
            elif k == "PREFETCH" and bcfg[k] == "L2":
                ret += "+prefetchT1"
            elif k == "PREFETCH" and bcfg[k] == "DOUBLE":
                ret += "+2prefetch"

        return ret

    # Dynamically build datasets list based on what is actually present or wanted
    datasets = []
    if not df_single.empty:
        df_single["identifier"] = df_single["build_cfg_str"].apply(make_identifier)
        df_single["run_cfg.fill_factor"] = pd.to_numeric(df_single["run_cfg.fill_factor"])
        datasets.append(df_single)
    if not df_dual.empty:
        df_dual["identifier"] = df_dual["build_cfg_str"].apply(make_identifier)
        df_dual["run_cfg.fill_factor"] = pd.to_numeric(df_dual["run_cfg.fill_factor"])
        datasets.append(df_dual)

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
    col = 2
    # Adjust overall height based on row count to avoid squished 1-row viewports
    fig, axes = plt.subplots(row, col, figsize=(12, 5.0 if row == 1 else 3.5 * row))

    unique_ids = datasets[0]["identifier"].unique()
    
    # Switched to the high-contrast qualitative "tab10" palette
    palette = sns.color_palette("tab10", n_colors=len(unique_ids))

    cnt = 0
    for df_set in datasets:
        # Handle 1D vs 2D array unpacking gracefully depending on row count
        rax = axes[cnt] if row > 1 else axes
        ax = rax[0]

        sns.lineplot(
            data=df_set,
            x="run_cfg.fill_factor",
            y="get_mops",
            hue="identifier",
            palette=palette,
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Fill Factor vs Find Mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")

        ax = rax[1]
        sns.lineplot(
            data=df_set,
            x="run_cfg.fill_factor",
            y="reprobe_factor",
            hue="identifier",
            palette=palette,
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_ylim(bottom=0)
        ax.set_title("Fill Factor vs Reprobe factor")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Reprobe")
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

    # Remaps the label text dynamically using LEGEND_REMAP dictionary lookup
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=LEGEND_REMAP.get(uid, uid))
        for i, uid in enumerate(unique_ids)
    ]

    # Adjusted bbox_to_anchor and limited column wrap to 4 items max so it wraps gracefully 
    # instead of shooting off-screen horizontally.
    fig.legend(
        fontsize=11, 
        handles=custom_lines, 
        loc="lower center", 
        bbox_to_anchor=(0.5, 0.88 if row == 1 else 0.93), 
        ncol=min(4, len(unique_ids)),
        frameon=False
    )

    # Added extra top-padding margin room (0.88 / 0.92) to fit wrapped text blocks safely
    plt.tight_layout(rect=[0, 0, 1, 0.88 if row == 1 else 0.92])

    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)