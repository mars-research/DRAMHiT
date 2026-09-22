#!/usr/bin/env python3
"""Profile the FIND path of dlht vs dramhit on the AMD box, fill 10.

These two are equally fast per core-GHz on the Max 9462 (34.9 vs 34.0) but dlht is 25%
behind dramhit here, so whatever AMD does differently shows up in this pair.

The MLP hypothesis from amd_vs_intel_lookup.md section 6 is directly testable on Zen4:

  ls_alloc_mab_count            in-flight L1 misses summed every cycle, so
                                mab/cycles is the average number of misses a
                                core keeps outstanding -- memory-level parallelism
  ex_no_retire.load_not_complete cycles where retire is blocked on load data
  ls_dmnd_fills_from_sys.*      where demand fills actually came from

Counters are cut to the find phase with the program's own markers; insert runs once
(--insert-factor 1) and find 50 times, so even a mis-cut window would be find-dominated.
Zen4 has 6 general counters per thread, so each pass asks for at most 6 events and the
percent-enabled column is checked.
"""
import os
import re
import subprocess
import sys
from collections import defaultdict

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs", "find_profile")
os.makedirs(OUT, exist_ok=True)

TABLES = {"dramhit": (8, 16), "dlht": (10, 32)}

PASSES = {
    "core": ["ls_not_halted_cyc", "ex_ret_instr", "ex_ret_ops",
             "ls_alloc_mab_count", "ex_no_retire.load_not_complete", "ex_no_retire.all"],
    "mem": ["ls_not_halted_cyc", "ls_dispatch.ld_dispatch",
            "ls_dmnd_fills_from_sys.dram_io_near", "ls_dmnd_fills_from_sys.dram_io_far",
            "ls_dmnd_fills_from_sys.local_ccx", "l2_cache_req_stat.ic_dc_miss_in_l2"],
}


def run(name, ht, batch, events, tag, fill=10, read_factor=50):
    cmd = ["sudo", "perf", "stat", "-e", ",".join(events), "-I", "100", "-x", ",", "--",
           DRAMHIT, "--mode", "11", "--ht-type", str(ht), "--ht-size", str(1 << 29),
           "--ht-fill", str(fill), "--num-threads", "64", "--numa-split", "1",
           "--batch-len", str(batch), "--find_queue", "64", "--no-prefetch", "0",
           "--hw-pref", "0", "--insert-factor", "1", "--read-factor", str(read_factor),
           "--skew", "0.01", "--seed", "1775762440565610239"]
    log = os.path.join(OUT, "{}_{}.log".format(name, tag))
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, text=True).check_returncode()

    tot, pcts, mops = defaultdict(float), [], None
    inphase = False
    for line in open(log):
        if "test find start" in line:
            inphase = True
        elif "test find end" in line:
            inphase = False
        m = re.search(r"get_mops\s*:\s*([\d.]+)", line)
        if m:
            mops = float(m.group(1))
        if not inphase:
            continue
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit():
            continue
        ev = p[3].strip()
        if ev not in events:
            continue
        try:
            tot[ev] += float(p[1])
        except ValueError:
            continue
        if p[5]:
            try: pcts.append(float(p[5]))
            except ValueError: pass
    return tot, (min(pcts) if pcts else 100.0), mops


if __name__ == "__main__":
    res = {}
    for name, (ht, batch) in TABLES.items():
        c, pc, mops = run(name, ht, batch, PASSES["core"], "core")
        m, pm, _ = run(name, ht, batch, PASSES["mem"], "mem")
        res[name] = (c, m, mops, min(pc, pm))

    # ops in the find window = mops/s x (window cycles / cycles-per-second).
    # Simpler and unit-free: everything below is normalised per retired-op or per
    # cycle, and per-lookup figures use the ratio of totals between the two passes
    # scaled by each pass's own cycle count.
    def per_op(tot, key, cyc_key, ops_per_cycle):
        return tot[key] / (tot[cyc_key] * ops_per_cycle) if tot[cyc_key] else 0.0

    print("FIND phase, fill 10, 64 threads, hw prefetch off")
    print("{:<34} {:>12} {:>12} {:>8}".format("metric", "dramhit", "dlht", "dlht/dh"))
    rows = []

    def add(label, f):
        a, b = f("dramhit"), f("dlht")
        rows.append((label, a, b, (b / a) if a else float("nan")))

    def g(name, ev, which=0):
        return res[name][which][ev]

    add("get_mops (throughput)", lambda n: res[n][2])
    add("IPC (instr / cycle)", lambda n: g(n, "ex_ret_instr") / g(n, "ls_not_halted_cyc"))
    add("MLP: avg in-flight L1 misses", lambda n: g(n, "ls_alloc_mab_count") / g(n, "ls_not_halted_cyc"))
    add("stall on load data (% cycles)",
        lambda n: 100 * g(n, "ex_no_retire.load_not_complete") / g(n, "ls_not_halted_cyc"))
    add("any no-retire (% cycles)",
        lambda n: 100 * g(n, "ex_no_retire.all") / g(n, "ls_not_halted_cyc"))
    add("instr per 1k cycles", lambda n: 1000 * g(n, "ex_ret_instr") / g(n, "ls_not_halted_cyc"))
    add("loads per 1k cycles",
        lambda n: 1000 * g(n, "ls_dispatch.ld_dispatch", 1) / g(n, "ls_not_halted_cyc", 1))
    add("local-DRAM fills per 1k cyc",
        lambda n: 1000 * g(n, "ls_dmnd_fills_from_sys.dram_io_near", 1) / g(n, "ls_not_halted_cyc", 1))
    add("remote-DRAM fills per 1k cyc",
        lambda n: 1000 * g(n, "ls_dmnd_fills_from_sys.dram_io_far", 1) / g(n, "ls_not_halted_cyc", 1))
    add("local-CCX fills per 1k cyc",
        lambda n: 1000 * g(n, "ls_dmnd_fills_from_sys.local_ccx", 1) / g(n, "ls_not_halted_cyc", 1))
    add("L2 misses per 1k cycles",
        lambda n: 1000 * g(n, "l2_cache_req_stat.ic_dc_miss_in_l2", 1) / g(n, "ls_not_halted_cyc", 1))

    for label, a, b, r in rows:
        print("{:<34} {:>12.3f} {:>12.3f} {:>8.2f}".format(label, a, b, r))
    print("\nenabled: dramhit {:.0f}%, dlht {:.0f}%".format(res["dramhit"][3], res["dlht"][3]))
