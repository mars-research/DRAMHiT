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
# (json file, series name). The series name picks the colour: the first five
# are the joins themselves, the last is radix again on the whole machine.
#
# Each join is drawn in the hardware-prefetcher state it actually wants, which
# is not the same state for all of them and is the point of the figure:
#
#   hashtables  prefetcher OFF. Measured on this machine, dlht and folklore
#               gain 16-26% from it and cas/cas23 are within a few percent
#               either way; all four are collected at MSR 0x1a4 = 0x2f, which
#               is every prefetcher this part lets us disable (0xf, what
#               prefetch_control.sh writes, leaves bit 5 running).
#   radix       prefetcher ON. It is the one join that loses without it --
#               22-41% on this sweep -- because it issues no software
#               prefetches and its partition pass streams.
#
# See readme.txt for both measurements.
CONFIGS = [
    ("intel_hbm_single_hash_cas_relation_size_pf_off.json", "cas"),
    ("intel_hbm_single_hash_cas23_relation_size_pf_off.json", "cas23"),
    ("intel_hbm_single_hash_dlht_relation_size_pf_off.json", "dlht"),
    ("intel_hbm_single_hash_folklore_relation_size_pf_off.json", "folklore"),
    ("intel_hbm_single_radix_relation_size_uniform_pf_on.json", "radix"),
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
    ax.set_title("single socket, dotted = all cpus\n"
                 "hashtables: hw prefetcher off; radix: hw prefetcher on")

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
