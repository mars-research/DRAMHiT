#!/usr/bin/env python3
"""Package power per instruction class, below the power cap, relative to the idle spin loop.

    energy_classes.py [--threads 16] [--reps 3] [--classes add imul ...]

For each class (throttling/spin.c: 8 independent chains, unrolled, L1-resident data) it runs
    idle (all cpus in POLL)  ->  class on N cpus (one per core)  ->  idle
through uncore_sweep.run(), i.e. one perf stream with RAPL package energy and, on the N busy
cpus, cycles / ref-cycles / instructions. The two idle runs bracket each class so slow drift
(die temperature moves the leakage power) cancels. Per class:
  dW        median package W of the run minus the mean of the two idle medians
  IPC, GHz  on the N busy cpus
  pJ/instr  dW / (N x IPC x GHz) -- energy per retired instruction RELATIVE TO the POLL loop
            those cpus would otherwise execute (with C-states disabled every idle cpu spins in
            POLL at 2.7 GHz, which is not free). Not an absolute per-instruction energy.
N = 16 threads (one per core) keeps every class under the 350 W cap, so core and mesh clocks
stay at 2.694 / 2.494 GHz; runs where either moved are flagged, since their dW includes a
frequency change.
"""
import argparse
import json
import statistics as st
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "throttling"))
import uncore_sweep as us  # noqa: E402
import license_sweep as ls  # noqa: E402

CLASSES = ["nop", "add", "imul", "crc", "load", "store", "ymmadd", "zload", "vcmp", "compress",
           "pack", "pf0", "bcast", "zmmlight", "zmmheavy"]


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--threads", type=int, default=16)
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--classes", nargs="+", default=CLASSES)
    ap.add_argument("--out", default="classes")
    args = ap.parse_args()
    n = args.threads
    out = HERE / "results" / args.out
    out.mkdir(parents=True, exist_ok=True)
    us.OUT = out
    us.CONFIGS[f"idle_{n}"] = ("idle", None, n)
    for cl in args.classes:
        us.CONFIGS[f"cls_{cl}_{n}"] = ("spin", cl, n)
    us.SPIN_SECONDS = 4
    res = []
    for rep in range(1, args.reps + 1):
        for cl in args.classes:
            time.sleep(us.PAUSE_S)
            b0 = us.run(f"idle_{n}", rep * 100 + 1)
            r = us.run(f"cls_{cl}_{n}", rep)
            b1 = us.run(f"idle_{n}", rep * 100 + 2)
            idle_w = (b0["pkg_w"] + b1["pkg_w"]) / 2
            d_w = r["pkg_w"] - idle_w
            ips = n * r["ipc"] * r["core_ghz"] * 1e9
            idle_ips = n * (b0["ipc"] + b1["ipc"]) / 2 * ((b0["core_ghz"] + b1["core_ghz"]) / 2) * 1e9
            row = {"class": cl, "rep": rep, "pkg_w": r["pkg_w"], "idle_w": round(idle_w, 2),
                   "dW": round(d_w, 2), "dW_per_cpu": round(d_w / n, 3), "ipc": round(r["ipc"], 2),
                   "core_ghz": r["core_ghz"], "mesh_ghz": r["cha_ghz"],
                   "pj_per_instr": round(d_w / (ips - idle_ips) * 1e12, 1) if ips > idle_ips else None,
                   "idle_ipc": round((b0["ipc"] + b1["ipc"]) / 2, 2),
                   "flag": "clock moved" if r["core_ghz"] < 2.68 or r["cha_ghz"] < 2.48 else ""}
            res.append(row)
            print(f"{cl:<9} rep{rep}: pkg {r['pkg_w']:6.1f} W (idle {idle_w:6.1f}) dW {d_w:5.1f} W "
                  f"= {d_w / n:4.2f} W/cpu | IPC {row['ipc']:4.2f} @ {r['core_ghz']:.3f} GHz | "
                  f"{row['pj_per_instr']} pJ/instr rel. to POLL (POLL IPC {row['idle_ipc']}) {row['flag']}", flush=True)
            (out / "classes.json").write_text(json.dumps(res, indent=1))
    print("\nmedian over reps:")
    for cl in args.classes:
        rows = [x for x in res if x["class"] == cl]
        print(f"{cl:<9} dW/cpu {st.median(x['dW_per_cpu'] for x in rows):5.2f} W | IPC {st.median(x['ipc'] for x in rows):4.2f} | "
              f"{st.median(x['pj_per_instr'] for x in rows if x['pj_per_instr']):6.1f} pJ/instr "
              f"({min(x['pj_per_instr'] for x in rows if x['pj_per_instr']):.0f}-{max(x['pj_per_instr'] for x in rows if x['pj_per_instr']):.0f})")


if __name__ == "__main__":
    main()
