#!/usr/bin/env python3
"""What makes the mesh (uncore) clock drop? One perf stream per run, 100 ms resolution.

    python3 uncore_sweep.py [--reps 3] [--only mem_t1_64 spin_zmmheavy_64 ...]

Every run records, for socket 0 and aligned in one `perf stat --per-socket -I 100`:
  pkg_w       RAPL package power (Joules / interval)
  cha_ghz     mesh clock: UNC_CHA_CLOCKTICKS of uncore_cha_0 / time enabled
  mdf_ghz     memory-die-fabric clock: event 0x01 of uncore_mdf_0
  hbmclk_ghz  HBM controller clock: event 0x01 of uncore_hbm_0
  hbm_gbps    HBM read + write CAS (32 B each) over all 32 boxes
and, from a second perf on the busy cpus only, core_ghz = cycles / ref-cycles x 2.7.
(Idle reads at 2.50 / 2.50 / 0.80 GHz, so the clock events count what they should.)

Workloads (all on socket 0's cpus; thread k on the k-th cpu of node 0):
  idle              nothing runs; the cpus spin in POLL (C-states are disabled)
  mem_t1_<N>        bandwidth_rand -m 256mb -inst t1, N threads: HBM traffic + core work
  spin_<mode>_<N>   throttling/spin.c, N threads, no memory traffic:
                    scalar (integer ALU), zmmlight (512-bit add/xor), zmmheavy (vpmullq)
A 3 s pause separates runs so one run's power does not feed the next one's ~1 s RAPL
average. `pkg_w_avg1s` in each interval is the trailing 1 s mean over the whole stream,
including the lead-in before the measured window, which is the quantity PL1 limits.

Hugepages: 16 GB of 2 MB pages on node 2 for the bandwidth_rand runs; the dramhit
reservation is restored at the end.
"""
import argparse
import json
import re
import statistics as st
import subprocess
import time
from collections import defaultdict
from pathlib import Path

import license_sweep as ls

HERE = Path(__file__).resolve().parent
SPIN = HERE / "build" / "spin"
OUT = HERE / "results" / "uncore"
SPIN_SECONDS = 5
PAUSE_S = 3
MEM_PER_THREAD = "256mb"     # bandwidth_rand -m; pl1_check.py overrides it for longer runs

CLOCKS = ("uncore_cha_0/event=0x01,name=clk_cha/,uncore_mdf_0/event=0x01,name=clk_mdf/,"
          "uncore_hbm_0/event=0x01,name=clk_hbm/")

CONFIGS = {"idle": ("idle", None, 0)}
for n in (8, 16, 24, 32, 48, 64):
    CONFIGS[f"mem_t1_{n}"] = ("mem", "t1", n)
for mode, counts in (("scalar", (16, 32, 64)), ("zmmlight", (64,)), ("zmmheavy", (16, 32, 64))):
    for n in counts:
        CONFIGS[f"spin_{mode}_{n}"] = ("spin", mode, n)


def command(kind, arg, n):
    cpus = ls.node_cpus(0)[:max(n, 1)]
    csv = ",".join(map(str, cpus))
    if kind == "idle":
        return csv, f"sleep {SPIN_SECONDS}"
    if kind == "mem":
        return csv, (f"{ls.BIN} -m {MEM_PER_THREAD} -pattern n0a2t{n} -freq {ls.REF_GHZ} -inst {arg} "
                     f"-lookahead 64 -mode r")
    return csv, f"{SPIN} {arg} {SPIN_SECONDS} {csv}"


