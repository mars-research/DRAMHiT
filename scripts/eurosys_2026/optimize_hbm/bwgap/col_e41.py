"""E41: dramblast insert phase vs the 1-read-1-write bound (bw_t1_w), §12.3-style table. Same formulas as
col_e12.py / analyze_100ms.py (steady = t >= 1.0 s into the phase, boundary intervals dropped; median of all steady
intervals [median of per-rep medians; min-max of per-rep medians]), but the dramblast window is the *insert* phase
and program lines are inserts (set_mops). Prediction check as §12.6: per rep k, ratio against bw_t1_w rep k,
cycles per HBM line measured directly (socket-0 cycles / HBM lines), medians over reps 2..5.
usage: col_e41.py [logs dir [workload ...]]  -> tables/E41.md (E41_ins) or tables/<logs dir>.md"""
import json, re, sys, statistics as st
import runlib as r
from analyze_gap import BW_MARK, DH_MARK
M = st.median
COLS = [("bw_t1", "bw_t1 (read only)"), ("bw_t1_w", "**bw_t1_w (1r1w)**"),
        ("a21_dvs_p3_ins_f10", "**dramblast insert, best now (`attempt11/dvs_p3`)**"),
        ("a21_keyshbm_ins_f10", "dramblast insert, keys in HBM (attempt6)"),
        ("a22_dvs_p3_q128_b64_f10", "dramblast insert, dvs_p3, q128 / b64"),
        ("a22_dvi_hs24_q128_b16_f10", "**deep insert (`dvi_hs24`), q128 / b16**"),
        ("a22_dvi_hs24_q128_b64_f10", "deep insert (`dvi_hs24`), q128 / b64"),
        ("a22_dvs_p3_q128_b16_f10", "dvs_p3 insert, q128 / b16"),
        ("a23_dvk_k64t2_f10", "**deep insert cleaned (`dvk`), harness key pf 64 t2**"),
        ("a23_dvk128_k64t2_f10", "`dvk128` (16 B hash store), key pf 64 t2")]
REF = "bw_t1_w"


