#!/usr/bin/env python3
"""Plot the four join data sets collected by run_all.sh.

Style follows ../collect_inline/plot_data_amd.py: configure_style() /
configure_palette() / get_subplots() are the same helpers, so these figures
drop into the paper next to the inline ones.

  python3 plot_data.py                 # all four sets + the overview grid
  python3 plot_data.py single_skew     # just that set
"""

import json
import sys
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

SCRIPT_DIR = Path(__file__).resolve().parent
MACHINE = "intel"

# (numa config, swept param) -> the directory run_join.py writes into.
SETS = [
    ("single", "relation_size"),
    ("single", "skew"),
    ("dual", "relation_size"),
    ("dual", "skew"),
]

# Plot order, which is also the palette order (rocket runs dark -> light).
JOIN_ORDER = ["cas", "cas23", "dlht", "folklore", "radix"]

TUPLE_BYTES = 16


def configure_style():
    """Configures the base matplotlib fonts and seaborn style."""
    rc_fonts = {
        "text.usetex": True,
        "font.family": "serif",
        "font.serif": ["Linux Libertine O"],
        "font.weight": "bold",
    }
    mpl.rcParams.update(rc_fonts)
    sns.set_context("paper")
    sns.set_style("whitegrid")


def configure_palette(len):
    """Generates a reversed rocket palette and sets it as the global default."""

    custom_palette = sns.color_palette("rocket", n_colors=len)[::-1]
    sns.set_palette(custom_palette)
    return custom_palette


def get_subplots(num_row, num_col):
    """Generate 4by4 plots"""
    plot_w = 4
    plot_h = 4
    fig_width = num_col * plot_w
    fig_height = num_row * plot_h
    fig, axes = plt.subplots(num_row, num_col, figsize=(fig_width, fig_height))
    return fig, axes


# =============================================================================
# DATA
# =============================================================================


def join_label(join):
    """run_join.py's json stem for a join: hash tables are prefixed."""
    return join if join == "radix" else f"hash_{join}"


def load_set(numa_config, param_name):
    """Long-form frame of every join in one set: join / x / mops.

    relation_size is stored as a tuple count; plot it in GB so the axis reads
    the way the sweep was specified.
    """
    set_dir = SCRIPT_DIR / f"{numa_config}_{param_name}"
    rows = []

    for join in JOIN_ORDER:
        path = set_dir / f"{MACHINE}_{numa_config}_{join_label(join)}_{param_name}.json"
        if not path.exists():
            print(f"[!] missing {path}, skipping {join}")
            continue

        with open(path) as f:
            data = json.load(f)

        for x, mops in zip(data["param_values"], data["throughput_mops"]):
            if param_name == "relation_size":
                x = x * TUPLE_BYTES / (1024 ** 3)
            rows.append({"join": join, "x": x, "mops": mops})

    if not rows:
        raise SystemExit(f"[!] no data found under {set_dir}")

    return pd.DataFrame(rows)


# =============================================================================
# PLOTTING
# =============================================================================


def axis_labels(param_name):
    if param_name == "relation_size":
        return "relation size per side (GB)", "throughput (Mops)"
    return "zipf skew", "throughput (Mops)"


def draw_set(ax, df, param_name, title):
    sns.lineplot(
        data=df,
        x="x",
        y="mops",
        hue="join",
        hue_order=[j for j in JOIN_ORDER if j in set(df["join"])],
        marker="o",
        legend=False,
        ax=ax,
    )

    xlabel, ylabel = axis_labels(param_name)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)

    if param_name == "relation_size":
        # the sweep doubles each step, so a log2 axis spaces the points evenly
        xs = sorted(set(df["x"]))
        ax.set_xscale("log", base=2)
        ax.set_xticks(xs)
        ax.set_xticklabels([f"{x:g}" if x >= 1 else f"{x:.2g}" for x in xs])

    ax.set_ylim(bottom=0)


def tidy(ax):
    ax.grid(True, which="major", axis="both", linestyle="--")
    ticks = ax.get_yticks()
    if len(ticks) > 1:
        step_value = ticks[1] - ticks[0]
        ymin, ymax = ax.get_ylim()
        remainder = ymax % step_value
        if remainder != 0:
            ax.set_ylim(ymin, ymax + remainder)


def add_legend(fig, palette, joins):
    custom_lines = [
        Line2D([0], [0], color=palette[i], marker="o", label=uid)
        for i, uid in enumerate(joins)
    ]
    fig.legend(fontsize=8, handles=custom_lines, loc="upper center", ncol=len(joins))


def plot_one_set(numa_config, param_name):
    """One figure per data set, written next to that set's json."""
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    df = load_set(numa_config, param_name)
    joins = [j for j in JOIN_ORDER if j in set(df["join"])]

    fig, axes = get_subplots(1, 1)
    ax = axes if not hasattr(axes, "ravel") else axes.ravel()[0]

    draw_set(ax, df, param_name, f"{numa_config} socket")
    tidy(ax)
    add_legend(fig, palette, joins)

    out = SCRIPT_DIR / f"{numa_config}_{param_name}" / f"{MACHINE}_{numa_config}_{param_name}.png"
    # a lone 4x4 panel needs far less headroom under the legend than the grid
    plt.tight_layout(rect=[0, 0, 1, 0.94])
    plt.savefig(out, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out}")


def plot_overview():
    """All four sets in one 2x2 grid: rows are the sweep, cols the numa config."""
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    params = ["relation_size", "skew"]
    configs = ["single", "dual"]

    fig, axes = get_subplots(len(params), len(configs))
    joins = []

    for r, param_name in enumerate(params):
        for c, numa_config in enumerate(configs):
            df = load_set(numa_config, param_name)
            joins = [j for j in JOIN_ORDER if j in set(df["join"])]
            ax = axes[r][c]
            draw_set(ax, df, param_name, f"{numa_config} socket")
            tidy(ax)

    add_legend(fig, palette, joins)

    out = SCRIPT_DIR / f"{MACHINE}_joins_overview.png"
    plt.tight_layout(rect=[0, 0, 1, 0.92])
    plt.savefig(out, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        wanted = []
        for name in sys.argv[1:]:
            match = [s for s in SETS if f"{s[0]}_{s[1]}" == name]
            if not match:
                raise SystemExit(
                    f"[!] unknown set '{name}', pick from: "
                    + ", ".join(f"{a}_{b}" for a, b in SETS)
                )
            wanted += match
        for numa_config, param_name in wanted:
            plot_one_set(numa_config, param_name)
    else:
        for numa_config, param_name in SETS:
            plot_one_set(numa_config, param_name)
        plot_overview()
