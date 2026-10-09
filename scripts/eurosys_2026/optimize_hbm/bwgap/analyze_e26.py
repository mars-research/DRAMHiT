"""E26: deep pop/push (rewritten DEEP_VECTORIZATION), find queue x batch length at fill 10 and 90, 3 reps;
reference: scalar 16 B at queue 128 / batch 64. -> tables/E26.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E26_qb_deeppop"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    prog = r.parse_program((d / "combined.log").read_text())
    assert prog["find_ops"] == prog["found"], d
    rows = [x for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and "hbm_ns" in x and x["t"] - iv[0]["t"] >= 1.0]
    ipc = M([x["cnt"]["instructions"] / x["cnt"]["cycles"] for x in rows])
    ghz = M([r.REF_GHZ * x["cnt"]["cycles"] / x["cnt"]["ref-cycles"] for x in rows])
    return dict(mops=prog["get_mops"], bw=M([(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in rows]),
                ipf=ipc * ghz * 1e9 * 64 / (prog["get_mops"] * 1e6))


def stat(n):
    reps = [per_rep(d) for d in sorted(BASE.glob(f"{n}_r*"))]
    mo = [p["mops"] for p in reps]
    return M(mo), min(mo), max(mo), M([p["bw"] for p in reps]), M([p["ipf"] for p in reps])


out = ["## E26: deep pop/push, find queue x batch length (`logs/E26_qb_deeppop`, fill 10 and 90, key prefetch 64 t2, 3 reps)\n"]
for f in (10, 90):
    ref = stat(f"a12_q16_q128_b64_f{f}")
    out += [f"### fill {f} — finds/s (M), median [min-max]; vs scalar at 128 / 64 = {ref[0]:.0f} [{ref[1]:.0f}-{ref[2]:.0f}], {ref[3]:.1f} GB/s\n",
            "| find queue \\\\ batch | 16 | 32 | 64 |", "|---|---|---|---|"]
    for fq in (32, 64, 128, 256):
        cells = []
        for bl in (16, 32, 64):
            m, lo, hi, bw, ipf = stat(f"a12_deepvec_q{fq}_b{bl}_f{f}")
            cells.append(f"{m:.0f} [{lo:.0f}-{hi:.0f}] ({100 * (m / ref[0] - 1):+.1f}%, {bw:.0f} GB/s, {ipf:.1f} i/f)")
        out.append(f"| {fq} | " + " | ".join(cells) + " |")
    out.append("")
txt = "\n".join(out)
(r.HERE / "tables" / "E26.md").write_text(txt + "\n")
print(txt)
