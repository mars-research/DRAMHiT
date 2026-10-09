import sys, statistics as st
sys.path.insert(0, '/opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/bwgap')
import runlib as r
from analyze_gap import BW_MARK, DH_MARK
BASE = r.HERE / "logs" / "E12_100ms"
W = ["bw_t1_c2200", "dramhit_keyshbm_f10", "bw_t1", "mimic_s1", "mimic_s2", "mimic_s3", "mimic_s4", "mimic_s5_keyshbm", "a7_base_f10", "a7_vec4s_f10", "a7_vec4_f10"]
M = st.median
print("| workload | core GHz | mesh GHz | cycles/HBM line | offcore data reads per HBM line | avg outstanding per core | latency (core cycles) | latency (ns) | xq full % | fb full % |")
print("|---|---|---|---|---|---|---|---|---|---|")
for w in W:
    per = []
    for d in sorted(BASE.glob(f"{w}_r*")):
        is_bw = w.startswith(("bw_", "mimic"))
        iv = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)[0]["run" if is_bw else "find"]
        rows = []
        for k in range(1, len(iv) - 1):
            x = iv[k]
            if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0: continue
            c = x["cnt"]; dt = x["t"] - iv[k-1]["t"]
            hbm_lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
            ghz = r.REF_GHZ * c["cycles"] / c["ref-cycles"]
            occ = c["offcore_requests_outstanding.data_rd"] / c["cycles"] * 64   # summed over 64 busy cpus -> per core x 64
            rows.append(dict(mesh=x["clk_cha_ghz"], ghz=ghz, cyc=c["cycles"] / hbm_lines, req=c["offcore_requests.data_rd"] / hbm_lines,
                             occ=c["offcore_requests_outstanding.data_rd"] / c["cycles"],
                             lat=c["offcore_requests_outstanding.data_rd"] / c["offcore_requests.data_rd"],
                             xq=100 * c["xq.full_cycles"] / c["cycles"], fb=100 * c["l1d_pend_miss.fb_full"] / c["cycles"]))
        if rows: per.append({k: M([x[k] for x in rows]) for k in rows[0]})
    g = lambda k: M([p[k] for p in per])
    print(f"| {w} | {g('ghz'):.3f} | {g('mesh'):.3f} | {g('cyc'):.1f} | {g('req'):.2f} | {g('occ'):.1f} | {g('lat'):.0f} | {g('lat')/g('ghz'):.0f} | {g('xq'):.1f} | {g('fb'):.1f} |")
