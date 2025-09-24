#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.lines import Line2D



row = 2
col = 2
fig, axes = plt.subplots(row, col, figsize=(12, 12))  

def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)
    
    df = pd.json_normalize(data, sep='.')
    
    df_single = df[df["run_cfg.numa_policy"] == 4]
    df_dual = df[df["run_cfg.numa_policy"] == 1]
    

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
            elif k == "PREFETCH" and bcfg[k] == "DOUBLE":
                ret += "+2prefetch"


        return ret

    df_single["build_cfg_str"] = df_single["build_cfg_str"].apply(make_identifier)
    df_dual["build_cfg_str"] = df_dual["build_cfg_str"].apply(make_identifier)
    
    ids1 = df_single["build_cfg_str"].unique()
    ids2 = df_dual["build_cfg_str"].unique()
    
    if  (ids1 != ids2).any():
        raise ValueError(f"Identifiers mismatch.\nOnly in df_single: {ids1 - ids2}\nOnly in df_other: {ids2 - ids1}")
    palette = sns.color_palette("rocket", n_colors=len(ids1))
    palette = palette[::-1]  # reverse the palette
    sns.set_theme(style="whitegrid", palette=palette)
    
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(ids1)
    ]

    fig.legend(
        fontsize=8,
        handles=custom_lines,
        loc="upper center",
        ncol=2
    )


    
    ax = axes[0][0]
    sns.lineplot(
        data=df_single,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="build_cfg_str",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title("Single socket - Find Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Find Mops (Millions)")
    ax.grid(True, which="major", axis="both", linestyle="--")
    #ax.set_xlim(0)
    #ax.set_ylim(0)

    ax = axes[0][1]
    sns.lineplot(
        data=df_single,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="build_cfg_str",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title(f"Single socket - Set Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Set Mops")
    ax.grid(True, which="major", axis="both", linestyle="--")
    #ax.set_xlim(0)
    #ax.set_ylim(0)

    ax = axes[1][0]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="build_cfg_str",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title("Dual socket - Find Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Find Mops")
    ax.grid(True, which="major", axis="both", linestyle="--")
    #ax.set_xlim(0)
    #ax.set_ylim(0)

    ax = axes[1][1]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="build_cfg_str",
        marker="o",
        ax=ax,
        legend=False
    )
    ax.set_title(f"Dual socket - Set Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Set Mops")
    ax.grid(True, which="major", axis="both", linestyle="--")
    
    
    #ax.set_xlim(0)
    #ax.set_ylim(0)


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
