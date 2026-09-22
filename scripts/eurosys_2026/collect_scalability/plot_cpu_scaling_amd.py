#!/usr/bin/env python3
"""Figure for amd_cpu_scaling.json: bandwidth vs core count on the AMD EPYC 9354P box.

Two panels, the same two questions the Intel sweep asks, adapted to a machine with one
socket split into 4 NUMA-local memory controllers instead of two sockets:

  1. aggregate GB/s, for a single controller alone (node_local, node 0 only) and for all
     4 running at once with every thread kept local (system_local) -- with a "4x node_local"
     reference line, so a bend that stays on that line is 4 independent per-controller
     ceilings, and a bend that falls below it is something shared above the controllers
     (the one Infinity Fabric all 4 sit behind).
  2. GB/s per thread for both curves overlaid -- flat means a core still buys its slice,
     falling means it is sharing.

Unlike the Intel sweep, there is no straggler artifact to plot around here: every
system_local point puts an equal thread count on every active node (thread i -> node
i%4, see collect_cpu_scaling_amd.py), so the grid (4, 8, ..., 64) never lands one node's
work unevenly the way Intel's 1-thread-per-core steps do at its SMT boundary. Median
across reps is therefore reported directly, with no peak-vs-median band needed.

node_local only goes to 16 threads (one NUMA node's 8 physical cores + 8 SMT siblings),
so it is drawn against the bottom axis alongside system_local's per-node thread count
(system_local's own total is 4x that, shown on the top axis) -- that is what makes the
"1 node alone" and "1 of 4 nodes, running with the other 3" comparison land on the same
x position.
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
JSON_PATH = os.path.join(HERE, "amd_cpu_scaling.json")
OUT_PATH = os.path.join(HERE, "amd_cpu_scaling.png")

LABELS = {
    "node_local": "1 node alone (node 0)",
    "system_local": "all 4 nodes at once (per-node thread count)",
}
MARKERS = {"node_local": "o", "system_local": "s"}
LINESTYLES = {"node_local": "-", "system_local": "-"}

PHYSICAL_CORES_PER_NODE = 8
SMT_START_PER_NODE = 9  # 9th thread/node is the first SMT sibling


def load():
    with open(JSON_PATH) as f:
        data = json.load(f)

    rows = []
    for name in ("node_local", "system_local"):
        if name not in data:
            continue
        for point in data[name]["points"].values():
            gbs = point.get("umc_all_gbs")
            if gbs is None:
                continue
            threads_total = point["threads"]
            # Nodes ACTUALLY active at this point (thread_layout only turns on as many
            # nodes as threads i%4 reaches), not the series' full node list -- system_local
            # at 1-2 threads only lights up 1-2 of its 4 nodes.
            num_nodes = len(point.get("node_threads", {})) or 1
            threads_per_node = threads_total / num_nodes
            rows.append({
                "series": name,
                "threads_total": threads_total,
                "threads_per_node": threads_per_node,
                "gbs": gbs,
                "gbs_per_node": gbs / num_nodes,
                "prog_gbs": point.get("prog_bw_gbs"),
                "per_thread": gbs / threads_total,
            })
    df = pd.DataFrame(rows).sort_values(["series", "threads_per_node"])
    return data, df


def main():
    data, df = load()
    if df.empty:
        sys.exit("no points in {}".format(JSON_PATH))

    ps.configure_style()
    palette = ps.configure_palette(n=2)
    styles = {
        name: {"color": palette[i], "linestyle": LINESTYLES[name], "marker": MARKERS[name]}
        for i, name in enumerate(["node_local", "system_local"])
    }

    fig, axes = ps.get_subplots(1, 2, plot_w=5.0, plot_h=4.0)
    ax_bw, ax_per = axes

    present = [n for n in ("node_local", "system_local") if n in set(df.series)]

    for name in present:
        sub = df[df.series == name]
        style = styles[name]
        sns.lineplot(data=sub, x="threads_per_node", y="gbs_per_node", ax=ax_bw,
                     legend=False, markersize=4, **style)
        sns.lineplot(data=sub, x="threads_per_node", y="per_thread", ax=ax_per,
                     legend=False, markersize=4, **style)

    # 4x node_local reference: if system_local's per-node share tracks node_local exactly,
    # the fabric above the 4 controllers is not the bottleneck at any point on this sweep.
    node = df[df.series == "node_local"].sort_values("threads_per_node")
    if not node.empty:
        ax_bw.plot(node.threads_per_node, node.gbs_per_node, color="0.35",
                   linestyle="--", linewidth=1, zorder=0.5, marker=None)

    for ax in (ax_bw, ax_per):
        ax.axvspan(SMT_START_PER_NODE, 17, color="0.5", alpha=0.10, linewidth=0, zorder=0)
        ax.axvline(SMT_START_PER_NODE, color="0.45", linestyle="-.", linewidth=1.1, zorder=1)
        ax.set_xlabel("threads per node (node_local: its only node; system_local: each of 4)")
        ax.set_xlim(0, 17)
        ax.set_ylim(bottom=0)
        ax.set_xticks([1, 2, 4, 6, 8, 12, 16])

    ax_bw.set_ylabel("GB/s per node (system_local: per-node share of the total)")
    ax_per.set_ylabel("GB/s per thread")

    top = ax_bw.get_ylim()[1]
    ax_bw.annotate("8 phys. cores/node\nSMT starts", xy=(SMT_START_PER_NODE, top * 0.55),
                   xytext=(6, 0), textcoords="offset points",
                   ha="left", va="center", fontsize=7, color="0.35")

    for ax in (ax_bw, ax_per):
        ps.tidy(ax)

    ps.add_legend(fig, palette, present, styles={n: dict(styles[n]) for n in present},
                  ncol=len(present))
    legend = fig.legends[-1]
    for text, name in zip(legend.get_texts(), present):
        text.set_text(LABELS[name])

    ps.save(fig, OUT_PATH, legend_top=0.86)

    cfg = data.get("config", {})
    print("bytes_per_cas: {}  node_umc_boxes: {}".format(
        cfg.get("bytes_per_cas"), cfg.get("node_umc_boxes")))
    for name in present:
        sub = df[df.series == name]
        peak = sub.loc[sub.gbs.idxmax()]
        print("{:14} peak {:6.1f} GB/s total at {:.0f} threads ({:.1f} GB/s/node)".format(
            name, peak.gbs, peak.threads_total, peak.gbs_per_node))


if __name__ == "__main__":
    main()
