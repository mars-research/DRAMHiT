#!/usr/bin/env python3
"""batch_test across the three platforms, one panel each (1x3).

Each panel plots the median cycles to issue a batch of N random cacheline
accesses (batch_test.c) against N, one line per instruction. The knee is where
the line fill buffer / miss address buffer runs out of entries.

    python3 plot_batch.py [-o batch_all]   # batch_all.png + batch_all_band.png

Reads amd_batch/, intel_batch/ and intel_hbm/ next to this file.
"""

import argparse
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))  # eurosys_2026/

import paper_style as ps

# (directory, panel title). amd_batch/ and intel_batch/ name files by mode
# number, intel_hbm/ by instruction; both are read via the mode column.
PLATFORMS = [
    ("amd_batch", "AMD EPYC 9354P"),
    ("intel_batch", "Intel Xeon Gold 6548Y+"),
    ("intel_hbm", "Intel Xeon Max 9462 (HBM)"),
]

# batch_test's mode string -> legend name. This order is the palette order, so
# an instruction has the same colour in every panel even where it is missing.
MODES = {
    "REGULAR_LOAD": "load",
    "AVX512_LOAD": "avx512 load",
    "PREFETCH_T0": "prefetcht0",
    "PREFETCH_T1": "prefetcht1",
    "PREFETCH_T2": "prefetcht2",
    "PREFETCH_NTA": "prefetchnta",
    "PREFETCHW": "prefetchw",
}
ORDER = list(MODES.values())
MARKERS = dict(zip(ORDER, ["o", "D", "s", "^", "v", "P", "X"]))


def load(directory):
    frames = [pd.read_csv(f) for f in sorted((HERE / directory).glob("*.csv"))]
    df = pd.concat(frames, ignore_index=True)
    df["series"] = df["mode"].map(MODES)
    return df.dropna(subset=["series"])


def draw(ax, df, title, styles, band):
    for name in ORDER:
        sub = df[df["series"] == name].sort_values("batch_size")
        if sub.empty:
            continue
        if band:
            ps.draw_band(ax, sub, styles[name], lo="min", hi="max", x="batch_size")
        sns.lineplot(data=sub, x="batch_size", y="median", ax=ax, legend=False,
                     markersize=4, **styles[name])

    ax.set_title(title)
    ax.set_xlabel("batch size (cachelines)")
    ax.set_ylabel("cycles per batch (median, min--max band)" if band
                  else "cycles per batch (median)")
    ax.set_xticks(range(10, 61, 10))
    ax.set_xlim(8, 62)
    # max is often a single-sample outlier (interrupts, up to ~50x the median),
    # so scale to the median lines and let the band clip at the top.
    ax.set_ylim(0, 1.3 * df["median"].max())
    ps.tidy(ax)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-o", "--out", default=str(HERE / "batch_all"),
                    help="output stem: writes <stem>.png and <stem>_band.png")
    args = ap.parse_args()

    ps.configure_style()
    # Instructions are not hashtables, so the palette is sized to them.
    palette = ps.configure_palette(n=len(ORDER))
    # Seven neighbouring rocket shades are hard to tell apart, so each
    # instruction also gets its own marker; demand loads are dashed.
    styles = {name: {"color": palette[i],
                     "linestyle": "--" if "load" in name else "-",
                     "marker": MARKERS[name]}
              for i, name in enumerate(ORDER)}

    data = [(load(d), title) for d, title in PLATFORMS]
    drawn = [n for n in ORDER if any((df["series"] == n).any() for df, _ in data)]

    # Two versions: medians only, and medians with the min..max noise band.
    for band, suffix in [(False, ""), (True, "_band")]:
        fig, axes = ps.get_subplots(1, len(PLATFORMS))
        for ax, (df, title) in zip(axes.ravel(), data):
            draw(ax, df, title, styles, band)
        ps.add_legend(fig, palette, drawn, styles=styles)
        ps.save(fig, f"{args.out}{suffix}.png", legend_top=0.9)


if __name__ == "__main__":
    main()
