"""E44: dynamic analysis of the deep insert (attempt11/dvi_hs24) vs dvs_p3, insert phase, q128 / b16, fill 10.
One core counter set per run (logs/E44_ctr/<set>), 2 reps. Steady insert-phase intervals (>= 1.0 s in, boundary
dropped), per-rep medians, median over reps. Per-insert value = per-HBM-line value x HBM lines per insert; "per core
cycle" = sum over threads / (thread cycles / 2) (64 threads on 32 cores). -> tables/E44.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
from analyze_e34 import COLS
M = st.median
BASE = r.HERE / "logs" / "E44_ctr"
WS = [("a22_dvs_p3_q128_b16_f10", "dvs_p3"), ("a22_dvi_hs24_q128_b16_f10", "dvi_hs24")]


def per_rep(d, cols):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["insert"]
    p = r.parse_program((d / "combined.log").read_text())
    rows, t0 = [], iv[0]["t"]
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - t0 < 1.0:
            continue
        c = {e.replace(":u", ""): v for e, v in x["cnt"].items()}
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        dt = x["t"] - iv[k - 1]["t"]
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                 lines_s=lines / dt, cyc_line=c["cycles"] / lines, instr_line=c["instructions"] / lines)
        for key, _, _, ev, kind in cols:
            if ev and ev in c:
                v[key] = {"pct": 100 * c[ev] / c["cycles"], "thr": c[ev] / c["cycles"], "core": c[ev] / (c["cycles"] / 2),
                          "slot": 100 * c[ev] / (6 * c["cycles"]), "find": c[ev] / lines}[kind]
        rows.append(v)
    out = {k: M([x[k] for x in rows]) for k in rows[0]}
    lpi = out["lines_s"] / (p["set_mops"] * 1e6)
    out["ins"] = p["set_mops"]
    for key, _, _, ev, kind in cols:
        if kind == "find" and key in out:
            out[key] *= lpi
    out["instr_ins"], out["cyc_ins"] = out["instr_line"] * lpi, out["cyc_line"] * lpi
    return out


out = ["## E44: insert phase, dvs_p3 vs deep insert dvi_hs24 (q128 / b16, fill 10; `logs/E44_ctr/<set>`, 2 reps)\n",
       "Per-insert columns: \"/ find\" in the headers below means per insert. thread-cycles / insert = cycles × 64 threads / inserts."]
for s in ("td", "ports_a", "ports_b", "stall", "fb", "br"):
    cols = COLS[s] if s != "ports_b" else COLS[s] + [("mba", "mba stalls %", 1, "int_misc.mba_stalls", "pct")]
    out += ["", f"### {s}\n", "| build | inserts/s (M) | HBM GB/s | core GHz | instr / insert | thread-cycles / insert | " +
            " | ".join(c[1].replace("/ find", "/ insert") for c in cols) + " |", "|---|---|---|---|---|---|" + "---|" * len(cols)]
    for w, name in WS:
        reps = [per_rep(d, cols) for d in sorted((BASE / s).glob(f"{w}_r*"))]
        if not reps:
            continue
        g = {k: M([x[k] for x in reps if k in x]) for k in reps[0]}
        out.append(f"| {name} | {g['ins']:.0f} | {g['bw']:.1f} | {g['ghz']:.3f} | {g['instr_ins']:.1f} | {g['cyc_ins']:.1f} | " +
                   " | ".join(f"{g[k]:.{n}f}" if k in g else "-" for k, _, n, _, _ in cols) + " |")
txt = "\n".join(out)
(r.HERE / "tables" / "E44.md").write_text(txt + "\n")
print(txt)
