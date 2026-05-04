#!/bin/python3

import json
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

row = 1
col = 2
fig, axes = plt.subplots(row, col, figsize=(10, 5))


def plot_json(json_file_dir, json_file_snoop, output_file):
    with open(json_file_dir, "r") as f:
        data_dir = json.load(f)

    # 2. Load the second file
    with open(json_file_snoop, "r") as f:
        data_snoop = json.load(f)

    df_dir = pd.json_normalize(data_dir, sep=".")
    df_snoop = pd.json_normalize(data_snoop, sep=".")

    df_dir["firmware-mode"] = "directory"
    df_snoop["firmware-mode"] = "snoop"

    df = pd.concat([df_dir, df_snoop], ignore_index=True)

    def make_identifier(build_cfg: str) -> str:
        # Parse into dict
        bcfg = dict(part.split("=", 1) for part in build_cfg.split("-"))
        ret = ""
        # if bcfg["DRAMHiT_VARIANT"] == "2025":
        #     ret += "base"
        # elif bcfg["DRAMHiT_VARIANT"] == "2025_INLINE":
        #     ret += "inline"

        for k in bcfg.keys():
            if k == "UNIFORM_PROBING" and bcfg[k] == "ON":
                ret += "+uniform"
            elif k == "UNIFORM_PROBING" and bcfg[k] == "OFF":
                ret += "+linear"

        return ret

    df["identifier"] = df["build_cfg_str"].apply(make_identifier)
    df["identifier"] = df["firmware-mode"] + df["identifier"]
    ids1 = df["identifier"].unique()
    palette = sns.color_palette("rocket", n_colors=len(ids1))
    palette = palette[::-1]  # reverse the palette
    sns.set_theme(style="whitegrid", palette=palette)

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(ids1)
    ]

    fig.legend(fontsize=8, handles=custom_lines, loc="upper center", ncol=2)

    ax = axes[0]
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="identifier",
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Find Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Find Mops (Millions)")
    ax.grid(True, which="major", axis="both", linestyle="--")
    # ax.set_xlim(0)
    ax = axes[1]
    sns.lineplot(
        data=df,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="identifier",
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Insert Throughput")
    ax.set_xlabel("Fill Factor(%)")
    ax.set_ylabel("Insert Mops (Millions)")
    ax.grid(True, which="major", axis="both", linestyle="--")

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python plot_dramhit.py <dir.json> <snoop.json> <output.png>")
        sys.exit(1)

    json_file_dir = sys.argv[1]
    json_file_snoop = sys.argv[2]
    output_file = sys.argv[3]
    plot_json(json_file_dir, json_file_snoop, output_file)
