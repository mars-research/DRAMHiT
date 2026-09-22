#!/usr/bin/env python3
"""Figures for amd_local_interleave.json.

Two figures, because the two sweeps have different x axes and putting them on one would
imply a comparison at equal x that does not exist (local's x is threads *per node*,
interleave's is threads *total*).

amd_local_scaling.png -- the local sweep: all 4 NUMA nodes loaded with the same thread
count each, memory node-local, 1..16 threads/node (4..64 total). Read and write, each
against a dashed **linear scaling line** through its own 1-thread-per-node point: what
the machine would deliver if every added core kept buying the same slice. Where the
measured curve leaves that line is the answer to "does a core buy a fixed slice".

amd_interleave_scaling.png -- the interleave sweep: 1..64 threads round-robinned over
the 4 nodes with memory MPOL_INTERLEAVEd across all 4, so no thread is mostly local.
Same two modes, same linear reference through the 1-thread point, plus the local curve
replotted against total threads so the cost of giving up locality is visible directly.

Both plot **controller-side traffic** (rd+wr at the amd_umc boxes). For reads that is
essentially all rd. For writes it is ~2x what the program stores, because a store miss
fetches the line (RFO) and writes it back later -- that is the traffic the DRAM has to
carry, and so the thing a bandwidth ceiling actually caps. The program's own store rate
is in the json as prog_bw_gbs for anyone who wants the other convention.
"""

import json
import os
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import paper_style as ps  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
JSON_PATH = os.path.join(HERE, "amd_local_interleave.json")
LOCAL_PNG = os.path.join(HERE, "amd_local_scaling.png")
INTERLEAVE_PNG = os.path.join(HERE, "amd_interleave_scaling.png")

LOCAL_SERIES = ["local_read", "local_write"]
INTERLEAVE_SERIES = ["interleave_read", "interleave_write"]

LABELS = {
    "local_read": "local, read (prefetchT1)",
    "local_write": "local, write (store; rd+wr traffic)",
    "interleave_read": "interleaved, read (prefetchT1)",
    "interleave_write": "interleaved, write (store; rd+wr traffic)",
    "local_read_total": "local, read (for reference)",
    "local_write_total": "local, write (for reference)",
}
MARKERS = {"local_read": "o", "local_write": "s",
           "interleave_read": "o", "interleave_write": "s"}

PHYS_CORES_PER_NODE = 8
# Each NPS4 node is 2 CCDs of 4 cores (L3 sharing: cpus 0-3,32-35 = CCD0; 4-7,36-39 =
# CCD1; and so on for all 8 CCDs). bandwidth.c fills a node's cpus in ascending order,
# so threads 1-4 per node land entirely on that node's FIRST CCD and the second one
# does not carry a single beat until thread 5. Verified with
# amd_df/local_socket_inf0_inbound_data_beats_ccm<N>: at 4 threads/node only ccm0-ccm3
# move (3.39e9 beats each, ccm4-7 at ~1e5, i.e. idle); at 8 threads/node all eight do.
CORES_PER_CCD = 4


def load():
    with open(JSON_PATH) as f:
        data = json.load(f)
    rows = []
    for name, row in data.items():
        if name == "config":
            continue
        for point in row["points"].values():
            gbs = point.get("umc_all_gbs")
            if gbs is None:
                continue
            rows.append({
                "series": name,
                "x": point["x"],
                "threads": point["threads"],
                "gbs": gbs,
                "rd": point.get("umc_rd_gbs"),
                "wr": point.get("umc_wr_gbs"),
                "prog_gbs": point.get("prog_bw_gbs"),
                "per_thread": gbs / point["threads"],
            })
    return data, pd.DataFrame(rows).sort_values(["series", "x"])


def linear_line(ax, sub, xcol, color):
    """Dashed line through the origin and this curve's first point: a fixed slice per
    thread, extrapolated. Drawn only over the measured x range."""
    first = sub.iloc[0]
    slope = first.gbs / first[xcol]
    xs = sub[xcol]
    ax.plot(xs, xs * slope, color=color, linestyle="--", linewidth=1, zorder=1)
    return slope


def panel(ax, df, series, xcol, styles, annotate_linear=True):
    slopes = {}
    for name in series:
        sub = df[df.series == name].sort_values(xcol)
        if sub.empty:
            continue
        sns.lineplot(data=sub, x=xcol, y="gbs", ax=ax, legend=False, markersize=4,
                     **styles[name])
        if annotate_linear:
            slopes[name] = linear_line(ax, sub, xcol, styles[name]["color"])
    return slopes


