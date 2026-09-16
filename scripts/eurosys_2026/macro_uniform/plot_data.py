#!/usr/bin/env python3
"""Plot the uniform-workload sweeps collected by collect_data_amd.py.

Style comes from ../paper_style.py, the same module collect_join and
intel_hbm draw with, so these panels sit next to those in the paper. See
../PLOTTING.md.

    python3 plot_data.py amd/amd-9354p_uniform.json      # set + get, one figure
    python3 plot_data.py amd/amd-9354p_uniform.json --split
    python3 plot_data.py amd/*.json

A table whose sweep stops early (dlht runs out of link buckets past 40% fill)
simply has a shorter line; the x axis still spans the whole sweep so the gap
is visible rather than rescaled away.
"""

import argparse
import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402

# The two phases mode 11 times, and what each is called on the page.
PHASES = [
    ("set", "insertion"),
    ("get", "lookup"),
]


# =============================================================================
# DATA
# =============================================================================


def load(path):
    data = json.loads(Path(path).read_text())
    return data if "tables" in data else from_legacy(data, path)


def from_legacy(data, path):
    """Lift a pre-2026 flat json into the current shape.

    amd-r6615.json and intel.json are {name: [{fill, set_mops, get_mops}]},
    written before the collector repeated its points or recorded its config.
    Those points are single runs, so there are no samples and no band; the
    lines still draw, and ps.ALIASES puts dramhit_2025 / dramhit_2023 on the
    colours cas / cas23 have everywhere else.
    """
    tables = {}
    for name, points in data.items():
        tables[ps.canonical(name)] = {
            "display": ps.display_name(name),
            "fills": [p["fill"] for p in points],
            "set_mops": [float(p["set_mops"]) for p in points],
            "get_mops": [float(p["get_mops"]) for p in points],
        }
    htsize = next(
        (p.get("htsize") for points in data.values() for p in points if p.get("htsize")),
        None,
    )
    print(f"[!] {path}: pre-2026 flat json, one run per point -- no band drawn")
    return {
        "machine": Path(path).stem,
        "ht_size": htsize,
        "ht_size_gib": htsize * 16 // (1 << 30) if htsize else None,
        "tables": tables,
    }


def frame(data, phase):
    """Long-form frame for one phase: table / x / mops / lo / hi.

    `mops` is the per-point median and lo/hi the min and max over the repeats,
    which is what the band shows.
    """
    rows = []
    for name in order(data):
        entry = data["tables"][name]
        samples = entry.get(f"{phase}_samples") or []
        for i, (fill, mops) in enumerate(zip(entry["fills"], entry[f"{phase}_mops"])):
            point = samples[i] if i < len(samples) else None
            rows.append({
                "table": name,
                "x": fill,
                "mops": mops,
                "lo": min(point) if point else float("nan"),
                "hi": max(point) if point else float("nan"),
            })
    return pd.DataFrame(rows)


def order(data):
    """Tables that actually have points, in the paper's plotting order."""
    have = [n for n, e in data["tables"].items() if e.get("fills")]
    listed = [n for n in data.get("plot_order", []) if n in have]
    return listed + ps.order_series(set(have) - set(listed))


# =============================================================================
# PLOTTING
# =============================================================================


def draw(ax, df, tables, title, palette, xticks):
    for name in tables:
        sub = df[df["table"] == name].sort_values("x")
        if sub.empty:
            continue
        style = ps.series_style(name, palette)
        ps.draw_band(ax, sub, style)
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False, **style)

    xlabel, ylabel = ps.axis_labels("fill")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(xticks)
    ax.set_xlim(min(xticks) - 5, max(xticks) + 5)
    ax.set_ylim(bottom=0)
    ps.tidy(ax)


def title_for(data, label):
    gib = data.get("ht_size_gib")
    threads = data.get("num_threads")
    bits = [label]
    if gib:
        bits.append(f"{gib} GiB table")
    if threads:
        bits.append(f"{threads} threads")
    return ", ".join(bits)


def plot(data, out_stem, split):
    ps.configure_style()
    palette = ps.configure_palette()

    tables = order(data)
    if not tables:
        print(f"[!] {out_stem}: no table has any points, nothing to plot")
        return

    xticks = sorted({f for n in tables for f in data["tables"][n]["fills"]})

    if split:
        for phase, label in PHASES:
            fig, ax = ps.get_subplots(1, 1)
            draw(ax, frame(data, phase), tables, title_for(data, label),
                 palette, xticks)
            ps.add_legend(fig, palette, tables)
            ps.save(fig, f"{out_stem}_{phase}.png", legend_top=0.94)
        return

    fig, axes = ps.get_subplots(1, len(PHASES))
    for ax, (phase, label) in zip(axes.ravel(), PHASES):
        draw(ax, frame(data, phase), tables, title_for(data, label),
             palette, xticks)
    ps.add_legend(fig, palette, tables)
    ps.save(fig, f"{out_stem}.png", legend_top=0.9)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("jsons", nargs="+", help="collect_data_amd.py output json(s)")
    ap.add_argument("--split", action="store_true",
                    help="one figure per phase instead of a two-panel figure")
    args = ap.parse_args()

    for path in args.jsons:
        path = Path(path)
        data = load(path)
        plot(data, str(path.with_suffix("")), args.split)


if __name__ == "__main__":
    main()
