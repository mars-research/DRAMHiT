#!/usr/bin/env python3
"""Plot the k-mer sweep: insert throughput vs k, one line per hashtable.

Reads either a summary CSV written by run_hashtables.py, or -- with --from-logs
-- the per-run logs directly, which lets a sweep be plotted while it is still
running. Writes a PNG and the aggregated numbers as a CSV alongside it, because
two of the four series sit below 3:1 contrast on a light surface and therefore
need a readable table as well as direct labels.

Usage:
  ./plot_kmer_sweep.py                          # newest logs/summary_*.csv
  ./plot_kmer_sweep.py --from-logs              # scrape logs/, works mid-sweep
  ./plot_kmer_sweep.py --csv logs/summary_X.csv --out plots/sweep.png
"""

import argparse
import csv
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.ticker import MultipleLocator
except ModuleNotFoundError:
    # matplotlib lives in the nix dev shell, not the system python, so this
    # fails whenever the shell is not active -- which looks like a broken
    # script rather than a missing environment.
    sys.exit("matplotlib not found. Run this inside the nix dev shell:\n"
             "    /opt/DRAMHiT/nix-dev-shell.sh\n"
             "then re-run this script. (Parsing works without it; only the PNG "
             "needs matplotlib -- the CSV table does not.)")

HERE = Path(__file__).resolve().parent

# Fixed slot order from the reference categorical palette; assigned by entity,
# never cycled and never reordered by rank, so a series keeps its hue when the
# set changes. Markers carry the same identity, so nothing is colour-alone.
SERIES = [
    (3,  "dramblast",   "#2a78d6", "o"),   # slot 1 blue
    (8,  "dramhit",     "#eb6834", "s"),   # slot 2 orange
    (1,  "dramhit-p",   "#1baf7a", "^"),   # slot 3 aqua
    (12, "dramblast-p", "#eda100", "D"),   # slot 4 yellow
]
ORDER = [s[0] for s in SERIES]

SURFACE   = "#fcfcfb"
INK       = "#0b0b0b"
INK_2     = "#52514e"
INK_MUTED = "#8a8985"

LOG_RE = re.compile(r"^(?P<label>[\w-]+)_ht(?P<ht>\d+)_k(?P<k>\d+)(?:_r(?P<rep>\d+))?_")


def from_logs(log_dir, stamp=None):
    """Scrape set_mops / fill out of the per-run logs. Tolerates a partial sweep.

    `stamp` restricts to one sweep. Without it every log in the directory is
    read, including earlier runs at other thread counts or numa policies, which
    would silently mix incomparable configurations into the same line.
    """
    rows = []
    pattern = f"*_ht*_k*_{stamp}.log" if stamp else "*_ht*_k*.log"
    for p in sorted(log_dir.glob(pattern)):
        m = LOG_RE.match(p.name)
        if not m:
            continue
        text = p.read_text(errors="replace")
        mops = re.findall(r"set_mops : (\d+)", text)
        if not mops:
            continue                     # failed or still running
        agg = re.search(r"fill : (\d+), capacity : (\d+)", text)
        if agg:
            fill, cap = int(agg.group(1)), int(agg.group(2))
        else:
            shards = re.findall(r"ht-fill:\s*(\d+),\s*ht-sz:\s*(\d+)", text)
            fill = sum(int(f) for f, _ in shards) if shards else None
            cap = sum(int(c) for _, c in shards) if shards else None
        rows.append({"ht_type": int(m["ht"]), "k": int(m["k"]),
                     "set_mops": int(mops[-1]), "fill": fill, "capacity": cap})
    return rows


def from_csv(path):
    rows = []
    with open(path) as f:
        for r in csv.DictReader(f):
            if r.get("status") != "ok" or not r.get("set_mops"):
                continue
            rows.append({"ht_type": int(r["ht_type"]), "k": int(r["k"]),
                         "set_mops": int(r["set_mops"]),
                         "fill": int(r["fill"]) if r.get("fill") else None,
                         "capacity": int(r["capacity"]) if r.get("capacity") else None})
    return rows


