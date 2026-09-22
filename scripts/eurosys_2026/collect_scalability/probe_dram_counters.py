#!/usr/bin/env python3
"""Row-activation rate and data-bus occupancy at the DRAM controllers, random vs
sequential access, for read / 1r1w store / pure NT write.

This is the evidence behind local_interleave_analysis.md section 5. The question it
answers is what actually meters this machine's bandwidth:

  act/CAS      -- DRAM rows opened per 64 B access. ~1.0 means every access opens a
                  fresh row (no row-buffer locality); its reciprocal is the number of
                  accesses served per activation.
  bus util     -- fraction of memory clocks the data bus is actually moving data.
                  umc_data_slot_clks counts per sub-channel and there are 2 per UMC,
                  so full occupancy is 2.0 slot-clk per mem-clk; that is the /2.

Run it against both builds (`make build/bandwidth_rand build/bandwidth_seq` in
machine_stats/). The finding is that sequential access cuts activates per access by a
third and buys ~5% of read bandwidth and none at all of write bandwidth -- so the
activate rate is not what is binding, and the write ceiling holds under every knob.

amd_umc exposes 4 counters per box, so activates and bus occupancy cannot be counted in
the same run without multiplexing; this takes two passes and asserts 100% enabled.
Needs sudo.
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BIN_DIR = os.path.normpath(os.path.join(HERE, "..", "machine_stats", "build"))
LOG_DIR = os.path.join(HERE, "logs", "dram_counters")

# Node 0's three UMC boxes. Every node carries identical traffic under the symmetric
# pattern used here, so one node's boxes are enough and keep the event count low.
BOXES = [0, 1, 2]

PASSES = {
    "bus": {"rd": "umc_cas_cmd.rd", "wr": "umc_cas_cmd.wr",
            "slot": "umc_data_slot_clks.all", "clk": "umc_mem_clk"},
    "act": {"rd": "umc_cas_cmd.rd", "wr": "umc_cas_cmd.wr", "act": "umc_act_cmd.all"},
}

WORKLOADS = [
    ("pure read (t1)", "r", "t1"),
    ("1r1w store (load)", "w", "load"),
    ("pure NT write", "w", "ntstore"),
]

ROW_RE = re.compile(r"\s*([\d,]+)\s+(\w+)_b\d+\s*(?:\(([\d.]+)%\))?")
BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)")


def run(binary, tpn, inst, mode, events, tag, chunk_mb, freq):
    ev = ",".join("amd_umc_{b}/{e},name={k}_b{b}/".format(b=b, e=e, k=k)
                  for b in BOXES for k, e in events.items())
    pattern = " ".join("n{n}a{n}t{c}".format(n=n, c=tpn) for n in range(4))
    cmd = ["sudo", "perf", "stat", "-a", "-e", ev, "--",
           os.path.join(BIN_DIR, binary),
           "-m", "{}mb".format(chunk_mb), "-pattern", pattern, "-freq", freq,
           "-inst", inst, "-lookahead", "64", "-mode", mode]
    log = os.path.join(LOG_DIR, "{}_{}_{}_{}_t{}.log".format(binary, tag, mode, inst, tpn))
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, text=True).check_returncode()

    totals, pcts, prog = {k: 0.0 for k in events}, [], None
    for line in open(log):
        m = ROW_RE.match(line)
        if m and m.group(2) in totals:
            totals[m.group(2)] += float(m.group(1).replace(",", ""))
            if m.group(3):
                pcts.append(float(m.group(3)))
        m = BW_RE.search(line)
        if m:
            prog = float(m.group(1))
    return totals, (min(pcts) if pcts else 100.0), prog


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--threads-per-node", nargs="+", type=int, default=[8, 16])
    ap.add_argument("--chunk-mb", type=int, default=256)
    ap.add_argument("--freq", default="3.25")
    ap.add_argument("--builds", nargs="+", default=["bandwidth_rand", "bandwidth_seq"])
    args = ap.parse_args()

    os.makedirs(LOG_DIR, exist_ok=True)
    for b in args.builds:
        if not os.path.exists(os.path.join(BIN_DIR, b)):
            sys.exit("ERROR: {} missing -- run `make build/{}` in machine_stats/".format(b, b))

    hdr = "{:<16} {:<20} {:>4} {:>9} {:>9} {:>11} {:>9} {:>8}"
    print(hdr.format("build", "workload", "thr", "prog GB/s", "act/CAS",
                     "acc/activate", "bus util", "wr frac"))
    for binary in args.builds:
        for label, mode, inst in WORKLOADS:
            for tpn in args.threads_per_node:
                bus, p1, prog = run(binary, tpn, inst, mode, PASSES["bus"], "bus",
                                    args.chunk_mb, args.freq)
                act, p2, _ = run(binary, tpn, inst, mode, PASSES["act"], "act",
                                 args.chunk_mb, args.freq)
                cas_bus = bus["rd"] + bus["wr"]
                cas_act = act["rd"] + act["wr"]
                apc = act["act"] / cas_act
                note = "" if min(p1, p2) > 99.5 else "  !! {:.0f}% enabled".format(min(p1, p2))
                print(hdr.format(
                    binary.replace("bandwidth_", ""), label, tpn * 4,
                    "{:.1f}".format(prog or 0.0), "{:.3f}".format(apc),
                    "{:.1f}".format(1.0 / apc),
                    "{:.1f}%".format(100 * (bus["slot"] / bus["clk"]) / 2.0),
                    "{:.1f}%".format(100 * bus["wr"] / cas_bus)) + note)


if __name__ == "__main__":
    main()
