#!/usr/bin/env python3
"""Print find_batch's hot range with cycles% and mispredict% per instruction.

    loop_view.py <profile dir> [min cycles% to start/stop the window, default 0.5]
"""
import re, sys
from pathlib import Path
d = Path(sys.argv[1])
def load(f):
    out = {}
    for l in (d / f).read_text().splitlines():
        m = re.match(r"\s*([\d.]+)\s*:\s*([0-9a-f]+):\s*(.*)", l)
        if m:
            out[int(m.group(2), 16)] = (float(m.group(1)), m.group(3).strip())
    return out
c, b = load("annotate_find_cycles.txt"), load("annotate_find_misp.txt")
thr = float(sys.argv[2]) if len(sys.argv) > 2 else 0.5
hot = [a for a in c if c[a][0] >= thr]
lo, hi = min(hot), max(hot)
print(f"{'cyc%':>6} {'misp%':>6}  addr    insn")
for a in sorted(c):
    if lo <= a <= hi:
        print(f"{c[a][0]:6.2f} {b.get(a, (0,))[0]:6.2f}  {a:x}: {c[a][1][:70]}")
