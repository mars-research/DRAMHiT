"""E15: split the time an L2 miss is outstanding into uncore (CHA TOR) and the rest, and count the
request types per HBM line. Steady intervals as in analyze_100ms (boundary dropped, t >= 1.0 s);
per rep medians, then median over reps. -> tables/E15.md"""
import statistics as st
import runlib as r
from analyze_gap import BW_MARK, DH_MARK

M = st.median
W = ["bw_t1", "mimic_s2", "mimic_s4", "a7_base_f10"]
DIRS = ["E15_cha_lat", "E15_cha_mix", "E15_cha_coh", "E15_mesh1600"]


def per_rep(d, w):
    is_bw = w.startswith(("bw_", "mimic"))
    iv = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)[0]["run" if is_bw else "find"]
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c, dt = x["cnt"], x["t"] - iv[k - 1]["t"]
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        ghz, mesh = r.REF_GHZ * c["cycles"] / c["ref-cycles"], x["clk_cha_ghz"]
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=ghz, mesh=mesh,
                 cyc=c["cycles"] / lines,
                 occ=c["offcore_requests_outstanding.data_rd"] / c["cycles"],
                 core_lat_ns=c["offcore_requests_outstanding.data_rd"] / c["offcore_requests.data_rd"] / ghz,
                 xq=100 * c["xq.full_cycles"] / c["cycles"])
        if "unc_cha_tor_occupancy.ia_miss" in c:
            v["cha_lat_ns"] = c["unc_cha_tor_occupancy.ia_miss"] / c["unc_cha_tor_inserts.ia_miss"] / mesh
            v["ia_miss_pl"] = c["unc_cha_tor_inserts.ia_miss"] / lines
            v["drd_pl"] = c["unc_cha_tor_inserts.ia_miss_drd"] / lines
        for ev, key in [("unc_cha_tor_inserts.ia_miss_drd_pref", "drd_pref_pl"), ("unc_cha_tor_inserts.ia_miss_llcprefdata", "llcpref_pl"),
                        ("unc_cha_tor_inserts.ia_miss_rfo", "rfo_pl"), ("unc_cha_tor_inserts.ia", "ia_all_pl"),
                        ("unc_cha_tor_inserts.ia_wbmtoi", "wb_pl"), ("unc_cha_snoops_sent.all", "snoop_pl")]:
            if ev in c:
                v[key] = c[ev] / lines
        rows.append(v)
    return {k: M([x[k] for x in rows]) for k in rows[0]}


out = ["## E15 (`logs/E15_*`): where an L2 miss spends its time, and what the cores send to the mesh\n",
       "core time per miss = offcore_requests_outstanding.data_rd / offcore_requests.data_rd (core cycles -> ns);",
       "uncore time per miss = unc_cha_tor_occupancy.ia_miss / unc_cha_tor_inserts.ia_miss (CHA cycles -> ns), all CHAs of socket 0.",
       "Per-HBM-line counts divide by HBM CAS lines (rd + wr). Median of steady intervals per rep, then over reps.\n"]
cols = [("bw", "HBM GB/s", 1), ("ghz", "core GHz", 3), ("mesh", "mesh GHz", 3), ("cyc", "cycles/HBM line", 1),
        ("occ", "misses in flight/core", 1), ("core_lat_ns", "core time per miss (ns)", 0), ("cha_lat_ns", "uncore (TOR) time per miss (ns)", 0),
        ("xq", "xq full %", 1), ("ia_miss_pl", "IA misses/line", 2), ("drd_pl", "DRd/line", 2), ("drd_pref_pl", "DRd_pref/line", 2),
        ("llcpref_pl", "LLC-pref data/line", 2), ("rfo_pl", "RFO/line", 3), ("ia_all_pl", "all IA reqs/line", 2),
        ("wb_pl", "WB M->I/line", 3), ("snoop_pl", "snoops/line", 3)]
for dname in DIRS:
    base = r.HERE / "logs" / dname
    data = {w: [per_rep(d, w) for d in sorted(base.glob(f"{w}_r*"))] for w in W}
    data = {w: v for w, v in data.items() if v}
    if not data:
        continue
    keys = [c for c in cols if all(c[0] in rep for v in data.values() for rep in v)]
    out += [f"### {dname}\n", "| workload | " + " | ".join(c[1] for c in keys) + " |", "|---|" + "---|" * len(keys)]
    for w, reps in data.items():
        out.append(f"| {w} ({len(reps)}) | " + " | ".join(f"{M([p[k] for p in reps]):.{n}f}" for k, _, n in keys) + " |")
    out.append("")
txt = "\n".join(out)
(r.HERE / "tables" / "E15.md").write_text(txt + "\n")
print(txt)
