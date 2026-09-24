import re
from collections import defaultdict
def totals(log, marks):
    inside, per, win = False, defaultdict(lambda: defaultdict(float)), {}
    for line in open(log):
        if marks[0] in line: inside = True
        elif marks[1] in line: inside = False
        f = line.split(",")
        if len(f) < 6: continue
        try: ts = float(f[0]); v = float(f[1])
        except ValueError: continue
        per[ts][re.sub(r"_b\d+$", "", f[3].strip())] += v; win.setdefault(ts, inside)
    tot = defaultdict(float)
    for t in [t for t in sorted(per) if win[t]][1:-1]:
        for k, v in per[t].items(): tot[k] += v
    return tot
