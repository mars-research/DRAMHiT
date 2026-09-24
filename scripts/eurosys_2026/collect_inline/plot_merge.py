#!/usr/bin/env python3
"""Lookup throughput vs fill factor for each inlining variant, one panel per
machine.

Style comes from ../paper_style.py so these panels sit next to the rest of the
paper. See ../PLOTTING.md.

    python plot_merge.py intel-paper.json ../intel_hbm/inline-hbm.json amd-r6615.json test.pdf

The series here are build variants of one hashtable, not hashtables, so they
have no slot in ps.PALETTE_ORDER. Per PLOTTING.md they get their own palette,
built once at the size of INLINE_ORDER so a variant keeps the same colour in
every panel and every figure drawn from this script.
"""

import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))  # eurosys_2026/
import paper_style as ps  # noqa: E402

# Palette order for the inlining variants: no inlining first, both kinds last
# (darkest). Append new variants; reordering recolours every existing figure.
INLINE_ORDER = ["Base", "Compiler Inline", "Manual Inline", "Manual+Compiler Inline"]

# Which run to plot on each machine. Intel DDR uses the dual-socket (policy 1,
# 128 thread) sweep; intel-paper.json also carries a single-socket (policy 4,
# 64 thread) sweep with the same points. HBM and AMD are 64 threads.
NUMA_POLICY = {"Intel DDR": 1, "Intel HBM": 10, "AMD DDR": 1}

TUPLE_BYTES = ps.TUPLE_BYTES


# =============================================================================
# DATA
# =============================================================================


def machine_label(path, df):
    """Panel name from the perf counters the collector recorded."""
    if "uops_dispatched.port_2_3_10" in df.columns:
        return "Intel HBM" if "hbm" in str(path).lower() else "Intel DDR"
    if "ls_dispatch.ld_dispatch" in df.columns:
        return "AMD DDR"
    return Path(path).stem


def load(path):
    """Long-form frame for one machine: variant / x / mops / lo / hi.

    `mops` is the per-point median and lo/hi the min and max over repeats.
    These collections ran each point once, so lo == hi and ps.draw_band()
    draws nothing; it will once the collector repeats its points.
    """
    df = pd.json_normalize(json.loads(Path(path).read_text()), sep=".")
    label = machine_label(path, df)

    policy = NUMA_POLICY.get(label)
    if policy is not None and "run_cfg.numa_policy" in df.columns:
        df = df[df["run_cfg.numa_policy"] == policy]

    df = df.copy()
    df["variant"] = df["identifier"]
    df["x"] = pd.to_numeric(df["run_cfg.fill_factor"])

    points = (
        df.groupby(["variant", "x"])["get_mops"]
        .agg(mops="median", lo="min", hi="max")
        .reset_index()
    )
    meta = {
        "label": label,
        "num_threads": int(df["run_cfg.numThreads"].iloc[0]) if not df.empty else None,
        "ht_size_gib": (int(df["run_cfg.size"].iloc[0]) * TUPLE_BYTES >> 30)
        if not df.empty else None,
    }
    return points, meta


def title_for(meta):
    bits = [meta["label"]]
    if meta["ht_size_gib"]:
        bits.append(f"{meta['ht_size_gib']} GiB table")
    if meta["num_threads"]:
        bits.append(f"{meta['num_threads']} threads")
    return ", ".join(bits)


def order(names):
    """Inlining variants in INLINE_ORDER; anything unknown goes last."""
    known = [n for n in INLINE_ORDER if n in names]
    return known + sorted(set(names) - set(INLINE_ORDER))


# =============================================================================
# PLOTTING
# =============================================================================


def plot(json_files, output_file):
    ps.configure_style()

    machines = [load(f) for f in json_files]
    for points, meta in machines:
        if points.empty:
            print(f"[!] {meta['label']}: no points after filtering, panel left empty")

    names = order({n for points, _ in machines for n in points["variant"]})
    extra = [n for n in names if n not in INLINE_ORDER]
    palette = ps.configure_palette(n=len(INLINE_ORDER) + len(extra))
    styles = {
        name: {"color": palette[(INLINE_ORDER + extra).index(name)],
               "linestyle": "-", "marker": "o"}
        for name in names
    }

    xticks = sorted({x for points, _ in machines for x in points["x"]})
    top = max((points["hi"].max() for points, _ in machines if not points.empty),
              default=1)
    xlabel, ylabel = ps.axis_labels("fill")

    fig, axes = ps.get_subplots(1, len(machines))
    axes = [axes] if len(machines) == 1 else list(axes.ravel())

    for i, (ax, (points, meta)) in enumerate(zip(axes, machines)):
        for name in order(set(points["variant"])):
            sub = points[points["variant"] == name].sort_values("x")
            ps.draw_band(ax, sub, styles[name])
            sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                         **styles[name])

        ax.set_title(title_for(meta))
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel if i == 0 else "")
        ax.set_xticks(xticks)
        ax.set_xlim(min(xticks) - 5, max(xticks) + 5)
        # Same y range on every panel so machines compare by eye.
        ax.set_ylim(0, top)
        ps.tidy(ax)

    ps.add_legend(fig, palette, names, styles=styles)
    ps.save(fig, output_file, legend_top=0.94)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python plot_merge.py <file1.json> [file2.json ...] <output.pdf>")
        sys.exit(1)
    plot(sys.argv[1:-1], sys.argv[-1])
