#!/usr/bin/env python3
"""Plot a k-mer sweep in the paper's figure style.

Same data as plot_kmer_sweep.py (a summary CSV from run_hashtables.py), drawn
through ../paper_style.py so the panels sit next to the other eurosys_2026
figures: dramblast / dramhit keep the colours they have everywhere else, and
the partitioned tables reuse their base table's colour. See ../PLOTTING.md.

    ./plot_kmer_paper.py logs/intel_snoop_hw_on_full_sweep_summary.csv \\
        --title "Intel 6548Y+, snoop, hw pref on" \\
        --out plots/intel-snoop-hw-on-kmer.png

--twin draws a single panel instead, with table fill on a second y axis.
"""

import argparse
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns
from matplotlib.lines import Line2D

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402
from plot_kmer_sweep import aggregate, from_csv, write_table  # noqa: E402

# ht-type -> canonical series name (see run_hashtables.py HASHTABLES).
HT_SERIES = {3: "cas", 8: "cas23", 12: "cas_part", 1: "cas23_part"}


def frame(agg):
    rows = []
    for (ht, k), a in agg.items():
        if ht not in HT_SERIES:
            continue
        rows.append({"table": HT_SERIES[ht], "x": k, "mops": a["mean"],
                     "lo": a["min"], "hi": a["max"], "fill": a["fill_pct"]})
    return pd.DataFrame(rows)


def plot(df, out_png, title):
    ps.configure_style()
    palette = ps.configure_palette()

    tables = ps.order_series(set(df["table"]))
    styles = ps.styles_for(tables, palette)
    ks = sorted(df["x"].unique())
    xticks = [k for k in ks if k % 2 == 0]

    fig, (ax, ax_fill) = ps.get_subplots(1, 2)

    for name in tables:
        sub = df[df["table"] == name].sort_values("x")
        ps.draw_band(ax, sub, styles[name])
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                     **styles[name])
    ax.set_xlabel("k")
    ax.set_ylabel("throughput (Mops)")
    # ax.set_title(f"Kmer counting, {title}" if title else "insertion")
    ax.set_ylim(bottom=0)

    # Every table counts the same k-mers, so the fill curves coincide; one
    # neutral line says so without four lines drawn on top of each other.
    fills = df.pivot_table(index="x", columns="table", values="fill")
    identical = fills.nunique(axis=1).le(1).all()
    if identical:
        fill = fills.iloc[:, 0].reset_index(name="fill")
        sns.lineplot(data=fill, x="x", y="fill", ax=ax_fill, color="0.4",
                     marker="o", legend=False)
    else:
        for name in tables:
            sub = df[df["table"] == name].sort_values("x")
            sns.lineplot(data=sub, x="x", y="fill", ax=ax_fill, legend=False,
                         **styles[name])
    pct = "\\%" if ps.mpl.rcParams["text.usetex"] else "%"
    ax_fill.set_xlabel("k")
    ax_fill.set_ylabel(f"table fill ({pct})")
    ax_fill.set_title("table occupancy (same for all tables)" if identical
                      else "table occupancy")
    ax_fill.set_ylim(0, 100)

    for a in (ax, ax_fill):
        a.set_xticks(xticks)
        a.set_xlim(min(ks) - 0.5, max(ks) + 0.5)
        ps.tidy(a)

    ps.add_legend(fig, palette, tables, styles=styles)
    ps.save(fig, out_png, legend_top=0.9)


def plot_twin(df, out_png, title):
    """One panel: throughput on the left axis, table fill on the right."""
    ps.configure_style()
    palette = ps.configure_palette()

    tables = ps.order_series(set(df["table"]))
    styles = ps.styles_for(tables, palette)
    ks = sorted(df["x"].unique())

    fig, ax = ps.get_subplots(1, 1)
    ax_fill = ax.twinx()

    for name in tables:
        sub = df[df["table"] == name].sort_values("x")
        ps.draw_band(ax, sub, styles[name])
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                     **styles[name])
    ax.set_xlabel("k")
    ax.set_ylabel("throughput (Mops)")
    # The paper caption already says insertion / machine; title only on request.
    if title:
        ax.set_title(title)
    ax.set_ylim(bottom=0)

    # Fill is the same k-mer count for every table (see plot()); draw it once.
    fill_colour = "0.6"
    fill_style = {"color": fill_colour, "linestyle": "--", "marker": "s",
                  "alpha": 0.5}
    fill = df.groupby("x")["fill"].mean().reset_index()
    sns.lineplot(data=fill, x="x", y="fill", ax=ax_fill, legend=False,
                 **fill_style)
    pct = "\\%" if ps.mpl.rcParams["text.usetex"] else "%"
    ax_fill.set_ylabel(f"table fill ({pct})", color=fill_colour)
    ax_fill.tick_params(axis="y", colors=fill_colour)
    ax_fill.set_ylim(0, 100)
    ax_fill.grid(False)
    # twinx stacks the fill axis on top; put throughput back in front.
    ax.set_zorder(ax_fill.get_zorder() + 1)
    ax.patch.set_visible(False)

    ax.set_xticks([k for k in ks if k % 2 == 0])
    ax.set_xlim(min(ks) - 0.5, max(ks) + 0.5)
    ps.tidy(ax)

    handles = [Line2D([0], [0], label=ps.display_name(n), **styles[n])
               for n in tables]
    handles.append(Line2D([0], [0], label="table fill", **fill_style))
    # A lone 4-inch panel can't fit five entries on one row.
    fig.legend(fontsize=8, handles=handles, loc="upper center", ncol=3)
    ps.save(fig, out_png, legend_top=0.9 if title else 0.92)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("csv", help="summary CSV from run_hashtables.py")
    ap.add_argument("--out", required=True, help="output PNG")
    ap.add_argument("--title", default="",
                    help="machine / firmware context for the panel title")
    ap.add_argument("--twin", action="store_true",
                    help="one panel, table fill on a second y axis")
    args = ap.parse_args()

    rows = from_csv(args.csv)
    if not rows:
        print(f"no successful runs in {args.csv}", file=sys.stderr)
        return 1
    agg = aggregate(rows)
    out_png = Path(args.out)
    out_png.parent.mkdir(parents=True, exist_ok=True)
    (plot_twin if args.twin else plot)(frame(agg), str(out_png), args.title)
    write_table(agg, out_png.with_suffix(".csv"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
