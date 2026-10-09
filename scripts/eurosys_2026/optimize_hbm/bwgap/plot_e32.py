"""E32: 16 B split arguments (SPLIT_ARGS) vs the shared 24 B InsertFindArgument, for the deep pop/push build
(distance 24) and the scalar build, queue 128 / batch 64, fills 10/30/50/70/90, 3 interleaved reps.
Writes tables/E32.md and figures/E32_split.png. Hue = find path (reference palette slots 1-2, a validated
pair); line style = argument size (solid 16 B split, dashed 24 B); markers filled/open repeat it."""
import statistics as st
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import runlib as r
from analyze_gap import DH_MARK

M = st.median
BASE = r.HERE / "logs" / "E32_split"
FILLS = [10, 30, 50, 70, 90]
BLUE, ORANGE = "#2a78d6", "#eb6834"
SERIES = [("dc24s", "deep, 16 B args", BLUE, "-", True), ("dc24", "deep, 24 B args", BLUE, "--", False),
          ("qcs", "scalar, 16 B args", ORANGE, "-", True), ("qc", "scalar, 24 B args", ORANGE, "--", False)]
INK, INK2, MUTED, GRID, AXIS, SURF = "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7", "#fcfcfb"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    p = r.parse_program((d / "combined.log").read_text())
    assert p["find_ops"] == p["found"], d
    R = [x for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and "hbm_ns" in x and x["t"] - iv[0]["t"] >= 1.0]
    return p["get_mops"], M([(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in R]), p["set_mops"]


data = {}
for v, *_ in SERIES:
    for f in FILLS:
        reps = [per_rep(d) for d in sorted(BASE.glob(f"a15_{v}_f{f}_r*"))]
        data[v, f] = tuple(list(col) for col in zip(*reps))  # (finds, bw, inserts)

rows = ["## E32: 16 B split arguments vs 24 B InsertFindArgument (`logs/E32_split`, queue 128 / batch 64, deep = distance 24, key prefetch 64 t2, 3 reps)\n",
        "| fill | deep 24 B finds/s (M) | deep 16 B finds/s (M) | deep 16 vs 24 | scalar 24 B | scalar 16 B | scalar 16 vs 24 | HBM GB/s deep 24 / 16 | HBM GB/s scalar 24 / 16 | inserts/s (M) deep 24 / 16 |",
        "|---|---|---|---|---|---|---|---|---|---|"]
for f in FILLS:
    g = lambda v, i: M(data[v, f][i])
    rng = lambda v: f"{g(v, 0):.0f} [{min(data[v, f][0]):.0f}-{max(data[v, f][0]):.0f}]"
    rows.append(f"| {f} | {rng('dc24')} | {rng('dc24s')} | {100 * (g('dc24s', 0) / g('dc24', 0) - 1):+.1f}% | {rng('qc')} | {rng('qcs')} | "
                f"{100 * (g('qcs', 0) / g('qc', 0) - 1):+.1f}% | {g('dc24', 1):.1f} / {g('dc24s', 1):.1f} | {g('qc', 1):.1f} / {g('qcs', 1):.1f} | "
                f"{g('dc24', 2):.0f} / {g('dc24s', 2):.0f} |")
(r.HERE / "tables" / "E32.md").write_text("\n".join(rows) + "\n")
print("\n".join(rows))

plt.rcParams.update({"font.size": 10, "axes.edgecolor": AXIS, "axes.labelcolor": INK2, "xtick.color": MUTED,
                     "ytick.color": MUTED, "text.color": INK})
fig, axes = plt.subplots(1, 3, figsize=(15, 4.4), facecolor=SURF)
panels = [("Find throughput", "M finds/s", 0), ("HBM bandwidth (find phase)", "GB/s", 1), ("Insert throughput", "M inserts/s", 2)]
for ax, (title, ylab, idx) in zip(axes, panels):
    ax.set_facecolor(SURF)
    for v, name, col, ls, filled in SERIES:
        med = [M(data[v, f][idx]) for f in FILLS]
        lo = [med[i] - min(data[v, f][idx]) for i, f in enumerate(FILLS)]
        hi = [max(data[v, f][idx]) - med[i] for i, f in enumerate(FILLS)]
        ax.errorbar(FILLS, med, yerr=[lo, hi], color=col, linestyle=ls, marker="o" if "deep" in name else "s",
                    markersize=7, linewidth=2, elinewidth=1, capsize=0,
                    markerfacecolor=col if filled else SURF, markeredgecolor=col, markeredgewidth=1.5,
                    label=name, zorder=3)
    if idx == 1:
        ax.axhline(328, color=INK2, linewidth=1, linestyle=(0, (4, 3)), zorder=2)
        ax.annotate("target 328 GB/s", (FILLS[0], 328), xytext=(0, 5), textcoords="offset points", fontsize=9, color=INK2)
        ax.set_ylim(250, 345)
    ax.set_title(title, loc="left", fontsize=11, color=INK)
    ax.set_xlabel("table fill (%)")
    ax.set_ylabel(ylab)
    ax.set_xticks(FILLS)
    ax.grid(axis="y", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
axes[0].legend(frameon=False, loc="lower left", fontsize=9)
fig.text(0.01, 0.01, "Queue 128, batch 64; deep = deep pop/push with L1 prefetch distance 24. 16 B args: find {key, id}, insert {key, value}; "
         "24 B: shared InsertFindArgument. Median of 3 runs; whiskers = min..max. All runs found every key.", fontsize=8, color=MUTED)
fig.tight_layout(rect=(0, 0.04, 1, 1))
out = r.HERE / "figures" / "E32_split.png"
out.parent.mkdir(exist_ok=True)
fig.savefig(out, dpi=150, facecolor=SURF)
print("wrote", out)
