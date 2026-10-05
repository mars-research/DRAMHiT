#!/usr/bin/env python3
"""Top-down (TMA level 2) breakdown per phase: where do the issue slots go?

    tma_profile.py dramhit <binary> [--fill 10] [--ht-size N --read-factor N] [--tag T]
    tma_profile.py bw <inst> [--threads 64] [--mem 256mb] [--pad N] [--bwbin path] [--tag T]

Runs the workload under `perf stat -a --per-socket -I 200 -x, -M TopdownL2` (the whole metric
group is scheduled together, so nothing is multiplexed), takes socket 0's rows, splits them by
the program's phase markers like mlp_profile.py, drops the first and last interval of a phase
and reports the median per metric. The eight categories partition the pipeline slots:
  retiring:   light_operations, heavy_operations
  frontend:   fetch_latency, fetch_bandwidth
  bad spec:   branch_mispredicts, machine_clears
  backend:    memory_bound (stalled on the memory hierarchy), core_bound (stalled on execution
              resources or dependencies)
"""
import argparse
import json
import statistics as st
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
import mlp_profile as m  # noqa: E402

CATS = ["light_operations", "heavy_operations", "fetch_latency", "fetch_bandwidth",
        "branch_mispredicts", "machine_clears", "memory_bound", "core_bound"]


def run(cmd, markers, tag):
    m.wait_cool()
    full = f"sudo perf stat -a --per-socket -I 200 -x, -M TopdownL2 -- {cmd}"
    out = subprocess.run(full, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True).stdout
    (HERE / "logs").mkdir(exist_ok=True)
    (HERE / "logs" / f"{tag}_tma.log").write_text(f"$ {full}\n\n{out}")
    phase, rows = None, defaultdict(lambda: defaultdict(dict))
    for line in out.splitlines():
        for mark, name in markers:
            if mark in line:
                phase = name
                break
        p = line.strip().split(",")
        if len(p) < 10 or not p[0][:1].isdigit() or p[1].strip() != "S0" or phase is None:
            continue
        if p[9].strip().startswith("%"):
            try:
                rows[phase][float(p[0])][p[9].split()[-1].replace("tma_", "")] = float(p[8])
            except ValueError:
                pass
    res = {}
    for ph, byts in rows.items():
        tss = sorted(byts)
        tss = tss[1:-1] if len(tss) > 4 else tss
        res[ph] = {c: round(st.median(byts[t][c] for t in tss if c in byts[t]), 1)
                   for c in CATS if any(c in byts[t] for t in tss)}
        res[ph]["_intervals"] = len(tss)
    prog = [l for l in out.splitlines() if "get_mops" in l or "Bandwidth" in l]
    return res, (prog[-1].strip() if prog else "")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("kind", choices=["dramhit", "bw"])
    ap.add_argument("what")
    ap.add_argument("--fill", type=int, default=10)
    ap.add_argument("--ht-size", type=int)
    ap.add_argument("--read-factor", type=int)
    ap.add_argument("--threads", type=int, default=64)
    ap.add_argument("--mem", default="256mb")
    ap.add_argument("--pad", type=int, default=0)
    ap.add_argument("--bwbin")
    ap.add_argument("--tag")
    a = ap.parse_args()
    if a.kind == "dramhit":
        m.c.DRAMHIT = a.what
        if a.ht_size:
            m.c.HT_SIZE = a.ht_size
        if a.read_factor:
            m.c.READ_FACTOR = a.read_factor
        cmd = m.c.dramhit_cmd(dict(m.c.TABLES["cas_hwpf_off"]), a.fill, with_bw=False)[len("sudo "):]
        markers = [("test insert start", "insert"), ("test insert end", None),
                   ("test find start", "find"), ("test find end", None)]
        tag = a.tag or f"tma_dh_{Path(a.what).parent.name}_f{a.fill}"
    else:
        cmd = (f"{a.bwbin or m.ls.BIN} -m {a.mem} -pattern n0a2t{a.threads} -freq 2.7 -inst {a.what} "
               f"-pad {a.pad} -near 8 -lookahead 64 -mode r")
        markers = [("Start perf collection", "run"), ("End perf collection", None)]
        tag = a.tag or f"tma_bw_{a.what}_p{a.pad}"
    res, prog = run(cmd, markers, tag)
    print(f"== {tag}   {prog}")
    for ph, d in res.items():
        be = d.get("memory_bound", 0) + d.get("core_bound", 0)
        ret = d.get("light_operations", 0) + d.get("heavy_operations", 0)
        fe = d.get("fetch_latency", 0) + d.get("fetch_bandwidth", 0)
        bs = d.get("branch_mispredicts", 0) + d.get("machine_clears", 0)
        print(f"  {ph:<7} retiring {ret:5.1f} | frontend {fe:5.1f} | bad-spec {bs:4.1f} | backend {be:5.1f} "
              f"(memory {d.get('memory_bound', 0):5.1f}, core {d.get('core_bound', 0):5.1f})   [{d['_intervals']} ivs]")
    (HERE / "results").mkdir(exist_ok=True)
    (HERE / "results" / f"{tag}.json").write_text(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
