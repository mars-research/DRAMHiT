#!/usr/bin/env python3
"""Ground truth for the uiCA memory-system extension: dramblast deep build (d760/dvk_rka) on the
CloudLab d760 (2x Xeon Gold 6548Y+, Emerald Rapids), socket 0 only.

Same protocol as optimize_hbm's a24 workloads (report-bwgap.md §40), except the table is in socket 0's
DDR5 (numa node 0) instead of HBM:
    64 threads on node 0 (np_cpu_node_msk 1), table bound to node 0 (np_mem_node_msk 1)
    uniform (mode 11), ht-type 3, 2^29 x 16 B = 8 GiB table, find queue 128, batch 64,
    read factor (4000 + f/2) // f, insert factor 100, KEY_PF_DIST=64 KEY_PF_HINT=t2
Machine state (checked before every run): core 2.5 GHz pinned, no turbo, C-states off, uncore 2.5 GHz,
MSR 0x1a4 = 0x2f (all hardware prefetchers off).

    python3 run_ground_truth.py [--fills 10 70] [--plain-reps 3] [--ctr-reps 2] [--sets base fb ...]

Per run: logs/<fill>/<set>_r<rep>.txt (dramhit + perf -I stream). Summary: results.json.
Counter rows are attributed to a phase by the last dramhit phase marker before them; the first and last
interval of the find phase are dropped. Per-find value = event count over the kept intervals /
(finds per second of that run x kept time). Core events are summed over socket 0 = the 64 benchmark cpus.
"""
import argparse, json, re, statistics, subprocess, sys, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
BIN = HERE / "dvk_rka" / "dramhit"
GHZ = 2.5           # core clock = TSC rate on this machine (pinned)
THREADS = 64
SEED = 1775762440565610239
INTERVAL_MS = 100
PHASE_MARKS = [("zipfian test insert start", "set"), ("zipfian test insert end", None),
               ("zipfian test find start", "get"), ("zipfian test find end", None)]

FIXED = ["cycles", "instructions", "ref-cycles"]
UNCORE = ["unc_m_cas_count.rd", "unc_m_cas_count.wr",
          "unc_cha_tor_inserts.ia_miss_drd", "unc_cha_tor_occupancy.ia_miss_drd",
          "unc_cha_tor_inserts.ia_miss_drd_pref"]   # TOR occupancy: one event per CHA (counter 0 only)
# 4 programmable core counters per set (with HT on), so nothing is multiplexed
SETS = {
    "base":    ["offcore_requests_outstanding.data_rd", "offcore_requests.data_rd",
                "offcore_requests_outstanding.cycles_with_data_rd", "l1d_pend_miss.fb_full"],
    "fb":      ["l1d_pend_miss.pending", "l1d_pend_miss.pending_cycles", "l1d_pend_miss.fb_full",
                "l1d_pend_miss.l2_stalls"],
    "swpf":    ["sw_prefetch_access.t1_t2", "sw_prefetch_access.t0", "load_hit_prefetch.swpf",
                "mem_load_retired.fb_hit"],
    "mem":     ["mem_load_retired.l1_hit", "mem_load_retired.l1_miss", "mem_load_retired.l2_miss",
                "mem_load_retired.l3_miss"],
    "l2":      ["l2_rqsts.swpf_miss", "l2_rqsts.swpf_hit", "l2_lines_in.all", "l1d.replacement"],
    "stall":   ["resource_stalls.sb", "resource_stalls.scoreboard", "cycle_activity.stalls_total",
                "cycle_activity.stalls_l1d_miss"],
    "td":      ["uops_issued.any", "topdown.backend_bound_slots", "topdown.memory_bound_slots",
                "topdown.bad_spec_slots"],
    "ports_a": ["uops_dispatched.port_0", "uops_dispatched.port_1", "uops_dispatched.port_5_11",
                "uops_dispatched.port_6"],
    "ports_b": ["uops_dispatched.port_2_3_10", "uops_dispatched.port_4_9", "uops_dispatched.port_7_8",
                "int_misc.mba_stalls"],
    "br":      ["br_misp_retired.all_branches", "br_inst_retired.all_branches", "int_misc.recovery_cycles",
                "uops_retired.slots"],
}


def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout.strip()


def check_machine():
    """Refuse to run unless the machine is in the setup.sh state."""
    bad = []
    freqs = set(sh("cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_m*_freq").split())
    if freqs != {"2500000"}: bad.append(f"cpufreq min/max {freqs}")
    if sh("cat /sys/devices/system/cpu/intel_pstate/no_turbo") != "1": bad.append("turbo on")
    pf = set(sh('sudo env PATH="$PATH" rdmsr -a 0x1a4').split())
    if pf != {"2f"}: bad.append(f"MSR 0x1a4 {pf}")
    unc = set(sh("cat /sys/devices/system/cpu/intel_uncore_frequency/package_0*/m*_freq_khz").split())
    if unc != {"2500000"}: bad.append(f"uncore {unc}")
    if bad:
        sys.exit("machine not set up: " + "; ".join(bad))


