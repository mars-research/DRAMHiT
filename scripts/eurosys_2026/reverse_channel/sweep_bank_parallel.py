#!/usr/bin/env python3
"""Bank parallelism vs read and 1r1w on one AMD memory controller.

The single-controller numbers in ../collect_scalability/local_interleave_analysis.md
say the 1r1w ceiling (0.77x read) lives at the controller, not the fabric, but not why.
The leading explanation is bank occupancy: a random write holds its bank for
ACT->tRCD->WR->WL+burst+tWR->PRE->tRP (~83 ns at DDR5-4800) against ~tRC (~48 ns) for a
read, so writes need ~1.7x as many banks concurrently busy to keep the bus fed -- and
these are 1Rx8 DIMMs, 32 banks per subchannel with no second rank to fall back on.

If that is the mechanism, starving the stream of banks must hurt writes faster than
reads. amd_channel_probe -c clamps bits of the physical address to zero; every clamped
bit that feeds bank/bank-group selection halves the reachable banks, and every bit that
feeds row/column selection costs nothing but footprint. Two passes:

  discover  clamp one bit at a time, bits 6..25, read mode. Bits that matter show up as
            a drop in controller bandwidth; the rest are flat. No assumption about
            which bits AMD uses for banks.
  sweep     clamp the discovered bits cumulatively, read and 1r1w at each depth.

-f 64 (flush-behind) is on throughout: clamping n bits divides the working set by 2^n
and a 45 MB set would sit entirely in the node's 64 MB of L3. With flush-behind every
access is a DRAM miss regardless. Pass --no-flush to check that against the unclamped
point, where the 358 MB set is already 5x L3 and the two must agree.

Usage: sudo ./sweep_bank_parallel.py [node] [discover|sweep|both] [--no-flush]
"""
import os
import re
import statistics
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
PROBE = os.path.join(HERE, "amd_channel_probe")
OUT = os.path.join(HERE, "logs", "bank_parallel")
os.makedirs(OUT, exist_ok=True)

# amd_umc has 4 counters per box, so bus occupancy and activates cannot be counted in
# the same pass; PASSES is run twice over the same point, as in the main report.
PASSES = [{"rd": "umc_cas_cmd.rd", "wr": "umc_cas_cmd.wr",
           "slot": "umc_data_slot_clks.all", "clk": "umc_mem_clk"},
          {"rd": "umc_cas_cmd.rd", "wr": "umc_cas_cmd.wr",
           "act": "umc_act_cmd.all", "clk": "umc_mem_clk"}]
THREADS = 16
GIB = 1          # the predicate only isolates one controller within a single 1 GiB
                 # page -- see the note at the bottom of this file
REPEATS = {"r": 0, "rw": 0, "nt": 0}   # 0 = probe picks a count for ~120 GB of traffic


def run(node, mode, clamp, flush, tag, ev_pass=0, norm=True, banks=0, secs=0):
    """One probe run under all 12 umc boxes; returns per-box GB/s and the pass's
    secondary metric (bus utilisation %, or activates per CAS)."""
    EV = PASSES[ev_pass]
    ev = ",".join("amd_umc_{b}/{e},name={k}_b{b}/".format(b=b, e=e, k=k)
                  for b in range(12) for k, e in EV.items())
    cmd = ["perf", "stat", "-a", "-e", ev, "-I", "50", "-x", ",", "--",
           PROBE, "-t", str(THREADS), "-m", mode, "-n", str(node),
           "-g", str(GIB), "-r", str(REPEATS[mode]),
           "-C" if norm else "-c", hex(clamp)]
    if banks:
        cmd += ["-b", str(banks)]
    if secs:
        cmd += ["-d", str(secs)]
    if flush:
        cmd += ["-f", "64"]
    log = os.path.join(OUT, "n{}_{}_{}{}_p{}.log".format(
        node, mode, "" if norm else "phys_", tag, ev_pass))
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, text=True).check_returncode()

    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0]))
    inwin, pcts, kept = False, [], 0
    for line in open(log):
        if "Start perf collection" in line:
            inwin = True; continue
        if "End perf collection" in line:
            inwin = False; continue
        m = re.search(r"-> (\d+) of \d+ owned lines kept", line)
        if m:
            kept = int(m.group(1))
        if not inwin:
            continue
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit():
            continue
        mm = re.match(r"(rd|wr|slot|act|clk)_b(\d+)$", p[3].strip())
        if not mm:
            continue
        try:
            ts, cnt, rns = float(p[0]), float(p[1]), float(p[4])
        except ValueError:
            continue
        if p[5]:
            try: pcts.append(float(p[5]))
            except ValueError: pass
        s = acc[ts]["{}_{}".format(mm.group(1), mm.group(2))]
        s[0] += cnt; s[1] += rns

    ts_list = sorted(acc)
    win = ts_list[1:-1] if len(ts_list) > 2 else ts_list
    per_box, second = {}, {}
    for b in range(12):
        vals, sec = [], []
        for t in win:
            r, w = acc[t]["rd_%d" % b], acc[t]["wr_%d" % b]
            cas = r[0] + w[0]
            if r[1] > 0:
                vals.append(64 * cas / r[1])
            if ev_pass == 0:
                sl, ck = acc[t]["slot_%d" % b][0], acc[t]["clk_%d" % b][0]
                if ck > 0:
                    sec.append(sl / ck / 2.0 * 100)
            else:
                if cas > 0:
                    sec.append(acc[t]["act_%d" % b][0] / cas)
        per_box[b] = statistics.median(vals) if vals else 0.0
        second[b] = statistics.median(sec) if sec else 0.0
    return per_box, second, kept, (min(pcts) if pcts else 100.0), len(win)


