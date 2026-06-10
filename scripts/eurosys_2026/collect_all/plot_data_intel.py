#!/bin/python3

import json
import sys
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

def plot_json(json_file, output_file):
    with open(json_file, "r") as f:
        data = json.load(f)

    df = pd.json_normalize(data, sep=".")

    # Split sockets (keep both)
    df_single = df[df["run_cfg.numa_policy"] == 4].copy()
    df_dual   = df[df["run_cfg.numa_policy"] == 1].copy()

    def make_identifier(build_cfg: str) -> str:
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

    df_single["build_cfg_str"] = df_single["build_cfg_str"].apply(make_identifier)
    df_dual["build_cfg_str"]   = df_dual["build_cfg_str"].apply(make_identifier)

    ids = sorted(df_single["build_cfg_str"].unique())

    palette = sns.color_palette("tab10", n_colors=len(ids))
    sns.set_theme(style="whitegrid")

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid, lw=2)
        for i, uid in enumerate(ids)
    ]

    legend = fig.legend(
        handles=custom_lines,
        loc="upper center",
        ncol=4,
        fontsize=9,
        frameon=True,
        edgecolor="darkgray"
    )

    # ---------------- LEFT COLUMN = SET ----------------
    ax = axes[0][0]
    sns.lineplot(
        data=df_single,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="build_cfg_str",
        hue_order=ids,
        palette=palette,
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Single Socket - Set")
    ax.set_xlabel("Fill Factor (%)")
    ax.set_ylabel("Set Mops")
    ax.set_ylim(bottom=0)

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_edgecolor("gray")

    ax = axes[1][0]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.fill_factor",
        y="set_mops",
        hue="build_cfg_str",
        hue_order=ids,
        palette=palette,
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Dual Socket - Set")
    ax.set_xlabel("Fill Factor (%)")
    ax.set_ylabel("Set Mops")
    ax.set_ylim(bottom=0)

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_edgecolor("gray")

    # ---------------- RIGHT COLUMN = FIND ----------------
    ax = axes[0][1]
    sns.lineplot(
        data=df_single,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="build_cfg_str",
        hue_order=ids,
        palette=palette,
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Single Socket - Find")
    ax.set_xlabel("Fill Factor (%)")
    ax.set_ylabel("Find Mops")
    ax.set_ylim(bottom=0)

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_edgecolor("gray")

    ax = axes[1][1]
    sns.lineplot(
        data=df_dual,
        x="run_cfg.fill_factor",
        y="get_mops",
        hue="build_cfg_str",
        hue_order=ids,
        palette=palette,
        marker="o",
        ax=ax,
        legend=False,
    )
    ax.set_title("Dual Socket - Find")
    ax.set_xlabel("Fill Factor (%)")
    ax.set_ylabel("Find Mops")
    ax.set_ylim(bottom=0)

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_edgecolor("gray")

    plt.tight_layout(rect=[0, 0, 1, 0.88])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Plots saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python plot_dramhit.py <input.json> <output.png>")
        sys.exit(1)

    plot_json(sys.argv[1], sys.argv[2])