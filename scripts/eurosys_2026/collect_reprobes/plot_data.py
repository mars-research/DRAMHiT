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
            elif k == "PREFETCH" and bcfg[k] == "L2":
                ret += "+prefetchT1"
            elif k == "PREFETCH" and bcfg[k] == "DOUBLE":
                ret += "+2prefetch"

        return ret

    df_single["identifier"] = df_single["build_cfg_str"].apply(make_identifier)
    df_dual["identifier"] = df_dual["build_cfg_str"].apply(make_identifier)

    # Ensure 'fill_factor' is numeric
    df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])
    datasets = [df_single, df_dual]

    # Set Seaborn style
    sns.set_theme()

    row = 2
    col = 2
    fig, axes = plt.subplots(row, col, figsize=(12, 7))

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
            legend=False,
        )
        ax.set_title("Fill Factor vs Find Mops")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Find Mops")

        ax = rax[1]
        sns.lineplot(
            data=df,
            x="run_cfg.fill_factor",
            y="reprobe_factor",
            hue="identifier",
            marker="o",
            ax=ax,
            legend=False,
        )
        ax.set_title(f"Fill Factor vs Reprobe factor")
        ax.set_xlabel("Fill Factor")
        ax.set_ylabel("Reprobe")
        cnt += 1

    unique_ids = datasets[0]["identifier"].unique()
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
