#!/usr/bin/env python3
"""HBM bandwidth, package power and core clock of bandwidth_rand per instruction mode.

    python3 license_sweep.py [--threads 64 8] [--inst t1 load avx512 t1avx512 t1avx512heavy] [--reps 3]

Each run is machine_stats/build/bandwidth_rand -m 256mb -pattern n0a2t<N> -freq 2.7
-lookahead 64 -mode r -inst <inst>, the same configuration as
../../macro_uniform/measure_hbm_ceiling.py, with N threads on node 0's cpus and the
buffers on HBM node 2. It is measured by two perf instances, both sampled every 100 ms:
  outer  perf stat --per-socket -I 100: uncore_hbm_* rd/wr CAS (32 B each, summed over
         boxes) and power/energy-pkg/, i.e. HBM GB/s and package watts per socket
  inner  perf stat -C <the N busy cpus> -I 100: cycles and ref-cycles, so the core clock
         of the cpus doing the work is cycles / ref-cycles * 2.7 GHz. (turbostat on one
         cpu cannot separate a working cpu from an idle one here: with C-states off the
         idle ones spin in POLL and look 100% busy.)
Only intervals inside the program's "Start/End perf collection" markers are used; its
page faulting runs outside them. Each run is summarised twice, for the first 1 s (while
the package still has PL1 headroom) and for everything after (sustained).

Hugepages: 16 GB of 2 MB pages on node 2 for the run. The dramhit reservation is
restored at the end.
"""
import argparse
import json
import re
import statistics as st
import subprocess
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
BIN = HERE.parents[1] / "machine_stats" / "build" / "bandwidth_rand"
PREFETCH = "/opt/DRAMHiT/scripts/prefetch_control_hbm.sh"
HUGE = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
DRAMHIT_RESERVATION = "n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb"
REF_GHZ = 2.7
BYTES_PER_CAS = 32
OUT = HERE / "results"


def node_cpus(node):
    text = Path(f"/sys/devices/system/node/node{node}/cpulist").read_text().strip()
    cpus = []
    for part in text.split(","):
        a, _, b = part.partition("-")
        cpus += list(range(int(a), int(b or a) + 1))
    return cpus


def hbm_events():
    pat = re.compile(r"uncore_hbm_(\d+)$")
    boxes = sorted(int(m.group(1)) for m in
                   (pat.match(p.name) for p in Path("/sys/devices").glob("uncore_hbm_*")) if m)
    enc = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
    return ",".join(f"uncore_hbm_{i}/{e},name=mem_{n}/" for i in boxes for n, e in enc.items())


