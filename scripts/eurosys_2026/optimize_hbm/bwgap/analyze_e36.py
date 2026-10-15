"""E36: p3 (hash dword stores) / p5 (scalar result stores) / p3+p5 on top of the E35 build (attempt11/dvs_trim =
baseline), fill 10..90, queue 128 / batch 64, key prefetch 64 t2, 3 interleaved reps, base counter set.
Per-rep medians of steady find-phase intervals (as E34), then median [min-max] over reps. -> tables/E36.md"""
import statistics as st
import runlib as r
from analyze_e34 import COLS, per_rep
M = st.median
BASE = r.HERE / "logs" / "E36_p3p5"
VS = [("dvs_trim", "baseline"), ("t_p3", "+p3"), ("t_p5", "+p5"), ("t_p3p5", "+p3+p5")]


def reps(v, f):
    return [per_rep(d, COLS["base"]) for d in sorted(BASE.glob(f"a18_{v}_f{f}_r*"))]


rng = lambda xs, n=0: f"{M(xs):.{n}f} [{min(xs):.{n}f}–{max(xs):.{n}f}]"
out = ["## E36: p3 / p5 / p3+p5 vs the E35 build (`logs/E36_p3p5`, 3 interleaved reps, median [min–max] of per-rep medians)\n",
       "| fill | build | finds/s (M) | Δ vs base | HBM GB/s | Δ GB/s | HBM lines / find | instr / find | thread-cycles / HBM line | core GHz | FB full % |",
       "|---|---|---|---|---|---|---|---|---|---|---|"]
for f in range(10, 100, 10):
    R = {v: reps(v, f) for v, _ in VS}
    if not all(R.values()):
        continue
    g = lambda v, k: [x[k] for x in R[v]]
    b_m, b_bw = M(g("dvs_trim", "mops")), M(g("dvs_trim", "bw"))
    for v, name in VS:
        d = "" if v == "dvs_trim" else f"{100 * (M(g(v, 'mops')) / b_m - 1):+.1f} %"
        dbw = "" if v == "dvs_trim" else f"{M(g(v, 'bw')) - b_bw:+.1f}"
        out.append(f"| {f} | {name} | {rng(g(v, 'mops'))} | {d} | {rng(g(v, 'bw'), 1)} | {dbw} | {M(g(v, 'lpf')):.3f} | "
                   f"{M(g(v, 'instr_find')):.1f} | {M(g(v, 'cyc_line')):.1f} | {M(g(v, 'ghz')):.3f} | {M(g(v, 'fbf')):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E36.md").write_text(txt + "\n")
print(txt)
