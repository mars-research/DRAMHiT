#!/usr/bin/env python3
"""Plot the join data sets collected by run_join.py.

Style follows ../collect_inline/plot_data_amd.py: configure_style() /
configure_palette() / get_subplots() are the same helpers, so these figures
drop into the paper next to the inline ones.

  python3 plot_data.py directory          # the Xeon's directory-mode tree
  python3 plot_data.py amd_nps4           # the EPYC's NPS4 tree
  python3 plot_data.py amd_nps4 n4_skew   # just that one set

Sets are discovered from the jsons themselves rather than from a hardcoded
list, because both generations of the collector name themselves: the current
run_join.py writes {"run": "n4_cas", "param_name": ...}, and the older one
wrote {"numa_config": "single", "join_type": "hash_cas", ...}. So one plotter
covers both trees, and a new machine spec needs no edit here.
"""

import json
import shutil
import sys
from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

SCRIPT_DIR = Path(__file__).resolve().parent

# Plot order, which is also the palette order (rocket runs dark -> light).
JOIN_ORDER = ["cas", "cas23", "dlht", "folklore", "radix"]

# Numa configs the Xeon trees use, drawn left-to-right in that order; any
# other config name (n1/n2/n4, ...) sorts after them alphabetically.
CONFIG_ORDER = ["single", "dual"]

TUPLE_BYTES = 16