def run(label, rep):
    kind, arg, n = CONFIGS[label]
    cpus, prog = command(kind, arg, n)
    logdir = OUT / "logs"
    logdir.mkdir(parents=True, exist_ok=True)
    core_csv = logdir / f"{label}_rep{rep}.core.csv"
    inner = f"perf stat -C {cpus} -I 100 -x, -e cycles,ref-cycles,instructions -o {core_csv} -- {prog}"
    cmd = (f"sudo perf stat -a --per-socket -I 100 -x, "
           f"-e {ls.hbm_events()},power/energy-pkg/,{CLOCKS} -- {inner}")
    out = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True).stdout
    (logdir / f"{label}_rep{rep}.log").write_text(f"$ {cmd}\n\n{out}")

    hbm = defaultdict(lambda: [0.0, 0.0, 0.0, 0])
    ev = defaultdict(dict)       # ts -> {"joules": J, "clk_cha": GHz, ...}
    t_start = t_end = None
    last_ts = 0.0
    for line in out.splitlines():
        if "Start perf collection" in line:
            t_start = last_ts
            continue
        if "End perf collection" in line:
            t_end = last_ts
            continue
        p = line.strip().split(",")
        if len(p) < 7 or not p[0][:1].isdigit():
            continue
        try:
            ts = float(p[0])
        except ValueError:
            continue
        last_ts = ts
        if p[1].strip() != "S0" or "<not" in line:
            continue
        name = p[5].strip()
        try:
            cnt, ns = float(p[3]), float(p[6])
        except ValueError:
            continue
        if name.startswith("power/energy-pkg"):
            ev[ts]["joules"] = cnt
        elif name in ("clk_cha", "clk_mdf", "clk_hbm"):
            ev[ts][name] = cnt / ns if ns else None
        elif name in ("mem_rd", "mem_wr"):
            h = hbm[ts]
            h[0 if name == "mem_rd" else 1] += cnt
            h[2] += ns
            h[3] += 1
    if t_start is None:        # idle has no markers: use the whole stream
        t_start, t_end = 0.0, last_ts
    t_end = t_end if t_end is not None else last_ts

    core = defaultdict(dict)
    if core_csv.exists():
        for line in core_csv.read_text().splitlines():
            p = line.strip().split(",")
            if len(p) >= 4 and p[0][:1].isdigit():
                try:
                    core[float(p[0])][p[3].strip()] = float(p[1])
                except ValueError:
                    pass

    series, prev = [], 0.0
    for ts in sorted(ev):
        dt = ts - prev
        prev = ts
        e = ev[ts]
        h = hbm.get(ts)
        gbps = None
        if h and h[3] and h[2]:
            gbps = ls.BYTES_PER_CAS * (h[0] + h[1]) / (h[2] / h[3])
        c = core.get(min(core, key=lambda x: abs(x - ts)), {}) if core else {}
        series.append({
            "t": round(ts - t_start, 2), "in_window": t_start < ts <= t_end,
            "pkg_w": e["joules"] / dt if "joules" in e and dt > 0 else None,
            "core_ghz": ls.REF_GHZ * c["cycles"] / c["ref-cycles"] if c.get("ref-cycles") else None,
            "ipc": c["instructions"] / c["cycles"] if c.get("instructions") and c.get("cycles") else None,
            "cha_ghz": e.get("clk_cha"), "mdf_ghz": e.get("clk_mdf"),
            "hbmclk_ghz": e.get("clk_hbm"), "hbm_gbps": gbps})
    # trailing 1 s mean of package power over the whole stream, 10 intervals of 100 ms
    for i, r in enumerate(series):
        w = [x["pkg_w"] for x in series[max(0, i - 9):i + 1] if x["pkg_w"] is not None]
        r["pkg_w_avg1s"] = sum(w) / len(w) if w else None
    win = [r for r in series if r["in_window"]]
    win = win[1:-1] if len(win) > 4 else win       # boundary intervals straddle a marker

    def med(k):
        v = [r[k] for r in win if r[k] is not None]
        return round(st.median(v), 3) if v else None

    def first_below(k, thr):
        for r in win:
            if r[k] is not None and r[k] < thr:
                return r["t"]
        return None

    return {"label": label, "kind": kind, "arg": arg, "threads": n, "rep": rep,
            "intervals": len(win), "pkg_w": med("pkg_w"), "pkg_w_avg1s": med("pkg_w_avg1s"),
            "core_ghz": med("core_ghz"), "ipc": med("ipc"), "cha_ghz": med("cha_ghz"), "mdf_ghz": med("mdf_ghz"),
            "hbmclk_ghz": med("hbmclk_ghz"), "hbm_gbps": med("hbm_gbps"),
            "cha_min_ghz": min((r["cha_ghz"] for r in win if r["cha_ghz"]), default=None),
            "t_cha_below_2.45": first_below("cha_ghz", 2.45),
            "t_core_below_2.65": first_below("core_ghz", 2.65),
            "series": series}


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--only", nargs="+", choices=list(CONFIGS))
    args = ap.parse_args()
    labels = args.only or list(CONFIGS)
    if not SPIN.exists():
        raise SystemExit(f"build {SPIN} first (gcc -O2 -mavx512f -mavx512dq -pthread spin.c)")

    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run(f'sudo env PATH="$PATH" {ls.PREFETCH} off', shell=True, check=True,
                   stdout=subprocess.DEVNULL)
    subprocess.run(f"{ls.HUGE} reset && {ls.HUGE} n2_0gb_17408mb n0_0gb_2048mb",
                   shell=True, check=True, stdout=subprocess.DEVNULL)
    results = []
    try:
        for rep in range(1, args.reps + 1):
            for label in labels:
                time.sleep(PAUSE_S)
                r = run(label, rep)
                results.append(r)
                print(f"{label:<18} rep{rep} | {r['intervals']:>2} x100ms | pkg {r['pkg_w']} W "
                      f"(1s avg {r['pkg_w_avg1s']:.0f}) | core {r['core_ghz']} GHz | mesh {r['cha_ghz']} "
                      f"(min {r['cha_min_ghz']}) | mdf {r['mdf_ghz']} | hbmclk {r['hbmclk_ghz']} | "
                      f"HBM {r['hbm_gbps']} GB/s | mesh<2.45 at {r['t_cha_below_2.45']}s, "
                      f"core<2.65 at {r['t_core_below_2.65']}s", flush=True)
                (OUT / "uncore_sweep.json").write_text(json.dumps(results, indent=1))
    finally:
        subprocess.run(f"{ls.HUGE} reset && {ls.HUGE} {ls.DRAMHIT_RESERVATION}", shell=True,
                       stdout=subprocess.DEVNULL)
    print(f"[OK] {OUT / 'uncore_sweep.json'}")


if __name__ == "__main__":
    main()
