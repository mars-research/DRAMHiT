"""E34: why HBM bandwidth drops at high fill. Deep build attempt11/dvs (build_deepvec.sh), queue 128 / batch 64,
key prefetch 64 t2, fills 10/50/70/90, one core counter set per run (no multiplexing), 2 reps.
Steady find-phase intervals (boundary dropped, >= 1.0 s in), per-rep medians, then median over reps.
Per-find values = per-HBM-line value x HBM lines per find (lines/s over the interval / program finds/s).
Socket 0 runs 64 threads on 32 cores, so "per core cycle" = sum over threads / (thread cycles / 2). -> tables/E34.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E34_fill"
FILLS = (10, 50, 70, 90)
# (column key, header, decimals, event, kind): kind pct = % of thread cycles, core = per core cycle,
# find = per find, lat = cycles per offcore read
COLS = {
    "base": [("occ", "L2-miss reads in flight / thread", 1, "offcore_requests_outstanding.data_rd", "thr"),
             ("lat_ns", "core time per L2-miss read (ns)", 0, None, None),
             ("fbf", "FB full %", 1, "l1d_pend_miss.fb_full", "pct"), ("xq", "xq full %", 1, "xq.full_cycles", "pct")],
    "td": [("uops_core", "uops issued / core cycle (of 6)", 2, "uops_issued.any", "core"),
           ("uops_find", "uops issued / find", 1, "uops_issued.any", "find"),
           ("be", "backend-bound % slots", 1, "topdown.backend_bound_slots", "slot"),
           ("mb", "memory-bound % slots", 1, "topdown.memory_bound_slots", "slot"),
           ("bs", "bad-spec % slots", 1, "topdown.bad_spec_slots", "slot")],
    "ports_a": [("p0", "p0 / core cycle", 2, "uops_dispatched.port_0", "core"), ("p1", "p1", 2, "uops_dispatched.port_1", "core"),
                ("p5", "p5+p11", 2, "uops_dispatched.port_5_11", "core"), ("p6", "p6", 2, "uops_dispatched.port_6", "core")],
    "ports_b": [("p23", "p2+p3+p10 / core cycle", 2, "uops_dispatched.port_2_3_10", "core"),
                ("p49", "p4+p9", 2, "uops_dispatched.port_4_9", "core"), ("p78", "p7+p8", 2, "uops_dispatched.port_7_8", "core")],
    "stall": [("sb", "store buffer full %", 1, "resource_stalls.sb", "pct"), ("sbd", "scoreboard %", 1, "resource_stalls.scoreboard", "pct"),
              ("st", "any stall %", 1, "cycle_activity.stalls_total", "pct"), ("stm", "stall with L1 miss %", 1, "cycle_activity.stalls_l1d_miss", "pct")],
    "fb": [("fbo", "FB occupancy / thread", 1, "l1d_pend_miss.pending", "thr"), ("fba", "cycles with an L1 miss %", 1, "l1d_pend_miss.pending_cycles", "pct"),
           ("fbf2", "FB full %", 1, "l1d_pend_miss.fb_full", "pct"), ("l2s", "L1 miss blocked by L2 %", 1, "l1d_pend_miss.l2_stalls", "pct")],
    "swpf": [("t12", "prefetcht1/t2 / find", 2, "sw_prefetch_access.t1_t2", "find"), ("t0", "prefetcht0 / find", 2, "sw_prefetch_access.t0", "find"),
             ("late", "loads hitting in-flight swpf / find", 2, "load_hit_prefetch.swpf", "find"),
             ("fbhit", "retired loads hitting FB / find", 2, "mem_load_retired.fb_hit", "find")],
    "br": [("misp", "mispredicted branches / find", 3, "br_misp_retired.all_branches", "find"),
           ("brs", "branches / find", 1, "br_inst_retired.all_branches", "find"),
           ("rec", "recovery cycles %", 1, "int_misc.recovery_cycles", "pct"),
           ("ret", "uops retired / find", 1, "uops_retired.slots", "find")],
    "l2": [("swm", "swpf L2 miss / find", 2, "l2_rqsts.swpf_miss", "find"), ("swh", "swpf L2 hit / find", 2, "l2_rqsts.swpf_hit", "find"),
           ("l2in", "L2 fills / find", 2, "l2_lines_in.all", "find"), ("l1in", "L1 fills / find", 2, "l1d.replacement", "find")],
}


def per_rep(d, cols):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    p = r.parse_program((d / "combined.log").read_text())
    assert p["find_ops"] == p["found"], d
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = x["cnt"]
        dt = x["t"] - iv[k - 1]["t"]
        rd_lines, lines = x["hbm_rd_B"] / 64, (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        ghz = r.REF_GHZ * c["cycles"] / c["ref-cycles"]
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], rd=x["hbm_rd_B"] / x["hbm_ns"], ghz=ghz,
                 ipc=c["instructions"] / c["cycles"], lines_s=lines / dt, rd_lines_s=rd_lines / dt,
                 cyc_line=c["cycles"] / lines, instr_line=c["instructions"] / lines, mesh=x["clk_cha_ghz"] or 0)
        for key, _, _, ev, kind in cols:
            if ev is None or ev not in c:
                continue
            v[key] = {"pct": 100 * c[ev] / c["cycles"], "thr": c[ev] / c["cycles"], "core": c[ev] / (c["cycles"] / 2),
                      "slot": 100 * c[ev] / (6 * c["cycles"]), "find": c[ev] / lines}[kind]  # "find": per line for now
        if "offcore_requests.data_rd" in c:
            v["lat_ns"] = c["offcore_requests_outstanding.data_rd"] / c["offcore_requests.data_rd"] / ghz
        rows.append(v)
    out = {k: M([x[k] for x in rows]) for k in rows[0]}
    out["mops"], out["set"] = p["get_mops"], p["set_mops"]
    out["lpf"] = out["lines_s"] / (p["get_mops"] * 1e6)              # HBM lines (rd + wr) per find
    out["rlpf"] = out["rd_lines_s"] / (p["get_mops"] * 1e6)
    for key, _, _, ev, kind in cols:
        if kind == "find" and key in out:
            out[key] *= out["lpf"]
    out["cyc_find"], out["instr_find"] = out["cyc_line"] * out["lpf"], out["instr_line"] * out["lpf"]
    return out


def agg(s, f):
    reps = [per_rep(d, COLS[s]) for d in sorted((BASE / s).glob(f"a16_dvs_f{f}_r*"))]
    return {k: M([p[k] for p in reps]) for k in reps[0]} if reps else None


if __name__ == "__main__":
    out = ["## E34: deep build (`attempt11/dvs`), fill 10/50/70/90 (`logs/E34_fill/<set>`, queue 128 / batch 64, 2 reps)\n",
           "thread-cycles/find = per-thread cycles x threads / finds (64 threads). HBM lines/find = (rd + wr) / finds.\n",
           "### Overview (base counter set)\n",
           "| fill | finds/s (M) | HBM GB/s (rd) | HBM lines / find (rd) | core GHz | mesh GHz | IPC | instr / find | thread-cycles / find | thread-cycles / HBM line |",
           "|---|---|---|---|---|---|---|---|---|---|"]
    for f in FILLS:
        g = agg("base", f)
        if g:
            out.append(f"| {f} | {g['mops']:.0f} | {g['bw']:.1f} ({g['rd']:.1f}) | {g['lpf']:.2f} ({g['rlpf']:.2f}) | {g['ghz']:.3f} | {g['mesh']:.2f} | "
                       f"{g['ipc']:.2f} | {g['instr_find']:.1f} | {g['cyc_find']:.1f} | {g['cyc_line']:.1f} |")
    for s, cols in COLS.items():
        out += ["", f"### {s}\n", "| fill | finds/s (M) | HBM GB/s | " + " | ".join(c[1] for c in cols) + " |", "|---|---|---|" + "---|" * len(cols)]
        for f in FILLS:
            g = agg(s, f)
            if g:
                out.append(f"| {f} | {g['mops']:.0f} | {g['bw']:.1f} | " + " | ".join(f"{g[k]:.{n}f}" if k in g else "-" for k, _, n, _, _ in cols) + " |")
    txt = "\n".join(out)
    (r.HERE / "tables" / "E34.md").write_text(txt + "\n")
    print(txt)
