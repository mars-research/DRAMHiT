#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D


def plot_json(json_file, output_file):
    # Load JSON data
    with open(json_file, "r") as f:
        data = json.load(f)

    # Convert to pandas DataFrame
    df = pd.DataFrame(data)

    df = pd.json_normalize(data, sep=".")

    datasets = df[df["run_cfg.numa_policy"] == 4]
    df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])

    sns.set_theme()

    row = 1
    col = 2
    fig, axes = plt.subplots(row, col, figsize=(15, 7))

    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="identifier",
        marker="o",
        ax=axes[0],
        legend=False,
    )
    axes[0].set_title("Fill Factor vs Find Mops")
    axes[0].set_xlabel("Fill Factor")
    axes[0].set_ylabel("Find Mops")

    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="identifier",
        marker="o",
        ax=axes[1],
        legend=False,
    )
    axes[1].set_title("Fill Factor vs Set Mops")
    axes[1].set_xlabel("Fill Factor")
    axes[1].set_ylabel("Set Mops")

    unique_ids = datasets["identifier"].unique()
    palette = sns.color_palette(n_colors=len(unique_ids))

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(unique_ids)
    ]

    fig.legend(fontsize=8, handles=custom_lines, loc="upper center", ncol=2)

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
