#!/usr/bin/env python3
"""Merge attempt-3 per-rep results into one table per phase.

    attempt3/summarize.py [--variants base l1 ...] [--json out.json]

Reads results/a3_<variant>_r<rep>/a3_<variant>_r<rep>_uniform.json. Each holds one rep
per fill (run_all.sh interleaves reps across variants). For each variant, fill and phase
it prints the median over reps of Mops, HBM GB/s, package W, core GHz and nJ/op, with
Mops's min-max, the change vs base, and any failed runs (the collector rejects a run
whose found count differs from find_ops).
"""
import argparse
import json
import statistics as st
from collections import defaultdict
from pathlib import Path

RES = Path(__file__).resolve().parent.parent / "results"
TABLE = "cas_hwpf_off"


def load(variants, prefix="a3"):
    data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    fails = defaultdict(list)
    for v in variants:
        for f in sorted(RES.glob(f"{prefix}_{v}_r*/{prefix}_{v}_r*_uniform.json")):
            t = json.loads(f.read_text())["tables"][TABLE]
            fails[v] += t.get("failures", [])
            for i, fill in enumerate(t["fills"]):
                for ph in ("set", "get"):
                    d = data[v][fill]
                    d[f"{ph}_mops"].append(t[f"{ph}_mops"][i])
                    for k in ("bw_gbps", "pkg_w", "core_ghz", "mesh_ghz", "nj_per_op"):
                        val = t.get(f"{ph}_{k}", [None] * len(t["fills"]))[i]
                        if val is not None:
                            d[f"{ph}_{k}"].append(val)
    return data, fails


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--variants", nargs="+",
                    default=["base", "l1", "l2", "ring", "cmp", "rc", "rc_l1", "rc_l2"])
    ap.add_argument("--json")
    ap.add_argument("--prefix", default="a3", help="results/<prefix>_<variant>_r<rep>/ (default a3)")
    args = ap.parse_args()
    data, fails = load(args.variants, args.prefix)
    med = lambda xs: st.median(xs) if xs else None
    out = {}
    for ph, name in (("get", "FIND"), ("set", "INSERT")):
        print(f"\n## {name} ({ph})")
        print("| fill | variant | reps | Mops (min–max) | vs base | HBM GB/s | pkg W | core GHz | mesh GHz | nJ/op | vs base |")
        print("|---|---|---|---|---|---|---|---|---|---|---|")
        fills = sorted({f for v in data for f in data[v]})
        for fill in fills:
            b = data.get("base", {}).get(fill, {})
            bm, bn = med(b.get(f"{ph}_mops", [])), med(b.get(f"{ph}_nj_per_op", []))
            for v in args.variants:
                d = data.get(v, {}).get(fill)
                if not d:
                    continue
                m = d[f"{ph}_mops"]
                row = {k: med(d.get(f"{ph}_{k}", [])) for k in ("bw_gbps", "pkg_w", "core_ghz", "mesh_ghz", "nj_per_op")}
                row["mops"], row["reps"] = med(m), len(m)
                out.setdefault(ph, {}).setdefault(str(fill), {})[v] = {**row, "mops_samples": m}
                dm = f"{(row['mops'] / bm - 1) * 100:+.1f}%" if bm else ""
                dn = f"{(row['nj_per_op'] / bn - 1) * 100:+.1f}%" if bn and row["nj_per_op"] else ""
                fmt = lambda x, p: "–" if x is None else f"{x:.{p}f}"
                print(f"| {fill} | {v} | {len(m)} | {row['mops']:.0f} ({min(m):.0f}–{max(m):.0f}) | {dm} | "
                      f"{fmt(row['bw_gbps'], 0)} | {fmt(row['pkg_w'], 0)} | {fmt(row['core_ghz'], 2)} | "
                      f"{fmt(row['mesh_ghz'], 2)} | {fmt(row['nj_per_op'], 1)} | {dn} |")
    bad = {v: f for v, f in fails.items() if f}
    print("\nfailed runs:", bad if bad else "none")
    if args.json:
        Path(args.json).write_text(json.dumps(out, indent=1))


if __name__ == "__main__":
    main()
