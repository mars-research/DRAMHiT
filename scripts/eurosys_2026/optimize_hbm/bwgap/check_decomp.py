"""Check, stage by stage, that the HBM-bandwidth change factorises into core clock x cycles per HBM line.

Per steady interval (same selection as analyze_100ms.py: boundary intervals dropped, t >= 1.0 s):
  bw      = HBM bytes / counter-enabled ns                      (GB/s)
  ghz     = 2.7 * cycles / ref-cycles                           (mean clock of the unhalted cpus)
  active  = ref-cycles / (dt * 2.7e9)                           (busy cpus on socket 0; the model assumes 64)
  cyc     = cycles / (dt * HBM lines/s)                         (measured total cycles per HBM line, NOT 64 x ghz)
Model: bw = active * ghz / cyc * 64 B. Per rep: median over intervals. For each step A -> B and each rep k
(rep k of every workload ran in the same rep-major round): bw ratio vs clock ratio x active ratio x cycle ratio.
-> tables/E12_decomp.md"""
import statistics as st
from pathlib import Path
import runlib as r
from analyze_gap import BW_MARK, DH_MARK

BASE = r.HERE / "logs" / "E12_100ms"
CHAIN = ["bw_t1", "mimic_s1", "mimic_s2", "mimic_s3", "mimic_s4", "mimic_s5_keyshbm", "dramhit_keyshbm_f10"]
EXTRA = [("bw_t1", "bw_t1_c2200"), ("mimic_s4", "mimic_s5_keysddr"),
         # attempt7 deep-vectorization variants (only if they were run)
         ("dramhit_keyshbm_f10", "a7_base_f10"), ("a7_base_f10", "a7_emb_f10"), ("a7_base_f10", "a7_vec4s_f10"),
         ("a7_vec4s_f10", "a7_vec4_f10"), ("a7_base_f10", "a7_vec4_f10"), ("a7_vec4_f10", "bw_t1"),
         ("bw_t1", "dramhit_keyshbm_f10")]
M = st.median


def rep_stats(d):
    is_bw = d.name.startswith(("bw_", "mimic"))
    phases, _ = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)
    iv = phases["run" if is_bw else "find"]
    rows = []
    for k in range(1, len(iv) - 1):                       # drop boundary intervals
        x, dt = iv[k], iv[k]["t"] - iv[k - 1]["t"]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = x["cnt"]
        bw = (x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"]
        rows.append({"bw": bw, "ghz": r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                     "active": c["ref-cycles"] / (dt * r.REF_GHZ * 1e9),
                     "cyc": c["cycles"] / (dt * bw * 1e9 / 64)})
    return {k: M([x[k] for x in rows]) for k in rows[0]} | {"n": len(rows)}


ALL = set(CHAIN) | {x for p in EXTRA for x in p}
data = {w: {int(d.name.rsplit("_r", 1)[1]): rep_stats(d) for d in sorted(BASE.glob(f"{w}_r*"))} for w in ALL}
data = {w: v for w, v in data.items() if v}
EXTRA = [(a, b) for a, b in EXTRA if a in data and b in data]

out = ["## E12 decomposition check: bandwidth ratio vs clock x active cpus x cycles per HBM line\n",
       "Per rep: medians of steady intervals. `cyc` is measured (socket-0 cycles / HBM lines), not derived from bandwidth.\n",
       "### Per workload (median over reps [min-max]); active = busy cpus on socket 0\n",
       "| workload | HBM GB/s | core GHz | active cpus | cycles per HBM line (measured) | 64 x GHz / lines (as in E12) |", "|---|---|---|---|---|---|"]
for w in [w for w in CHAIN + ["bw_t1_c2200", "mimic_s5_keysddr", "a7_base_f10", "a7_emb_f10", "a7_vec4s_f10", "a7_vec4_f10"] if w in data]:
    R = data[w].values()
    f = lambda k, p: f"{M([x[k] for x in R]):.{p}f} [{min(x[k] for x in R):.{p}f}-{max(x[k] for x in R):.{p}f}]"
    derived = M([64 * x["ghz"] / (x["bw"] / 64) for x in R])
    out.append(f"| {w} | {f('bw',1)} | {f('ghz',3)} | {f('active',1)} | {f('cyc',2)} | {derived:.2f} |")

out += ["", "### Steps (per rep k: ratio B/A; table shows median over the 5 reps, then reps 2-5 only)\n",
        "Model: bw_B/bw_A = (ghz_B/ghz_A) x (active_B/active_A) / (cyc_B/cyc_A). Residual = actual / model - 1.\n",
        "| step | reps | bw ratio | clock ratio | active ratio | 1/cycle ratio | model | residual | share of the log drop: clock / cycles / active |",
        "|---|---|---|---|---|---|---|---|---|"]
import math
for a, b in list(zip(CHAIN, CHAIN[1:])) + EXTRA:
    for reps in ([1, 2, 3, 4, 5], [2, 3, 4, 5]):
        rr = [k for k in reps if k in data[a] and k in data[b]]
        bw = [data[b][k]["bw"] / data[a][k]["bw"] for k in rr]
        ck = [data[b][k]["ghz"] / data[a][k]["ghz"] for k in rr]
        ac = [data[b][k]["active"] / data[a][k]["active"] for k in rr]
        cy = [data[a][k]["cyc"] / data[b][k]["cyc"] for k in rr]
        mo = [x * y * z for x, y, z in zip(ck, ac, cy)]
        res = [p / q - 1 for p, q in zip(bw, mo)]
        L = math.log(M(bw))
        share = (f"{math.log(M(ck))/L*100:.0f}% / {math.log(M(cy))/L*100:.0f}% / {math.log(M(ac))/L*100:.0f}%"
                 if abs(L) > 0.02 else "(no change)")
        out.append(f"| {a} -> {b} | {','.join(map(str, rr))} | {M(bw):.3f} | {M(ck):.3f} | {M(ac):.3f} | {M(cy):.3f} | "
                   f"{M(mo):.3f} | {M(res)*100:+.2f}% [{min(res)*100:+.2f}..{max(res)*100:+.2f}] | {share} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E12_decomp.md").write_text(txt + "\n")
print(txt)