def aggregate(rows):
    """(ht_type, k) -> mean/min/max/n of set_mops, plus fill factor."""
    by = defaultdict(list)
    for r in rows:
        by[(r["ht_type"], r["k"])].append(r)
    out = {}
    for key, group in by.items():
        m = [g["set_mops"] for g in group]
        caps = [g for g in group if g["fill"] and g["capacity"]]
        out[key] = {
            "mean": statistics.mean(m), "min": min(m), "max": max(m), "n": len(m),
            "stdev": statistics.stdev(m) if len(m) > 1 else 0.0,
            "fill_pct": (100 * caps[0]["fill"] / caps[0]["capacity"]) if caps else None,
        }
    return out


def plot(agg, out_png, title_note):
    ks = sorted({k for _, k in agg})
    if not ks:
        print("no data to plot", file=sys.stderr)
        return False

    fig, (ax, ax2) = plt.subplots(
        2, 1, figsize=(10, 8.5), dpi=150, sharex=True,
        gridspec_kw={"height_ratios": [2.4, 1], "hspace": 0.13})
    fig.patch.set_facecolor(SURFACE)

    for a in (ax, ax2):
        a.set_facecolor(SURFACE)
        a.grid(True, color="#e8e7e3", linewidth=0.8, zorder=0)
        a.set_axisbelow(True)
        for side in ("top", "right"):
            a.spines[side].set_visible(False)
        for side in ("left", "bottom"):
            a.spines[side].set_color("#d6d5d0")
        a.tick_params(colors=INK_2, labelsize=9, length=3, color="#d6d5d0")

    # ---- throughput -------------------------------------------------------
    ends = []
    for ht, label, color, marker in SERIES:
        xs = [k for k in ks if (ht, k) in agg]
        if not xs:
            continue
        mean = [agg[(ht, k)]["mean"] for k in xs]
        lo = [agg[(ht, k)]["min"] for k in xs]
        hi = [agg[(ht, k)]["max"] for k in xs]
        # min-max band: the spread over repeats, not a computed interval
        ax.fill_between(xs, lo, hi, color=color, alpha=0.13, linewidth=0, zorder=2)
        ax.plot(xs, mean, color=color, linewidth=2, marker=marker, markersize=5,
                markeredgecolor=SURFACE, markeredgewidth=0.8, zorder=3,
                label=f"{label}  (ht {ht})")
        ends.append((mean[-1], xs[-1], label))

    # Selective direct labels: the fastest and the slowest at the right edge.
    # Labelling all four put two of them on top of each other, and the legend
    # plus the table view already carry identity for the middle pair.
    for y, x, label in ([min(ends), max(ends)] if len(ends) > 1 else ends):
        ax.annotate(f" {label}", (x, y), color=INK_2, fontsize=9, va="center",
                    ha="left", xytext=(5, 0), textcoords="offset points")

    ax.set_ylabel("insert throughput  (set_mops)", color=INK_2, fontsize=10)
    ax.set_title("DRAMHiT k-mer counting: insert throughput vs k",
                 color=INK, fontsize=13, pad=26, loc="left")
    ax.annotate(title_note, (0, 1.012), xycoords="axes fraction", color=INK_MUTED,
                fontsize=8.5, va="bottom", ha="left")
    leg = ax.legend(loc="lower left", frameon=False, fontsize=9, ncol=2,
                    labelcolor=INK_2)
    ax.set_ylim(bottom=0)
    ax.margins(x=0.06)

    # ---- table occupancy, its own axis (never a second y on the same plot) --
    # Every variant counts the same k-mers, so their fill curves land on top of
    # each other and only the last drawn would be visible. Draw one neutral line
    # when they agree -- and say so, because "they agree" is the correctness
    # check. Fall back to per-series lines if they ever diverge.
    def fills(ht):
        return {k: round(agg[(ht, k)]["fill_pct"], 4) for k in ks
                if (ht, k) in agg and agg[(ht, k)]["fill_pct"] is not None}
    per_series = {ht: fills(ht) for ht, _, _, _ in SERIES}
    non_empty = [f for f in per_series.values() if f]
    identical = len(non_empty) > 1 and all(f == non_empty[0] for f in non_empty)

    if identical:
        xs = sorted(non_empty[0])
        ax2.plot(xs, [non_empty[0][k] for k in xs], color=INK_MUTED, linewidth=2,
                 marker="o", markersize=4, markeredgecolor=SURFACE,
                 markeredgewidth=0.8, zorder=3)
        ax2.annotate("identical across all four variants - same k-mers counted",
                     (0, 1.02), xycoords="axes fraction", color=INK_MUTED,
                     fontsize=8.5, va="bottom", ha="left")
    else:
        for ht, label, color, marker in SERIES:
            f = per_series[ht]
            if not f:
                continue
            xs = sorted(f)
            ax2.plot(xs, [f[k] for k in xs], color=color, linewidth=2,
                     marker=marker, markersize=4, markeredgecolor=SURFACE,
                     markeredgewidth=0.8, zorder=3)
    ax2.set_ylabel("table fill  (%)", color=INK_2, fontsize=10)
    ax2.set_xlabel("k", color=INK_2, fontsize=10)
    ax2.xaxis.set_major_locator(MultipleLocator(2))
    ax2.set_ylim(0, 105)
    ax2.margins(x=0.06)

    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, facecolor=SURFACE, bbox_inches="tight")
    plt.close(fig)
    return True


