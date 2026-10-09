"""E21: DEEP_VECTORIZATION find-queue length x batch length (attempt10). Finds/s from the program (get_mops);
other columns are medians of steady 100 ms intervals (boundary dropped, t >= 1.0 s); median over 3 reps. -> tables/E21.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E21_qb"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    prog = r.parse_program((d / "combined.log").read_text())
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = x["cnt"]
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        rows.append(dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                         ipc=c["instructions"] / c["cycles"], cyc=c["cycles"] / lines, xq=100 * c["xq.full_cycles"] / c["cycles"],
                         fb=100 * c["l1d_pend_miss.fb_full"] / c["cycles"]))
    v = {k: M([x[k] for x in rows]) for k in rows[0]}
    v["mops"] = prog["get_mops"]
    v["ipf"] = v["ipc"] * v["ghz"] * 1e9 * 64 / (prog["get_mops"] * 1e6)
    return v


names = sorted({p.name.rsplit("_r", 1)[0] for p in BASE.glob("a10_*_r*")})
data = {n: [per_rep(d) for d in sorted(BASE.glob(f"{n}_r*"))] for n in names}
g = lambda n, k: M([p[k] for p in data[n]])
ref = g("a10_q16_q64_b16", "mops")
out = ["## E21: DEEP_VECTORIZATION, find-queue length x batch length (`logs/E21_qb`, attempt10, fill 10, keys in HBM, key prefetch 64 ahead t2, 3 reps)\n",
       f"Reference: default 16 B scalar build at find queue 64, batch 16 = {ref:.0f} M finds/s.\n",
       "### finds/s (M), median [min-max] over reps; (vs reference)\n",
       "| find queue \\\\ batch | 16 | 32 | 64 |", "|---|---|---|---|"]
for fq in (32, 64, 128, 256):
    cells = []
    for bl in (16, 32, 64):
        n = f"a10_dv_q{fq}_b{bl}"
        mo = [p["mops"] for p in data[n]]
        cells.append(f"{g(n, 'mops'):.0f} [{min(mo):.0f}-{max(mo):.0f}] ({100 * (g(n, 'mops') / ref - 1):+.1f}%)")
    out.append(f"| {fq} | " + " | ".join(cells) + " |")
out += ["", "### Detail\n", "| config | finds/s (M) | HBM GB/s | core GHz | IPC | instr/find | thread-cycles / HBM line | xq full % | fb full % |",
        "|---|---|---|---|---|---|---|---|---|"]
for n in ["a10_q16_q64_b16"] + [f"a10_dv_q{fq}_b{bl}" for fq in (32, 64, 128, 256) for bl in (16, 32, 64)]:
    out.append(f"| {n} | {g(n, 'mops'):.0f} | {g(n, 'bw'):.1f} | {g(n, 'ghz'):.3f} | {g(n, 'ipc'):.2f} | {g(n, 'ipf'):.1f} | {g(n, 'cyc'):.1f} | {g(n, 'xq'):.1f} | {g(n, 'fb'):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E21.md").write_text(txt + "\n")
print(txt)
