#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


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
        df["normalized_cyc"] = df["uops_dispatched.port_2_3_10"] / df["cycles"]
        df["normalized_uops"] = df["uops_dispatched.port_2_3_10"] / df["uops_issued.any"]

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
            ax=ax
        )
        ax.set_title("Fill Factor vs Find Mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")
        
        
        ax = rax[1]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="normalized_cyc",
            hue="identifier",
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs Mem Uops/Cycles")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops/Cycles")
        
        ax = rax[2]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="normalized_uops",
            hue="identifier",
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs Mem Uops/Uops issued")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops/Uops issued")
        
        ax = rax[3]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="uops_dispatched.port_2_3_10",
            hue="identifier",
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs Mem Uops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Mem Uops")
        
        cnt += 1


    for ax in axes.flatten():
        leg = ax.get_legend()
        if leg is not None:  # only adjust if legend exists
            ax.legend(fontsize=8, markerscale=0.1, title_fontsize=12)
            
    plt.tight_layout()
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    json_file = sys.argv[1]
    output_file = sys.argv[2]
    plot_json(json_file, output_file)

