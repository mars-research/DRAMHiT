"""E19: find key-stream prefetch placement (attempt8). Finds/s from the program (get_mops), the rest from steady
100 ms intervals (boundary dropped, t >= 1.0 s). Per-rep medians; median [min-max] over reps. -> tables/E19.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
A = ["a8_base", "a8_off", "a8_d32", "a8_d64", "a8_d128", "a8_d256", "a8_d64t2", "a8_d128t2", "a8_b64", "a8_b128"]
DESC = {"a8_base": "inline, 16 ahead, t0 (original)", "a8_off": "no key prefetch", "a8_d32": "inline, 32, t0", "a8_d64": "inline, 64, t0",
        "a8_d128": "inline, 128, t0", "a8_d256": "inline, 256, t0", "a8_d64t2": "inline, 64, t2", "a8_d128t2": "inline, 128, t2",
        "a8_b64": "batch start, 64, t0", "a8_b128": "batch start, 128, t0"}


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


lines = ["## E19: find key-stream prefetch placement (`logs/E19_keypf*`, attempt8 binary, fill 10, keys in HBM)\n",
         "finds/s from the program; other columns: median of steady 100 ms intervals per rep, median over 3 reps [min-max of finds/s].\n",
         "| config | key prefetch | finds/s (M) | vs original | HBM GB/s | core GHz | mesh GHz | IPC | instr/find | thread-cycles / HBM line | xq full % | fb full % |",
         "|---|---|---|---|---|---|---|---|---|---|---|---|"]
base = None
for a in A:
    reps = [per_rep(d) for d in sorted((r.HERE / "logs" / "E19_keypf").glob(f"{a}_r*"))]
    g = lambda k: M([p[k] for p in reps])
    mo = [p["mops"] for p in reps]
    base = base or g("mops")
    lines.append(f"| {a} | {DESC[a]} | {g('mops'):.0f} [{min(mo):.0f}-{max(mo):.0f}] | {100 * (g('mops') / base - 1):+.1f}% | {g('bw'):.1f} | "
                 f"{g('ghz'):.3f} | {g('mesh'):.3f} | {g('ipc'):.2f} | {g('ipf'):.1f} | {g('cyc_line'):.1f} | {g('xq'):.1f} | {g('fb'):.1f} |")
lines += ["", "### Software-prefetch counters (`E19_keypf_swpf`, 2 reps)\n",
          "| config | finds/s (M) | HBM GB/s | loads hitting an in-flight sw prefetch / HBM line | prefetcht0 / line | prefetcht1,t2 / line |", "|---|---|---|---|---|---|"]
for a in ["a8_base", "a8_off", "a8_d64", "a8_d128", "a8_b128"]:
    reps = [per_rep(d) for d in sorted((r.HERE / "logs" / "E19_keypf_swpf").glob(f"{a}_r*"))]
    g = lambda k: M([p[k] for p in reps])
    lines.append(f"| {a} | {g('mops'):.0f} | {g('bw'):.1f} | {g('late'):.3f} | {g('t0'):.2f} | {g('t12'):.2f} |")
txt = "\n".join(lines)
(r.HERE / "tables" / "E19.md").write_text(txt + "\n")
print(txt)
