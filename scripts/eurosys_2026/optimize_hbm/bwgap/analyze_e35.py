"""E35: asm trims p1/p2/p4/p6 (attempt11/trims/applied.diff; build attempt11/dvs_trim) vs the E34 deep build
(attempt11/dvs), fill 10..90, queue 128 / batch 64, key prefetch 64 t2, 3 interleaved reps, base counter set.
Steady find-phase intervals as in E34; per-rep medians, then median [min-max] over reps. -> tables/E35.md"""
import statistics as st
import runlib as r
from analyze_e34 import COLS, per_rep
M = st.median
BASE = r.HERE / "logs" / "E35_trim"


def reps(v, f):
    return [per_rep(d, COLS["base"]) for d in sorted(BASE.glob(f"a17_{v}_f{f}_r*"))]


rng = lambda xs, n=0: f"{M(xs):.{n}f} [{min(xs):.{n}f}–{max(xs):.{n}f}]"
out = ["## E35: asm trims (p1 wrap from blk, p2 andn byte offset, p4 bucket offset, p6 16 B reprobe store) vs E34 deep build\n",
       "`logs/E35_trim`, 3 interleaved reps, median [min–max] of per-rep medians. All runs `found == find_ops`.\n",
       "| fill | finds/s (M) base | finds/s (M) trim | Δ finds/s | HBM GB/s base | HBM GB/s trim | Δ GB/s | instr/find base → trim | thread-cycles / HBM line base → trim |",
       "|---|---|---|---|---|---|---|---|---|"]
for f in range(10, 100, 10):
    b, t = reps("dvs", f), reps("dvs_trim", f)
    if not b or not t:
        continue
    g = lambda R, k: [x[k] for x in R]
    db = 100 * (M(g(t, "mops")) / M(g(b, "mops")) - 1)
    out.append(f"| {f} | {rng(g(b, 'mops'))} | {rng(g(t, 'mops'))} | {db:+.1f} % | {rng(g(b, 'bw'), 1)} | {rng(g(t, 'bw'), 1)} | "
               f"{M(g(t, 'bw')) - M(g(b, 'bw')):+.1f} | {M(g(b, 'instr_find')):.1f} → {M(g(t, 'instr_find')):.1f} | "
               f"{M(g(b, 'cyc_line')):.1f} → {M(g(t, 'cyc_line')):.1f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E35.md").write_text(txt + "\n")
print(txt)
