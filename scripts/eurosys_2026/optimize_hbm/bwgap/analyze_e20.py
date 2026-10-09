"""E20: 16 B find-queue entries (attempt9). Finds/s from the program (get_mops), the rest from steady
100 ms intervals (boundary dropped, t >= 1.0 s). Per-rep medians; median [min-max] over reps. -> tables/E20.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
A = ["a9_base", "a9_q16", "a9_q16x", "a9_q16v", "a9_v4"]
DESC = {"a9_base": "32 B entries (attempt8 base)", "a9_q16": "16 B entries", "a9_q16x": "16 B entries, one 16 B store", "a9_q16v": "16 B entries + 4-entry block push/pop", "a9_v4": "32 B entries + vec4 group"}


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    prog = r.parse_program((d / "combined.log").read_text())
    rows = []
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
            continue
        c = {kk.replace(":u", ""): v for kk, v in x["cnt"].items()}
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        v = dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                 mesh=x["clk_cha_ghz"], ipc=c["instructions"] / c["cycles"], w=c["power/energy-pkg/"] / (x["t"] - iv[k - 1]["t"]),
                 cyc_line=c["cycles"] / lines)
        if "xq.full_cycles" in c:
            v["xq"] = 100 * c["xq.full_cycles"] / c["cycles"]
            v["fb"] = 100 * c["l1d_pend_miss.fb_full"] / c["cycles"]
        if "load_hit_prefetch.swpf" in c:
            v["late"] = c["load_hit_prefetch.swpf"] / lines
            v["t0"] = c["sw_prefetch_access.t0"] / lines
            v["t12"] = c["sw_prefetch_access.t1_t2"] / lines
        rows.append(v)
    out = {k: M([x[k] for x in rows]) for k in rows[0]}
    out["mops"] = prog["get_mops"]
    out["ipf"] = M([x["ipc"] for x in rows]) * out["ghz"] * 1e9 * 64 / (prog["get_mops"] * 1e6)
    return out


lines = ["## E20: 16 B find-queue entries (`logs/E20_q16*`, attempt9 binaries, fill 10, keys in HBM, key prefetch 64 ahead t2)\n",
         "finds/s from the program; other columns: median of steady 100 ms intervals per rep, median over 3 reps [min-max of finds/s].\n",
         "| config | key prefetch | finds/s (M) | vs original | HBM GB/s | core GHz | mesh GHz | IPC | instr/find | thread-cycles / HBM line | xq full % | fb full % |",
         "|---|---|---|---|---|---|---|---|---|---|---|---|"]
base = None
for a in A:
    reps = [per_rep(d) for d in sorted((r.HERE / "logs" / "E20_q16").glob(f"{a}_r*"))]
    g = lambda k: M([p[k] for p in reps])
    mo = [p["mops"] for p in reps]
    base = base or g("mops")
    lines.append(f"| {a} | {DESC[a]} | {g('mops'):.0f} [{min(mo):.0f}-{max(mo):.0f}] | {100 * (g('mops') / base - 1):+.1f}% | {g('bw'):.1f} | "
                 f"{g('ghz'):.3f} | {g('mesh'):.3f} | {g('ipc'):.2f} | {g('ipf'):.1f} | {g('cyc_line'):.1f} | {g('xq'):.1f} | {g('fb'):.1f} |")
lines += ["", "### Stall counters (`E20_q16_stall`, 2 reps)\n", "| config | finds/s (M) | HBM GB/s | store buffer full % | any stall % | stall with L1 miss % |", "|---|---|---|---|---|---|"]
for a in A:
    reps = []
    for d in sorted((r.HERE / "logs" / "E20_q16_stall").glob(f"{a}_r*")):
        iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
        prog = r.parse_program((d / "combined.log").read_text())
        rows = []
        for k in range(1, len(iv) - 1):
            x = iv[k]
            if "hbm_ns" not in x or x["t"] - iv[0]["t"] < 1.0:
                continue
            c = x["cnt"]
            rows.append(dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], sb=100 * c["resource_stalls.sb"] / c["cycles"],
                             st=100 * c["cycle_activity.stalls_total"] / c["cycles"], l1m=100 * c["cycle_activity.stalls_l1d_miss"] / c["cycles"]))
        v = {k: M([x[k] for x in rows]) for k in rows[0]}
        v["mops"] = prog["get_mops"]
        reps.append(v)
    g = lambda k: M([p[k] for p in reps])
    lines.append(f"| {a} | {g('mops'):.0f} | {g('bw'):.1f} | {g('sb'):.1f} | {g('st'):.1f} | {g('l1m'):.1f} |")
txt = "\n".join(lines)
(r.HERE / "tables" / "E20.md").write_text(txt + "\n")
print(txt)
