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

# Distinct shapes to cycle through
MARKERS = ["o", "s", "^", "D", "v", "p", "*", "X"]

def plot_json(json_file, output_file):
    with open(json_file, "r") as f:
        data = json.load(f)

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
            elif k == "PREFETCH" and v == "L2":
                ret += "+L2"
        return ret

    df_single["build_cfg_str"] = df_single["build_cfg_str"].apply(make_identifier)
    df_dual["build_cfg_str"] = df_dual["build_cfg_str"].apply(make_identifier)

    ids1 = df_single["build_cfg_str"].unique()
    palette = sns.color_palette("colorblind", n_colors=len(ids1))
    color_map = dict(zip(ids1, palette))
    
    sns.set_theme(style="whitegrid")

    # Legend with hollow shapes and unique dashes
    custom_lines = []
    # We use a temporary plot to grab the default dashes Seaborn generates
    temp_ax = plt.figure().add_subplot(111)
    sns.lineplot(data=df_single, x="run_cfg.fill_factor", y="set_mops", 
                 hue="build_cfg_str", style="build_cfg_str", ax=temp_ax, palette=color_map)
    
    for i, (uid, line) in enumerate(zip(ids1, temp_ax.get_lines())):
        custom_lines.append(Line2D([0], [0], color=color_map[uid], 
                           marker=MARKERS[i % len(MARKERS)], 
                           linestyle=line.get_linestyle(), 
                           markerfacecolor="none", markeredgecolor=color_map[uid],
                           markeredgewidth=1.5, markersize=8, label=uid))
    plt.close(temp_ax.figure)

    fig.legend(fontsize=9, handles=custom_lines, loc="upper center", ncol=3)

    plot_configs = [
        (df_single, axes[0][0], "set_mops", "Single socket - Set Throughput", "Set Mops"),
        (df_single, axes[0][1], "get_mops", "Single socket - Find Throughput", "Find Mops (Millions)"),
        (df_dual, axes[1][0], "set_mops", "Dual socket - Set Throughput", "Set Mops"),
        (df_dual, axes[1][1], "get_mops", "Dual socket - Find Throughput", "Find Mops"),
    ]

    for df_sub, ax, y_col, title, y_label in plot_configs:
        sns.lineplot(
            data=df_sub, x="run_cfg.fill_factor", y=y_col, 
            hue="build_cfg_str", style="build_cfg_str", 
            dashes=True, markers=MARKERS[:len(ids1)], 
            ax=ax, legend=False, palette=color_map
        )
        
        # Force markers to be hollow and match line color
        for line in ax.get_lines():
            line.set_markerfacecolor("none")
            line.set_markeredgecolor(line.get_color())
            line.set_markeredgewidth(1.5)
            line.set_markersize(4)

        ax.set_title(title)
        ax.set_xlabel("Fill Factor(%)")
        ax.set_ylabel(y_label)
        ax.set_ylim(bottom=0)
        ax.grid(True, which="both", axis="both", linestyle="--")

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) == 3:
        plot_json(sys.argv[1], sys.argv[2])