def write_table(agg, out_csv):
    """The table view. Two series sit under 3:1 on a light surface, so the
    numbers have to be readable somewhere that is not the picture."""
    label = {ht: lab for ht, lab, _, _ in SERIES}
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["ht_type", "label", "k", "repeats", "set_mops_mean",
                    "set_mops_min", "set_mops_max", "set_mops_stdev", "fill_pct"])
        for ht in ORDER:
            for k in sorted(k for h, k in agg if h == ht):
                a = agg[(ht, k)]
                w.writerow([ht, label.get(ht, "?"), k, a["n"],
                            f"{a['mean']:.1f}", a["min"], a["max"],
                            f"{a['stdev']:.1f}",
                            f"{a['fill_pct']:.2f}" if a["fill_pct"] is not None else ""])


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--csv", default=None, help="summary CSV from run_hashtables.py")
    p.add_argument("--from-logs", action="store_true",
                   help="scrape logs/ instead; works on a partial sweep")
    p.add_argument("--log-dir", default=str(HERE / "logs"))
    p.add_argument("--stamp", default=None,
                   help="with --from-logs, restrict to one sweep's timestamp "
                        "(e.g. 20260914-184524); without it, logs from earlier "
                        "runs with different settings are mixed in")
    p.add_argument("--out", default=str(HERE / "plots" / "kmer_sweep.png"))
    args = p.parse_args()

    log_dir = Path(args.log_dir)
    if args.from_logs:
        rows = from_logs(log_dir, args.stamp)
        src = f"{log_dir}/*_{args.stamp or ''}*.log"
    else:
        path = Path(args.csv) if args.csv else max(
            log_dir.glob("summary_*.csv"), key=lambda q: q.stat().st_mtime, default=None)
        if path is None:
            print("no summary CSV found; try --from-logs", file=sys.stderr)
            return 2
        rows, src = from_csv(path), str(path)

    if not rows:
        print(f"no successful runs found in {src}", file=sys.stderr)
        return 1

    agg = aggregate(rows)
    reps = {a["n"] for a in agg.values()}
    note = (f"{len(rows)} runs from {Path(src).name}; "
            f"{'x'.join(str(r) for r in sorted(reps))} repeats per point; "
            f"band = min-max over repeats")

    out_png = Path(args.out)
    if not plot(agg, out_png, note):
        return 1
    out_csv = out_png.with_suffix(".csv")
    write_table(agg, out_csv)

    print(f"  data points {len(agg)} ({len(rows)} runs)")
    print(f"  plot        {out_png}")
    print(f"  table       {out_csv}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