def dramhit_cmd(fill):
    rf = (4000 + fill // 2) // fill
    return (f"env KEY_PF_DIST=64 KEY_PF_HINT=t2 {BIN} --mode 11 --ht-type 3 --ht-size 536870912 "
            f"--ht-fill {fill} --num-threads {THREADS} --numa-split 10 --np_cpu_node_msk 1 "
            f"--np_mem_node_msk 1 --np_mem_local 0 --batch-len 64 --find_queue 128 --no-prefetch 0 "
            f"--hw-pref 0 --insert-factor 100 --read-factor {rf} --skew 0.01 --seed {SEED}")


def parse_stats(out):
    g = lambda k: int(re.search(rf"{k} : (\d+)", out).group(1))
    s = {k: g(k) for k in ("global_find_cycle", "find_ops", "found", "global_insert_cycle", "insert_ops",
                           "set_cycles", "get_cycles", "set_mops", "get_mops")}
    assert s["found"] == s["find_ops"], "found != find_ops"
    s["find_s"] = s["global_find_cycle"] / (GHZ * 1e9)
    s["finds_per_s"] = s["find_ops"] / s["find_s"]
    s["thread_cycles_per_find"] = s["global_find_cycle"] * THREADS / s["find_ops"]
    s["insert_s"] = s["global_insert_cycle"] / (GHZ * 1e9)
    s["inserts_per_s"] = s["insert_ops"] / s["insert_s"]
    return s


def parse_intervals(out, phase_want="get"):
    """-> {event: (summed count over kept intervals, kept seconds)} for socket 0, phase `phase_want`."""
    phase, rows = None, {}            # ts -> {ev: count}
    tsphase = {}
    for line in out.splitlines():
        for mark, ph in PHASE_MARKS:
            if mark in line:
                phase = ph
        p = line.strip().split(",")
        if len(p) < 8 or not p[0][:1].isdigit() or p[1] != "S0":
            continue
        try:
            ts, cnt = float(p[0]), float(p[3])
        except ValueError:
            continue                  # <not counted>
        m = re.match(r"[0-9.]+", p[7])   # a dramhit log line can be spliced onto a row (shared pipe)
        pct = float(m.group(0)) if m else 100.0
        assert pct > 99.0, f"multiplexed: {line}"
        rows.setdefault(ts, {})[p[5]] = cnt
        tsphase.setdefault(ts, phase)
    allts = sorted(rows)
    keep = [t for t in allts if tsphase[t] == phase_want]
    keep = keep[1:-1]                 # boundary intervals straddle a phase change
    dt = {t: t - allts[allts.index(t) - 1] for t in keep}
    secs = sum(dt.values())
    evs = {e for t in keep for e in rows[t]}
    return {e: sum(rows[t].get(e, 0.0) for t in keep) for e in evs}, secs, len(keep)


def run(cmd, logf):
    t0 = time.time()
    out = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True).stdout
    logf.write_text(out)
    return out, time.time() - t0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fills", type=int, nargs="+", default=[10, 70])
    ap.add_argument("--plain-reps", type=int, default=3)
    ap.add_argument("--ctr-reps", type=int, default=2)
    ap.add_argument("--sets", nargs="+", default=list(SETS))
    ap.add_argument("--out", default=str(HERE / "results.json"))
    args = ap.parse_args()
    outp = Path(args.out)
    res = json.loads(outp.read_text()) if outp.exists() else {}
    res.setdefault("binary", str(BIN))
    res["md5"] = sh(f"md5sum {BIN}").split()[0]

    plan = [(f, "plain", r) for r in range(args.plain_reps) for f in args.fills]
    plan += [(f, s, r) for r in range(args.ctr_reps) for s in args.sets for f in args.fills]
    for i, (fill, cset, rep) in enumerate(plan):
        if any(e["rep"] == rep for e in res.get(str(fill), {}).get(cset, [])):
            continue                  # resume: already measured
        check_machine()
        d = HERE / "logs" / f"f{fill}"; d.mkdir(parents=True, exist_ok=True)
        cmd = "sudo " + dramhit_cmd(fill)
        if cset != "plain":
            ev = ",".join(FIXED + SETS[cset] + UNCORE)
            cmd = f"sudo perf stat -a --per-socket -I {INTERVAL_MS} -x, -e {ev} -- " + dramhit_cmd(fill)
        out, wall = run(cmd, d / f"{cset}_r{rep}.txt")
        st = parse_stats(out)
        ent = res.setdefault(str(fill), {}).setdefault(cset, [])
        rec = {"rep": rep, "stats": st, "wall_s": round(wall, 1)}
        if cset != "plain":
            cnt, secs, n = parse_intervals(out)
            fps = st["finds_per_s"]
            rec["kept_intervals"], rec["kept_s"] = n, round(secs, 3)
            rec["per_find"] = {e: c / (fps * secs) for e, c in cnt.items()}
            rec["per_s"] = {e: c / secs for e, c in cnt.items()}
        ent[:] = [e for e in ent if e["rep"] != rep] + [rec]
        outp.write_text(json.dumps(res, indent=1))
        msg = f"[{i+1}/{len(plan)}] fill {fill} {cset} r{rep}: {st['get_cycles']} cyc/find, {st['get_mops']} Mops"
        if cset != "plain":
            pf = rec["per_find"]
            msg += f", core cyc/find {pf['cycles']:.1f}, instr/find {pf['instructions']:.1f}, " \
                   f"DRAM rd lines/find {pf['unc_m_cas_count.rd']:.2f} ({n} intervals)"
        print(msg, flush=True)
    print("DONE")


if __name__ == "__main__":
    main()
