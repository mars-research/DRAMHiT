#!/usr/bin/env python3
"""All three machines' core-count sweeps side by side: one panel per architecture,
three lines on each.

    python3 plot_cpu_scaling_all.py                      # the three jsons in this dir
    python3 plot_cpu_scaling_all.py a.json b.json c.json
    python3 plot_cpu_scaling_all.py --free-y             # per-panel y scaling
    python3 plot_cpu_scaling_all.py --metric prog
    python3 plot_cpu_scaling_all.py --set reads          # every read instruction

`--set reads` instead draws random read under every access instruction (no sw
prefetch, prefetcht0/t1/t2, nta, prefetchw), skipping any a machine did not run.

The default set's three lines, same colour/style in every panel:

    random read, prefetcht1    solid
    1r1w store,  prefetcht1    dashed
    0r1w nt store              dotted -- a full-line non-temporal store never fetches
                               the line it overwrites, so it is the write path with
                               the RFO half removed.

**Bandwidth here is what the memory controllers actually moved**, not what the program
asked for. The two agree for reads and differ by about 2x for 1r1w, because an 8 B store
into a 64 B line makes the controller fetch the line and write it back. `--metric prog`
draws bandwidth.c's own number instead.

y is shared across panels by default, because the point of putting them side by side is
comparing magnitudes. `--free-y` scales each panel to its own data.

Verticals: dashed grey is where SMT starts (a second thread on an already-busy core);
faint dotted, where a json records them, are the points a further NUMA node's cores join
the ramp -- only the AMD sweep has those, since its 4 NPS4 nodes are one package and its
threads fill them 8 at a time.
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402

DEFAULT_JSONS = [
    "amd-9354p_cpu_scaling.json",
    "intel-6548y_cpu_scaling.json",
    "intel-max9462_hbm_cpu_scaling.json",
]

# The series each figure draws, in legend order:
# (json series name, label, linestyle, marker). A machine missing a series skips it.
SERIES_SETS = {
    # --set mix (default): the read / 1r1w / 0r1w comparison.
    "mix": [
        ("read_t1", "random read, prefetcht1", "-", "^"),
        ("write_t1", "1r1w store, prefetcht1", "--", "s"),
        ("write_ntstore", "0r1w nt store", ":", "v"),
    ],
    # --set reads: random read under every access instruction.
    "reads": [
        ("read_load", "no sw prefetch", "-", "o"),
        ("read_t0", "prefetcht0", "-", "s"),
        ("read_t1", "prefetcht1", "-", "^"),
        ("read_t2", "prefetcht2", "-", "D"),
        ("read_nta", "prefetchnta", "-", "X"),
        ("read_prefetchw", "prefetchw", "-", "P"),
    ],
}

# What each machine is, for the panel titles. Keyed by the json's own "machine".
MACHINE_TITLE = {
    "amd-9354p": "AMD EPYC 9354P\n1 socket, 32c/64t, DDR5 x12",
    "intel-6548y": "Intel Xeon Gold 6548Y+\n1 socket, 32c/64t, DDR5",
    "intel-max9462": "Intel Xeon CPU Max 9462\n1 socket, 32c/64t, HBM2e",
}


def draw(ax, data, series, colors, metric, ylim):
    key = "prog_gbps" if metric == "prog" else "dram_gbps"

    smt = data.get("smt_boundary")
    top = ylim[1] if ylim else series_peak(data, series, key, default=1)

    # These land on x-ticks, so the grid would swallow a faint line; tint them and
    # label them instead. Only the AMD sweep records any -- its 4 NPS4 nodes are one
    # package and its ramp fills them 8 cores at a time.
    for i, nb in enumerate(data.get("node_boundaries") or []):
        if nb == smt:
            continue
        ax.axvline(nb, color="#4c8fbd", linestyle=(0, (2, 2)), linewidth=1.0, zorder=1)
        ax.annotate(f"n{i + 1}", xy=(nb, top), xytext=(2, -8),
                    textcoords="offset points", fontsize=6.5, color="#4c8fbd",
                    va="top")
    if smt:
        ax.axvline(smt, color="0.45", linestyle=(0, (4, 2)), linewidth=1.1, zorder=1)
        ax.annotate("SMT", xy=(smt, top), xytext=(3, -8), textcoords="offset points",
                    fontsize=7, color="0.45", va="top")

    for i, (name, label, style, marker) in enumerate(series):
        entry = data["series"].get(name)
        if entry is None:
            continue
        pts = [(x, y) for x, y in zip(entry["threads"], entry[key]) if y is not None]
        if not pts:
            continue
        xs, ys = zip(*pts)
        ax.plot(xs, ys, color=colors[i], linestyle=style, marker=marker,
                markersize=4, linewidth=1.6, label=label)

    machine = data.get("machine", "?")
    peak = series_peak(data, series, key)
    ax.set_title(f"{MACHINE_TITLE.get(machine, machine)}\npeak {peak:.0f} GB/s",
                 fontsize=9)
    ax.set_xlabel("threads")
    ax.set_xlim(0, max(data["threads"]) + 2)
    ax.set_xticks([1, 8, 16, 24, 32, 40, 48, 56, 64])
    if ylim:
        ax.set_ylim(*ylim)
    else:
        ax.set_ylim(0, top * 1.15)
    ps.tidy(ax)


def series_peak(data, series, key, default=0):
    """Max bandwidth over just the series this figure draws."""
    return max([v for name, *_ in series for v in data["series"].get(name, {}).get(key, [])
                if v is not None] or [default])


def plot(datasets, series, out_path, metric, free_y):
    ps.configure_style()
    colors = ps.configure_palette(len(series))

    key = "prog_gbps" if metric == "prog" else "dram_gbps"
    ylim = None
    if not free_y:
        top = max(series_peak(d, series, key, default=1) for d in datasets)
        ylim = (0, top * 1.12)

    fig, axes = plt.subplots(1, len(datasets), figsize=(4.6 * len(datasets), 4.8),
                             sharey=not free_y)
    axes = [axes] if len(datasets) == 1 else list(axes.ravel())
    for ax, data in zip(axes, datasets):
        draw(ax, data, series, colors, metric, ylim)

    axes[0].set_ylabel("DRAM bandwidth at the controllers (GB/s)" if metric != "prog"
                       else "bandwidth reported by bandwidth.c (GB/s)")

    handles = [Line2D([], [], color=colors[i], linestyle=style, marker=marker,
                      markersize=4, linewidth=1.6, label=label)
               for i, (_, label, style, marker) in enumerate(series)]
    fig.legend(handles=handles, loc="upper center", bbox_to_anchor=(0.5, 1.0),
               ncol=len(handles), fontsize=8, frameon=False)

    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig(out_path, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {out_path}")


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("jsons", nargs="*", default=None,
                    help="one per architecture; defaults to the three in this directory")
    ap.add_argument("--metric", choices=["dram", "prog"], default="dram")
    ap.add_argument("--set", choices=list(SERIES_SETS), default="mix",
                    help="mix: read/1r1w with prefetcht1 + 0r1w nt store; "
                         "reads: random read under every access instruction")
    ap.add_argument("--free-y", action="store_true",
                    help="scale each panel to its own data instead of sharing y")
    ap.add_argument("--out", default=None)
    args = ap.parse_args()

    paths = [Path(p) for p in (args.jsons or [SCRIPT_DIR / n for n in DEFAULT_JSONS])]
    missing = [p for p in paths if not p.exists()]
    if missing:
        raise SystemExit("[!] missing: " + ", ".join(str(p) for p in missing))

    datasets = [json.loads(p.read_text()) for p in paths]
    for p, d in zip(paths, datasets):
        if "series" not in d:
            raise SystemExit(f"[!] {p}: no 'series' key; not a cpu_scaling json")

    suffix = "" if args.metric == "dram" else "_prog"
    free = "_freey" if args.free_y else ""
    which = "" if args.set == "mix" else f"_{args.set}"
    out = args.out or str(SCRIPT_DIR / f"cpu_scaling_all{which}{suffix}{free}.png")
    plot(datasets, SERIES_SETS[args.set], out, args.metric, args.free_y)


if __name__ == "__main__":
    main()
