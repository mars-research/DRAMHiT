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
    
    # for df in datasets:
    #     df["normalized_allbr"] = df["br_inst_retired.all_branches"] / df["find_ops"]
    #     df["normalized_uops"] = df["uops_issued.any"] / df["find_ops"]
    #     df["normalized_mispbr"] = df["br_misp_retired.all_branches"] / df["find_ops"]

    # Set Seaborn style
    sns.set_theme()
    
    row = 2
    col = 1
    fig, axes = plt.subplots(row, col, figsize=(19, 7))    
        
    cnt = 0
    for df in datasets:
        rax = axes[cnt]
        ax = rax

        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="set_mops",
            hue="identifier",
            marker="o",
            ax=ax
        )
        ax.set_title("Fill Factor vs insert Mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Insert Mops")
        
    
        cnt += 1


    for ax in axes.flatten():
        leg = ax.get_legend()
        if leg is not None:  # only adjust if legend exists
            ax.legend(fontsize=4, markerscale=0.1, title_fontsize=12)
            
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

