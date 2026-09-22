#!/usr/bin/env python3
"""Per-controller read vs 1r1w, from amd_channel_probe under the umc counters.

Cuts the perf -I series to the probe's Start/End markers so the 1 GiB memset+clflush
init -- which spreads over every channel and would otherwise dominate -- is excluded,
then reports each of node 0's three channels separately so the number of channels the
predicate actually lands on is visible rather than assumed.
"""
import os
import re
import statistics
import subprocess
import sys
from collections import defaultdict

PROBE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "amd_channel_probe")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs", "amd_channel")
os.makedirs(OUT, exist_ok=True)
BOXES = [0, 1, 2]
EV = {"rd": "umc_cas_cmd.rd", "wr": "umc_cas_cmd.wr",
      "slot": "umc_data_slot_clks.all", "clk": "umc_mem_clk"}


def run(threads, mode, repeats):
    ev = ",".join("amd_umc_{b}/{e},name={k}_b{b}/".format(b=b, e=e, k=k)
                  for b in BOXES for k, e in EV.items())
    cmd = ["sudo", "perf", "stat", "-a", "-e", ev, "-I", "20", "-x", ",", "--",
           PROBE, "-t", str(threads), "-m", mode, "-r", str(repeats)]
    log = os.path.join(OUT, "t{}_{}.log".format(threads, mode))
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, text=True).check_returncode()

    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0]))
    inwin, pcts, cpu_bw = False, [], None
    for line in open(log):
        if "Start perf collection" in line:
            inwin = True; continue
        if "End perf collection" in line:
            inwin = False; continue
        m = re.search(r"CPU-side bandwidth:\s*([\d.]+)", line)
        if m:
            cpu_bw = float(m.group(1))
        if not inwin:
            continue
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit():
            continue
        name = p[3].strip()
        mm = re.match(r"(rd|wr|slot|clk)_b(\d+)$", name)
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
    out = {}
    for b in BOXES:
        for k in ("rd", "wr"):
            key = "{}_{}".format(k, b)
            vals = [64 * acc[t][key][0] / acc[t][key][1] for t in win
                    if acc[t][key][1] > 0]
            out[key] = statistics.median(vals) if vals else 0.0
    utils = []
    for t in win:
        sl = sum(acc[t]["slot_{}".format(b)][0] for b in BOXES)
        ck = sum(acc[t]["clk_{}".format(b)][0] for b in BOXES)
        if ck > 0:
            utils.append((sl / ck) / 2.0 * 100)
    return out, (statistics.median(utils) if utils else 0.0), cpu_bw, \
        (min(pcts) if pcts else 100.0), len(win)


if __name__ == "__main__":
    threads = [int(x) for x in (sys.argv[1].split(",") if len(sys.argv) > 1 else ["4", "8", "16"])]
    print("{:>4} {:>5} | {:>26} | {:>7} {:>8} {:>8} {:>7}".format(
        "thr", "mode", "per-channel rd+wr GB/s", "active", "total", "per-ch", "bus"))
    for t in threads:
        for mode, reps in (("r", 500), ("rw", 300)):
            o, util, cpu_bw, pct, n = run(t, mode, reps)
            per = {b: o["rd_%d" % b] + o["wr_%d" % b] for b in BOXES}
            active = [b for b in BOXES if per[b] > 2.0]
            tot = sum(per.values())
            print("{:>4} {:>5} | {} | {:>7} {:>8.1f} {:>8.1f} {:>6.1f}%  ({} int, {:.0f}% enab)".format(
                t, mode,
                "  ".join("umc{}: {:6.1f}".format(b, per[b]) for b in BOXES),
                len(active), tot, tot / max(len(active), 1), util, n, pct))
