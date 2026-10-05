#!/usr/bin/env python3
"""Run ../macro_uniform/measure_hbm_ceiling.py's lookup ceiling with core clock and power.

The collector is used unchanged (bandwidth_rand -m 256mb -pattern n0a2t64 -inst t1
-mode r, HBM rd/wr counted at the controllers inside the program's own window).
Only its output paths are redirected here, so the stored ceiling json is not
overwritten. turbostat runs on cpu 0 (socket 0) alongside every rep.

    python3 ceiling_with_power.py [--reps 3] [--inst t1 t0 ...]

Needs 64 x 256 MB = 16 GB of 2 MB hugepages on node 2; this script reserves
them and puts the dramhit reservation back at the end.
"""
import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "macro_uniform"))
import measure_hbm_ceiling as m  # noqa: E402

HUGE = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
DRAMHIT_RESERVATION = "n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb"
OUTDIR = HERE / "results" / "ceiling"


def turbostat_rows(path):
    rows = []
    for line in path.read_text().splitlines():
        p = line.split()
        if len(p) >= 4 and p[0] == "0":
            rows.append({"mhz": int(p[1]), "pkg_w": float(p[2]), "unc_mhz": int(p[3])})
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--inst", nargs="+", default=["t1"])
    args = ap.parse_args()

    OUTDIR.mkdir(parents=True, exist_ok=True)
    m.SCRIPT_DIR = OUTDIR          # logs -> results/ceiling/intel_hbm/logs/ceiling/
    (OUTDIR / "intel_hbm").mkdir(exist_ok=True)

    subprocess.run(f"{HUGE} reset && {HUGE} n2_0gb_17408mb n0_0gb_2048mb",
                   shell=True, check=True, stdout=subprocess.DEVNULL)
    results = {"pattern": m.PATTERN, "per_thread": m.PER_THREAD, "runs": []}
    try:
        for inst in args.inst:
            cfg = {"mode": "r", "inst": inst}
            for rep in range(1, args.reps + 1):
                ts = OUTDIR / f"turbostat_{inst}_rep{rep}.txt"
                tproc = subprocess.Popen(
                    ["sudo", "turbostat", "--quiet", "--cpu", "0", "--show",
                     "CPU,Bzy_MHz,PkgWatt,UncMHz", "-i", "0.5", "-o", str(ts)])
                time.sleep(1)
                t0 = time.monotonic()
                r = m.run("lookup", cfg, "0x2f", rep)
                dt = time.monotonic() - t0
                subprocess.run(["sudo", "pkill", "turbostat"])
                tproc.wait()
                rows = turbostat_rows(ts) if ts.exists() else []
                busy = [x for x in rows if x["pkg_w"] > 330]   # loop running
                entry = {"inst": inst, "rep": rep, "wall_s": round(dt, 1), **(r or {}),
                         "turbostat": rows}
                if busy:
                    entry["loop_mhz"] = [x["mhz"] for x in busy]
                    entry["loop_pkg_w"] = [x["pkg_w"] for x in busy]
                    entry["loop_unc_mhz"] = [x["unc_mhz"] for x in busy]
                results["runs"].append(entry)
                print(f"-inst {inst} rep {rep}: total {entry.get('total_gbps')} GB/s "
                      f"(peak {entry.get('peak_total_gbps')}, program {entry.get('prog_reported_gbps')}) "
                      f"| {entry.get('intervals')} x 100 ms | MHz {entry.get('loop_mhz')} "
                      f"| W {entry.get('loop_pkg_w')} | unc {entry.get('loop_unc_mhz')}", flush=True)
    finally:
        subprocess.run(f"{HUGE} reset && {HUGE} {DRAMHIT_RESERVATION}",
                       shell=True, stdout=subprocess.DEVNULL)
    (OUTDIR / "ceiling_with_power.json").write_text(json.dumps(results, indent=2))
    print(f"[OK] {OUTDIR / 'ceiling_with_power.json'}")


if __name__ == "__main__":
    main()
