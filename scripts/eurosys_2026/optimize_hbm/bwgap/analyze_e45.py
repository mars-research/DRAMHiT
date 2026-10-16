"""E45: cleaned-up deep insert (attempt11/dvj, dvj128) vs dvi_hs24, x the insert harness's key-stream prefetch
(INS_KEY_PF_DIST/_HINT), q128 / b16. Insert phase, per-rep medians as col_e41.py, median [min-max] over reps.
dvi_hs24 predates the INS_KEY_PF knob (its runs all use the original 16 ahead, t0).
usage: analyze_e45.py [logs dir]  -> tables/<dir>.md"""
import re, sys, statistics as st
import runlib as r
from col_e41 import rep
M = st.median
base = r.HERE / "logs" / (sys.argv[1] if len(sys.argv) > 1 else "E45_clean")
pat = re.compile(r"a23_(.+)_(def|k\d+t\d)_f(\d+)_r(\d+)$")
runs = {}
for d in sorted(base.glob("a23_*_r*")):
    m = pat.match(d.name)
    if m and (d / "meta.json").exists():
        runs.setdefault((m.group(1), m.group(2), int(m.group(3))), []).append(rep(d)[1])
ref = {f: runs[k] for k in runs if k[0] == "dvi_hs24" and k[1] == "def" for f in [k[2]]}
rng = lambda xs, n: f"{M(xs):.{n}f} [{min(xs):.{n}f}–{max(xs):.{n}f}]"
out = [f"## {base.name}: cleaned-up deep insert x insert key prefetch (q128 / b16; median [min–max] of per-rep medians)\n",
       "| fill | build | key prefetch | reps | inserts/s (G) | Δ vs dvi_hs24 def | HBM GB/s | core GHz | IPC | instr / insert | "
       "cycles / HBM line | cycles / insert | xq full % | fb full % |", "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
order = {"dvs_p3": 0, "dvi_hs24": 1, "dvj": 2, "dvj128": 3}
for (v, k, f) in sorted(runs, key=lambda x: (x[2], order.get(x[0], 9), x[1])):
    R = runs[(v, k, f)]
    g = lambda key: M([x[key] for x in R])
    ins = [x["prog"] / 1e9 for x in R]
    d = f"{100 * (M(ins) / M([x['prog'] / 1e9 for x in ref[f]]) - 1):+.1f} %" if f in ref else ""
    lpi = g("bw") * 1e9 / 64 / g("prog")
    out.append(f"| {f} | {v} | {k} | {len(R)} | {rng(ins, 3)} | {d} | {rng([x['bw'] for x in R], 1)} | {g('ghz'):.3f} | {g('ipc'):.2f} | "
               f"{g('ipl') * lpi:.1f} | {64 * g('ghz') / (g('bw') / 64):.1f} | {64 * g('ghz') * 1e9 / g('prog'):.1f} | "
               f"{g('xq'):.1f} | {g('fb'):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / f"{base.name}.md").write_text(txt + "\n")
print(txt)
