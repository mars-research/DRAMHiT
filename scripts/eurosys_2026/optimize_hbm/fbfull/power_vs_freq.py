#!/usr/bin/env python3
"""How much of the package power depends on the core clock?

    power_vs_freq.py [--caps 800 1200 1600 2000 2400 2700] [--reps 2]

At each core clock (cpufreq cap on node 0's cpus, socket 1 untouched) it measures, with the
same one-perf-stream helper as the other sweeps (RAPL package energy, core clock, mesh clock):
  idle     all 64 cpus of socket 0 in the POLL idle loop (C-states are disabled on this box)
  add x32  32 threads (one per core) of the integer `add` class, IPC ~4
Both are below the 350 W cap, so nothing is throttled except by the cap itself. The idle curve
is the part of the package power the clock sets with no work done; the difference between the
two curves is the part that depends on the clock AND on work. Caps are restored in a finally.
"""
import argparse
import json
import statistics as st
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "throttling"))
import uncore_sweep as us  # noqa: E402
from cpufreq_cap import capped  # noqa: E402
import time  # noqa: E402


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--caps", type=int, nargs="+", default=[800, 1200, 1600, 2000, 2400, 2700])
    ap.add_argument("--reps", type=int, default=2)
    args = ap.parse_args()
    out = HERE / "results" / "power_vs_freq"
    out.mkdir(parents=True, exist_ok=True)
    us.OUT = out
    us.SPIN_SECONDS = 4
    us.CONFIGS["idle_64"] = ("idle", None, 64)
    us.CONFIGS["cls_add_32"] = ("spin", "add", 32)
    res = []
    for rep in range(1, args.reps + 1):
        for cap in args.caps:
            with capped(cap):
                time.sleep(2)
                for label in ("idle_64", "cls_add_32"):
                    time.sleep(us.PAUSE_S)
                    r = us.run(label, rep)
                    res.append({"cap_mhz": cap, "rep": rep, "label": label, "pkg_w": r["pkg_w"],
                                "core_ghz": r["core_ghz"], "mesh_ghz": r["cha_ghz"], "ipc": r["ipc"]})
                    print(f"cap {cap:4d} MHz rep{rep} {label:<11} pkg {r['pkg_w']:6.1f} W | core {r['core_ghz']:.3f} GHz | "
                          f"mesh {r['cha_ghz']:.3f} GHz | IPC {r['ipc']:.2f}", flush=True)
                    (out / "power_vs_freq.json").write_text(json.dumps(res, indent=1))
    print("\nmedian over reps:")
    for label in ("idle_64", "cls_add_32"):
        print(label)
        for cap in args.caps:
            rows = [x for x in res if x["label"] == label and x["cap_mhz"] == cap]
            print(f"  {cap:4d} MHz: {st.median(x['pkg_w'] for x in rows):6.1f} W  core {st.median(x['core_ghz'] for x in rows):.3f}  mesh {st.median(x['mesh_ghz'] for x in rows):.3f}")


if __name__ == "__main__":
    main()
