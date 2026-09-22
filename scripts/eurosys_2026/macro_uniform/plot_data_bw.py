#!/usr/bin/env python3
"""Throughput and DRAM bandwidth on one figure, for the uniform sweeps.

Companion to plot_data.py: same data, same style, but each panel carries a
second y axis with the DRAM bandwidth collect_data_intel.py samples with
`perf stat -I` while the run is in flight.

    python3 plot_data_bw.py intel/intel-6548y_uniform.json
    python3 plot_data_bw.py intel/*.json --split
    python3 plot_data_bw.py intel/... --ceiling 350

Reading it: solid + filled marker is throughput (left axis), dashed + open
marker is bandwidth (right axis), and a table keeps its colour across both.
A table that is bandwidth-bound sits on the ceiling line no matter what its
throughput does; one that falls off the line has stopped being limited by
memory and is bound by its own per-op work.

Bandwidth is decimal GB/s -- DRAM CAS count x 64 B / 1e9 -- which is the
convention DDR5 part numbers use. Divide by 1.0737 for GiB/s (a reading of
380 GB/s is 354 GiB/s).
"""

import argparse
import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402

PHASES = [
    ("set", "insertion"),
    ("get", "lookup"),
]

# Measured random-access DRAM ceiling on the 2-socket 6548Y+. Drawn as a
# reference line so it is obvious which tables are saturating it.
DEFAULT_CEILING_GBPS = 350.0

# A read stream and a 1r1w stream do not have the same ceiling, so one line
# across both panels misreads the insertion panel badly. An insert dirties the
# line it touches, so the DRAM carries the fetch (RFO) AND the writeback -- a
# 1:1 read/write mix, which tops out well below a pure read stream because the
# write path is the narrower one (see
# ../collect_scalability/local_interleave_analysis.md sections 1 and 5). The
# same split shows up on the HBM box, measured with machine_stats/bandwidth.c
# on the same cpu/memory pairing (measure_hbm_ceiling.py): 408 GB/s read,
# 606 GB/s for the write mix.
# Measured on the amd-9354p at this workload's own operating point -- 64
# threads, table interleaved over all 4 NPS4 nodes:
CEILINGS_AMD_9354P = {"set": 274.0, "get": 353.0}


# =============================================================================
# DATA
# =============================================================================


def load(path):
    data = json.loads(Path(path).read_text())
    if "tables" not in data:
        raise SystemExit(f"[!] {path}: pre-2026 flat json has no bandwidth")
    if not any(f"{p}_bw_gbps" in e
               for e in data["tables"].values() for p, _ in PHASES):
        raise SystemExit(
            f"[!] {path}: no *_bw_gbps fields -- collected before bandwidth "
            f"sampling existed. Use plot_data.py, or re-collect.")
    return data


def frame(data, phase):
    """Long-form frame for one phase: table / x / mops / lo / hi / bw."""
    rows = []
    for name in order(data):
        entry = data["tables"][name]
        samples = entry.get(f"{phase}_samples") or []
        bw = entry.get(f"{phase}_bw_gbps") or []
        rd = entry.get(f"{phase}_bw_rd_gbps") or []
        wr = entry.get(f"{phase}_bw_wr_gbps") or []
        for i, (fill, mops) in enumerate(zip(entry["fills"],
                                             entry[f"{phase}_mops"])):
            point = samples[i] if i < len(samples) else None
            rows.append({
                "table": name,
                "x": fill,
                "mops": mops,
                "lo": min(point) if point else float("nan"),
                "hi": max(point) if point else float("nan"),
                "bw": bw[i] if i < len(bw) else float("nan"),
                "bw_rd": rd[i] if i < len(rd) else float("nan"),
                "bw_wr": wr[i] if i < len(wr) else float("nan"),
            })
    return pd.DataFrame(rows)


def order(data):
    have = [n for n, e in data["tables"].items() if e.get("fills")]
    listed = [n for n in data.get("plot_order", []) if n in have]
    return listed + ps.order_series(set(have) - set(listed))


# =============================================================================
# PLOTTING
# =============================================================================


