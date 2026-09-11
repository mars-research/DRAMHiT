#!/usr/bin/env python3
"""Fold a partial relation_size sweep into the collected curve.

Adding one point to a curve means mixing runs taken at different times, so any
point present in both files is treated as a check rather than an update: the
freshly measured value is compared against the stored one and the spread is
reported, loudly if it is larger than run-to-run noise. New points are appended
in size order.

Usage:
  merge_relation_size_points.py <partial.json> <target.json> [--tolerance 0.05]
"""

import argparse
import json
from pathlib import Path

NOISE_TOLERANCE = 0.05  # 5%; the measured run-to-run spread here is ~1%


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("partial", type=Path)
    ap.add_argument("target", type=Path)
    ap.add_argument("--tolerance", type=float, default=NOISE_TOLERANCE)
    ap.add_argument("--replace", action="store_true",
                    help="Overwrite overlapping points with the new values "
                         "instead of only checking them.")
    args = ap.parse_args()

    partial = json.loads(args.partial.read_text())
    if not args.target.exists():
        args.target.write_text(json.dumps(partial, indent=4))
        print(f"[*] {args.target.name} did not exist; wrote the partial sweep as-is")
        return

    target = json.loads(args.target.read_text())
    merged = dict(zip(target["param_values"], target["throughput_mops"]))

    worst = 0.0
    for value, mops in zip(partial["param_values"], partial["throughput_mops"]):
        gib = value * 16 // (1024 ** 3)
        if mops <= 0:
            print(f"    {gib:>3} gb: run failed (0 mops), not merged")
            continue
        if value in merged:
            old = merged[value]
            delta = (mops - old) / old if old else 0.0
            worst = max(worst, abs(delta))
            flag = "" if abs(delta) <= args.tolerance else "   <-- OUTSIDE TOLERANCE"
            action = "replaced" if args.replace else "kept stored"
            print(f"    {gib:>3} gb: stored {old:.0f} vs new {mops:.0f} "
                  f"({delta:+.1%}), {action}{flag}")
            if args.replace:
                merged[value] = mops
        else:
            print(f"    {gib:>3} gb: new point, {mops:.0f} mops")
            merged[value] = mops

    ordered = sorted(merged)
    target["param_values"] = ordered
    target["throughput_mops"] = [merged[v] for v in ordered]
    # Record how the curve was assembled, so a later reader can see that not
    # every point came from one sitting.
    target.setdefault("merged_from", []).append(
        {"file": args.partial.name,
         "sizes_gib": [v * 16 // (1024 ** 3) for v in partial["param_values"]],
         "prefetch": partial.get("prefetch"),
         "cas_prefetch_insertion": partial.get("cas_prefetch_insertion")})
    args.target.write_text(json.dumps(target, indent=4))
    print(f"[*] {args.target.name}: "
          f"{[v * 16 // (1024 ** 3) for v in ordered]} gb"
          + (f"  (worst overlap spread {worst:.1%})" if worst else ""))


if __name__ == "__main__":
    main()
