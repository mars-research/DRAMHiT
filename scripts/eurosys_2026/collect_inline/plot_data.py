#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.lines import Line2D


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)
    
    df = pd.json_normalize(data, sep='.')
    
    df_single = df[df["run_cfg.numa_policy"] == 4]
    df_dual = df[df["run_cfg.numa_policy"] == 1]

    
    # Ensure 'fill_factor' is numeric
    df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])

    
    datasets = [df_single, df_dual]
    
    for df in datasets:
        df["normalized_cyc"] = df["uops_dispatched.port_2_3_10"] / (df["total_find_duration"] * df["run_cfg.numThreads"])
        df["normalized_uops"] = df["uops_dispatched.port_2_3_10"] / df["uops_issued.any"]
        df["normalized_ops"] = df["uops_dispatched.port_2_3_10"] / df["find_ops"]

    # Set Seaborn style
    sns.set_theme()
    
    row = 2
    col = 4
    fig, axes = plt.subplots(row, col, figsize=(19, 7))    
        
    cnt = 0
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
            legend=False
        )
        ax.set_title("Fill Factor vs Find Mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")
        MODE = ""
        if cnt == 0:
            MODE = "Single Socket"
        else: 
            MODE = "Dual Socket"
        ax.text(
            0.1, 1.2, MODE,         # (x,y) in axes coords
            transform=ax.transAxes,      # relative to the axis
            ha="right", va="top",
            fontsize=12, fontweight="bold"
        )
        
        ax = rax[1]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="normalized_cyc",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False
        )
        ax.set_title(f"Fill Factor vs Mem Uops/Cycles")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops/Cycles")
        
        ax = rax[2]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="normalized_ops",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False
        )
        ax.set_title(f"Fill Factor vs Mem Uops/find")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops/find")
        
        ax = rax[3]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="uops_dispatched.port_2_3_10",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False
        )
        ax.set_title(f"Fill Factor vs Mem Uops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops")
        
        cnt += 1

    
    unique_ids = datasets[0]["identifier"].unique()
    palette = sns.color_palette(n_colors=len(unique_ids))

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]

    fig.legend(
        fontsize=8,
        handles=custom_lines,
        loc="upper center",
        ncol=2
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

