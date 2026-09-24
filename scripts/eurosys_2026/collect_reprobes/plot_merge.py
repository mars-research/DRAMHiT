#!/usr/bin/env python3
"""Lookup throughput vs fill factor for each probing variant, one panel per
machine, after a single reprobe-factor panel.

Style comes from ../paper_style.py so these panels sit next to the rest of the
paper. See ../PLOTTING.md.

    python plot_merge.py intel-paper.json intel-hbm.json amd-r6615.json test.pdf

The series here are probing variants of one table, not hashtables, so they
have no slot in ps.PALETTE_ORDER. Per PLOTTING.md they get their own palette,
built once at the size of PROBE_ORDER so a variant keeps the same colour in
every panel and every figure drawn from this script.

The reprobe factor depends only on the table layout and the key stream (the
collectors use a fixed seed), not on the machine: it is identical across the
three collections. So it is drawn once, from the first file that has each
variant, rather than once per machine.
"""

import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))  # eurosys_2026/
import paper_style as ps  # noqa: E402

# Palette order for the probing variants: plain linear probing first, the full
# scheme the paper uses last (darkest). Append new variants; reordering
# recolours every existing figure.
PROBE_ORDER = [
    "linear",
    "linear+uniform",
    "linear+bucket",
    "linear+bucket+simd",
    "linear+bucket+simd+uniform",
]

# linear+bucket and linear+bucket+simd probe exactly the same slots, so their
# reprobe curves coincide. The simd one is dashed and drawn on top so both
# stay visible on the reprobe panel.
REPROBE_LINESTYLE = {"linear+bucket+simd": "--"}

# Which sweep to draw on each machine. intel-paper.json carries both a
# single-socket (policy 4, 64 thread) and a dual-socket (policy 1, 128 thread)
# sweep with the same points; Intel DDR uses the 128-thread dual-socket sweep,
# as in ../collect_prefetches and ../collect_inline. HBM and AMD are
# single-socket, 64 threads.
NUMA_POLICY = {"Intel DDR": 1, "Intel HBM": 10, "AMD DDR": 1}

TUPLE_BYTES = ps.TUPLE_BYTES


# =============================================================================
# DATA
# =============================================================================


def machine_label(path, df):
    """Panel name from the CPU frequency the collector pinned."""
    mhz = str(df["build_cfg.CPUFREQ_MHZ"].iloc[0]) if not df.empty else ""
    return {"2500": "Intel DDR", "2700": "Intel HBM", "3250": "AMD DDR"}.get(
        mhz, Path(path).stem)


def variant_name(bcfg):
    """build_cfg -> the variant name used for colour lookup and the legend."""
    name = "linear"
    if bcfg["BUCKETIZATION"] == "ON":
        name += "+bucket"
    if bcfg["BRANCH"] == "simd":
        name += "+simd"
    if bcfg["UNIFORM_PROBING"] == "ON":
        name += "+uniform"
    return name


def load(path):
    """Long-form frame for one machine: variant / x / mops / lo / hi / reprobe.

    `mops` is the per-point median and lo/hi the min and max over repeats.
    These collections ran each point once, so lo == hi and ps.draw_band()
    draws nothing; it will once the collector repeats its points.
    """
    data = json.loads(Path(path).read_text())
    df = pd.json_normalize(data, sep=".")
    label = machine_label(path, df)

    policy = NUMA_POLICY.get(label)
    if policy is not None:
        df = df[df["run_cfg.numa_policy"] == policy].copy()

    df["variant"] = [variant_name(r["build_cfg"]) for r in data
                     if policy is None or r["run_cfg"]["numa_policy"] == policy]
    df["x"] = pd.to_numeric(df["run_cfg.fill_factor"])

    points = (
        df.groupby(["variant", "x"])
        .agg(mops=("get_mops", "median"), lo=("get_mops", "min"),
             hi=("get_mops", "max"), reprobe=("reprobe_factor", "median"))
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
    """Variants in PROBE_ORDER; anything unknown goes last."""
    known = [n for n in PROBE_ORDER if n in names]
    return known + sorted(set(names) - set(PROBE_ORDER))


def reprobe_points(machines):
    """One reprobe curve per variant, from the first machine that ran it."""
    seen, parts = set(), []
    for points, _ in machines:
        for name in order(set(points["variant"]) - seen):
            parts.append(points[points["variant"] == name])
            seen.add(name)
    return pd.concat(parts) if parts else pd.DataFrame(columns=["variant", "x", "reprobe"])


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
    extra = [n for n in names if n not in PROBE_ORDER]
    palette = ps.configure_palette(n=len(PROBE_ORDER) + len(extra))
    styles = {
        name: {"color": palette[(PROBE_ORDER + extra).index(name)],
               "linestyle": "-", "marker": "o"}
        for name in names
    }

    xticks = sorted({x for points, _ in machines for x in points["x"]})
    top = max((points["hi"].max() for points, _ in machines if not points.empty),
              default=1)
    xlabel, ylabel = ps.axis_labels("fill")

    fig, axes = ps.get_subplots(1, len(machines) + 1)
    axes = list(axes.ravel())

    def frame(ax):
        ax.set_xlabel(xlabel)
        ax.set_xticks(xticks)
        ax.set_xlim(min(xticks) - 5, max(xticks) + 5)

    for i, (ax, (points, meta)) in enumerate(zip(axes[1:], machines)):
        for name in order(set(points["variant"])):
            sub = points[points["variant"] == name].sort_values("x")
            ps.draw_band(ax, sub, styles[name])
            sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                         **styles[name])

        ax.set_title(title_for(meta))
        ax.set_ylabel(ylabel if i == 0 else "")
        frame(ax)
        # Same y range on every panel so machines compare by eye.
        ax.set_ylim(0, top)
        ps.tidy(ax)

    ax = axes[0]
    reprobes = reprobe_points(machines)
    for name in order(set(reprobes["variant"])):
        sub = reprobes[reprobes["variant"] == name].sort_values("x")
        style = {**styles[name],
                 "linestyle": REPROBE_LINESTYLE.get(name, styles[name]["linestyle"])}
        sns.lineplot(data=sub, x="x", y="reprobe", ax=ax, legend=False, **style)
    ax.set_title("Reprobe factor, all machines")
    ax.set_ylabel("reprobe factor (1 = no reprobes)")
    frame(ax)
    # 1.0 is a lookup that hits on its first probe -- the floor of the scale.
    ax.set_ylim(bottom=1)
    ps.tidy(ax)

    ps.add_legend(fig, palette, names, styles=styles)
    ps.save(fig, output_file, legend_top=0.94)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python plot_merge.py <file1.json> [file2.json ...] <output.pdf>")
        sys.exit(1)
    plot(sys.argv[1:-1], sys.argv[-1])
