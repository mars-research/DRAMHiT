#!/usr/bin/env python3
"""Are dlht's software prefetches actually landing on Zen4?

amd_vs_intel_lookup.md section 6 found dlht sustains 4.68 in-flight L1 misses to
dramhit's 6.80 and left it there. This asks the next question directly.

dlht's find_batch fires one __builtin_prefetch per key for the whole batch and then
drains the batch with nothing further in flight, so --batch-len IS its prefetch depth,
and at 64 threads on 32 SMT cores it is twice that per core. A software prefetch that
cannot allocate a Miss Address Buffer entry on Zen4 is discarded, so the test is whether
the fraction that reaches the data cache falls as the burst gets deeper:

  ls_pref_instr_disp.all     software prefetch instructions dispatched
  ls_sw_pf_dc_fills.all      ... that actually filled the data cache
  ls_inef_sw_pref.all        ... that were redundant (MAB match / already a DC hit)
  -> disp - inef - fills     is the part the core threw away
  ls_dmnd_fills_from_sys.all demand fills, i.e. the misses left exposed
  ls_alloc_mab_count/cycles  in-flight L1 misses (MLP), as in section 6

dramhit is the control: its find_batch keeps a persistent queue and only drains to
FLUSH_THRESHOLD, so it issues one prefetch per result consumed rather than a burst.

Counters are cut to the find phase with the program's own markers (--insert-factor 1
--read-factor 50 so find dominates either way). Six events exceed Zen4's free counters,
so perf multiplexes; the percent-enabled column is printed and the ratios are the point.
"""
import os
import re
import subprocess
import sys
from collections import defaultdict

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs", "dlht_prefetch")
os.makedirs(OUT, exist_ok=True)

EV = ["ls_not_halted_cyc", "ls_alloc_mab_count", "ls_pref_instr_disp.all",
      "ls_sw_pf_dc_fills.all", "ls_inef_sw_pref.all", "ls_dmnd_fills_from_sys.all"]

# (tag, ht_type, batch_len).  8 = cas23/dramhit, 10 = dlht.
CASES = [("dramhit_b16", 8, 16), ("dlht_b8", 10, 8), ("dlht_b16", 10, 16),
         ("dlht_b32", 10, 32), ("dlht_b64", 10, 64)]


def run(tag, ht, batch, events):
    cmd = ["sudo", "perf", "stat", "-e", ",".join(events), "-I", "100", "-x", ",", "--",
           DRAMHIT, "--mode", "11", "--ht-type", str(ht), "--ht-size", str(1 << 29),
           "--ht-fill", "10", "--num-threads", "64", "--numa-split", "1",
           "--batch-len", str(batch), "--find_queue", "64", "--no-prefetch", "0",
           "--hw-pref", "0", "--insert-factor", "1", "--read-factor", "50",
           "--skew", "0.01", "--seed", "1775762440565610239"]
    log = os.path.join(OUT, tag + ".log")
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT,
                       text=True).check_returncode()

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
            try:
                pcts.append(float(p[5]))
            except ValueError:
                pass
    return tot, (min(pcts) if pcts else 100.0), mops


if __name__ == "__main__":
    res = {}
    for tag, ht, b in CASES:
        res[tag] = run(tag, ht, b, EV)
        print("done", tag, file=sys.stderr)

    hdr = "{:<32}" + "{:>13}" * len(CASES)
    print("FIND phase, fill 10, 64 threads, hw prefetch off")
    print(hdr.format("metric", *[c[0] for c in CASES]))

    def g(r, e):
        return r[0][e]

    def row(label, f, fmt="{:.3f}"):
        print(hdr.format(label, *[fmt.format(f(res[c[0]])) for c in CASES]))

    row("get_mops", lambda r: r[2], "{:.0f}")
    row("MLP: avg in-flight L1 misses",
        lambda r: g(r, "ls_alloc_mab_count") / g(r, "ls_not_halted_cyc"))
    row("sw pf dispatched /1k cyc",
        lambda r: 1000 * g(r, "ls_pref_instr_disp.all") / g(r, "ls_not_halted_cyc"))
    row("sw pf DC fills /1k cyc",
        lambda r: 1000 * g(r, "ls_sw_pf_dc_fills.all") / g(r, "ls_not_halted_cyc"))
    row("ineffective sw pf /1k cyc",
        lambda r: 1000 * g(r, "ls_inef_sw_pref.all") / g(r, "ls_not_halted_cyc"))
    row("demand fills /1k cyc",
        lambda r: 1000 * g(r, "ls_dmnd_fills_from_sys.all") / g(r, "ls_not_halted_cyc"))
    row("fills / dispatched",
        lambda r: g(r, "ls_sw_pf_dc_fills.all") / g(r, "ls_pref_instr_disp.all"))
    row("DROPPED (disp-inef-fills)/disp",
        lambda r: (g(r, "ls_pref_instr_disp.all") - g(r, "ls_inef_sw_pref.all")
                   - g(r, "ls_sw_pf_dc_fills.all")) / g(r, "ls_pref_instr_disp.all"))
    row("enabled %", lambda r: r[1], "{:.0f}")