def draw(ax, df, tables, title, palette, xticks, ceiling, limits,
         styles, split_rw=False):
    """Throughput on ax, bandwidth on a twinned right-hand axis."""
    bw_ax = ax.twinx()

    for name in tables:
        sub = df[df["table"] == name].sort_values("x")
        if sub.empty:
            continue
        style = styles[name]
        ps.draw_band(ax, sub, style)
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False, **style)

        bw = sub.dropna(subset=["bw"])
        if not bw.empty:
            # Marker fill is what separates the two metrics (filled = left
            # axis, open = right), because linestyle is already carrying the
            # series variant: a "hw pref off" run is dashed on both axes, so
            # dashing the bandwidth line would collide with it.
            bw_ax.plot(bw["x"], bw["bw"], color=style["color"],
                       linestyle=":" if style["linestyle"] != "-" else "--",
                       marker=style["marker"], markersize=4,
                       markerfacecolor="none", linewidth=1.2, zorder=2)
            # The write half of that total, shaded up from zero. On insert it is
            # ~46% of the bar -- every store fetches its line (RFO) and writes it
            # back, so half the traffic buys no new data. On find it is ~0.
            if split_rw:
                # A thin line, not a fill from zero: four tables shaded from
                # zero overlap into one block that hides the throughput lines
                # underneath.
                w = bw.dropna(subset=["bw_wr"])
                if not w.empty and w["bw_wr"].max() > 1.0:
                    bw_ax.plot(w["x"], w["bw_wr"], color=style["color"],
                               linestyle="-", linewidth=0.9, alpha=0.55,
                               zorder=1)

    if ceiling:
        bw_ax.axhline(ceiling, color="0.35", linestyle=(0, (1, 2)),
                      linewidth=1.0, zorder=0)
        bw_ax.annotate(f"{ceiling:.0f} GB/s", xy=(1.0, ceiling),
                       xycoords=("axes fraction", "data"),
                       xytext=(-2, 3), textcoords="offset points",
                       ha="right", va="bottom", fontsize=7, color="0.35")

    xlabel, ylabel = ps.axis_labels("fill")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(xticks)
    ax.set_xlim(min(xticks) - 5, max(xticks) + 5)
    ax.set_ylim(0, limits["mops"])
    ps.tidy(ax)

    bw_ax.set_ylabel("DRAM bandwidth (GB/s)")
    bw_ax.set_ylim(0, limits["bw"])
    # One grid is enough; the twin's would double every dashed line.
    bw_ax.grid(False)


