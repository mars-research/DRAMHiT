#!/usr/bin/env python3
"""Lookup throughput vs fill factor for each software-prefetch flavour, one
panel per machine.

Style comes from ../paper_style.py so these panels sit next to the rest of the
paper. See ../PLOTTING.md.

    python plot_merge.py intel.json ../intel_hbm/prefetches_hbm.json amd-r6615.json test.pdf

The series here are prefetch instructions, not hashtables, so they have no
slot in ps.PALETTE_ORDER. Per PLOTTING.md they get their own palette, built
once at the size of PREFETCH_ORDER so a flavour keeps the same colour in
every panel and every figure drawn from this script.
"""

import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))  # eurosys_2026/
import paper_style as ps  # noqa: E402

# Palette order for the prefetch flavours: nearest cache level first, the
# DOUBLE scheme the paper uses last (darkest). Append new flavours; reordering
# recolours every existing figure.
PREFETCH_ORDER = ["L1", "L2", "L3", "NTA", "DOUBLE"]

# The single-socket run on each machine, so every panel compares 64 threads on
# one node. intel.json also carries a dual-socket (policy 1, 128 thread) sweep
# with the same number of points; picking by mode() would tie and draw that.
NUMA_POLICY = {"Intel DDR": 4, "Intel HBM": 10, "AMD DDR": 1}

TUPLE_BYTES = ps.TUPLE_BYTES


# =============================================================================
# DATA
# =============================================================================


def machine_label(path, df):
    """Panel name from the perf counters the collector recorded."""
    if "cycle_activity.stalls_total" in df.columns:
        return "Intel HBM" if "hbm" in str(path).lower() else "Intel DDR"
    if "ls_mab_alloc.all_allocations" in df.columns:
        return "AMD DDR"
    return Path(path).stem


def load(path):
    """Long-form frame for one machine: prefetch / x / mops / lo / hi.

    `mops` is the per-point median and lo/hi the min and max over repeats.
    These collections ran each point once, so lo == hi and ps.draw_band()
    draws nothing; it will once the collector repeats its points.
    """
    df = pd.json_normalize(json.loads(Path(path).read_text()), sep=".")
    label = machine_label(path, df)

    policy = NUMA_POLICY.get(label)
    if policy is not None and "run_cfg.numa_policy" in df.columns:
        df = df[df["run_cfg.numa_policy"] == policy]

    # NONE is a no-prefetch baseline only the HBM collection has.
    df = df[df["identifier"] != "NONE"].copy()
    df["prefetch"] = df["identifier"].str.split("-").str[0]
    df["x"] = pd.to_numeric(df["run_cfg.fill_factor"])

    points = (
        df.groupby(["prefetch", "x"])["get_mops"]
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
    """Prefetch flavours in PREFETCH_ORDER; anything unknown goes last."""
    known = [n for n in PREFETCH_ORDER if n in names]
    return known + sorted(set(names) - set(PREFETCH_ORDER))


# =============================================================================
# PLOTTING
# =============================================================================


def plot(json_files, output_file):
    ps.configure_style()

    machines = [load(f) for f in json_files]
    for points, meta in machines:
        if points.empty:
            print(f"[!] {meta['label']}: no points after filtering, panel left empty")

    names = order({n for points, _ in machines for n in points["prefetch"]})
    extra = [n for n in names if n not in PREFETCH_ORDER]
    palette = ps.configure_palette(n=len(PREFETCH_ORDER) + len(extra))
    styles = {
        name: {"color": palette[(PREFETCH_ORDER + extra).index(name)],
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
        for name in order(set(points["prefetch"])):
            sub = points[points["prefetch"] == name].sort_values("x")
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
