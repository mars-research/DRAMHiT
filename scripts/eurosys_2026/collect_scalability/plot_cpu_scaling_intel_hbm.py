#!/usr/bin/env python3
"""Threads vs bandwidth for the HBM sweep on the Xeon CPU Max 9462.

    python3 plot_cpu_scaling_intel_hbm.py intel-max9462_hbm_cpu_scaling.json
    python3 plot_cpu_scaling_intel_hbm.py ... --metric prog
    python3 plot_cpu_scaling_intel_hbm.py ... --metric median

Left panel is the random-read workload, right is the 1r1w store workload, so the
instructions being compared sit next to their own baseline rather than across an
eleven-line jumble. Both panels carry the prefetch hints: the RFO half of a store
is a read, so the same L2 concurrency that drives the read curve drives stores
too -- prefetcht1/t2 are worth ~1.7x a plain store here, where prefetchw is
worth ~3%. The dashed grey line is what a fixed per-core slice would
draw, extrapolated from that panel's best 1-thread rate -- the gap to it is the
whole finding.

The default metric is the **peak** measured HBM interval, not the median. From
33 to 63 threads the placement is unbalanced (at 40, eight cores run two threads
and 24 run one), and since bandwidth.c gives every thread the same fixed work,
the paired threads straggle and leave the machine idle, which drags the median
down: read_t1's median falls from 32 to 40 threads while its peak rises. The
peak samples the machine while every thread is still running and stays
comparable across the whole sweep; at the balanced points (1..32 and 64) the two
agree within a few percent. --metric median draws the median, --metric prog what
bandwidth.c reports from the bytes it asked for.

That last distinction matters on the write panel: an 8 B store into a 64 B line
fetches the line and writes it back, so the controllers move about twice what
the program asked for -- except for the nt-store control, which never fetches.
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402

PANELS = [
    ("rand read", ["read_load", "read_t0", "read_t1", "read_t2", "read_nta"]),
    ("1r1w store", ["write_load", "write_prefetchw", "write_t0", "write_t1",
                    "write_t2", "write_ntstore"]),
]

# Within a panel the series differ only by access instruction, so they are told
# apart by marker and dash rather than by the hashtable palette.
STYLES = {
    "read_load":       {"marker": "o", "linestyle": "-"},
    "read_t0":         {"marker": "s", "linestyle": "-"},
    "read_t1":         {"marker": "^", "linestyle": "-"},
    "read_t2":         {"marker": "D", "linestyle": "--"},
    "read_nta":        {"marker": "v", "linestyle": ":"},
    "write_load":      {"marker": "o", "linestyle": "-"},
    "write_prefetchw": {"marker": "s", "linestyle": "-"},
    "write_t0":        {"marker": "P", "linestyle": "-"},
    "write_t1":        {"marker": "^", "linestyle": "-"},
    "write_t2":        {"marker": "D", "linestyle": "--"},
    "write_ntstore":   {"marker": "*", "linestyle": ":"},
}

METRIC_KEY = {"peak": "dram_peak_gbps", "median": "dram_gbps",
              "prog": "prog_gbps"}
METRIC_LABEL = {
    "peak": "HBM bandwidth, peak interval (GB/s)",
    "median": "HBM bandwidth, median interval (GB/s)",
    "prog": "bandwidth reported by bandwidth.c (GB/s)",
}


def series_xy(entry, key):
    xs, ys = [], []
    for x, y in zip(entry["threads"], entry.get(key) or []):
        if y is not None:
            xs.append(x)
            ys.append(y)
    return xs, ys


def draw(ax, data, names, title, palette, key, metric, ymax):
    best_slice = 0.0
    for i, name in enumerate(names):
        entry = data["series"].get(name)
        if not entry or not entry["threads"]:
            continue
        xs, ys = series_xy(entry, key)
        if not xs:
            continue
        ax.plot(xs, ys, color=palette[i % len(palette)],
                label=entry["label"], markersize=4.5, linewidth=1.6,
                **STYLES.get(name, {}))
        # The ideal line is anchored on the *best* 1-thread rate in the panel:
        # the fastest instruction is the one whose slice the machine would have
        # to keep up with.
        if xs[0] == 1:
            best_slice = max(best_slice, ys[0])

    if best_slice:
        top_x = max(data["threads"])
        ax.plot([0, top_x], [0, top_x * best_slice], color="0.35",
                linestyle="--", linewidth=1, zorder=0)
        ax.annotate(f"fixed {best_slice:.1f} GB/s per core",
                    xy=(top_x * 0.62, top_x * 0.62 * best_slice),
                    xytext=(0, 4), textcoords="offset points",
                    ha="center", fontsize=7, color="0.35", rotation=32,
                    rotation_mode="anchor")

    smt = data.get("smt_boundary")
    if smt:
        # Threads 1..smt are one per physical core; thread smt+1 is the first to
        # share one, so the boundary is drawn where SMT actually starts.
        ax.axvspan(smt + 1, max(data["threads"]) + 2, color="0.5", alpha=0.08,
                   linewidth=0, zorder=0)
        ax.axvline(smt + 1, color="0.45", linestyle=(0, (1, 2)), linewidth=1.0,
                   zorder=0)
        # Low, not at the top: the fixed-slice line's own label lives up there.
        ax.annotate(f"thread {smt + 1}: SMT starts", xy=(smt + 1, ymax * 0.04),
                    xytext=(4, 0), textcoords="offset points", fontsize=7,
                    color="0.45", va="bottom")

    ax.set_xlabel("threads (node 0)")
    ax.set_ylabel(METRIC_LABEL[metric])
    ax.set_title(title)
    ax.set_xlim(0, max(data["threads"]) + 2)
    ax.set_ylim(0, ymax)
    ax.legend(fontsize=6.5, loc="upper left", ncol=1, framealpha=0.9)
    ps.tidy(ax)


def plot(data, out_path, metric):
    ps.configure_style()
    palette = ps.configure_palette(max(len(n) for _, n in PANELS))

    key = METRIC_KEY[metric]
    top = max([v for e in data["series"].values() for v in (e.get(key) or [])
               if v is not None] or [1])
    ymax = top * 1.18

    fig, axes = plt.subplots(1, len(PANELS), figsize=(11, 4.2))
    for ax, (title, names) in zip(axes.ravel(), PANELS):
        draw(ax, data, names, title, palette, key, metric, ymax)
    fig.tight_layout()
    fig.savefig(out_path, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out_path}")


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("json")
    ap.add_argument("--metric", choices=["peak", "median", "prog"],
                    default="peak")
    args = ap.parse_args()

    path = Path(args.json)
    data = json.loads(path.read_text())
    suffix = {"peak": "", "median": "_median", "prog": "_prog"}[args.metric]
    plot(data, str(path.with_suffix("")) + suffix + ".png", args.metric)


if __name__ == "__main__":
    main()
