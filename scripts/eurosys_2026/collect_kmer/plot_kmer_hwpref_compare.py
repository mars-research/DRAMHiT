#!/usr/bin/env python3
"""Plot the k-mer sweep with hardware prefetchers ON against the same sweep OFF.

Two sweeps of identical shape -- ht-types 3/8/1/12, k=10..32, 5 repeats,
ht-size 2^31, 128 threads -- differing only in MSR 0x1a4 (0x0 all four
prefetchers enabled, 0xf all disabled). dramhit's --hw-pref flag does not do
this and never did: Application.cpp:794 sits behind HARDCODE_PREFETCH_H14A,
which is defined nowhere in the tree.

The upper panel carries both conditions; the lower one carries the ratio, which
is the question actually being asked -- "what does leaving the prefetchers on
buy this variant?" -- and which cannot be read off the upper panel by eye when
the pairs sit at different heights.

Colour identifies the VARIANT (same slots as plot_kmer_sweep.py, so a series
keeps its hue across every figure in this directory); line style identifies the
PREFETCHER STATE. Nothing is encoded by colour alone.

Usage:
  ./plot_kmer_hwpref_compare.py
  ./plot_kmer_hwpref_compare.py --on logs/A.csv --off logs/B.csv --out plots/x.png
"""

import argparse
import csv
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import MultipleLocator

from plot_kmer_sweep import (SERIES, SURFACE, INK, INK_2, INK_MUTED,
                             from_csv, aggregate)

HERE = Path(__file__).resolve().parent


def style_axis(a):
    a.set_facecolor(SURFACE)
    a.grid(True, color="#e8e7e3", linewidth=0.8, zorder=0)
    a.set_axisbelow(True)
    for side in ("top", "right"):
        a.spines[side].set_visible(False)
    for side in ("left", "bottom"):
        a.spines[side].set_color("#d6d5d0")
    a.tick_params(colors=INK_2, labelsize=9, length=3, color="#d6d5d0")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--on", default=str(HERE / "logs" / "intel_snoop_hw_on_full_sweep_summary.csv"))
    p.add_argument("--off", default=str(HERE / "logs" / "intel_snoop_full_sweep_summary.csv"))
    p.add_argument("--out", default=str(HERE / "plots" / "intel-snoop-hwpref-compare.png"))
    p.add_argument("--note", default="Intel Xeon Gold 6548Y+ (2 x 32c, 128 threads), "
                                     "snoop mode, 2.5 GHz pinned; the two sweeps differ "
                                     "only in MSR 0x1a4")
    args = p.parse_args()

    agg = {}
    for cond, path in (("on", args.on), ("off", args.off)):
        rows = from_csv(Path(path))
        if not rows:
            sys.exit(f"no successful runs in {path}")
        agg[cond] = aggregate(rows)

    ks = sorted({k for _, k in agg["on"]} & {k for _, k in agg["off"]})
    if not ks:
        sys.exit("the two sweeps share no k values")

    fig, (ax, ax2) = plt.subplots(
        2, 1, figsize=(10.5, 9), dpi=150, sharex=True,
        gridspec_kw={"height_ratios": [2.4, 1], "hspace": 0.13})
    fig.patch.set_facecolor(SURFACE)
    for a in (ax, ax2):
        style_axis(a)

    # ---- throughput, both conditions ---------------------------------------
    for ht, label, color, marker in SERIES:
        for cond, ls, alpha in (("on", "-", 0.13), ("off", (0, (4, 2)), 0.10)):
            xs = [k for k in ks if (ht, k) in agg[cond]]
            if not xs:
                continue
            a = agg[cond]
            mean = [a[(ht, k)]["mean"] for k in xs]
            lo = [a[(ht, k)]["min"] for k in xs]
            hi = [a[(ht, k)]["max"] for k in xs]
            ax.fill_between(xs, lo, hi, color=color, alpha=alpha, linewidth=0, zorder=2)
            ax.plot(xs, mean, color=color, linewidth=2, linestyle=ls,
                    marker=marker, markersize=4.5, markeredgecolor=SURFACE,
                    markeredgewidth=0.8, zorder=3,
                    markerfacecolor=(color if cond == "on" else SURFACE))

    ax.set_ylabel("insert throughput  (set_mops)", color=INK_2, fontsize=10)
    ax.set_title("DRAMHiT k-mer counting: hardware prefetchers on vs off",
                 color=INK, fontsize=13, pad=38, loc="left")
    ax.annotate(f"{args.note}\nband = min-max over 5 repeats; "
                f"filled marker + solid = prefetchers on, hollow + dashed = off",
                (0, 1.012), xycoords="axes fraction", color=INK_MUTED,
                fontsize=8.5, va="bottom", ha="left")

    handles = [Line2D([0], [0], color=c, marker=m, markeredgecolor=SURFACE,
                      linewidth=2, label=f"{lab}  (ht {ht})")
               for ht, lab, c, m in SERIES]
    handles += [
        Line2D([0], [0], color=INK_MUTED, linewidth=2, linestyle="-", label="prefetchers on"),
        Line2D([0], [0], color=INK_MUTED, linewidth=2, linestyle=(0, (4, 2)), label="prefetchers off"),
    ]
    ax.legend(handles=handles, loc="lower left", frameon=False, fontsize=9,
              ncol=3, labelcolor=INK_2)
    ax.set_ylim(bottom=0)
    ax.margins(x=0.06)

    # ---- the ratio, which is the actual question ---------------------------
    ax2.axhline(1.0, color=INK_MUTED, linewidth=1, linestyle=(0, (2, 2)), zorder=1)
    ends = []
    for ht, label, color, marker in SERIES:
        xs = [k for k in ks if (ht, k) in agg["on"] and (ht, k) in agg["off"]]
        if not xs:
            continue
        r = [agg["on"][(ht, k)]["mean"] / agg["off"][(ht, k)]["mean"] for k in xs]
        ax2.plot(xs, r, color=color, linewidth=2, marker=marker, markersize=4.5,
                 markeredgecolor=SURFACE, markeredgewidth=0.8, zorder=3)
        ends.append((r[-1], xs[-1], label))
    for y, x, label in ends:
        ax2.annotate(f" {label}", (x, y), color=INK_2, fontsize=8.5, va="center",
                     ha="left", xytext=(5, 0), textcoords="offset points")

    ax2.set_ylabel("on / off", color=INK_2, fontsize=10)
    ax2.set_xlabel("k", color=INK_2, fontsize=10)
    ax2.xaxis.set_major_locator(MultipleLocator(2))
    ax2.margins(x=0.06)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out, facecolor=SURFACE, bbox_inches="tight")
    plt.close(fig)

    # ---- the table view ----------------------------------------------------
    out_csv = out.with_suffix(".csv")
    lab = {ht: l for ht, l, _, _ in SERIES}
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ht_type", "label", "k", "set_mops_on", "set_mops_off",
                    "ratio_on_over_off", "pct_change"])
        for ht, _, _, _ in SERIES:
            for k in ks:
                if (ht, k) not in agg["on"] or (ht, k) not in agg["off"]:
                    continue
                on = agg["on"][(ht, k)]["mean"]
                off = agg["off"][(ht, k)]["mean"]
                w.writerow([ht, lab[ht], k, f"{on:.1f}", f"{off:.1f}",
                            f"{on / off:.4f}", f"{(on / off - 1) * 100:+.1f}"])

    print(f"  plot   {out}")
    print(f"  table  {out_csv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
