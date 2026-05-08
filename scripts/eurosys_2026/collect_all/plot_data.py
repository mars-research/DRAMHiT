#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

row = 2
col = 2
fig, axes = plt.subplots(row, col, figsize=(12, 12))


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.json_normalize(data, sep=".")

    df_single = df[df["run_cfg.numa_policy"] == 4].copy()
    df_dual = df[df["run_cfg.numa_policy"] == 1].copy()

    def make_identifier(build_cfg: str) -> str:
        bcfg = dict(part.split("=", 1) for part in build_cfg.split("-"))
        ret = ""
        if bcfg["DRAMHiT_VARIANT"] == "2025":
            ret += "base"
        elif bcfg["DRAMHiT_VARIANT"] == "2025_INLINE":
            ret += "inline"

        for k, v in bcfg.items():
            if k == "BUCKETIZATION" and v == "ON":
                ret += "+bucket"
            elif k == "BRANCH" and v == "simd":
                ret += "+simd"
            elif k == "UNIFORM_PROBING" and v == "ON":
                ret += "+uniform"
            elif k == "PREFETCH" and v == "DOUBLE":
                ret += "+2prefetch"
        return ret

    df_single["build_cfg_str"] = df_single["build_cfg_str"].apply(make_identifier)
    df_dual["build_cfg_str"] = df_dual["build_cfg_str"].apply(make_identifier)

    ids1 = df_single["build_cfg_str"].unique()
    
    # Use colorblind palette
    palette = sns.color_palette("colorblind", n_colors=len(ids1))
    sns.set_theme(style="whitegrid")

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(ids1)
    ]

    fig.legend(fontsize=9, handles=custom_lines, loc="upper center", ncol=3)

    # Left Column: Set (Insertions) | Right Column: Get (Finds)

    # Plot 0,0: Single Set
    ax = axes[0][0]
    sns.lineplot(data=df_single, x="run_cfg.fill_factor", y="set_mops", hue="build_cfg_str", 
                 marker="o", ax=ax, legend=False, palette=palette)
    ax.set_title("Single socket - Set Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Set Mops")
    ax.set_ylim(bottom=0)
    ax.grid(True, which="both", axis="both", linestyle="--")

    # Plot 0,1: Single Find
    ax = axes[0][1]
    sns.lineplot(data=df_single, x="run_cfg.fill_factor", y="get_mops", hue="build_cfg_str", 
                 marker="o", ax=ax, legend=False, palette=palette)
    ax.set_title("Single socket - Find Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Find Mops (Millions)")
    ax.set_ylim(bottom=0)
    ax.grid(True, which="both", axis="both", linestyle="--")

    # Plot 1,0: Dual Set
    ax = axes[1][0]
    sns.lineplot(data=df_dual, x="run_cfg.fill_factor", y="set_mops", hue="build_cfg_str", 
                 marker="o", ax=ax, legend=False, palette=palette)
    ax.set_title("Dual socket - Set Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Set Mops")
    ax.set_ylim(bottom=0)
    ax.grid(True, which="both", axis="both", linestyle="--")

    # Plot 1,1: Dual Find
    ax = axes[1][1]
    sns.lineplot(data=df_dual, x="run_cfg.fill_factor", y="get_mops", hue="build_cfg_str", 
                 marker="o", ax=ax, legend=False, palette=palette)
    ax.set_title("Dual socket - Find Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Find Mops")
    ax.set_ylim(bottom=0)
    ax.grid(True, which="both", axis="both", linestyle="--")

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    plot_json(sys.argv[1], sys.argv[2])