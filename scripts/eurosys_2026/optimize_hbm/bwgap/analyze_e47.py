"""E47: deep find pop variants on the dvk build: DEEP_FIND_RES128 (one 16 B result store per hit, no 64 B assembly),
DEEP_FIND_KADD (value-lane mask by kaddb), both; find phase, queue 128 / batch 64, fill 10/50/90, 3 interleaved reps.
Per-rep medians of steady find-phase intervals (analyze_e34.per_rep), median [min-max] over reps. -> tables/E47.md"""
import statistics as st
import runlib as r
from analyze_e34 import COLS, per_rep
M = st.median
BASE = r.HERE / "logs" / "E47_find"
VS = [("dvk", "dvk (64 B result assembly)"), ("dvk_r", "+RES128"), ("dvk_ka", "+KADD"), ("dvk_rka", "+RES128 +KADD")]
rng = lambda xs, n=0: f"{M(xs):.{n}f} [{min(xs):.{n}f}–{max(xs):.{n}f}]"
out = ["## E47: deep find pop, 16 B result store per hit / kaddb (`logs/E47_find`, 3 reps, median [min–max] of per-rep medians)\n",
       "| fill | build | finds/s (M) | Δ vs dvk | HBM GB/s | Δ GB/s | core GHz | instr / find | thread-cycles / HBM line | FB full % |",
       "|---|---|---|---|---|---|---|---|---|---|"]
for f in (10, 50, 90):
    R = {v: [per_rep(d, COLS["base"]) for d in sorted(BASE.glob(f"a24_{v}_f{f}_r*"))] for v, _ in VS}
    if not R["dvk"]:
        continue
    g = lambda v, k: [x[k] for x in R[v]]
    b_m, b_bw = M(g("dvk", "mops")), M(g("dvk", "bw"))
    for v, name in VS:
        if not R[v]:
            continue
        d = "" if v == "dvk" else f"{100 * (M(g(v, 'mops')) / b_m - 1):+.1f} %"
        dbw = "" if v == "dvk" else f"{M(g(v, 'bw')) - b_bw:+.1f}"
        out.append(f"| {f} | {name} | {rng(g(v, 'mops'))} | {d} | {rng(g(v, 'bw'), 1)} | {dbw} | {M(g(v, 'ghz')):.3f} | "
                   f"{M(g(v, 'instr_find')):.1f} | {M(g(v, 'cyc_line')):.1f} | {M(g(v, 'fbf')):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E47.md").write_text(txt + "\n")
print(txt)
