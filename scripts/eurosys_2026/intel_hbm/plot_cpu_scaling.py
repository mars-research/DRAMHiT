#!/usr/bin/env python3
"""Figure for intel_hbm_cpu_scaling.json: bandwidth vs core count on one socket.

Three panels, because "does a core buy a fixed slice of bandwidth?" is really
three questions:

  1. aggregate GB/s at the memory controllers, against the line a fixed
     per-core slice would draw (the 1-thread rate, extrapolated);
  2. the same data per thread -- flat means fixed slice, falling means the
     cores are sharing something;
  3. the marginal GB/s the *next* thread adds, which is the question stated
     literally. A fixed slice is a horizontal line here; a shared bottleneck
     decays to zero.

Two measurement choices this figure makes, both forced by the data:

**Peak interval, not run median.** From 33 to 63 threads the placement is
unbalanced -- at 33, one core runs two threads while 31 run one. bandwidth.c
gives every thread the same fixed work, so the paired threads take ~2x as long
and the machine sits nearly idle while they straggle. That drags the run median
down hard (353.6 -> 324.5 GB/s from 32 to 33 threads) while the peak interval,
which samples the machine while every thread is still running, keeps rising
(368.6 -> 369.2). The median is only trustworthy at the balanced points (1-32,
all one thread per core, and 64, all two). The peak is comparable everywhere,
and at the balanced points it sits a uniform ~4% above the median. So the line
is the peak and the band below it is the median -- the band's width is the
straggler artifact, and it is worth seeing.

**No latency panel.** bandwidth.c's cycles/access is elapsed_cycles divided by
that thread's own access count, i.e. algebraically the reciprocal of its
throughput (64 B x 2.7 GHz / cpa reproduces the per-thread GB/s). It is not an
independent latency measurement and cannot be used as evidence of queueing;
it stays in the json and the table but not on a panel that would imply
otherwise. Real loaded-latency and queue-occupancy evidence for this machine is
in machine_spec_analysis.md section 4b.

ddr_read is on the same axes as a control: same cores, same mesh, a different
memory system behind it.
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
JSON_PATH = os.path.join(HERE, "intel_hbm_cpu_scaling.json")
OUT_PATH = os.path.join(HERE, "intel_hbm_cpu_scaling.png")

SERIES_ORDER = ["hbm_read", "hbm_write", "ddr_read"]

# The write series is plotted as the traffic the controllers actually see. A
# store misses, so the line is fetched (RFO) and later written back: the DRAM
# moves about twice what the program stores. That is the point -- the same
# cores are driving read and write traffic at once, and the total goes far
# above where reads alone stop.
LABELS = {
    "hbm_read": "HBM read (n0 $\\rightarrow$ n2)",
    "hbm_write": "HBM write, rd+wr traffic",
    "ddr_read": "DDR read (n0 $\\rightarrow$ n0)",
}
MARKERS = {"hbm_read": "o", "hbm_write": "s", "ddr_read": "^"}
LINESTYLES = {"hbm_read": "-", "hbm_write": "-", "ddr_read": ":"}

# Where the second thread per core starts, verified rather than assumed.
# bandwidth.c pins thread t to the t-th cpu of the node in ascending cpu order,
# and node 0 enumerates as 0,2,...,62 then 64,66,...,126. Those first 32 are 32
# distinct thread_siblings groups; cpu 64 -- thread 33 -- is the sibling of
# cpu 0, confirmed against the pinning lines in the 64-thread run log.
PHYSICAL_CORES = 32
SMT_START = 33

# 33, 34 and 36 were collected afterwards as a dense probe of the SMT boundary.
# They belong on the first two panels, but not in the marginal one: a marginal
# is a difference divided by the thread gap, and over a 1-thread gap the
# counters' own few-percent jitter becomes tens of GB/s (the write series' peak
# dips at 33 and recovers at 34, which alone reads as -52 then +53 GB/s per
# thread). The marginal is therefore taken on the original grid, whose steps
# are 4 threads or more past t=8.
DENSE_PROBE = {33, 34, 36}


def load():
    with open(JSON_PATH) as f:
        data = json.load(f)

    rows = []
    for name in SERIES_ORDER:
        if name not in data:
            continue
        for point in data[name]["points"].values():
            peak = point.get("mem_all_peak_gbs")
            if peak is None:
                continue
            rows.append({
                "series": name,
                "threads": point["threads"],
                "gbs": peak,
                "median_gbs": point.get("mem_all_gbs"),
                "per_thread": peak / point["threads"],
                "cycles_per_access": point.get("cycles_per_access"),
                "prog_gbs": point.get("prog_bw_gbs"),
            })
    df = pd.DataFrame(rows).sort_values(["series", "threads"])

    # Marginal GB/s the next thread adds, over the gap to the previous point,
    # taken on the original grid only (see DENSE_PROBE).
    coarse = df[~df.threads.isin(DENSE_PROBE)].copy()
    coarse["marginal"] = (coarse.groupby("series")["gbs"].diff()
                          / coarse.groupby("series")["threads"].diff())
    # The first point's "marginal" is the whole of it: one thread, from zero.
    first = coarse.groupby("series")["threads"].transform("min") == coarse.threads
    coarse.loc[first, "marginal"] = (coarse.loc[first, "gbs"]
                                     / coarse.loc[first, "threads"])
    df = df.merge(coarse[["series", "threads", "marginal"]],
                  on=["series", "threads"], how="left")
    return data, df


def main():
    data, df = load()
    if df.empty:
        sys.exit("no points in {}".format(JSON_PATH))

    ps.configure_style()
    # Not hashtables, so the palette is built at the size of this figure's own
    # series rather than at len(PALETTE_ORDER).
    palette = ps.configure_palette(n=len(SERIES_ORDER))
    styles = {
        name: {"color": palette[i], "linestyle": LINESTYLES[name],
               "marker": MARKERS[name]}
        for i, name in enumerate(SERIES_ORDER)
    }

    fig, axes = ps.get_subplots(1, 3, plot_w=4.2, plot_h=3.7)
    ax_bw, ax_per, ax_marg = axes

    present = [n for n in SERIES_ORDER if n in set(df.series)]

    for name in present:
        sub = df[df.series == name]
        style = styles[name]
        # Median under peak: the gap is the fixed-work straggler artifact, and
        # it is only wide where the thread placement is unbalanced.
        ax_bw.fill_between(sub.threads, sub.median_gbs, sub.gbs,
                           color=style["color"], alpha=0.18, linewidth=0,
                           zorder=1)
        sns.lineplot(data=sub, x="threads", y="gbs", ax=ax_bw, legend=False,
                     markersize=4, **style)
        sns.lineplot(data=sub, x="threads", y="per_thread", ax=ax_per,
                     legend=False, markersize=4, **style)
        marg = sub.dropna(subset=["marginal"])
        sns.lineplot(data=marg, x="threads", y="marginal", ax=ax_marg,
                     legend=False, markersize=4, **style)

    # What a fixed per-core slice would look like, anchored on the 1-thread HBM
    # read point -- the only point on the sweep where no core is sharing.
    hbm = df[df.series == "hbm_read"].sort_values("threads")
    slice_gbs = None
    if not hbm.empty:
        one = hbm.iloc[0]
        slice_gbs = one.gbs / one.threads
        ax_bw.plot(hbm.threads, hbm.threads * slice_gbs, color="0.35",
                   linestyle="--", linewidth=1, zorder=2)
        ax_bw.annotate("fixed {:.1f} GB/s per core".format(slice_gbs),
                       xy=(41, 41 * slice_gbs), xytext=(-4, 6),
                       textcoords="offset points", ha="right", va="bottom",
                       fontsize=7, color="0.35", rotation=30,
                       rotation_mode="anchor")
        for ax in (ax_per, ax_marg):
            ax.axhline(slice_gbs, color="0.35", linestyle="--", linewidth=1)

    for ax in (ax_bw, ax_per, ax_marg):
        ax.axvspan(SMT_START, 66, color="0.5", alpha=0.10, linewidth=0, zorder=0)
        ax.axvline(SMT_START, color="0.45", linestyle="-.", linewidth=1.1,
                   zorder=1)
        ax.set_xlabel("threads on node 0")
        ax.set_xlim(0, 66)
        ax.set_ylim(bottom=0)
        ax.set_xticks([1, 8, 16, 24, 32, 40, 48, 56, 64])

    # Keep the read curves readable: the write series' peak sets the top of
    # panel 1, but the ideal line runs off to 832 GB/s and must not set it.
    ax_bw.set_ylim(0, max(df.gbs) * 1.12)

    for ax in (ax_bw, ax_per, ax_marg):
        top = ax.get_ylim()[1]
        ax.annotate("thread 33:\nSMT starts", xy=(SMT_START, top * 0.62),
                    xytext=(6, 0), textcoords="offset points",
                    ha="left", va="center", fontsize=7, color="0.35")
        ax.annotate("1 thread/core", xy=(SMT_START - 2, top * 0.035),
                    ha="right", fontsize=7, color="0.40")
        ax.annotate("2 threads/core", xy=(SMT_START + 2, top * 0.035),
                    ha="left", fontsize=7, color="0.40")

    ax_bw.set_ylabel("memory bandwidth (GB/s)")
    ax_per.set_ylabel("bandwidth per thread (GB/s)")
    ax_marg.set_ylabel("marginal GB/s per added thread")

    for ax in (ax_bw, ax_per, ax_marg):
        ps.tidy(ax)

    ps.add_legend(fig, palette, present,
                  styles={n: dict(styles[n]) for n in present},
                  ncol=len(present))
    # add_legend labels by display_name; these series are not in DISPLAY_NAMES,
    # so relabel the handles with this figure's own names.
    legend = fig.legends[-1]
    for text, name in zip(legend.get_texts(), present):
        text.set_text(LABELS[name])

    ps.save(fig, OUT_PATH, legend_top=0.88)

    cfg = data.get("config", {})
    print("pmus: {} | {} reps/point".format(cfg.get("pmus"), cfg.get("reps")))
    if slice_gbs:
        for name in present:
            sub = df[df.series == name]
            top = sub.gbs.max()
            print("{:10} ceiling {:6.1f} GB/s | {:4.1f}% of a fixed slice at 64 thr".format(
                name, top,
                100 * sub[sub.threads == sub.threads.max()].gbs.iloc[0]
                / (64 * (sub.iloc[0].gbs / sub.iloc[0].threads))))


if __name__ == "__main__":
    main()
