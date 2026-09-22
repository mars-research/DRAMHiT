#!/usr/bin/env python3
"""Where does the ceiling move to when the second CCD of each node is engaged?

4 CCDs (1-4 threads/node) top out at ~200 GB/s = ~50 GB/s per CCD. Engaging the second
CCD of every node gets 367, not 400. Either the CCD links are still the limit and the
second one just is not being driven as hard, or something below them -- the IOD fabric
or the DRAM itself -- has become the constraint.

Measured at three points along the path, per thread count:
  amd_df ccm<0-7>  inbound data beats at the 8 CCD<->IOD fabric ports (32 B/beat)
  amd_umc          CAS + data-bus occupancy at the 12 DRAM controllers

If the CCD link is the limit, per-CCD fabric rate sits pinned at its ceiling while the
DRAM bus still has headroom. If the DRAM is the limit, per-CCD rate falls below that
ceiling while bus occupancy pins near its max.

amd_df and amd_umc both have 4 counters per box, so this takes three passes.
"""
import os
import re
import statistics
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
BIN = os.path.normpath(os.path.join(HERE, "..", "machine_stats", "build", "bandwidth_rand"))
OUT = os.path.join(HERE, "logs", "ccd_fabric")
os.makedirs(OUT, exist_ok=True)

BEAT_BYTES = 32  # calibrated: total ccm beats x 32 B reproduces total UMC bytes
UMC_BOXES = [0, 1, 2]  # node 0; all nodes symmetric under this pattern

PASSES = [
    ("ccmA", {"c{}".format(i): "amd_df/local_socket_inf0_inbound_data_beats_ccm{}/".format(i)
              for i in range(4)}),
    ("ccmB", {"c{}".format(i): "amd_df/local_socket_inf0_inbound_data_beats_ccm{}/".format(i)
              for i in range(4, 8)}),
    ("umc", {"rd": "amd_umc_{b}/umc_cas_cmd.rd/", "wr": "amd_umc_{b}/umc_cas_cmd.wr/",
             "slot": "amd_umc_{b}/umc_data_slot_clks.all/", "clk": "amd_umc_{b}/umc_mem_clk/"}),
]

CHUNK = {1: 2048, 2: 2048, 3: 1024, 4: 1024, 5: 512, 6: 512, 8: 512, 12: 256, 16: 256}


def event_string(spec):
    terms = []
    for key, tmpl in spec.items():
        if "{b}" in tmpl:
            for b in UMC_BOXES:
                terms.append(tmpl.format(b=b).rstrip("/") + ",name={}_b{}/".format(key, b))
        else:
            terms.append(tmpl.rstrip("/") + ",name={}/".format(key))
    return ",".join(terms)


def run(tpn, inst, mode, tag, spec):
    pattern = " ".join("n{n}a{n}t{c}".format(n=n, c=tpn) for n in range(4))
    cmd = ["sudo", "perf", "stat", "-a", "-e", event_string(spec), "-I", "20", "-x", ",",
           "--", BIN, "-m", "{}mb".format(CHUNK[tpn]), "-pattern", pattern,
           "-freq", "3.25", "-inst", inst, "-lookahead", "64", "-mode", mode]
    log = os.path.join(OUT, "{}_{}_{}_t{}.log".format(tag, mode, inst, tpn))
    with open(log, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, text=True).check_returncode()

    # ts -> name -> [count, run_ns, boxes]
    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))
    inwin, pcts = False, []
    for line in open(log):
        line = line.strip()
        if "Start perf collection" in line:
            inwin = True; continue
        if "End perf collection" in line:
            inwin = False; continue
        if not inwin:
            continue
        p = line.split(",")
        if len(p) < 6 or not p[0][:1].isdigit():
            continue
        name = p[3].strip().split("_b")[0]
        if name not in spec:
            continue
        try:
            ts, cnt, rns = float(p[0]), float(p[1]), float(p[4])
        except ValueError:
            continue
        if p[5]:
            try: pcts.append(float(p[5]))
            except ValueError: pass
        s = acc[ts][name]
        s[0] += cnt; s[1] += rns; s[2] += 1

    ts_list = sorted(acc)
    win = ts_list[1:-1] if len(ts_list) > 2 else ts_list
    out = {}
    for key in spec:
        rates = [acc[t][key][2] * acc[t][key][0] / acc[t][key][1]
                 for t in win if acc[t][key][1] > 0]
        out[key] = statistics.median(rates) if rates else 0.0   # counts per ns
    return out, (min(pcts) if pcts else 100.0)


if __name__ == "__main__":
    tpns = [int(x) for x in sys.argv[1:]] or [1, 2, 4, 6, 8, 12, 16]
    hdr = "{:>4} {:>5} {:>9} {:>11} {:>12} {:>10} {:>9}"
    print(hdr.format("t/nd", "CCDs", "DRAM GB/s", "bus util", "fabric GB/s",
                     "per-CCD", "act. CCDs"))
    for tpn in tpns:
        a, pa = run(tpn, "t1", "r", "ccmA", PASSES[0][1])
        b, pb = run(tpn, "t1", "r", "ccmB", PASSES[1][1])
        u, pu = run(tpn, "t1", "r", "umc", PASSES[2][1])

        per_ccd = {}
        for d in (a, b):
            for k, v in d.items():
                per_ccd[k] = v * BEAT_BYTES          # bytes/ns == GB/s
        active = [v for v in per_ccd.values() if v > 1.0]
        fabric_total = sum(per_ccd.values())
        # node 0's 3 UMC boxes -> whole machine is x4 (4 symmetric nodes)
        dram = (u["rd"] + u["wr"]) * 64 * 4
        util = (u["slot"] / u["clk"]) / 2.0 * 100
        print(hdr.format(tpn, len(active), "{:.1f}".format(dram), "{:.1f}%".format(util),
                         "{:.1f}".format(fabric_total),
                         "{:.1f}".format(statistics.mean(active) if active else 0),
                         "{:.0f}% enab".format(min(pa, pb, pu))))