def make_local_figure(data, df, styles):
    fig, axes = ps.get_subplots(1, 2, plot_w=5.0, plot_h=4.0)
    ax_bw, ax_per = axes

    slopes = panel(ax_bw, df, LOCAL_SERIES, "x", styles)

    for name in LOCAL_SERIES:
        sub = df[df.series == name].sort_values("x")
        if sub.empty:
            continue
        sns.lineplot(data=sub, x="x", y="per_thread", ax=ax_per, legend=False,
                     markersize=4, **styles[name])
        if name in slopes:
            # per-thread view of the same linear reference: a horizontal line at the
            # 1-thread-per-node slice, divided by the 4 threads that point runs.
            ax_per.axhline(slopes[name] / 4, color=styles[name]["color"],
                           linestyle="--", linewidth=1)

    for ax in (ax_bw, ax_per):
        ax.axvspan(PHYS_CORES_PER_NODE + 0.5, 17, color="0.5", alpha=0.10,
                   linewidth=0, zorder=0)
        ax.axvline(PHYS_CORES_PER_NODE + 0.5, color="0.45", linestyle="-.",
                   linewidth=1.1, zorder=1)
        ax.axvline(CORES_PER_CCD + 0.5, color="0.25", linestyle=(0, (3, 2)),
                   linewidth=1.1, zorder=1)
        ax.set_xlabel("threads per node (all 4 nodes loaded; total = 4x)")
        ax.set_xlim(0, 17)
        ax.set_ylim(bottom=0)
        ax.set_xticks([1, 2, 4, 6, 8, 10, 12, 14, 16])
        ps.tidy(ax)

    # The linear reference reaches 1.6 TB/s by 16 threads/node and would squash every
    # measured point into the bottom fifth of the panel. Scale to the data and let the
    # dashed lines run off the top -- the gap is the finding, not the ideal's altitude.
    measured_top = df[df.series.isin(LOCAL_SERIES)].gbs.max()
    ax_bw.set_ylim(0, measured_top * 1.15)

    top = ax_bw.get_ylim()[1]
    ax_bw.annotate("8 phys. cores/node\nSMT beyond", xy=(PHYS_CORES_PER_NODE + 0.7, top * 0.30),
                   xytext=(4, 0), textcoords="offset points", ha="left", va="center",
                   fontsize=7, color="0.35")
    ax_bw.annotate("2nd CCD of each node\nfirst used here", xy=(CORES_PER_CCD + 0.7, top * 0.62),
                   xytext=(2, 0), textcoords="offset points", ha="left", va="center",
                   fontsize=7, color="0.25")
    ax_bw.annotate("linear scaling (dashed,\nruns off the top)", xy=(0.6, top * 0.97),
                   ha="left", va="top", fontsize=7, color="0.35")
    ax_bw.annotate("1 CCD/node: capped by the\nCCD's own fabric link, not DRAM",
                   xy=(3.5, 199), xytext=(5.6, 95), ha="left", va="center", fontsize=7,
                   color="0.25",
                   arrowprops=dict(arrowstyle="-", linewidth=0.7, color="0.45",
                                   shrinkA=0, shrinkB=3))

    ax_bw.set_ylabel("DRAM traffic at the controllers (GB/s)")
    ax_per.set_ylabel("GB/s per thread")

    ps.add_legend(fig, [styles[n]["color"] for n in LOCAL_SERIES], LOCAL_SERIES,
                  styles={n: dict(styles[n]) for n in LOCAL_SERIES}, ncol=2)
    legend = fig.legends[-1]
    for text, name in zip(legend.get_texts(), LOCAL_SERIES):
        text.set_text(LABELS[name])
    ps.save(fig, LOCAL_PNG, legend_top=0.86)


