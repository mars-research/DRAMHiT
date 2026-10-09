"""E25: fill sweep 10..90, deep pop/push (DEEP_VECTORIZATION, rewritten) vs scalar 16 B (attempt10, queue 128,
batch 64, key prefetch 64 t2, keys in HBM). Finds/s from the program; HBM GB/s and instructions per find from steady
100 ms intervals; median over 5 reps. -> tables/E25.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E25_deeppop"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    prog = r.parse_program((d / "combined.log").read_text())
    assert prog["find_ops"] == prog["found"], d
    rows = [x for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and "hbm_ns" in x and x["t"] - iv[0]["t"] >= 1.0]
    c = lambda x: x["cnt"]
    ipc = M([c(x)["instructions"] / c(x)["cycles"] for x in rows])
    ghz = M([r.REF_GHZ * c(x)["cycles"] / c(x)["ref-cycles"] for x in rows])
    return dict(mops=prog["get_mops"], bw=M([(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in rows]),
                ipf=ipc * ghz * 1e9 * 64 / (prog["get_mops"] * 1e6))


out = ["## E25: fill sweep, deep pop/push (rewritten DEEP_VECTORIZATION) vs scalar 16 B (`logs/E25_deeppop`, queue 128 / batch 64, key prefetch 64 t2, 5 reps)\n",
       "| fill | scalar finds/s (M) [min-max] | deep pop/push finds/s (M) [min-max] | deep vs scalar | scalar / deep HBM GB/s | scalar / deep instr per find |",
       "|---|---|---|---|---|---|"]
for f in range(10, 100, 10):
    q = [per_rep(d) for d in sorted(BASE.glob(f"a11_q16_f{f}_r*"))]
    v = [per_rep(d) for d in sorted(BASE.glob(f"a11_deepvec_f{f}_r*"))]
    gq = lambda k: M([p[k] for p in q]); gv = lambda k: M([p[k] for p in v])
    mq, mv = [p["mops"] for p in q], [p["mops"] for p in v]
    out.append(f"| {f} | {gq('mops'):.0f} [{min(mq):.0f}-{max(mq):.0f}] | {gv('mops'):.0f} [{min(mv):.0f}-{max(mv):.0f}] | "
               f"{100 * (gv('mops') / gq('mops') - 1):+.1f}% | {gq('bw'):.1f} / {gv('bw'):.1f} | {gq('ipf'):.1f} / {gv('ipf'):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E25.md").write_text(txt + "\n")
print(txt)