def rep(d):
    meta = json.loads((d / "meta.json").read_text())
    is_bw = meta["label"].startswith("bw_")
    iv = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)[0]["run" if is_bw else "insert"]
    p = r.parse_program((d / "combined.log").read_text())
    rows, t0 = [], iv[0]["t"]
    for k in range(1, len(iv) - 1):
        x = iv[k]
        if "hbm_ns" not in x or x["t"] - t0 < 1.0:
            continue
        c, dt = x["cnt"], x["t"] - iv[k - 1]["t"]
        lines = (x["hbm_rd_B"] + x["hbm_wr_B"]) / 64
        rows.append(dict(bw=(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"], rd=x["hbm_rd_B"] / x["hbm_ns"],
                         wr=x["hbm_wr_B"] / x["hbm_ns"], ghz=r.REF_GHZ * c["cycles"] / c["ref-cycles"],
                         mesh=x["clk_cha_ghz"] or 0, ipc=c["instructions"] / c["cycles"],
                         ips=c["instructions"] / dt / 64 / 1e9, w=c["power/energy-pkg/"] / dt,
                         xq=100 * c["xq.full_cycles"] / c["cycles"], fb=100 * c["l1d_pend_miss.fb_full"] / c["cycles"],
                         act=c["ref-cycles"] / (dt * r.REF_GHZ * 1e9), ccl=c["cycles"] / lines,
                         ipl=c["instructions"] / lines))
    if is_bw:
        prog_s, window = p["bw_printed_gibps"] * 2 ** 30 / 64, p["time_s"]
    else:
        prog_s = p["set_mops"] * 1e6
        window = int(re.search(r"insert_ops : (\d+)", (d / "combined.log").read_text()).group(1)) / prog_s
    med = {k: M([x[k] for x in rows]) for k in rows[0]}
    med.update(prog=prog_s, window=window, n=len(rows))
    return rows, med



def main(base, cols=None):
    global data
    if cols:
        COLS[:] = [(w, dict(COLS).get(w, w)) for w in cols]
    data = {}
    for w, _ in COLS:
        reps = {int(d.name.rsplit("_r", 1)[1]): rep(d) for d in sorted(base.glob(f"{w}_r*")) if (d / "meta.json").exists()}
        if reps:
            data[w] = reps


    def stat(w, k, n):
        per = [m[k] for _, m in data[w].values()]
        allv = M([x[k] for rows, _ in data[w].values() for x in rows])
        return f"{allv:.{n}f} [{M(per):.{n}f}; {min(per):.{n}f}–{max(per):.{n}f}]"


    def per(w, f, n):
        return f"{M([f(m) for _, m in data[w].values()]):.{n}f}"


    cols = [(w, h) for w, h in COLS if w in data]
    out = [f"## {base.name}: insert phase vs 1r1w bound (`logs/{base.name}`; reps {', '.join(str(len(data[w])) for w, _ in cols)})\n",
           "| metric | " + " | ".join(h for _, h in cols) + " |", "|---|" + "---|" * len(cols)]
    row = lambda name, f: out.append(f"| {name} | " + " | ".join(f(w) for w, _ in cols) + " |")
    row("HBM GB/s (rd + wr, controllers)", lambda w: stat(w, "bw", 1))
    row("HBM read / write GB/s", lambda w: f"{per(w, lambda m: m['rd'], 1)} / {per(w, lambda m: m['wr'], 1)}")
    row("core GHz", lambda w: stat(w, "ghz", 3))
    row("mesh GHz", lambda w: per(w, lambda m: m["mesh"], 3))
    row("IPC", lambda w: per(w, lambda m: m["ipc"], 2))
    row("instr rate per thread (G/s)", lambda w: per(w, lambda m: m["ips"], 2))
    row("package W", lambda w: per(w, lambda m: m["w"], 1))
    row("xq full % / fb_full %", lambda w: f"{per(w, lambda m: m['xq'], 1)} / {per(w, lambda m: m['fb'], 1)}")
    row("program lines (inserts) per s (G)", lambda w: per(w, lambda m: m["prog"] / 1e9, 3))
    row("window from program (s)", lambda w: per(w, lambda m: m["window"], 2))
    row("energy per program line (nJ)", lambda w: per(w, lambda m: m["w"] / m["prog"] * 1e9, 1))
    row("energy per HBM line (nJ)", lambda w: per(w, lambda m: m["w"] / (m["bw"] * 1e9 / 64) * 1e9, 1))
    row("HBM lines per program line (rd + wr)", lambda w: f"{per(w, lambda m: m['bw'] * 1e9 / 64 / m['prog'], 3)} "
        f"({per(w, lambda m: m['rd'] * 1e9 / 64 / m['prog'], 3)} + {per(w, lambda m: m['wr'] * 1e9 / 64 / m['prog'], 3)})")
    row("instr per HBM line", lambda w: per(w, lambda m: m["ipl"], 1))
    row("cycles per HBM line (64 × core GHz ÷ HBM lines/s)", lambda w: per(w, lambda m: 64 * m["ghz"] * 1e9 / (m["bw"] * 1e9 / 64), 1))
    row("cycles per program line", lambda w: per(w, lambda m: 64 * m["ghz"] * 1e9 / m["prog"], 1))
    row("steady intervals per rep", lambda w: per(w, lambda m: m["n"], 0))

    if REF in data:
        out += ["", f"### Prediction check against `{REF}` (per-rep ratios, reps 2–5, medians)\n",
                "| step | HBM GB/s ratio | clock ratio | active-cpu ratio | cycles-per-line effect (1 / ratio) | model | residual |",
                "|---|---|---|---|---|---|---|"]
        for w, h in cols:
            if w == REF:
                continue
            ks = [k for k in data[w] if k in data[REF] and k >= 2]
            if not ks:
                continue
            R = lambda key: [data[w][k][1][key] / data[REF][k][1][key] for k in ks]
            bw, ck, ac, cc = M(R("bw")), M(R("ghz")), M(R("act")), M(R("ccl"))
            model = [data[w][k][1]["ghz"] / data[REF][k][1]["ghz"] * data[w][k][1]["act"] / data[REF][k][1]["act"]
                     / (data[w][k][1]["ccl"] / data[REF][k][1]["ccl"]) for k in ks]
            res = [b / m - 1 for b, m in zip(R("bw"), model)]
            out.append(f"| {REF} → {h} | {bw:.3f} | {ck:.3f} | {ac:.3f} | {1 / cc:.3f} | {M(model):.3f} | {100 * M(res):+.1f} % |")
    txt = "\n".join(out)
    (r.HERE / "tables" / f"{'E41' if base.name == 'E41_ins' else base.name}.md").write_text(txt + "\n")
    print(txt)


if __name__ == "__main__":
    main(r.HERE / "logs" / (sys.argv[1] if len(sys.argv) > 1 else "E41_ins"), sys.argv[2:])
