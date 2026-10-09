"""E23: fill sweep 10..90, DEEP_VECTORIZATION vs the same build without it (attempt10, queue 128, batch 64, key prefetch
64 t2, keys in HBM). Finds/s from the program; other columns: medians of steady 100 ms intervals; median over 5 reps.
Fallback rates from the stats-only build (attempt10/stats/f*.log, one run per fill). -> tables/E23.md"""
import re, statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E23_fill"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    prog = r.parse_program((d / "combined.log").read_text())
    assert prog["find_ops"] == prog.get("found", prog["find_ops"]), d
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = x["cnt"]
        rows.append(dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                         ipc=c["instructions"] / c["cycles"]))
    v = {k: M([x[k] for x in rows]) for k in rows[0]}
    v["mops"] = prog["get_mops"]
    v["ipf"] = v["ipc"] * v["ghz"] * 1e9 * 64 / (prog["get_mops"] * 1e6)
    v["n"] = len(rows)
    return v


stats = {}
for f in range(10, 100, 10):
    t = (r.OPT / "attempt10" / "stats" / f"f{f}.log").read_text()
    m = re.search(r"vec_finds \d+ \(([\d.]+)%\) miss_fallbacks \d+ \(([\d.]+)%", t)
    stats[f] = (float(m.group(1)), float(m.group(2)))
out = ["## E23: fill sweep, DEEP_VECTORIZATION vs scalar 16 B (`logs/E23_fill`, attempt10, queue 128 / batch 64, key prefetch 64 t2, 5 reps)\n",
       "| fill | scalar finds/s (M) [min-max] | deep-vec finds/s (M) [min-max] | deep-vec vs scalar | scalar HBM GB/s | deep-vec HBM GB/s | scalar / deep-vec instr per find | finds in 4-wide groups | miss fallbacks (% of finds) |",
       "|---|---|---|---|---|---|---|---|---|"]
for f in range(10, 100, 10):
    q = [per_rep(d) for d in sorted(BASE.glob(f"a11_q16_f{f}_r*"))]
    v = [per_rep(d) for d in sorted(BASE.glob(f"a11_deepvec_f{f}_r*"))]
    gq = lambda k: M([p[k] for p in q]); gv = lambda k: M([p[k] for p in v])
    mq, mv = [p["mops"] for p in q], [p["mops"] for p in v]
    out.append(f"| {f} | {gq('mops'):.0f} [{min(mq):.0f}-{max(mq):.0f}] | {gv('mops'):.0f} [{min(mv):.0f}-{max(mv):.0f}] | {100 * (gv('mops') / gq('mops') - 1):+.1f}% | "
               f"{gq('bw'):.1f} | {gv('bw'):.1f} | {gq('ipf'):.1f} / {gv('ipf'):.1f} | {stats[f][0]:.1f}% | {stats[f][1]:.2f}% |")
txt = "\n".join(out)
(r.HERE / "tables" / "E23.md").write_text(txt + "\n")
print(txt)
