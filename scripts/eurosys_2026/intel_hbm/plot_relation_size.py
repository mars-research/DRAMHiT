#!/usr/bin/env python3
"""Plot throughput vs relation_size (R = S) for every hashtable + radix join.

Reads the per-config JSON files produced by run_single_join.py
(--param-name relation_size) and overlays them on one chart, in the same style
as ../collect_join/plot_data.py so the figures sit together in the paper.
"""

import json
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

from plot_style import (JOIN_ORDER, TUPLE_BYTES, add_legend, axis_labels,
                        configure_palette, configure_style, draw_band,
                        get_subplots, series_style, tidy)

SCRIPT_DIR = Path(__file__).resolve().parent
OUT_PATH = SCRIPT_DIR / "intel_hbm_single_relation_size.png"

# (json file, series name). The series name picks the colour: the first five
# are the joins themselves, the last is radix again on the whole machine.
CONFIGS = [
    ("intel_hbm_single_hash_cas_relation_size.json", "cas"),
    ("intel_hbm_single_hash_cas23_relation_size.json", "cas23"),
    ("intel_hbm_single_hash_dlht_relation_size.json", "dlht"),
    ("intel_hbm_single_hash_folklore_relation_size.json", "folklore"),
    ("intel_hbm_single_radix_relation_size.json", "radix"),
    # 128 threads over both sockets, each thread's partitions and hashtable in
    # its own socket's hbm node (node 0 cpus -> node 2, node 1 cpus -> node 3).
    ("intel_hbm_allcpu_radix_relation_size.json", "radix (all cpus)"),
]


def load():
    """Long-form frame of every collected curve: series / x (GB) / mops."""
    rows = []
    names = []
    for filename, name in CONFIGS:
        path = SCRIPT_DIR / filename
        if not path.exists():
            print(f"[!] skipping missing {filename}")
            continue

        data = json.loads(path.read_text())
        names.append(name)
        samples = data.get("throughput_samples") or []
        for i, (value, mops) in enumerate(zip(data["param_values"],
                                              data["throughput_mops"])):
            # Failed runs are recorded as 0.0; don't draw them as real points.
            if mops <= 0:
                continue
            point = samples[i] if i < len(samples) else None
            rows.append({"series": name,
                         "x": value * TUPLE_BYTES / (1024 ** 3),
                         "mops": mops,
                         "lo": min(point) if point else float("nan"),
                         "hi": max(point) if point else float("nan")})

    return (pd.DataFrame(rows) if rows else None), names


def main():
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    df, names = load()
    if df is None:
        raise SystemExit("[!] no relation_size data found")

    fig, axes = get_subplots(1, 1)
    ax = axes if not hasattr(axes, "ravel") else axes.ravel()[0]

    for name in names:
        sub = df[df["series"] == name].sort_values("x")
        style = series_style(name, palette)
        draw_band(ax, sub, style)
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                     linewidth=1.6, **style)

    xlabel, ylabel = axis_labels("relation_size")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    # Most series are one socket; the dotted one is the whole machine, so the
    # title says so rather than labelling the figure "single socket" outright.
    ax.set_title("single socket, dotted = all cpus")

    # the sweep doubles each step, so a log2 axis spaces the points evenly
    xs = sorted(set(df["x"]))
    ax.set_xscale("log", base=2)
    ax.set_xticks(xs)
    ax.set_xticklabels([f"{x:g}" for x in xs])
    ax.minorticks_off()
    ax.set_ylim(bottom=0)
    tidy(ax)

    add_legend(fig, palette, names, ncol=3)
    plt.tight_layout(rect=[0, 0, 1, 0.90])
    plt.savefig(OUT_PATH, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {OUT_PATH}")


if __name__ == "__main__":
    main()