def run(inst, threads, rep):
    cpus = node_cpus(0)[:threads]   # bandwidth_rand pins thread k to the k-th cpu of node 0
    core_csv = OUT / "logs" / f"{inst}_t{threads}_rep{rep}.core.csv"
    log = OUT / "logs" / f"{inst}_t{threads}_rep{rep}.log"
    log.parent.mkdir(parents=True, exist_ok=True)
    prog = (f"{BIN} -m 256mb -pattern n0a2t{threads} -freq {REF_GHZ} -inst {inst} "
            f"-lookahead 64 -mode r")
    inner = (f"perf stat -C {','.join(map(str, cpus))} -I 100 -x, -e cycles,ref-cycles "
             f"-o {core_csv} -- {prog}")
    cmd = (f"sudo perf stat --per-socket -I 100 -x, -e {hbm_events()},power/energy-pkg/ "
           f"-- {inner}")
    out = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True).stdout
    log.write_text(f"$ {cmd}\n\n{out}")

    # outer rows: ts,S0,<ncpus>,count,unit,event,run_ns,...  (energy-pkg: count in Joules)
    hbm = defaultdict(lambda: [0.0, 0.0, 0.0, 0])   # ts -> [rd, wr, sum run_ns, boxes]
    joules = defaultdict(float)
    win, t_start, t_end, last_ts = False, None, None, 0.0
    for line in out.splitlines():
        if "Start perf collection" in line:
            t_start = last_ts
            continue
        if "End perf collection" in line:
            t_end = last_ts
            continue
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit():
            continue
        try:
            ts = float(p[0])
        except ValueError:
            continue
        last_ts = ts
        if p[1].strip() != "S0" or "<not" in line:
            continue
        ev = p[5].strip() if len(p) > 5 else ""
        try:
            cnt = float(p[3])
        except ValueError:
            continue
        if ev.startswith("power/energy-pkg"):
            joules[ts] = cnt
        elif ev in ("mem_rd", "mem_wr"):
            try:
                ns = float(p[6])
            except (ValueError, IndexError):
                continue
            # count/run_ns per box, times boxes, gives CAS per ns for the socket
            h = hbm[ts]
            h[0 if ev == "mem_rd" else 1] += cnt
            h[2] += ns
            h[3] += 1
    if t_start is None:
        return None
    t_end = t_end if t_end is not None else last_ts

    core = defaultdict(dict)
    for line in core_csv.read_text().splitlines() if core_csv.exists() else []:
        p = line.strip().split(",")
        if len(p) >= 4 and p[0][:1].isdigit():
            try:
                core[float(p[0])][p[3].strip()] = float(p[1])   # ts,count,unit,event,...
            except ValueError:
                pass

    rows, prev = [], None
    for ts in sorted(hbm):
        if not (t_start < ts <= t_end):   # interval (ts-0.1, ts] entirely inside the window
            prev = ts
            continue
        rd, wr, ns, boxes = hbm[ts]
        dt = ts - prev if prev is not None else 0.1
        prev = ts
        per_box_ns = ns / boxes if boxes else 0
        gbps = BYTES_PER_CAS * (rd + wr) / per_box_ns if per_box_ns else None
        # the inner perf starts a few ms later, so match its nearest interval
        cts = min(core, key=lambda c: abs(c - ts)) if core else None
        c = core.get(cts, {})
        ghz = REF_GHZ * c["cycles"] / c["ref-cycles"] if c.get("ref-cycles") else None
        rows.append({"t": round(ts - t_start, 2), "hbm_gbps": gbps,
                     "pkg_w": joules[ts] / dt if ts in joules else None, "core_ghz": ghz})
    rows = rows[1:-1] if len(rows) > 2 else rows   # boundary intervals straddle a marker

    def summ(rs):
        def med(k):
            v = [r[k] for r in rs if r[k] is not None]
            return round(st.median(v), 3 if k == "core_ghz" else 1) if v else None
        return {"intervals": len(rs), "hbm_gbps": med("hbm_gbps"), "pkg_w": med("pkg_w"),
                "core_ghz": med("core_ghz")}

    m = re.search(r"Bandwidth\s*:\s*([\d.]+)", out)
    return {"inst": inst, "threads": threads, "rep": rep,
            "prog_gbps": float(m.group(1)) if m else None,
            "all": summ(rows), "first_1s": summ([r for r in rows if r["t"] < 1.0]),
            "after_1s": summ([r for r in rows if r["t"] >= 1.0]), "series": rows}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--threads", type=int, nargs="+", default=[64, 8])
    ap.add_argument("--inst", nargs="+",
                    default=["t1", "load", "avx512", "t1avx512", "t1avx512heavy"])
    ap.add_argument("--reps", type=int, default=3)
    args = ap.parse_args()

    OUT.mkdir(parents=True, exist_ok=True)
    subprocess.run(f'sudo env PATH="$PATH" {PREFETCH} off', shell=True, check=True,
                   stdout=subprocess.DEVNULL)
    subprocess.run(f"{HUGE} reset && {HUGE} n2_0gb_17408mb n0_0gb_2048mb", shell=True,
                   check=True, stdout=subprocess.DEVNULL)
    results = []
    try:
        for threads in args.threads:
            for inst in args.inst:
                for rep in range(1, args.reps + 1):
                    r = run(inst, threads, rep)
                    if r is None:
                        print(f"[!] {inst} t{threads} rep{rep}: no measurement window")
                        continue
                    results.append(r)
                    f, a = r["first_1s"], r["after_1s"]
                    print(f"t{threads:<3} {inst:<14} rep{rep} | first 1s: {f['hbm_gbps']} GB/s "
                          f"{f['core_ghz']} GHz {f['pkg_w']} W | after: {a['hbm_gbps']} GB/s "
                          f"{a['core_ghz']} GHz {a['pkg_w']} W ({a['intervals']} x 100ms) "
                          f"| program {r['prog_gbps']}", flush=True)
                    (OUT / "license_sweep.json").write_text(json.dumps(results, indent=1))
    finally:
        subprocess.run(f"{HUGE} reset && {HUGE} {DRAMHIT_RESERVATION}", shell=True,
                       stdout=subprocess.DEVNULL)
    print(f"[OK] {OUT / 'license_sweep.json'}")


if __name__ == "__main__":
    main()
