#!/usr/bin/env python3
"""Per-operation cycles / instructions / mispredicts for find_batch and insert_batch.

    summarize.py <profile dir> [<profile dir> ...]

Reads report.txt from perf_profile.sh. Counts are the symbol's share of each
event's total, divided by find_ops (the run inserts the same number of keys it
looks up, so the same count is used for insert_batch). The counts are summed
over all 64 threads, so cycles per op is thread-cycles per op.
"""
import re, sys
from pathlib import Path

EV = {"cycles": "cyc", "instructions": "ins", "br_misp": "misp"}
print(f"{'profile':<28}{'fn':<8}{'cyc/op':>8}{'ins/op':>8}{'IPC':>6}{'misp/op':>9}  get_mops set_mops")
for d in sys.argv[1:]:
    txt = (Path(d) / "report.txt").read_text()
    ops = int(re.search(r"find_ops : (\d+)", txt).group(1))
    gm = re.search(r"get_mops : (\d+)", txt).group(1)
    sm = re.search(r"set_mops : (\d+)", txt).group(1)
    res, ev, total = {}, None, 0
    for line in txt.splitlines():
        m = re.match(r"# Samples: .* of event '([a-z_.]+)", line)
        if m:
            ev = next(v for k, v in EV.items() if m.group(1).startswith(k)); continue
        m = re.match(r"# Event count \(approx.\): (\d+)", line)
        if m:
            total = int(m.group(1)); continue
        m = re.match(r"\s*([\d.]+)%\s+\d+\s+\[.\] .*::(find_batch|insert_batch)\(", line)
        if m and ev:
            res.setdefault(m.group(2), {})[ev] = float(m.group(1)) / 100 * total / ops
    for fn in ("find_batch", "insert_batch"):
        r = {"cyc": 0.0, "ins": 0.0, "misp": 0.0, **res[fn]}  # an event under 1% is not listed
        print(f"{Path(d).parent.name + '/' + Path(d).name:<28}{fn.split('_')[0]:<8}"
              f"{r['cyc']:8.1f}{r['ins']:8.1f}{r['ins']/r['cyc']:6.2f}{r['misp']:9.3f}  {gm:>8} {sm:>8}")
