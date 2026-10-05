#!/usr/bin/env python3
"""Where is the memory-level parallelism limit? Occupancy counters per phase.

    mlp_profile.py dramhit <binary> [--fill 10] [--find-queue 64] [--batch-len 16]
    mlp_profile.py bw <inst> [--threads 64] [--mem 256mb]          (bandwidth_rand)

The workload is run once per event group (a core has only a few programmable counters, and
multiplexing would blur the ratios), each under
    perf stat -a --per-socket -I 200 -x, -e cycles,instructions,<4 events> -- <cmd>
Socket-0 rows are split into phases by the program's own markers (dramhit: insert / find;
bandwidth_rand: its Start/End perf collection window), the first and last interval of a
phase are dropped, and counts are summed over the rest. All 64 logical cpus of socket 0
run threads in these workloads, so sums are divided by 32 cores where a per-core figure is
meant. Derived (per phase):

  cyc/op             core cycles per op, from the benchmark's own Mops or bandwidth
  fb_full %          l1d_pend_miss.fb_full / cycles: share of cpu-cycles with a request
                     waiting for a free L1 fill buffer
  L1 out/core        l1d_pend_miss.pending / cycles x 2: mean outstanding L1 misses per core
                     (16 fill buffers per core)
  L2q out/core       offcore_requests_outstanding.data_rd / cycles x 2: mean outstanding
                     L2-miss reads per core, from the L2 -> mesh queue
  xq full %          xq.full_cycles / cycles
  lat (ns)           outstanding.data_rd / offcore_requests.data_rd / core GHz: Little's law
                     latency of an L2-miss read as the core sees it
  stall l1d %        cycle_activity.stalls_l1d_miss / cycles: cycles with no uop issued
                     while an L1D miss is outstanding
"""
import argparse
import json
import os
import re
import statistics as st
import subprocess
import sys
import time
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
OPT = HERE.parent
sys.path.insert(0, str(OPT.parent / "macro_uniform"))
sys.path.insert(0, str(OPT / "throttling"))
import collect_data_intel_hbm as c  # noqa: E402
import license_sweep as ls  # noqa: E402

GROUPS = {
    "l1": ["l1d_pend_miss.pending", "l1d_pend_miss.pending_cycles",
           "l1d_pend_miss.fb_full", "l1d_pend_miss.fb_full_periods"],
    "l2": ["offcore_requests_outstanding.data_rd", "offcore_requests.data_rd",
           "offcore_requests_outstanding.cycles_with_data_rd", "xq.full_cycles"],
    # prefetch effectiveness: executed vs accepted by the L2, and how demand loads of the
    # prefetched lines turned out (hit L1, hit a fill buffer = prefetch still in flight, missed)
    "pf": ["sw_prefetch_access.t0", "sw_prefetch_access.t1_t2",
           "l2_rqsts.swpf_hit", "l2_rqsts.swpf_miss"],
    "ld": ["mem_load_retired.l1_miss", "mem_load_retired.fb_hit",
           "mem_load_retired.l2_miss", "load_hit_prefetch.swpf"],
    "st": ["cycle_activity.stalls_l1d_miss", "cycle_activity.stalls_total",
           "cycle_activity.stalls_l2_miss", "l2_rqsts.swpf_hit"],
}
PATH = os.environ["PATH"]


def margin():
    r = subprocess.run(["sudo", "env", f"PATH={PATH}", "rdmsr", "-p", "0", "-f", "22:16", "-d", "0x1b1"],
                       capture_output=True, text=True).stdout.strip()
    return int(r) if r.isdigit() else None


def wait_cool(min_margin=12, timeout=120):
    t0 = time.time()
    while time.time() - t0 < timeout:
        m = margin()
        if m is None or m >= min_margin:
            return
        time.sleep(3)


def run_group(cmd, events, tag):
    wait_cool()
    ev = ",".join(["cycles", "instructions", "ref-cycles"] + events +
                  [c.perf_event_string(), "uncore_cha_0/event=0x01,name=clk_cha/",
                   "unc_m_cas_count.rd", "unc_m_cas_count.wr"])
    full = f"sudo perf stat -a --per-socket -I 200 -x, -e {ev} -- {cmd}"
    out = subprocess.run(full, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True).stdout
    (HERE / "logs").mkdir(exist_ok=True)
    (HERE / "logs" / f"{tag}.log").write_text(f"$ {full}\n\n{out}")
    return out


