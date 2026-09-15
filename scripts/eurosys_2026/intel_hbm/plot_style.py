#!/usr/bin/env python3
"""Shared figure style for the intel_hbm plots.

Mirrors ../collect_join/plot_data.py (which itself follows
../collect_inline/plot_data_amd.py): same configure_style() /
configure_palette() / get_subplots() helpers, so these figures drop into the
paper next to the collect_join ones instead of looking like a second source.

The join palette is deliberately built at len(JOIN_ORDER) == 5, the same as
collect_join, so cas is the same colour in both sets of figures. The whole-
machine radix run is not a sixth join -- it is radix again with more cpus --
so it reuses radix's colour and is separated by line style instead, which
keeps the palettes identical.
"""

import shutil

import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.lines import Line2D

# Plot order, which is also the palette order (rocket runs dark -> light).
JOIN_ORDER = ["cas", "cas23", "dlht", "folklore", "radix"]

# Internal series names (matching data keys / filenames) -> display names
# shown in legends. Only the legend text changes; lookups stay on the
# internal names above.
DISPLAY_NAMES = {
    "cas": "dramblast",
    "cas23": "dramhit",
}


def display_name(name):
    return DISPLAY_NAMES.get(name, name)

TUPLE_BYTES = 16

# Runs that are a variant of one of the joins above rather than a join of their
# own: same colour as their base, told apart by dash pattern and marker.
VARIANT_STYLE = {
    "radix (all cpus)": {"base": "radix", "linestyle": ":", "marker": "^"},
}


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


def configure_palette(n):
    """Generates a reversed rocket palette and sets it as the global default."""
    custom_palette = sns.color_palette("rocket", n_colors=n)[::-1]
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


def series_style(name, palette):
    """Colour, dash and marker for one plotted series."""
    variant = VARIANT_STYLE.get(name)
    base = variant["base"] if variant else name
    colour = palette[JOIN_ORDER.index(base) % len(palette)] if base in JOIN_ORDER else None
    # Both radix curves (single socket and all cpus) are dotted, told apart by
    # marker; every other join stays solid.
    default_linestyle = ":" if base == "radix" else "-"
    return {
        "color": colour,
        "linestyle": variant["linestyle"] if variant else default_linestyle,
        "marker": variant["marker"] if variant else "o",
    }


def draw_band(ax, sub, style):
    """Min/max band over a point's repeats, drawn under its line.

    Collections taken before --repeats existed carry one sample per point (or
    none), so there is nothing to shade and the band is simply skipped.
    """
    if "lo" not in sub.columns or sub["lo"].isna().any():
        return
    if not (sub["hi"] > sub["lo"]).any():
        return
    ax.fill_between(sub["x"], sub["lo"], sub["hi"], color=style["color"],
                    alpha=0.18, linewidth=0, zorder=1)


def tidy(ax):
    ax.grid(True, which="major", axis="both", linestyle="--")
    ticks = ax.get_yticks()
    if len(ticks) > 1:
        step_value = ticks[1] - ticks[0]
        ymin, ymax = ax.get_ylim()
        remainder = ymax % step_value
        if remainder != 0:
            ax.set_ylim(ymin, ymax + remainder)


def add_legend(fig, palette, names, ncol=None):
    custom_lines = [
        Line2D([0], [0], label=display_name(name), **series_style(name, palette))
        for name in names
    ]
    fig.legend(fontsize=8, handles=custom_lines, loc="upper center",
               ncol=ncol or len(names))


def axis_labels(param_name):
    if param_name == "relation_size":
        return "relation size per side (GB)", "throughput (Mops)"
    return "zipf skew", "throughput (Mops)"
