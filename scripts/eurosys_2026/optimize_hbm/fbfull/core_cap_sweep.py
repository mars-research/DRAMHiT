#!/usr/bin/env python3
"""Does capping the core clock let the mesh keep its clock, and does find throughput change?

    core_cap_sweep.py [--binary attempt4/rck/dramhit] [--caps 2700 2200 2000 1800 2400 1600 2700]

For each cpufreq cap on node 0's cpus (restored afterwards), one run_uniform_hbm.py --energy
run of the dramblast uniform benchmark (fills 10 and 90, 64 threads, table in HBM node 2),
recording Mops, package power, core clock, mesh clock and nJ/op per phase. The default order
puts the stock 2700 MHz first and last, so drift during the session shows up as a difference
between the two control rows; the caps in between are shuffled so a trend is not a drift.
"""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
OPT = HERE.parent
sys.path.insert(0, str(HERE))
from cpufreq_cap import capped  # noqa: E402


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--binary", default=str(OPT / "attempt4" / "rck" / "dramhit"))
    ap.add_argument("--caps", type=int, nargs="+", default=[2700, 2200, 2000, 1800, 2400, 1600, 2700])
    ap.add_argument("--fills", type=int, nargs="+", default=[10, 90])
    ap.add_argument("--tag", default="cap")
    args = ap.parse_args()
    fill_args = [a for f in args.fills for a in ("--fill", str(f))]
    for i, cap in enumerate(args.caps):
        tag = f"{args.tag}_{i}_{cap}"
        with capped(cap):
            time.sleep(2)
            p = subprocess.run([sys.executable, str(OPT / "run_uniform_hbm.py"), "--config", "baseline",
                                "--energy", "--reps", "1", *fill_args, "--no-hugepages",
                                "--binary", args.binary, "--tag", tag], capture_output=True, text=True)
        lines = [l for l in p.stdout.splitlines() if "energy fill" in l or "=> " in l or "[!]" in l]
        print(f"--- cap {cap} MHz ({tag})", *lines, sep="\n  ", flush=True)


if __name__ == "__main__":
    main()