def parse(out, markers):
    """-> {phase: {event: summed count}}, {phase: intervals}, program text lines."""
    phase = None
    rows = defaultdict(lambda: defaultdict(lambda: defaultdict(float)))   # phase -> ts -> ev -> n
    unc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))        # phase -> ts -> [cas, ns, rows]
    mesh = defaultdict(dict)
    ddr = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))        # phase -> ts -> [cas, ns, rows]
    mux = []
    for line in out.splitlines():
        for mark, name in markers:
            if mark in line:
                phase = name
                break
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit() or p[1].strip() != "S0" or "<not" in line:
            continue
        try:
            ts, cnt = float(p[0]), float(p[3])
        except ValueError:
            continue
        if phase is None:
            continue
        name = p[5].strip()
        if name in ("mem_rd", "mem_wr"):
            u = unc[phase][ts]
            u[0] += cnt
            u[1] += float(p[6])
            u[2] += 1
            continue
        if name in ("unc_m_cas_count.rd", "unc_m_cas_count.wr"):
            u = ddr[phase][ts]
            u[0] += cnt
            u[1] += float(p[6])
            u[2] += 1
            continue
        if name == "clk_cha":
            mesh[phase][ts] = cnt / float(p[6])
            continue
        rows[phase][ts][name] += cnt
        try:
            mux.append(float(p[7]))
        except (ValueError, IndexError):
            pass
    sums, nint = {}, {}
    for ph, byts in rows.items():
        tss = sorted(byts)
        if len(tss) > 4:
            tss = tss[1:-1]
        nint[ph] = len(tss)
        tot = defaultdict(float)
        for t in tss:
            for k, v in byts[t].items():
                tot[k] += v
        sums[ph] = dict(tot)
        gb = [32 * unc[ph][t][0] / (unc[ph][t][1] / unc[ph][t][2]) for t in tss if unc[ph][t][2]]
        sums[ph]["_gbps"] = st.median(gb) if gb else None
        dd = [64 * ddr[ph][t][0] / (ddr[ph][t][1] / ddr[ph][t][2]) for t in tss if ddr[ph][t][2]]
        sums[ph]["_ddr"] = st.median(dd) if dd else None
        ms = [mesh[ph][t] for t in tss if t in mesh[ph]]
        sums[ph]["_mesh"] = st.median(ms) if ms else None
    return sums, nint, min(mux) if mux else None


