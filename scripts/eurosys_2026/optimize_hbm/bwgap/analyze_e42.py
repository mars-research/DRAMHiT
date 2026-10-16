"""E42: deep insert (DEEP_VEC_INSERT, split {key,value}/hash insert queue; attempt11/dvi*) vs dvs_p3 over insert
queue length x batch length. Insert phase only (steady = t >= 1.0 s into the phase, boundary intervals dropped), per-rep
medians as col_e41.py, then median over reps. usage: analyze_e42.py [logs dir] [fill]  -> tables/<dir>.md"""
import re, sys, statistics as st
import runlib as r
from col_e41 import rep
M = st.median
base = r.HERE / "logs" / (sys.argv[1] if len(sys.argv) > 1 else "E42_qb")
pat = re.compile(r"a22_(.+)_q(\d+)_b(\d+)_f(\d+)_r(\d+)$")
runs = {}
for d in sorted(base.glob("a22_*_r*")):
    m = pat.match(d.name)
    if not m or not (d / "meta.json").exists():
        continue
    v, q, b, f, k = m.group(1), int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5))
    runs.setdefault((v, q, b, f), []).append(rep(d)[1])
VS = sorted({k[0] for k in runs}, key=lambda v: (v != "dvs_p3", v))
out = [f"## E42: deep insert vs dvs_p3, insert phase (`logs/{base.name}`; median over reps of per-rep medians)\n",
       "| fill | build | queue | batch | reps | inserts/s (G) | Δ vs dvs_p3 same q/b | HBM GB/s | rd / wr GB/s | core GHz | IPC | "
       "instr / insert | cycles / HBM line | cycles / insert | xq full % | fb full % |",
       "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
for (v, q, b, f) in sorted(runs, key=lambda k: (k[3], VS.index(k[0]), k[1], k[2])):
    R = runs[(v, q, b, f)]
    g = lambda key: M([x[key] for x in R])
    ins = g("prog")
    ref = runs.get(("dvs_p3", q, b, f))
    d = "" if v == "dvs_p3" or not ref else f"{100 * (ins / M([x['prog'] for x in ref]) - 1):+.1f} %"
    lines_per_ins = g("bw") * 1e9 / 64 / ins
    out.append(f"| {f} | {v} | {q} | {b} | {len(R)} | {ins / 1e9:.3f} | {d} | {g('bw'):.1f} | {g('rd'):.0f} / {g('wr'):.0f} | "
               f"{g('ghz'):.3f} | {g('ipc'):.2f} | {g('ipl') * lines_per_ins:.1f} | {64 * g('ghz') * 1e9 / (g('bw') * 1e9 / 64):.1f} | "
               f"{64 * g('ghz') * 1e9 / ins:.1f} | {g('xq'):.1f} | {g('fb'):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / f"{base.name}.md").write_text(txt + "\n")
print(txt)
