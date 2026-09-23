#!/usr/bin/env python3
"""Threads vs bandwidth for the AMD EPYC 9354P package-wide sweep.

    python3 plot_cpu_scaling_amd.py amd-9354p_cpu_scaling.json
    python3 plot_cpu_scaling_amd.py ... --metric prog

Same layout as plot_cpu_scaling_intel.py: left panel is the random-read workload,
right is the 1r1w store workload, so each prefetch hint sits next to its own baseline.

The default metric is measured DRAM traffic, not the program's own number. They are the
same thing for reads and roughly 2x apart for writes -- an 8 B store into a 64 B line
fetches the line and writes it back, so the controllers move about twice what the
program asked for. --metric prog draws what bandwidth.c reports instead.

Two sets of guides, because this machine's ramp has more structure than the Intel one:

  dotted verticals at 8/16/24/32   a NUMA node's 8 physical cores joining. The package
                                   is one memory system (memory is interleaved over all
                                   4 nodes at every point), so these are cores arriving,
                                   not memory arriving. Each node is 2 CCDs of 4 cores,
                                   so its second CCD lights up midway through its span.
  dashed vertical at 32            SMT starts: 1..32 is one thread per physical core on
                                   the whole package, 33..64 add a second thread to an
                                   already-busy core.

A curve that keeps climbing past 32 was core-limited; one that flattens at it was not.
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
    ("rand read", ["read_load", "read_t0", "read_nta", "read_prefetchw",
                   "read_t1", "read_t2"]),
    ("1r1w store", ["write_load", "write_prefetchw", "write_t0", "write_t1",
                    "write_t2", "write_ntstore"]),
]

# Within a panel the series differ only by prefetch hint, so they are told apart by
# marker and dash rather than by the hashtable palette.
STYLES = {
    "read_load":       {"marker": "o", "linestyle": "-"},
    "read_t0":         {"marker": "s", "linestyle": "-"},
    "read_t1":         {"marker": "^", "linestyle": "-"},
    # The L1-targeting hints (t0, nta, prefetchw) land on top of each other and below
    # the no-prefetch baseline; the L2-targeting ones (t1, t2) land on top of each
    # other well above it. Dashes separate the two groups so the overlap reads as a
    # result rather than as a missing line.
    "read_t2":         {"marker": "D", "linestyle": "--"},
    "read_nta":        {"marker": "X", "linestyle": "--"},
    "read_prefetchw":  {"marker": "P", "linestyle": ":"},
    "write_load":      {"marker": "o", "linestyle": "-"},
    "write_prefetchw": {"marker": "s", "linestyle": "-"},
    "write_t0":        {"marker": "P", "linestyle": "-"},
    "write_t1":        {"marker": "^", "linestyle": "-"},
    "write_t2":        {"marker": "D", "linestyle": "--"},
    "write_ntstore":   {"marker": "v", "linestyle": "--"},
}


def draw(ax, data, names, title, palette, metric, ymax):
    key = "prog_gbps" if metric == "prog" else "dram_gbps"

    # Node arrivals first, so the data draws over them.
    smt = data.get("smt_boundary")
    for i, nb in enumerate(data.get("node_boundaries", [])):
        if nb == smt:
            continue
        ax.axvline(nb, color="0.78", linestyle=(0, (1, 3)), linewidth=0.9, zorder=0)
        ax.annotate(f"n{i + 1}", xy=(nb, ymax), xytext=(2, -7),
                    textcoords="offset points", fontsize=6.5, color="0.6", va="top")

    for i, name in enumerate(names):
        entry = data["series"].get(name)
        if not entry or not entry["threads"]:
            continue
        xs, ys = [], []
        for x, y in zip(entry["threads"], entry[key]):
            if y is not None:
                xs.append(x)
                ys.append(y)
        if not xs:
            continue
        ax.plot(xs, ys, color=palette[i % len(palette)],
                label=entry["label"], markersize=5, linewidth=1.6,
                **STYLES.get(name, {}))

    if smt:
        ax.axvline(smt, color="0.45", linestyle=(0, (4, 2)), linewidth=1.1, zorder=1)
        ax.annotate("SMT", xy=(smt, ymax), xytext=(3, -8),
                    textcoords="offset points", fontsize=7, color="0.45", va="top")

    ax.set_xlabel("threads (package-wide: 8 per node, nodes in turn, then SMT)")
    ax.set_ylabel("DRAM bandwidth (GB/s)" if metric != "prog"
                  else "bandwidth reported by bandwidth.c (GB/s)")
    ax.set_title(title)
    ax.set_xlim(0, max(data["threads"]) + 2)
    ax.set_ylim(0, ymax)
    ax.set_xticks([1, 8, 16, 24, 32, 40, 48, 56, 64])
    ax.legend(fontsize=7, loc="lower right")
    ps.tidy(ax)


def plot(data, out_path, metric):
    ps.configure_style()
    palette = ps.configure_palette(max(len(n) for _, n in PANELS))

    key = "prog_gbps" if metric == "prog" else "dram_gbps"
    top = max([v for e in data["series"].values() for v in e[key]
               if v is not None] or [1])
    ymax = top * 1.15

    fig, axes = plt.subplots(1, len(PANELS), figsize=(11, 4.2))
    for ax, (title, names) in zip(axes.ravel(), PANELS):
        draw(ax, data, names, title, palette, metric, ymax)
    fig.tight_layout()
    fig.savefig(out_path, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out_path}")


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("json")
    ap.add_argument("--metric", choices=["dram", "prog"], default="dram")
    args = ap.parse_args()

    path = Path(args.json)
    data = json.loads(path.read_text())
    suffix = "" if args.metric == "dram" else "_prog"
    plot(data, str(path.with_suffix("")) + suffix + ".png", args.metric)


if __name__ == "__main__":
    main()
