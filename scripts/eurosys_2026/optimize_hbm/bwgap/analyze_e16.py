"""E16: die-to-die fabric (MDF) traffic/congestion and CHA ingress rejects, per HBM line and per mesh cycle.
Steady intervals as everywhere (boundary dropped, t >= 1.0 s); per-rep medians, then median over reps -> tables/E16.md"""
import statistics as st
import runlib as r
from analyze_gap import BW_MARK, DH_MARK
M = st.median
W = ["bw_t1", "mimic_s1", "mimic_s2", "mimic_s4", "a7_base_f10"]
N_MDF = 20  # MDF boxes per socket (40 total)


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
        g = r.REF_GHZ * c["cycles"] / c["ref-cycles"]
        mesh_cyc = x["clk_cha_ghz"] * 1e9 * dt * N_MDF          # mesh cycles summed over the socket's MDF boxes
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], mesh=x["clk_cha_ghz"],
                 lat=c["offcore_requests_outstanding.data_rd"] / c["offcore_requests.data_rd"] / g)
        if "unc_mdf_crs_txr_inserts.ad_bnc" in c:
            v["ad_pl"] = (c["unc_mdf_crs_txr_inserts.ad_bnc"] + c["unc_mdf_crs_txr_inserts.ad_crd"]) / lines
            v["bl_pl"] = (c["unc_mdf_crs_txr_inserts.bl_bnc"] + c["unc_mdf_crs_txr_inserts.bl_crd"]) / lines
            v["bl_crd_frac"] = c["unc_mdf_crs_txr_inserts.bl_crd"] / (c["unc_mdf_crs_txr_inserts.bl_bnc"] + c["unc_mdf_crs_txr_inserts.bl_crd"])
        if "unc_mdf_crs_txr_v_bounces.ad" in c:
            v["vb_ad_pct"] = 100 * c["unc_mdf_crs_txr_v_bounces.ad"] / mesh_cyc
            v["vb_bl_pct"] = 100 * c["unc_mdf_crs_txr_v_bounces.bl"] / mesh_cyc
            v["fa_ad_pct"] = 100 * c["unc_mdf_fast_asserted.ad_bnc"] / mesh_cyc
            v["fa_bl_pct"] = 100 * c["unc_mdf_fast_asserted.bl_crd"] / mesh_cyc
        if "unc_cha_rxc_inserts.irq" in c:
            v["irq_pl"] = c["unc_cha_rxc_inserts.irq"] / lines
            v["rej_pl"] = c["unc_cha_rxc_inserts.irq_rej"] / lines
            v["rej_per_ins"] = c["unc_cha_rxc_inserts.irq_rej"] / c["unc_cha_rxc_inserts.irq"]
        rows.append(v)
    return {k: M([x[k] for x in rows]) for k in rows[0]}


cols = {"E16_mdf_ins": [("ad_pl", "AD (request) crossings / HBM line", 2), ("bl_pl", "BL (data) crossings / HBM line", 2), ("bl_crd_frac", "BL credited share", 2)],
        "E16_mdf_cong": [("vb_ad_pct", "AD V-bounce % of mesh cycles", 3), ("vb_bl_pct", "BL V-bounce %", 3), ("fa_ad_pct", "AD distress %", 3), ("fa_bl_pct", "BL distress %", 3)],
        "E16_chaq": [("irq_pl", "CHA ingress inserts / HBM line", 2), ("rej_pl", "CHA ingress rejects / HBM line", 2), ("rej_per_ins", "rejects per insert", 2)]}
out = ["## E16: die-to-die fabric (MDF) and CHA ingress (`logs/E16_*`)\n",
       "MDF % columns are event cycles / (mesh GHz x interval x 20 MDF boxes). Median of steady intervals per rep, then over reps (2 reps).\n"]
for dname, cc in cols.items():
    base = r.HERE / "logs" / dname
    out += [f"### {dname}\n", "| workload | HBM GB/s | mesh GHz | time per miss (ns) | " + " | ".join(c[1] for c in cc) + " |", "|---|---|---|---|" + "---|" * len(cc)]
    for w in W:
        reps = [per_rep(d, w) for d in sorted(base.glob(f"{w}_r*"))]
        g = lambda k: M([p[k] for p in reps])
        out.append(f"| {w} | {g('bw'):.1f} | {g('mesh'):.3f} | {g('lat'):.0f} | " + " | ".join(f"{g(k):.{n}f}" for k, _, n in cc) + " |")
    out.append("")
txt = "\n".join(out)
(r.HERE / "tables" / "E16.md").write_text(txt + "\n")
print(txt)