def derive(s, active_threads=64):
    cyc = s["cycles"]
    ghz = None
    ghz = 2.7 * cyc / s["ref-cycles"]
    d = {"core GHz": round(ghz, 3), "mesh GHz": round(s["_mesh"], 3) if s.get("_mesh") else None,
         "HBM GB/s": round(s["_gbps"], 1) if s.get("_gbps") else None,
         "DDR GB/s (rd+wr)": round(s["_ddr"], 1) if s.get("_ddr") else None,
         "instr/cycle": round(s["instructions"] / cyc, 2), "_ghz": ghz}
    g = lambda k: s.get(k)
    if g("l1d_pend_miss.fb_full") is not None:
        d["fb_full %"] = round(100 * g("l1d_pend_miss.fb_full") / cyc, 1)
        d["L1 demand-miss out/thread"] = round(g("l1d_pend_miss.pending") / cyc * 64 / active_threads, 2)
    if g("offcore_requests_outstanding.data_rd") is not None:
        d["L2q out/thread"] = round(g("offcore_requests_outstanding.data_rd") / cyc * 64 / active_threads, 1)
        d["xq full %"] = round(100 * g("xq.full_cycles") / cyc, 1)
        d["_lat_cycles"] = g("offcore_requests_outstanding.data_rd") / g("offcore_requests.data_rd")
        d["offcore rd / instr"] = round(g("offcore_requests.data_rd") / s["instructions"], 4)
    for ev in ("sw_prefetch_access.t0", "sw_prefetch_access.t1_t2", "l2_rqsts.swpf_hit", "l2_rqsts.swpf_miss",
               "mem_load_retired.l1_miss", "mem_load_retired.fb_hit", "mem_load_retired.l2_miss",
               "load_hit_prefetch.swpf"):
        if g(ev) is not None:
            d[f"{ev} /100 instr"] = round(100 * g(ev) / s["instructions"], 3)
    if g("sw_prefetch_access.t0") is not None:
        issued = g("sw_prefetch_access.t0") + g("sw_prefetch_access.t1_t2")
        d["swpf accepted / executed"] = round((g("l2_rqsts.swpf_hit") + g("l2_rqsts.swpf_miss")) / issued, 3)
    if g("cycle_activity.stalls_l1d_miss") is not None:
        d["stall l1d %"] = round(100 * g("cycle_activity.stalls_l1d_miss") / cyc, 1)
        d["stall total %"] = round(100 * g("cycle_activity.stalls_total") / cyc, 1)
    return d


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("kind", choices=["dramhit", "bw"])
    ap.add_argument("what")
    ap.add_argument("--fill", type=int, default=10)
    ap.add_argument("--find-queue", type=int, default=64)
    ap.add_argument("--batch-len", type=int, default=16)
    ap.add_argument("--ht-size", type=int, default=None, help="table entries (default 2^29 = 8 GiB)")
    ap.add_argument("--read-factor", type=int, default=None)
    ap.add_argument("--insert-factor", type=int, default=None)
    ap.add_argument("--threads", type=int, default=64)
    ap.add_argument("--pad", type=int, default=0, help="bandwidth_rand -pad (t1pad / double modes)")
    ap.add_argument("--near", type=int, default=8, help="bandwidth_rand -near (double mode)")
    ap.add_argument("--bwbin", default=None, help="bandwidth_rand binary (default build/bandwidth_rand)")
    ap.add_argument("--mem", default="256mb")
    ap.add_argument("--tag", default=None)
    ap.add_argument("--groups", nargs="+", default=list(GROUPS))
    args = ap.parse_args()

    if args.kind == "dramhit":
        c.DRAMHIT = args.what
        if args.ht_size:
            c.HT_SIZE = args.ht_size
        if args.read_factor:
            c.READ_FACTOR = args.read_factor
        if args.insert_factor:
            c.INSERT_FACTOR = args.insert_factor
        table = dict(c.TABLES["cas_hwpf_off"], batch_len=args.batch_len)
        cmd = c.dramhit_cmd(table, args.fill, with_bw=False)
        cmd = cmd[len("sudo "):].replace("--find_queue 64", f"--find_queue {args.find_queue}")
        markers = [("test insert start", "insert"), ("test insert end", None),
                   ("test find start", "find"), ("test find end", None)]
        tag = args.tag or (f"dramhit_{Path(args.what).parent.name}_f{args.fill}_q{args.find_queue}_b{args.batch_len}"
                           + (f"_s{args.ht_size.bit_length() - 1}" if args.ht_size else ""))
    else:
        cmd = (f"{args.bwbin or ls.BIN} -m {args.mem} -pattern n0a2t{args.threads} -freq 2.7 "
               f"-inst {args.what} -pad {args.pad} -near {args.near} -lookahead 64 -mode r")
        markers = [("Start perf collection", "run"), ("End perf collection", None)]
        tag = args.tag or f"bw_{args.what}_t{args.threads}"

    merged, nint, texts = defaultdict(dict), {}, []
    for gname in args.groups:
        out = run_group(cmd, GROUPS[gname], f"{tag}_{gname}")
        sums, ni, mux = parse(out, markers)
        for ph, s in sums.items():
            merged[ph].update(s)
            nint[ph] = ni[ph]
        prog = [l for l in out.splitlines() if re.search(r"get_mops|set_mops|Bandwidth\s*:", l)]
        texts.append(prog[-1] if prog else "")
        if mux is not None and mux < 99.5:
            print(f"[!] group {gname} was multiplexed ({mux:.0f}% running); ratios are scaled estimates")

    res = {}
    print(f"\n== {tag}   ({'; '.join(sorted(set(t.strip() for t in texts if t)))})")
    for ph, s in merged.items():
        d = derive(s, args.threads if args.kind == "bw" else 64)
        res[ph] = {"intervals": nint[ph], **{k: v for k, v in d.items() if not k.startswith("_")}}
        print(f"-- phase {ph}: {nint[ph]} intervals of 200 ms")
        for k, v in d.items():
            if not k.startswith("_") and v is not None:
                print(f"   {k:<28} {v}")
        if "_lat_cycles" in d:
            ghz = d["_ghz"]
            print(f"   {'avg L2-miss latency':<28} {d['_lat_cycles']:.0f} cycles = {d['_lat_cycles'] / ghz:.0f} ns at {ghz:.2f} GHz")
            res[ph]["lat_ns"] = round(d["_lat_cycles"] / ghz, 1)
    (HERE / "results").mkdir(exist_ok=True)
    (HERE / "results" / f"{tag}.json").write_text(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
