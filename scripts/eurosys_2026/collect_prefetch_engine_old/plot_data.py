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

    # Ensure 'fill_factor' is numeric
    df["fill_factor"] = pd.to_numeric(df["fill_factor"])

    # Set Seaborn style
    sns.set_theme()

    #sns.set(style="whitegrid", palette="tab10", font_scale=1.2)

    # Create figure with 5 subplots (4 counters + get_mops)
    fig, axes = plt.subplots(3, 2, figsize=(14, 12))
    axes = axes.flatten()

    # Plot perf counters
    for i, counter in enumerate(counters):
        ax = axes[i]
        sns.lineplot(
            data=df,
            x="fill_factor",
            y=counter,
            hue="title",
            marker="o",
            ax=ax
        )
        ax.set_title(f"Fill Factor vs {counter}")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel(counter)

    # Plot get_mops
    ax = axes[4]
    if "get_mops" in df.columns:
        sns.lineplot(
            data=df,
            x="fill_factor",
            y="get_mops",
            hue="title",
            marker="o",
            ax=ax
        )
        ax.set_title("Fill Factor vs get_mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("get_mops")

    # Remove unused subplot (if any)
    if len(axes) > 5:
        fig.delaxes(axes[5])

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
