#!/usr/bin/env python3
"""E1: the as-shipped comparison. Interleaved repetitions of three workloads, each under
`perf stat -a --per-socket -I 200`, raw output kept.

    python3 run_stream.py [--reps 5] [--workloads bw_t1 bw_double24 dramhit_rck_f10] [--reserve]

Order is rep-major (rep 1: every workload, rep 2: every workload, ...), so drift during the
session spreads over all workloads. Logs: logs/E1_stream/<workload>_r<k>/{cmd.txt,combined.log,meta.json}.
The 1 GiB + 2 MiB hugepage pool is NOT re-reserved between runs (--reserve does it once, first).
"""
import argparse
import subprocess
import sys
from pathlib import Path

import runlib as r

WORKLOADS = {
    "bw_t1":           lambda: r.bw_cmd("t1", pad=0),
    "bw_t1_c2200":     lambda: r.bw_cmd("t1", pad=0),     # same program; run with --cap 2200 (core clock held at 2.2 GHz)
    "bw_double24":     lambda: r.bw_cmd("double", pad=24, near=8),
    "dramhit_rck_f10": lambda: r.dramhit_cmd(fill=10),
    "dramhit_rck_f90": lambda: r.dramhit_cmd(fill=90),
    # attempt6 build = rck + harness change: local key partitions bound to HBM when numa_split == 10
    "dramhit_keyshbm_f10": lambda: r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt6" / "ddrhbm" / "dramhit")),
    "dramhit_keysddr_f10": lambda: "env NO_KEY_BIND=1 " + r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt6" / "ddrhbm" / "dramhit")),
    # E5 mimic stages (bw_double built up toward the find loop); stages 1-4 keep their 64 keys in L1,
    # stage 5 streams dramblast's 0.84 M x 8 B keys per thread: MIMIC_KEY_NODE=2 puts them in HBM, 0 in DDR
    **{f"mimic_s{s}": (lambda s=s: r.bw_cmd("mimic", pad=0, stage=s)) for s in (1, 2, 3, 4)},
    "mimic_s5_keyshbm": lambda: "env MIMIC_KEY_NODE=2 " + r.bw_cmd("mimic", pad=0, stage=5),
    "mimic_s5_keysddr": lambda: "env MIMIC_KEY_NODE=0 " + r.bw_cmd("mimic", pad=0, stage=5),
}

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--start-rep", type=int, default=1)
    ap.add_argument("--workloads", nargs="+", default=["bw_t1", "bw_double24", "dramhit_rck_f10"], choices=list(WORKLOADS))
    ap.add_argument("--interval-ms", type=int, default=200)
    ap.add_argument("--reserve", action="store_true")
    ap.add_argument("--out", default="E1_stream")
    ap.add_argument("--cap", type=int, help="cpufreq cap (MHz) on node 0 cpus, restored after")
    ap.add_argument("--read-factor", type=int, default=100, help="dramhit find passes (longer find phase = more intervals)")
    a = ap.parse_args()
    if a.reserve:
        r.reserve_pool()
    base = r.HERE / "logs" / a.out
    import contextlib
    sys.path.insert(0, str(r.OPT / "fbfull"))
    from cpufreq_cap import capped
    with (capped(a.cap) if a.cap else contextlib.nullcontext()):
        for rep in range(a.start_rep, a.reps + 1):
            for w in a.workloads:
                d = base / f"{w}_r{rep}"
                print(f"[{a.out}] rep {rep}/{a.reps}  {w}", flush=True)
                cmd = WORKLOADS[w]()
                if w.startswith("dramhit"):
                    cmd = cmd.replace("--read-factor 100", f"--read-factor {a.read_factor}")
                r.run_stream(cmd, d, w, a.interval_ms)
    print("[OK]")

if __name__ == "__main__":
    main()