def make_interleave_figure(data, df, styles):
    fig, axes = ps.get_subplots(1, 2, plot_w=5.0, plot_h=4.0)
    ax_bw, ax_cmp = axes

    panel(ax_bw, df, INTERLEAVE_SERIES, "threads", styles)

    # Right panel: interleaved vs local at equal TOTAL thread count -- the price of
    # giving up locality on the same 12 channels.
    for name in INTERLEAVE_SERIES:
        sub = df[df.series == name].sort_values("threads")
        if not sub.empty:
            sns.lineplot(data=sub, x="threads", y="gbs", ax=ax_cmp, legend=False,
                         markersize=4, **styles[name])
    for name in LOCAL_SERIES:
        sub = df[df.series == name].sort_values("threads")
        if sub.empty:
            continue
        style = dict(styles[name])
        style["linestyle"] = ":"
        style["marker"] = None
        sns.lineplot(data=sub, x="threads", y="gbs", ax=ax_cmp, legend=False, **style)

    for ax in (ax_bw, ax_cmp):
        ax.axvspan(32.5, 66, color="0.5", alpha=0.10, linewidth=0, zorder=0)
        ax.axvline(32.5, color="0.45", linestyle="-.", linewidth=1.1, zorder=1)
        # 4 threads/node = 16 total is the last point served by one CCD per node.
        ax.axvline(CORES_PER_CCD * 4 + 0.5, color="0.25", linestyle=(0, (3, 2)),
                   linewidth=1.1, zorder=1)
        ax.set_xlabel("total threads (round-robin over the 4 nodes)")
        ax.set_xlim(0, 66)
        ax.set_ylim(bottom=0)
        ax.set_xticks([1, 8, 16, 24, 32, 40, 48, 56, 64])
        ps.tidy(ax)

    # Same reason as the local figure: scale to the data, let the ideal run off the top.
    measured_top = df[df.series.isin(INTERLEAVE_SERIES)].gbs.max()
    ax_bw.set_ylim(0, measured_top * 1.15)

    top = ax_bw.get_ylim()[1]
    ax_bw.annotate("32 phys. cores\nSMT beyond", xy=(33.5, top * 0.30), xytext=(4, 0),
                   textcoords="offset points", ha="left", va="center", fontsize=7,
                   color="0.35")
    ax_bw.annotate("2nd CCD/node\nfirst used here", xy=(CORES_PER_CCD * 4 + 1, top * 0.62),
                   xytext=(2, 0), textcoords="offset points", ha="left", va="center",
                   fontsize=7, color="0.25")
    ax_bw.annotate("linear scaling (dashed,\nruns off the top)", xy=(1.5, top * 0.97),
                   ha="left", va="top", fontsize=7, color="0.35")
    ax_cmp.annotate("dotted = node-local,\nsame total threads",
                    xy=(34, ax_cmp.get_ylim()[1] * 0.22),
                    ha="left", va="center", fontsize=7, color="0.35")

    ax_bw.set_ylabel("DRAM traffic at the controllers (GB/s)")
    ax_cmp.set_ylabel("DRAM traffic at the controllers (GB/s)")

    ps.add_legend(fig, [styles[n]["color"] for n in INTERLEAVE_SERIES], INTERLEAVE_SERIES,
                  styles={n: dict(styles[n]) for n in INTERLEAVE_SERIES}, ncol=2)
    legend = fig.legends[-1]
    for text, name in zip(legend.get_texts(), INTERLEAVE_SERIES):
        text.set_text(LABELS[name])
    ps.save(fig, INTERLEAVE_PNG, legend_top=0.86)


def main():
    data, df = load()
    if df.empty:
        sys.exit("no points in {}".format(JSON_PATH))

    ps.configure_style()
    palette = ps.configure_palette(n=2)
    # read and write keep the same colour across both figures: the pair being compared
    # is always (read, write), and local vs interleaved is carried by the figure.
    styles = {}
    for group in (LOCAL_SERIES, INTERLEAVE_SERIES):
        for i, name in enumerate(group):
            styles[name] = {"color": palette[i], "linestyle": "-", "marker": MARKERS[name]}

    if not df[df.series.isin(LOCAL_SERIES)].empty:
        make_local_figure(data, df, styles)
    if not df[df.series.isin(INTERLEAVE_SERIES)].empty:
        make_interleave_figure(data, df, styles)

    for name in ["local_read", "local_write", "interleave_read", "interleave_write"]:
        sub = df[df.series == name].sort_values("threads")
        if sub.empty:
            continue
        first, peak = sub.iloc[0], sub.loc[sub.gbs.idxmax()]
        slice_gbs = first.gbs / first.threads
        ideal = slice_gbs * 64
        print("{:18} 1st point {:5.1f} GB/s @ {:2.0f} thr ({:5.2f}/thr) | peak {:6.1f} @ "
              "{:2.0f} thr | 64-thr ideal {:6.1f} -> {:4.1f}% of linear".format(
                  name, first.gbs, first.threads, slice_gbs, peak.gbs, peak.threads,
                  ideal, 100 * sub[sub.threads == sub.threads.max()].gbs.iloc[0] / ideal))


if __name__ == "__main__":
    main()
