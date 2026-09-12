#!/usr/bin/env python3
"""cas vs cas23, point by point, from a run_join.py tree.

    python3 compare_cas_cas23.py intel_dual_recheck
    python3 compare_cas_cas23.py intel_dual_recheck --prefix dual   # run-name prefix

Prints one table per sweep: each table's median throughput, the spread over
the raw samples, the cas/cas23 ratio, a Welch t on the samples so a point can
be called instead of eyeballed, and the build/probe cycle-per-op split that
says *which phase* any gap is in.

throughput_mops in the json is already the per-point median; the samples are
alongside it, and everything below is computed from the samples so a tree
collected at reps=1 still prints (with the statistics suppressed).
"""

import argparse
import json
import math
import statistics
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent


def load(data_dir, prefix, table, param):
    """The one json for (table, sweep), searched by run name not filename."""
    for path in sorted((SCRIPT_DIR / data_dir).glob(f"{param}/*_{param}.json")):
        data = json.loads(path.read_text())
        if data.get("run") == f"{prefix}_{table}" and data.get("param_name") == param:
            return data
    return None


def welch(a, b):
    """t and Welch-Satterthwaite dof for two independent samples."""
    if len(a) < 2 or len(b) < 2:
        return None, None
    va, vb = statistics.variance(a) / len(a), statistics.variance(b) / len(b)
    if va + vb == 0:
        return None, None
    t = (statistics.mean(a) - statistics.mean(b)) / math.sqrt(va + vb)
    dof = (va + vb) ** 2 / (
        va**2 / (len(a) - 1) + vb**2 / (len(b) - 1)
    )
    return t, dof


def fmt_x(value, param):
    if param != "relation_size":
        return f"{value:g}"
    gb = value * 16 / (1024**3)
    return f"{gb:g} GB" if gb >= 1 else f"{int(gb * 1024)} MB"


def med(samples):
    clean = [s for s in samples if s is not None]
    return statistics.median(clean) if clean else float("nan")


def compare(data_dir, prefix, param):
    cas = load(data_dir, prefix, "cas", param)
    cas23 = load(data_dir, prefix, "cas23", param)
    if not cas or not cas23:
        print(f"[!] {param}: missing {'cas' if not cas else 'cas23'}, skipped\n")
        return None

    if cas["param_values"] != cas23["param_values"]:
        raise SystemExit(f"[!] {param}: the two runs swept different x values")

    reps = (f"{cas['reps']} reps/point" if cas["reps"] == cas23["reps"]
            else f"cas {cas['reps']} reps, cas23 {cas23['reps']} reps per point")
    print(f"### {param}   ({reps}, medians)\n")
    print(f"| {param:>10} | cas mops | cas23 mops | cas/cas23 | cas spread | "
          f"cas23 spread | t (Welch) | build cyc/op | probe cyc/op |")
    print("|" + "---|" * 9)

    wins = ties = losses = 0
    ratios = []
    for i, x in enumerate(cas["param_values"]):
        a, b = cas["throughput_samples"][i], cas23["throughput_samples"][i]
        ma, mb = statistics.median(a), statistics.median(b)
        ratio = ma / mb if mb else float("nan")
        ratios.append(ratio)
        t, dof = welch(a, b)
        # A point only counts as decided if the samples separate; otherwise it
        # is a tie whatever the medians say.
        if t is None:
            verdict = "?"
        elif abs(t) < 2.0:
            verdict = "tie"
            ties += 1
        elif t > 0:
            verdict = "cas"
            wins += 1
        else:
            verdict = "cas23"
            losses += 1

        print(
            f"| {fmt_x(x, param):>10} | {ma:8.0f} | {mb:10.0f} | {ratio:9.3f} "
            f"| {min(a):.0f}-{max(a):.0f} | {min(b):.0f}-{max(b):.0f} "
            f"| {('n/a' if t is None else f'{t:+.1f}'):>9} "
            f"| {med(cas['build_cyc_per_op_samples'][i]):.0f} vs "
            f"{med(cas23['build_cyc_per_op_samples'][i]):.0f} "
            f"| {med(cas['probe_cyc_per_op_samples'][i]):.0f} vs "
            f"{med(cas23['probe_cyc_per_op_samples'][i]):.0f} |"
        )

    geo = math.exp(sum(math.log(r) for r in ratios) / len(ratios))
    print(f"\ngeometric-mean cas/cas23 over the sweep: **{geo:.3f}** "
          f"({'cas ahead' if geo > 1 else 'cas23 ahead'} by "
          f"{abs(geo - 1) * 100:.1f}%)")
    print(f"points decided at |t| > 2: cas {wins}, cas23 {losses}, "
          f"indistinguishable {ties}\n")
    return {"param": param, "geo": geo, "wins": wins, "losses": losses, "ties": ties}


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("data_dir", help="tree written by run_join.py, e.g. intel_dual_recheck")
    parser.add_argument("--prefix", default="dual",
                        help="run-name prefix, i.e. <prefix>_cas (default: dual)")
    parser.add_argument("--param", action="append", default=None,
                        help="only this sweep (repeatable; default: relation_size, skew)")
    args = parser.parse_args()

    params = args.param or ["relation_size", "skew"]
    print(f"# cas vs cas23 -- {args.data_dir}\n")
    print("A ratio above 1 means cas is faster. 'spread' is min-max over the "
          "raw samples.\nThe t column is a Welch t on the two sample sets: "
          "positive favours cas, and\n|t| < 2 means the point cannot be "
          "called at these reps.\n")

    summary = [s for s in (compare(args.data_dir, args.prefix, p) for p in params) if s]
    if len(summary) > 1:
        print("### Overall\n")
        for s in summary:
            print(f"- `{s['param']}`: geomean {s['geo']:.3f}, "
                  f"cas wins {s['wins']} / cas23 wins {s['losses']} / "
                  f"ties {s['ties']}")


if __name__ == "__main__":
    main()