def target_of(per_box, node):
    """The controller under test: the busiest of the node's three boxes."""
    return max(range(3 * node, 3 * node + 3), key=lambda b: per_box[b])


def line(label, per_box, util, node, kept, extra=""):
    boxes = list(range(3 * node, 3 * node + 3))
    tgt = target_of(per_box, node)
    others = sum(per_box[b] for b in range(12) if b not in boxes)
    print("{:<22} {} | tgt umc{} {:6.2f} GB/s  util {:4.1f}%  off-node {:4.2f}"
          "  set {:6.1f} MB {}".format(
              label, "  ".join("umc{}:{:6.2f}".format(b, per_box[b]) for b in boxes),
              tgt, per_box[tgt], util[tgt], others, kept * 64 / 1e6, extra))
    return per_box[tgt], util[tgt]


def discover(node, flush, norm=True):
    space = "normalized" if norm else "physical"
    print("\n== single-bit clamp sweep on the {} address, read mode ==".format(space))
    per, util, kept, pct, n = run(node, "r", 0, flush, "disc_base", 0, norm)
    base, _ = line("clamp none", per, util, node, kept)
    hits = []
    for bit in range(6, 25):
        per, util, kept, pct, n = run(node, "r", 1 << bit, flush,
                                      "disc_b%d" % bit, 0, norm)
        bw = per[target_of(per, node)]
        line("clamp bit {:<2} (0x{:x})".format(bit, 1 << bit), per, util, node, kept,
             "{:+5.1f}%".format(100 * bw / base - 100))
        if bw < 0.95 * base:
            hits.append(bit)
    print("\n{} bits whose removal costs >5%: {}".format(
        space, ", ".join(str(b) for b in hits) if hits else "none"))
    return hits


def sweep(node, bits, flush):
    """Cumulative clamp: strip address entropy above the column bits, bit by bit, and
    watch read and 1r1w fall. Every clamped bit that feeds bank or bank-group selection
    halves the banks the stream can reach; act/CAS says how much of any change is
    really row locality arriving instead."""
    print("\n== cumulative clamp: bank parallelism vs read and 1r1w ==")
    print("{:>4} {:>10} {:>9} | {:>8} {:>6} {:>7} | {:>8} {:>6} {:>7} | {:>9}".format(
        "bits", "mask", "set MB",
        "read", "util", "act/CAS", "1r1w", "util", "act/CAS", "1r1w/read"))
    mask, rows = 0, []
    for k in range(len(bits) + 1):
        if k:
            mask |= 1 << bits[k - 1]
        tag = "cum%d" % k
        out = {}
        for mode in ("r", "rw"):
            per_u, util, kept, _, _ = run(node, mode, mask, flush, tag, 0, True)
            tgt = target_of(per_u, node)
            per_a, act, _, _, _ = run(node, mode, mask, flush, tag, 1, True)
            out[mode] = (per_u[tgt], util[tgt], act[target_of(per_a, node)], kept)
        br, ur, ar, kept = out["r"]
        bw, uw, aw, _ = out["rw"]
        rows.append((k, mask, kept, br, ur, ar, bw, uw, aw))
        print("{:>4} {:>10} {:>9.1f} | {:8.2f} {:5.1f}% {:7.3f} | {:8.2f} {:5.1f}%"
              " {:7.3f} | {:9.3f}".format(
                  k, hex(mask), kept * 64 / 1e6, br, ur, ar, bw, uw, aw,
                  bw / br if br else 0))
    return rows


