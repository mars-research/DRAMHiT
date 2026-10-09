"""E31: finds/s and HBM bandwidth vs table fill, deep pop/push (queue 128 / batch 64, L1 prefetch distance 24)
vs scalar (same settings). Medians over 3 reps, thin whiskers = min..max of reps. Writes tables/E31.md and
figures/E31_fill.png. Colors: reference palette slots 1-2 (#2a78d6, #eb6834), validated as a pair in the
dataviz skill's palette file; identity is also carried by marker shape and direct labels."""
import statistics as st
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import runlib as r
from analyze_gap import DH_MARK

M = st.median
BASE = r.HERE / "logs" / "E31_fill"
FILLS = list(range(10, 100, 10))
SERIES = [("dc24", "deep pop/push", "#2a78d6", "o"), ("qc", "scalar", "#eb6834", "s")]
INK, INK2, MUTED, GRID, AXIS, SURF = "#0b0b0b", "#52514e", "#898781", "#e1e0d9", "#c3c2b7", "#fcfcfb"


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    p = r.parse_program((d / "combined.log").read_text())
    assert p["find_ops"] == p["found"], d
    R = [x for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and "hbm_ns" in x and x["t"] - iv[0]["t"] >= 1.0]
    return p["get_mops"], M([(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in R])


data = {}
for v, *_ in SERIES:
    for f in FILLS:
        reps = [per_rep(d) for d in sorted(BASE.glob(f"a15_{v}_f{f}_r*"))]
        data[v, f] = ([m for m, _ in reps], [b for _, b in reps])

# table
rows = ["## E31: deep pop/push vs scalar, fill 10-90 (queue 128 / batch 64, L1 prefetch distance 24 for deep, key prefetch 64 t2, 3 reps)\n",
        "| fill | deep finds/s (M) [min-max] | scalar finds/s (M) [min-max] | deep vs scalar | deep HBM GB/s | scalar HBM GB/s |",
        "|---|---|---|---|---|---|"]
for f in FILLS:
    dm, db = data["dc24", f]; qm, qb = data["qc", f]
    rows.append(f"| {f} | {M(dm):.0f} [{min(dm):.0f}-{max(dm):.0f}] | {M(qm):.0f} [{min(qm):.0f}-{max(qm):.0f}] | "
                f"{100 * (M(dm) / M(qm) - 1):+.1f}% | {M(db):.1f} | {M(qb):.1f} |")
(r.HERE / "tables" / "E31.md").write_text("\n".join(rows) + "\n")
print("\n".join(rows))

# figure: two panels, one y-scale each (no dual axis)
plt.rcParams.update({"font.size": 10, "axes.edgecolor": AXIS, "axes.labelcolor": INK2, "xtick.color": MUTED,
                     "ytick.color": MUTED, "text.color": INK})
fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), facecolor=SURF)
panels = [(0, "Find throughput", "M finds/s", 0), (1, "HBM bandwidth (find phase)", "GB/s", 1)]
axes[1].set_ylim(240, 340)
for ax, (k, title, ylab, idx) in zip(axes, panels):
    ax.set_facecolor(SURF)
    ends = []
    for v, name, col, mk in SERIES:
        med = [M(data[v, f][idx]) for f in FILLS]
        lo = [med[i] - min(data[v, f][idx]) for i, f in enumerate(FILLS)]
        hi = [max(data[v, f][idx]) - med[i] for i, f in enumerate(FILLS)]
        ax.errorbar(FILLS, med, yerr=[lo, hi], color=col, marker=mk, markersize=7, linewidth=2,
                    elinewidth=1, capsize=0, markeredgecolor=SURF, markeredgewidth=1.5, label=name, zorder=3)
        ends.append((med[-1], name))
    # direct labels at the right end, in text ink; nudged apart (in points) when the ends are close
    ends.sort()
    y0, y1 = ax.get_ylim()
    pts_per_unit = ax.get_window_extent().height / (y1 - y0)
    offs = [0.0] * len(ends)
    for i in range(1, len(ends)):
        gap = (ends[i][0] - ends[i - 1][0]) * pts_per_unit + offs[i] - offs[i - 1]
        if gap < 12:
            offs[i - 1] -= (12 - gap) / 2
            offs[i] += (12 - gap) / 2
    for (yv, name), o in zip(ends, offs):
        ax.annotate(name, (FILLS[-1], yv), xytext=(9, o), textcoords="offset points", va="center",
                    fontsize=9, color=INK2)
    if idx == 1:
        ax.axhline(328, color=INK2, linewidth=1, linestyle=(0, (4, 3)), zorder=2)
        ax.annotate("target 328 GB/s", (FILLS[0], 328), xytext=(0, 5), textcoords="offset points", fontsize=9, color=INK2)
    ax.set_title(title, loc="left", fontsize=11, color=INK)
    ax.set_xlabel("table fill (%)")
    ax.set_ylabel(ylab)
    ax.set_xticks(FILLS)
    ax.set_xlim(5, 106)
    ax.grid(axis="y", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    ax.legend(frameon=False, loc="lower left", fontsize=9)
fig.text(0.01, 0.01, "deep: queue 128, batch 64, L1 prefetch distance 24; scalar: queue 128, batch 64. "
         "Median of 3 runs; whiskers = min..max. All runs found every key.", fontsize=8, color=MUTED)
fig.tight_layout(rect=(0, 0.04, 1, 1))
out = r.HERE / "figures" / "E31_fill.png"
out.parent.mkdir(exist_ok=True)
fig.savefig(out, dpi=150, facecolor=SURF)
print("wrote", out)
