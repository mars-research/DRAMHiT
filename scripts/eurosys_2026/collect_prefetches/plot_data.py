#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Hard-coded counter names
counters = [
    "cycles",
    "l1d_pend_miss.fb_full",
    "memory_activity.cycles_l1d_miss",
    "cycle_activity.stalls_total"
]

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
    # Set Seaborn style
    sns.set_theme()

    #sns.set(style="whitegrid", palette="tab10", font_scale=1.2)

    # Create figure with 5 subplots (4 counters + get_mops)
    
    row = 2
    col = 3
    fig, axes = plt.subplots(row, col, figsize=(15, 7))

    cnt = 0
    
    for df in datasets:
        rax = axes[cnt]
        ax = rax[0]
        df["prefetch_id"] = df["identifier"].str.split("-").str[0]

        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="get_mops",
            # hue="identifier",
            hue="prefetch_id",
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
            y="cycle_activity.stalls_total",
            # hue="identifier",
            hue="prefetch_id",  
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs Stall Cycles")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Stall Cycles")
        
        ax = rax[2]
        

        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="l1d_pend_miss.fb_full",
            # hue="identifier",
            hue="prefetch_id",
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs FB full cycle")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("FB full cycle")
        cnt += 1
        


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