def bank_sweep(node, flush, counts=(1, 2, 4, 8, 16, 24, 32, 48, 64), secs=3):
    """Throughput against the number of banks the stream may use.

    The bank-occupancy model says a read holds its bank ~tRC and a 1r1w access holds it
    for a read cycle plus a write cycle (the RFO fetch and, later, the writeback), so
    per bank they are worth ~1.33 and ~0.98 GB/s of controller traffic. If that is what
    sets the ceilings, each curve climbs linearly at that slope and levels off only when
    the banks run out. If instead both level off well below 64 banks, whatever caps them
    is not bank parallelism -- and the read/write gap at the plateau is something else.
    """
    print("\n== throughput vs banks in play (row-conflict clustering, -b) ==")
    print("{:>6} | {:>8} {:>7} {:>8} | {:>8} {:>7} {:>8} | {:>8} {:>7} {:>8} |"
          " {:>9}".format(
              "banks", "read", "act/CAS", "ns/bank", "1r1w", "act/CAS", "ns/bank",
              "ntwrite", "act/CAS", "ns/bank", "1r1w/read"))
    rows = []
    for n in counts:
        out = {}
        for mode in ("r", "rw", "nt"):
            per_u, util, kept, _, _ = run(node, mode, 0, flush, "bank%d" % n, 0,
                                          True, n, secs)
            tgt = target_of(per_u, node)
            per_a, act, _, _, _ = run(node, mode, 0, flush, "bank%d" % n, 1,
                                      True, n, secs)
            out[mode] = (per_u[tgt], util[tgt], act[target_of(per_a, node)])
        br, ur, ar = out["r"]
        bw, uw, aw = out["rw"]
        bn, un, an = out["nt"]
        # ns of bank time per 64 B moved, at this bank count: 64 B / (GB/s per bank).
        ns = lambda g: 64.0 * n / g if g else 0
        rows.append((n, br, ur, ar, bw, uw, aw, bn, un, an))
        print("{:>6} | {:8.2f} {:7.3f} {:8.1f} | {:8.2f} {:7.3f} {:8.1f} |"
              " {:8.2f} {:7.3f} {:8.1f} | {:9.3f}".format(
                  n, br, ar, ns(br), bw, aw, ns(bw), bn, an, ns(bn),
                  bw / br if br else 0))
    return rows


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flush = "--no-flush" not in sys.argv
    node = int(args[0]) if args else 1
    what = args[1] if len(args) > 1 else "both"
    print("node {}, {} threads, {} GiB page, flush-behind {}".format(
        node, THREADS, GIB, "on" if flush else "off"))
    bits = []
    if what in ("discover", "both"):
        bits = discover(node, flush, norm="--phys" not in sys.argv)
    if what in ("banks", "both"):
        bank_sweep(node, flush)
    if what in ("sweep",):
        # Single-bit clamps above bit 7 are free (nothing individually binds), so the
        # sweep walks bits cumulatively from the first bit above the 256 B channel
        # interleave chunk upwards, stripping entropy until something gives.
        env = [int(b) for b in os.environ.get("BANK_BITS", "").split(",") if b]
        sweep(node, env or list(range(8, 21)), flush)

# Note on -g: amd_channel_probe can map several 1 GiB hugepages, but the predicate only
# isolates a single controller inside ONE page. Measured on node 1 with -g 16, traffic
# splits umc3 24.4 / umc4 36.6 / umc5 24.4 GB/s instead of landing on umc4 alone: the
# real channel hash folds in physical address bits above bit 30, which are constant
# across a 1 GiB page and so invisible to the 12 MB-cycle model reversed_amd.c fits.
# Hence GIB = 1 here, and flush-behind rather than a bigger page to keep the clamped
# working sets out of L3.
