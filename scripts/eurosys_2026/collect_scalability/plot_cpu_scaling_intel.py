#!/usr/bin/env python3
"""Threads vs bandwidth for the one-socket sweep.

    python3 plot_cpu_scaling_intel.py intel-6548y_cpu_scaling.json
    python3 plot_cpu_scaling_intel.py ... --metric prog

Left panel is the random-read workload, right is the 1r1w store workload, so
the prefetch hints being compared sit next to their own baseline rather than
across a six-line jumble.

The default metric is measured DRAM traffic, not the program's own number.
They are the same thing for reads and roughly 2x apart for writes -- an 8 B
store into a 64 B line fetches the line and writes it back, so the controllers
move about twice what the program asked for. --metric prog draws what
bandwidth.c reports instead.

The dotted vertical is where SMT starts: threads 1..32 are one per physical
core on node 0, 33..64 put a second thread on an already-busy core. A curve
that keeps climbing past it was core-limited; one that flattens at it was not.
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
    ("rand read", ["read_load", "read_t0", "read_t1"]),
    ("1r1w store", ["write_load", "write_prefetchw", "write_ntstore"]),
]

# Within a panel the series differ only by prefetch hint, so they are told
# apart by marker and dash rather than by the hashtable palette.
STYLES = {
    "read_load":       {"marker": "o", "linestyle": "-"},
    "read_t0":         {"marker": "s", "linestyle": "-"},
    "read_t1":         {"marker": "^", "linestyle": "-"},
    "write_load":      {"marker": "o", "linestyle": "-"},
    "write_prefetchw": {"marker": "s", "linestyle": "-"},
    "write_ntstore":   {"marker": "^", "linestyle": "--"},
}


def draw(ax, data, names, title, palette, metric, ymax):
    key = "prog_gbps" if metric == "prog" else "dram_gbps"
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

    smt = data.get("smt_boundary")
    if smt:
        ax.axvline(smt, color="0.45", linestyle=(0, (1, 2)), linewidth=1.0,
                   zorder=0)
        ax.annotate("SMT", xy=(smt, ymax), xytext=(3, -8),
                    textcoords="offset points", fontsize=7, color="0.45",
                    va="top")

    ax.set_xlabel("threads (node 0)")
    ax.set_ylabel("DRAM bandwidth (GB/s)" if metric != "prog"
                  else "bandwidth reported by bandwidth.c (GB/s)")
    ax.set_title(title)
    ax.set_xlim(0, max(data["threads"]) + 2)
    ax.set_ylim(0, ymax)
    ax.legend(fontsize=7, loc="lower right")
    ps.tidy(ax)


def plot(data, out_path, metric):
    ps.configure_style()
    palette = ps.configure_palette(3)

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
