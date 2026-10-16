"""E40: hyperthreading. 64 threads (2 per core) vs 32 threads (1 per core; sibling idle-polling or offline) for
bw_t1 and dramblast (attempt11/dvs_p3), fill 10 and 90. Core events user-mode only. Steady intervals (boundary
dropped, t >= 1.0 s); per-rep medians, median over 2 reps. Per-core values: FBs, the L2 miss queue and issue width
are per physical core, so counts summed over socket 0 are divided by core cycles = thread cycles / threads per core.
-> tables/E40.md"""
import statistics as st
import runlib as r
from analyze_gap import BW_MARK, DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E40_ht"
ROWS = [  # (workload, label, threads per core)
    ("bw_t1", "bw_t1, 64 thr (HT)", 2), ("bw_t1_t32", "bw_t1, 32 thr", 1), ("bw_t1_t32_la128", "bw_t1, 32 thr, lookahead 128", 1),
    ("a20_t64_q128_f10", "dramblast f10, 64 thr (HT), q128", 2), ("a20_t32_q128_f10", "dramblast f10, 32 thr, q128", 1),
    ("a20_t32_q256_f10", "dramblast f10, 32 thr, q256", 1),
    ("a20_t64_q128_f90", "dramblast f90, 64 thr (HT), q128", 2), ("a20_t32_q128_f90", "dramblast f90, 32 thr, q128", 1),
    ("a20_t32_q256_f90", "dramblast f90, 32 thr, q256", 1)]


def per_rep(d, tpc):
    is_bw = d.name.startswith("bw_")
    iv = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)[0]["run" if is_bw else "find"]
    p = r.parse_program((d / "combined.log").read_text())
    if not is_bw:
        assert p["find_ops"] == p["found"], d
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = {e.replace(":u", ""): v for e, v in x["cnt"].items()}
        dt = x["t"] - iv[k - 1]["t"]
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        core_cyc = c["cycles"] / tpc
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                 thr=c["ref-cycles"] / (dt * r.REF_GHZ * 1e9), ccl=core_cyc / lines, ipl=c["instructions"] / lines,
                 mesh=x["clk_cha_ghz"] or 0)
        g = lambda e: c.get(e)
        if g("offcore_requests_outstanding.data_rd"):
            v["l2q"] = c["offcore_requests_outstanding.data_rd"] / core_cyc            # L2-miss reads in flight per core
            v["lat"] = c["offcore_requests_outstanding.data_rd"] / c["offcore_requests.data_rd"] / v["ghz"]
            v["xq"] = 100 * c["xq.full_cycles"] / c["cycles"]
        if g("l1d_pend_miss.fb_full") is not None:
            v["fbf"] = 100 * c["l1d_pend_miss.fb_full"] / c["cycles"]
        if g("l1d_pend_miss.pending"):
            v["fbo"] = c["l1d_pend_miss.pending"] / core_cyc                           # L1 misses in flight per core
            v["l2s"] = 100 * c["l1d_pend_miss.l2_stalls"] / c["cycles"]
        if g("uops_issued.any"):
            v["iss"] = c["uops_issued.any"] / core_cyc                                 # of 6 per core cycle
            v["be"] = 100 * c["topdown.backend_bound_slots"] / (6 * c["cycles"])
            v["mb"] = 100 * c["topdown.memory_bound_slots"] / (6 * c["cycles"])
        rows.append(v)
    out = {k: M([x[k] for x in rows]) for k in rows[0]}
    out["prog"] = p["bw_printed_gibps"] * 2 ** 30 / 64 / 1e9 if is_bw else p["get_mops"] / 1e3   # G lines (finds) / s
    return out


def agg(cfg, s, w, tpc):
    reps = [per_rep(d, tpc) for d in sorted((BASE / f"{cfg}_{s}").glob(f"{w}_r*")) if (d / "meta.json").exists()]
    return {k: M([x[k] for x in reps if k in x]) for k in reps[0]} if reps else None


def cfgs(w):
    return [("online", "HT" if w in ("bw_t1",) or "_t64_" in w else "sibling polling")] + \
           ([("offline", "sibling offline")] if w not in ("bw_t1",) and "_t64_" not in w else [])


out = ["## E40: hyperthreading (`logs/E40_ht/<online|offline>_<set>`, 2 reps, core events user mode)\n",
       "Per core = summed over socket 0 / (thread cycles / threads per core); 32 cores in every row.\n",
       "| workload | sibling | HBM GB/s | program G/s | core GHz | busy threads | core-cycles / HBM line | instr / HBM line | "
       "L2-miss reads in flight / core | ns per L2-miss read | xq full % | L1 misses in flight / core | FB full % | L1 miss blocked by L2 % | uops issued / core cycle | backend % | mem-bound % |",
       "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
for w, label, tpc in ROWS:
    for cfg, sib in cfgs(w):
        b, f, t = agg(cfg, "base", w, tpc), agg(cfg, "fb", w, tpc), agg(cfg, "td", w, tpc)
        if not b:
            continue
        fx = lambda d, k, n: f"{d[k]:.{n}f}" if d and k in d else "-"
        out.append(f"| {label} | {sib} | {b['bw']:.1f} | {b['prog']:.3f} | {b['ghz']:.3f} | {b['thr']:.1f} | {b['ccl']:.1f} | {b['ipl']:.1f} | "
                   f"{fx(b,'l2q',1)} | {fx(b,'lat',0)} | {fx(b,'xq',1)} | {fx(f,'fbo',1)} | {fx(b,'fbf',1)} | {fx(f,'l2s',1)} | "
                   f"{fx(t,'iss',2)} | {fx(t,'be',1)} | {fx(t,'mb',1)} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E40.md").write_text(txt + "\n")
print(txt)
