"""E17: core resources around software prefetches. Per steady interval (boundary dropped, t >= 1.0 s):
% columns are per-thread cycles / cycles; per-line columns divide by HBM CAS lines; FB occupancy = average
outstanding L1D misses per thread. Per-rep medians, then median over reps (2). -> tables/E17.md"""
import statistics as st
import runlib as r
from analyze_gap import BW_MARK, DH_MARK
M = st.median
W = ["bw_t1", "mimic_s1", "mimic_s2", "mimic_s3", "mimic_s4", "a7_base_f10", "bw_t1_t32", "mimic_s4_t32"]
SETS = {
    "fb": [("fb_occ", "FB occupancy / thread", 1), ("fb_any", "cycles with an L1 miss %", 1), ("fb_full", "FB full %", 1),
           ("l2_stall", "L1 miss blocked by L2 (queue full) %", 1)],
    "swpf": [("t12_pl", "prefetcht1/t2 per line", 2), ("t0_pl", "prefetcht0 per line", 2),
             ("late_pl", "loads hitting an in-flight sw prefetch per line", 3), ("fbhit_pl", "retired loads hitting FB per line", 3)],
    "stall": [("sb", "store buffer full %", 1), ("sbd", "scoreboard %", 1), ("st_all", "any stall %", 1), ("st_l1m", "stall with L1 miss %", 1)],
    "l2": [("swpf_miss_pl", "sw prefetch L2 miss per line", 2), ("swpf_hit_pl", "sw prefetch L2 hit per line", 2),
           ("l2in_pl", "L2 fills per line", 2), ("l1rep_pl", "L1 fills per line", 2)],
}
EV = {"fb_occ": ("l1d_pend_miss.pending", "cyc"), "fb_any": ("l1d_pend_miss.pending_cycles", "pct"), "fb_full": ("l1d_pend_miss.fb_full", "pct"),
      "l2_stall": ("l1d_pend_miss.l2_stalls", "pct"), "t12_pl": ("sw_prefetch_access.t1_t2", "line"), "t0_pl": ("sw_prefetch_access.t0", "line"),
      "late_pl": ("load_hit_prefetch.swpf", "line"), "fbhit_pl": ("mem_load_retired.fb_hit", "line"), "sb": ("resource_stalls.sb", "pct"),
      "sbd": ("resource_stalls.scoreboard", "pct"), "st_all": ("cycle_activity.stalls_total", "pct"), "st_l1m": ("cycle_activity.stalls_l1d_miss", "pct"),
      "swpf_miss_pl": ("l2_rqsts.swpf_miss", "line"), "swpf_hit_pl": ("l2_rqsts.swpf_hit", "line"), "l2in_pl": ("l2_lines_in.all", "line"),
      "l1rep_pl": ("l1d.replacement", "line")}


def per_rep(d, w):
    is_bw = w.startswith(("bw_", "mimic"))
    iv = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)[0]["run" if is_bw else "find"]
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = {k.replace(":u", ""): v for k, v in x["cnt"].items()}
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        threads = c["ref-cycles"] / ((x["t"] - iv[k - 1]["t"]) * r.REF_GHZ * 1e9)
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                 cyc_line=c["cycles"] / lines, threads=threads)
        for key, (ev, kind) in EV.items():
            if ev in c:
                v[key] = c[ev] / c["cycles"] * (100 if kind == "pct" else 1) if kind != "line" else c[ev] / lines
        rows.append(v)
    return {k: M([x[k] for x in rows]) for k in rows[0]}


out = ["## E17: core resources around software prefetches (`logs/E17_*`, 2 reps each)\n",
       "cycles/line = thread cycles per HBM line (64-thread runs: x64 threads; 32-thread runs: x32). % = per-thread event cycles / cycles.\n"]
for s, cols in SETS.items():
    base = r.HERE / "logs" / f"E17_{s}"
    out += [f"### {s}\n", "| workload | threads | HBM GB/s | core GHz | thread-cycles / HBM line | " + " | ".join(c[1] for c in cols) + " |",
            "|---|---|---|---|---|" + "---|" * len(cols)]
    for w in W:
        reps = [per_rep(d, w) for d in sorted(base.glob(f"{w}_r*"))]
        if not reps:
            continue
        g = lambda k: M([p[k] for p in reps])
        out.append(f"| {w} | {g('threads'):.0f} | {g('bw'):.1f} | {g('ghz'):.3f} | {g('cyc_line'):.1f} | " + " | ".join(f"{g(k):.{n}f}" for k, _, n in cols) + " |")
    out.append("")
txt = "\n".join(out)
(r.HERE / "tables" / "E17.md").write_text(txt + "\n")
print(txt)
