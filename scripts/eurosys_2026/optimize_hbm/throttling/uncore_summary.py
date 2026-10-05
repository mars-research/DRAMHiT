#!/usr/bin/env python3
"""Summarise results/uncore/uncore_sweep.json.

    python3 uncore_summary.py [--series LABEL]

1. one row per workload: median over reps of the per-run medians
2. mesh and core clock binned by package power, for every in-window 100 ms interval of
   every run, once by instantaneous power and once by the trailing 1 s mean (PL1's window)
3. the order of events in the first second: when the mesh and the core first drop
4. --series LABEL prints the interval series of the first rep of one workload
"""
import argparse
import json
import statistics as st
from pathlib import Path

DATA = Path(__file__).resolve().parent / "results" / "uncore" / "uncore_sweep.json"


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def fmt(x, p=2):
    return "–" if x is None else f"{x:.{p}f}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--series")
    args = ap.parse_args()
    runs = json.loads(DATA.read_text())
    labels = list(dict.fromkeys(r["label"] for r in runs))

    print("## Per workload (median of reps; each rep is the median of its in-window 100 ms intervals)\n")
    print("| workload | reps | pkg W | trailing-1s W | core GHz | mesh GHz | mesh min | HBM-ctl GHz | HBM GB/s | mesh<2.45 at (s) | core<2.65 at (s) |")
    print("|---|---|---|---|---|---|---|---|---|---|---|")
    for lb in labels:
        rs = [r for r in runs if r["label"] == lb]
        g = lambda k: med([r[k] for r in rs])
        print(f"| {lb} | {len(rs)} | {fmt(g('pkg_w'), 0)} | {fmt(g('pkg_w_avg1s'), 0)} | {fmt(g('core_ghz'))} | "
              f"{fmt(g('cha_ghz'))} | {fmt(g('cha_min_ghz'))} | {fmt(g('hbmclk_ghz'))} | {fmt(g('hbm_gbps'), 0)} | "
              f"{fmt(g('t_cha_below_2.45'), 1)} | {fmt(g('t_core_below_2.65'), 1)} |")

    bins = [(0, 330), (330, 340), (340, 350), (350, 360), (360, 380), (380, 1000)]
    for key, title in (("pkg_w", "instantaneous package power (100 ms)"),
                       ("pkg_w_avg1s", "trailing 1 s mean package power (PL1's window)")):
        print(f"\n## Mesh and core clock by {title}\n")
        print("| W bin | mem: n | mem: mesh | mem: core | spin: n | spin: mesh | spin: core |")
        print("|---|---|---|---|---|---|---|")
        for lo, hi in bins:
            cells = []
            for kind in ("mem", "spin"):
                iv = [s for r in runs if r["kind"] == kind for s in r["series"]
                      if s["in_window"] and s[key] is not None and lo <= s[key] < hi]
                cells += [str(len(iv)), fmt(med([s["cha_ghz"] for s in iv])),
                          fmt(med([s["core_ghz"] for s in iv]))]
            print(f"| {lo}–{hi} | " + " | ".join(cells) + " |")

    if args.series:
        r = next(r for r in runs if r["label"] == args.series)
        print(f"\n## {args.series} rep{r['rep']}: t(s) W W1s core mesh HBM\n")
        for s in r["series"]:
            if s["in_window"]:
                print(f"{s['t']:5.1f} {fmt(s['pkg_w'], 0):>4} {fmt(s['pkg_w_avg1s'], 0):>4} "
                      f"{fmt(s['core_ghz'])} {fmt(s['cha_ghz'])} {fmt(s['hbm_gbps'], 0):>4}")


if __name__ == "__main__":
    main()