def configure_style():
    """Configures the base matplotlib fonts and seaborn style."""
    # usetex needs a real latex + dvipng on PATH; fall back to matplotlib's
    # own mathtext when they are missing so plotting still works.
    usetex = bool(shutil.which("latex") and shutil.which("dvipng"))
    if not usetex:
        print("[!] latex/dvipng not found, rendering without usetex")

    rc_fonts = {
        "text.usetex": usetex,
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


def split_run(run):
    """'n4_cas' -> ('n4', 'cas'); a bare run name has no config prefix."""
    if "_" in run:
        config, join = run.split("_", 1)
        return config, join
    return "", run


def discover(root):
    """Every set under root, keyed (numa config, swept param).

    Each value carries the machine name, the directory the set's jsons live
    in (so figures land next to their data in either tree layout), and the
    per-join data.
    """
    sets = {}

    for path in sorted(root.rglob("*.json")):
        if path.name == "manifest.json":
            continue
        data = json.loads(path.read_text())
        param_name = data.get("param_name")
        if not param_name or "throughput_mops" not in data:
            continue

        if "run" in data:  # current run_join.py
            config, join = split_run(data["run"])
            machine = data.get("machine") or path.stem.split("_")[0]
        elif "numa_config" in data:  # the pre-spec collector
            config = data["numa_config"]
            join = data["join_type"]
            if join.startswith("hash_"):
                join = join[len("hash_"):]
            machine = path.stem.split("_")[0]
        else:
            print(f"[!] {path} names neither a run nor a numa config, skipping")
            continue

        entry = sets.setdefault(
            (config, param_name),
            {"machine": machine, "dir": path.parent, "joins": {}},
        )
        entry["joins"][join] = data

    return sets


def ordered_configs(sets):
    def key(config):
        if config in CONFIG_ORDER:
            return (0, CONFIG_ORDER.index(config), "")
        return (1, 0, config)

    return sorted({c for c, _ in sets}, key=key)


def load_set(entry):
    """Long-form frame of every join in one set: join / x / mops / lo / hi.

    `mops` is the per-point median and lo/hi are the min and max over the
    repeats, so the figure can show the spread. Collections made before
    run_join.py repeated its points carry no samples; lo/hi are NaN there and
    the band is simply not drawn.

    relation_size is stored as a tuple count; plot it in GB so the axis reads
    the way the sweep was specified.
    """
    rows = []
    for join in JOIN_ORDER:
        data = entry["joins"].get(join)
        if data is None:
            continue
        samples = data.get("throughput_samples") or []
        for i, (x, mops) in enumerate(zip(data["param_values"], data["throughput_mops"])):
            if data["param_name"] == "relation_size":
                x = x * TUPLE_BYTES / (1024 ** 3)
            point = samples[i] if i < len(samples) else None
            lo = min(point) if point else float("nan")
            hi = max(point) if point else float("nan")
            rows.append({"join": join, "x": x, "mops": mops, "lo": lo, "hi": hi})

    unknown = sorted(set(entry["joins"]) - set(JOIN_ORDER))
    if unknown:
        print(f"[!] not in JOIN_ORDER, not plotted: {unknown}")

    return pd.DataFrame(rows) if rows else None


def set_title(config, entry):
    """The Xeon trees are one socket vs two; elsewhere say what the config is."""
    if config in ("single", "dual"):
        return f"{config} socket"

    threads = next(
        (d.get("threads_by_node") for d in entry["joins"].values() if d.get("threads_by_node")),
        None,
    )
    if threads:
        return f"{config}: {sum(threads.values())} threads, {len(threads)} nodes"
    return config or "joins"


# =============================================================================
# PLOTTING
# =============================================================================


def axis_labels(param_name):
    if param_name == "relation_size":
        return "relation size per side (GB)", "throughput (Mops)"
    return "zipf skew", "throughput (Mops)"


def draw_set(ax, df, param_name, title, palette=None):
    joins = [j for j in JOIN_ORDER if j in set(df["join"])]
    sns.lineplot(
        data=df,
        x="x",
        y="mops",
        hue="join",
        hue_order=joins,
        marker="o",
        legend=False,
        ax=ax,
    )

    # min/max band over the repeats. hue_order fixes the colour cycle, so
    # palette[i] is the colour seaborn just used for joins[i].
    if palette is not None and "lo" in df.columns:
        for i, join in enumerate(joins):
            sub = df[df["join"] == join].sort_values("x")
            if sub["lo"].notna().all() and (sub["hi"] > sub["lo"]).any():
                ax.fill_between(sub["x"], sub["lo"], sub["hi"],
                                color=palette[i % len(palette)],
                                alpha=0.18, linewidth=0, zorder=1)

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


def plot_one_set(config, param_name, entry):
    """One figure per data set, written next to that set's json."""
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    df = load_set(entry)
    if df is None:
        print(f"[!] no data for {config}_{param_name}, skipping")
        return
    joins = [j for j in JOIN_ORDER if j in set(df["join"])]

    fig, axes = get_subplots(1, 1)
    ax = axes if not hasattr(axes, "ravel") else axes.ravel()[0]

    draw_set(ax, df, param_name, set_title(config, entry), palette)
    tidy(ax)
    add_legend(fig, palette, joins)

    stem = "_".join(part for part in (entry["machine"], config, param_name) if part)
    out = entry["dir"] / f"{stem}.png"
    # a lone 4x4 panel needs far less headroom under the legend than the grid
    plt.tight_layout(rect=[0, 0, 1, 0.94])
    plt.savefig(out, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out}")


def plot_overview(root, sets):
    """Every set in one grid: rows are the sweep, cols the numa config."""
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    configs = ordered_configs(sets)
    # a tree may only be partly collected (e.g. skew swept but not
    # relation_size); lay out just the rows that have data for every config
    params = [
        p
        for p in ("relation_size", "skew")
        if all((c, p) in sets for c in configs)
    ]
    if not params:
        print(f"[!] no sweep collected for every config under {root}, skipping overview")
        return

    # rows are the sweep and cols the numa config, except when a machine has
    # only one config -- then the sweeps read better side by side than stacked.
    transposed = len(configs) == 1 and len(params) > 1
    num_row, num_col = (1, len(params)) if transposed else (len(params), len(configs))
    fig, axes = get_subplots(num_row, num_col)
    grid = np.asarray(axes).reshape(num_row, num_col)
    if transposed:
        grid = grid.reshape(len(params), len(configs))
    machine = sets[(configs[0], params[0])]["machine"]
    joins = []

    for r, param_name in enumerate(params):
        for c, config in enumerate(configs):
            entry = sets[(config, param_name)]
            df = load_set(entry)
            joins = [j for j in JOIN_ORDER if j in set(df["join"])]
            ax = grid[r][c]
            draw_set(ax, df, param_name, set_title(config, entry), palette)
            tidy(ax)

    add_legend(fig, palette, joins)

    out = root / f"{machine}_joins_overview.png"
    plt.tight_layout(rect=[0, 0, 1, 0.92])
    plt.savefig(out, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(
            "usage: plot_data.py <tree> [set ...]\n"
            "  e.g. plot_data.py directory\n"
            "       plot_data.py amd_nps4 n4_skew"
        )

    root = SCRIPT_DIR / sys.argv[1]
    if not root.is_dir():
        raise SystemExit(f"[!] no such data directory: {root}")

    sets = discover(root)
    if not sets:
        raise SystemExit(f"[!] no join data found under {root}")
    names = {f"{c}_{p}": (c, p) for c, p in sets}

    if len(sys.argv) > 2:
        wanted = []
        for name in sys.argv[2:]:
            if name not in names:
                raise SystemExit(
                    f"[!] unknown set '{name}', pick from: " + ", ".join(sorted(names))
                )
            wanted.append(names[name])
        for config, param_name in wanted:
            plot_one_set(config, param_name, sets[(config, param_name)])
    else:
        for config in ordered_configs(sets):
            for param_name in ("relation_size", "skew"):
                if (config, param_name) in sets:
                    plot_one_set(config, param_name, sets[(config, param_name)])
        plot_overview(root, sets)
