#!/usr/bin/env python3
"""Splice a per-variant skew sweep into the combined intel_hbm_single_skew.json.

The skew data predates run_single_join.py: one file holds every hashtable plus
radix, written by the older collect_join.py. run_single_join.py writes one file
per variant, so re-collecting a single hashtable means splicing its row back in.

  merge_skew_points.py <variant.json> cas                 # replace cas's row
  merge_skew_points.py <variant.json> cas23 --check-only  # just compare

--check-only compares without writing, which is how a stored row is spot-checked
before the rest of the file is trusted. A replace keeps the points it was not
given, so a partial sweep (--skews) updates only those skews.
"""

import argparse
import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
TARGET = SCRIPT_DIR / "intel_hbm_single_skew.json"

NOISE_TOLERANCE = 0.05


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("variant", type=Path, help="per-variant skew json")
    ap.add_argument("name", help="row to update: a hashtable name, or 'radix'")
    ap.add_argument("--target", type=Path, default=TARGET)
    ap.add_argument("--check-only", action="store_true",
                    help="compare against the stored row without writing")
    ap.add_argument("--tolerance", type=float, default=NOISE_TOLERANCE)
    args = ap.parse_args()

    new = json.loads(args.variant.read_text())
    target = json.loads(args.target.read_text())

    if args.name == "radix":
        stored = dict(zip(target["param_values"], target["radix_join_throughput"]))
    else:
        row = target["hash_join_throughput"].get(args.name)
        if row is None:
            raise SystemExit(f"[!] {args.name} is not a row in {args.target.name}")
        stored = dict(zip(target["param_values"], row))

    worst = 0.0
    merged = dict(stored)
    for skew, mops in zip(new["param_values"], new["throughput_mops"]):
        if mops <= 0:
            print(f"    skew {skew}: run failed (0 mops), left alone")
            continue
        old = stored.get(skew)
        if old:
            delta = (mops - old) / old
            worst = max(worst, abs(delta))
            flag = "" if abs(delta) <= args.tolerance else "   <-- OUTSIDE TOLERANCE"
            action = "checked" if args.check_only else "replaced"
            print(f"    skew {skew}: stored {old:.0f} vs new {mops:.0f} "
                  f"({delta:+.1%}), {action}{flag}")
        else:
            print(f"    skew {skew}: new point, {mops:.0f} mops")
        merged[skew] = mops

    print(f"[*] worst spread {worst:.1%}")
    if args.check_only:
        print("[*] check only, nothing written")
        return

    # Any skew the sweep did not cover keeps its stored value, so a partial
    # re-collection stays a partial update.
    values = sorted(set(target["param_values"]) | set(merged))
    target["param_values"] = values
    series = [merged.get(v, 0.0) for v in values]
    if args.name == "radix":
        target["radix_join_throughput"] = series
    else:
        target["hash_join_throughput"][args.name] = series

    # Carry the repeats through so the plot can shade min/max; the combined
    # file keys them by row, the same way it keys the throughputs.
    new_samples = new.get("throughput_samples")
    if new_samples:
        by_skew = dict(zip(new["param_values"], new_samples))
        stored_samples = target.setdefault("throughput_samples", {})
        prior = dict(zip(target["param_values"],
                         stored_samples.get(args.name) or []))
        prior.update(by_skew)
        stored_samples[args.name] = [prior.get(v, []) for v in values]

    target.setdefault("recollected", {})[args.name] = {
        "file": args.variant.name,
        "skews": new["param_values"],
        "prefetch": new.get("prefetch"),
        "cas_prefetch_insertion": new.get("cas_prefetch_insertion"),
        "repeats": new.get("repeats"),
    }
    args.target.write_text(json.dumps(target, indent=4))
    print(f"[*] {args.target.name}: {args.name} row updated")


if __name__ == "__main__":
    main()