def legend_geometry(n_tables, ncol):
    """Where the metric legend sits, and how much figure the panels get.

    Both have to move down as the series legend grows: at two rows these are
    the 0.90 / 0.82 the figure has always used, and each further row pushes
    them down by its own height. A figure with every table in both prefetcher
    states is three rows, and without this the two legends overlap.
    """
    rows = -(-n_tables // ncol)
    extra = max(0, rows - 2)
    return 0.90 - 0.03 * extra, 0.82 - 0.05 * extra


def metric_legend(fig, y=0.90):
    """Second legend saying which linestyle is which axis."""
    handles = [
        Line2D([0], [0], color="0.25", linestyle="none", marker="o",
               markersize=5, label="filled marker: throughput (left axis)"),
        Line2D([0], [0], color="0.25", linestyle="none", marker="o",
               markersize=5, markerfacecolor="none",
               label="open marker: bandwidth (right axis)"),
    ]
    fig.legend(handles=handles, fontsize=7, loc="upper center",
               bbox_to_anchor=(0.5, y), ncol=2, frameon=False)


def title_for(data, label, note=None):
    gib = data.get("ht_size_gib")
    threads = data.get("num_threads")
    bits = [label]
    if gib:
        bits.append(f"{gib} GiB table")
    if threads:
        bits.append(f"{threads} threads")
    title = ", ".join(bits)
    return f"{title}\n{note}" if note else title


def axis_limits(data, ceilings):
    """Axis tops per phase, from EVERY series in the json.

    Two things are being balanced here. A --only figure is nearly always one
    half of a comparison, so both halves have to share a scale or the eye
    reads the difference off the axes instead of off the data -- hence "every
    series", not just the plotted subset.

    But the scale is per *phase*. Lookup reaches ~5000 Mops and insertion
    ~4000, so one top shared across both squeezes every insertion line into
    the bottom 40% of its panel and the curves that panel exists to show stop
    being legible. Sharing per phase keeps the two figures comparable without
    that cost.
    """
    limits = {}
    for phase, _ in PHASES:
        mops = bw = 0.0
        for entry in data["tables"].values():
            mops = max([mops] + [v for v in entry.get(f"{phase}_mops", [])])
            bw = max([bw] + [v for v in entry.get(f"{phase}_bw_gbps", [])
                             if v is not None])
        top = max([bw] + [c for c in [ceilings.get(phase)] if c])
        limits[phase] = {"mops": mops * 1.08, "bw": top * 1.12}
    return limits


def plot(data, out_stem, split, ceilings, only=None, note=None, split_rw=False):
    ps.configure_style()
    palette = ps.configure_palette()

    limits = axis_limits(data, ceilings)

    tables = order(data)
    if only:
        missing = [n for n in only if n not in data["tables"]]
        if missing:
            raise SystemExit(f"[!] not in {out_stem}: {', '.join(missing)}; "
                             f"have {', '.join(sorted(data['tables']))}")
        tables = [n for n in tables if n in only]
    if not tables:
        print(f"[!] {out_stem}: no table has any points, nothing to plot")
        return

    styles = ps.styles_for(tables, palette)
    xticks = sorted({f for n in tables for f in data["tables"][n]["fills"]})

    if split:
        for phase, label in PHASES:
            fig, ax = ps.get_subplots(1, 1, plot_w=5)
            draw(ax, frame(data, phase), tables,
                 title_for(data, label, note), palette, xticks,
                 ceilings.get(phase), limits[phase], styles, split_rw)
            ncol = min(len(tables), 3)
            metric_y, legend_top = legend_geometry(len(tables), ncol)
            ps.add_legend(fig, palette, tables, ncol=ncol, styles=styles)
            metric_legend(fig, metric_y)
            ps.save(fig, f"{out_stem}_bw_{phase}.png",
                    legend_top=legend_top + 0.02)
        return

    fig, axes = ps.get_subplots(1, len(PHASES), plot_w=5)
    for ax, (phase, label) in zip(axes.ravel(), PHASES):
        draw(ax, frame(data, phase), tables, title_for(data, label, note),
             palette, xticks, ceilings.get(phase), limits[phase], styles,
             split_rw)
    ncol = min(len(tables), 3)
    metric_y, legend_top = legend_geometry(len(tables), ncol)
    ps.add_legend(fig, palette, tables, ncol=ncol, styles=styles)
    metric_legend(fig, metric_y)
    ps.save(fig, f"{out_stem}_bw.png", legend_top=legend_top)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("jsons", nargs="+")
    ap.add_argument("--split", action="store_true",
                    help="one figure per phase instead of a two-panel figure")
    ap.add_argument("--ceiling", type=float, nargs="+",
                    metavar="GBPS",
                    help="reference line, GB/s. One value applies to both "
                         "panels; two are read as <insert> <lookup>, which is "
                         "what you want on a machine where the 1r1w insert "
                         "ceiling differs from the read ceiling. Default: the "
                         "measured amd-9354p pair (274 insert / 353 lookup) "
                         "for that machine, else 350 on both. 0 to omit.")
    ap.add_argument("--only", nargs="+", metavar="TABLE",
                    help="plot only these series (axis scales still come "
                         "from the whole json, so subsets stay comparable)")
    ap.add_argument("--split-rw", action="store_true",
                    help="shade the write half of each bandwidth total "
                         "(needs a json collected after the rd/wr fix)")
    ap.add_argument("--tag", help="appended to the output filename")
    ap.add_argument("--note", help="appended to each panel title")
    args = ap.parse_args()

    for path in args.jsons:
        path = Path(path)
        stem = str(path.with_suffix(""))
        if args.tag:
            stem = f"{stem}_{args.tag}"
        data = load(path)

        if args.ceiling is None:
            ceilings = (dict(CEILINGS_AMD_9354P)
                        if data.get("machine") == "amd-9354p"
                        else {p: DEFAULT_CEILING_GBPS for p, _ in PHASES})
        elif len(args.ceiling) == 1:
            ceilings = {p: args.ceiling[0] for p, _ in PHASES}
        else:
            ceilings = dict(zip([p for p, _ in PHASES], args.ceiling))

        plot(data, stem, args.split, ceilings, args.only, args.note,
             args.split_rw)


if __name__ == "__main__":
    main()
