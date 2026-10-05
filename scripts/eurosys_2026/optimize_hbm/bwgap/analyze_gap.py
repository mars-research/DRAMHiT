#!/usr/bin/env python3
"""Regenerate every table of report-bwgap.md from the raw logs. Reads only logs/, writes tables/.

    python3 analyze_gap.py totals  [--dir logs/E2_totals_core]     # exact per-line costs
    python3 analyze_gap.py stream  [--dir logs/E1_stream]          # as-shipped interval stream
    python3 analyze_gap.py ladder  [--dir logs/E2_totals_ladder]   # t1pad vs t1dpad
    python3 analyze_gap.py all

totals  per workload and rep: Delta(instructions:u, cycles:u, ref-cycles:u, HBM CAS) between the
        2x-work and the 1x-work run, divided by the difference in lines. Nothing else is assumed.
stream  per workload and rep: socket-0 medians over the settled intervals (first and last
        interval of the phase dropped) of the 200 ms perf rows, split by the program's own markers.
"""
import argparse
import json
import statistics as st
import sys
from collections import defaultdict
from pathlib import Path

import runlib as r

TABLES = r.HERE / "tables"


def med(xs):
    xs = [x for x in xs if x is not None]
    return st.median(xs) if xs else None


def span(xs):
    xs = [x for x in xs if x is not None]
    return (min(xs), max(xs)) if xs else (None, None)


def fmt(xs, p=2):
    m = med(xs)
    if m is None:
        return "–"
    lo, hi = span(xs)
    return f"{m:.{p}f} ({lo:.{p}f}–{hi:.{p}f})"


# ------------------------------------------------------------------ E2: differential totals
def load_run(d):
    prog = r.parse_program((d / "program.out").read_text())
    tot = r.parse_totals(d / "perf.csv")
    meta = json.loads((d / "meta.json").read_text())
    is_bw = "alloc_mb" in prog
    if is_bw:
        lines = r.bw_lines(prog, meta["iters"])
        T = prog["time_s"]
    else:
        assert prog["found"] == prog["find_ops"], f"{d}: found != find_ops"
        lines = prog["find_ops"]
        T = prog["find_ops"] / (prog["get_mops"] * 1e6)
    rd = sum(v for k, v in tot.items() if False)  # placeholder (HBM rows are named mem_rd/mem_wr)
    return {"prog": prog, "tot": tot, "lines": lines, "T": T, "is_bw": is_bw}


def hbm_cas(d):
    """Sum of mem_rd / mem_wr CAS over socket-0 rows of perf.csv (event name is the 5th field)."""
    rd = wr = 0.0
    for line in (d / "perf.csv").read_text().splitlines():
        p = line.split(",")
        if len(p) < 6 or p[0] != "S0":
            continue
        try:
            v = float(p[2])
        except ValueError:
            continue
        if p[4] == "mem_rd":
            rd += v
        elif p[4] == "mem_wr":
            wr += v
    return rd, wr


def diff_pair(d1, d2):
    a, b = load_run(d1), load_run(d2)
    dl = b["lines"] - a["lines"]
    dT = b["T"] - a["T"]
    di = b["tot"]["instructions:u"] - a["tot"]["instructions:u"]
    dc = b["tot"]["cycles:u"] - a["tot"]["cycles:u"]
    dr = b["tot"]["ref-cycles:u"] - a["tot"]["ref-cycles:u"]
    rd1, wr1 = hbm_cas(d1)
    rd2, wr2 = hbm_cas(d2)
    out = {
        "instr_per_line": di / dl, "cycles_per_line": dc / dl, "ipc": di / dc,
        "core_ghz": r.REF_GHZ * dc / dr,
        "lines_per_s": dl / dT,
        "hbm_rd_lines_per_line": (rd2 - rd1) * 32 / 64 / dl,
        "hbm_wr_lines_per_line": (wr2 - wr1) * 32 / 64 / dl,
        "T1": a["T"], "T2": b["T"], "lines1": a["lines"], "lines2": b["lines"],
    }
    out["gbps_decimal_of_lines"] = out["lines_per_s"] * 64 / 1e9
    if "power/energy-pkg/" in a["tot"] and "power/energy-pkg/" in b["tot"]:     # socket-0 package energy (J)
        dj = b["tot"]["power/energy-pkg/"] - a["tot"]["power/energy-pkg/"]
        out["nj_per_line"] = dj / dl * 1e9
        out["pkg_w"] = dj / dT
    out["cycles_per_line_from_rate"] = 64 * out["core_ghz"] * 1e9 / out["lines_per_s"]
    if a["is_bw"]:
        out["printed_gibps_x2"] = b["prog"]["bw_printed_gibps"]
    else:
        out["get_mops_x1"], out["get_mops_x2"] = a["prog"]["get_mops"], b["prog"]["get_mops"]
    return out


def collect_totals(base):
    names = sorted({p.name.rsplit("_x", 1)[0] for p in base.glob("*_x1_r*")})
    res = {}
    for n in names:
        reps = sorted({p.name.rsplit("_r", 1)[1] for p in base.glob(f"{n}_x1_r*")})
        res[n] = [diff_pair(base / f"{n}_x1_r{k}", base / f"{n}_x2_r{k}") for k in reps]
    return res


def cmd_totals(a):
    base = Path(a.dir or r.HERE / "logs" / "E2_totals_core")
    res = collect_totals(base)
    TABLES.mkdir(exist_ok=True)
    lines = [f"## Per-line costs, differential totals ({base.name}), median (min–max) over reps\n",
             "| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |",
             "|---|---|---|---|---|---|---|---|---|---|"]
    for n, rows in res.items():
        g = lambda k, s=1.0, p=2: fmt([x[k] * s for x in rows], p)
        lines.append(f"| {n} | {len(rows)} | {g('lines_per_s', 1e-9, 3)} | {g('gbps_decimal_of_lines', 1, 1)} | {g('core_ghz', 1, 3)} | "
                     f"{g('instr_per_line', 1, 1)} | {g('cycles_per_line', 1, 2)} | {g('ipc', 1, 2)} | "
                     f"{g('hbm_rd_lines_per_line', 1, 3)} | {g('hbm_wr_lines_per_line', 1, 3)} |")
    lines += ["", "Cross-check, per workload (median): cycles/line computed two ways",
              "(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:", ""]
    for n, rows in res.items():
        lines.append(f"- {n}: (a) {med([x['cycles_per_line'] for x in rows]):.2f}  (b) {med([x['cycles_per_line_from_rate'] for x in rows]):.2f}")
    txt = "\n".join(lines)
    (TABLES / f"totals_{base.name}.md").write_text(txt + "\n")
    (TABLES / f"totals_{base.name}.json").write_text(json.dumps(res, indent=1))
    print(txt)
    return res


# ------------------------------------------------------------------ E1: interval stream
DH_MARK = [("zipfian test insert start", "insert"), ("zipfian test insert end", None),
           ("zipfian test find start", "find"), ("zipfian test find end", None)]
BW_MARK = [("Start perf collection", "run"), ("End perf collection", None)]


def stream_run(d, skip_s=0.0):
    meta = json.loads((d / "meta.json").read_text())
    text = (d / "combined.log").read_text()
    prog = r.parse_program(text)
    is_bw = "bw_" in meta["label"]
    phases, info = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)
    ph = "run" if is_bw else "find"
    iv = phases[ph]
    # interval length from consecutive timestamps; first interval of the phase starts mid-interval
    ts = [x["t"] for x in iv]
    for i, x in enumerate(iv):
        x["dt"] = ts[i] - ts[i - 1] if i else None
    sel = [x for x in r.settled(iv) if x["t"] - ts[0] >= skip_s]
    def ratio(num, den):
        n, dn = sum(x["cnt"].get(num, 0) for x in sel), sum(x["cnt"].get(den, 0) for x in sel)
        return n / dn if dn else None
    hbm = [(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in sel if "hbm_ns" in x]       # B/ns = GB/s
    hbm_rd = [x["hbm_rd_B"] / x["hbm_ns"] for x in sel if "hbm_ns" in x]
    out = {
        "intervals_total": len(iv), "intervals_used": len(sel), "window_s_from_rows": round(ts[-1] - ts[0], 2),
        "core_ghz": r.REF_GHZ * ratio("cycles", "ref-cycles"), "ipc": ratio("instructions", "cycles"),
        "mesh_ghz": med([x["clk_cha_ghz"] for x in sel]),
        "hbm_gbps": med(hbm), "hbm_rd_gbps": med(hbm_rd),
        "power_w": med([x["cnt"]["power/energy-pkg/"] / x["dt"] for x in sel if x["dt"] and "power/energy-pkg/" in x["cnt"]]),
        "xq_full_pct": 100 * ratio("xq.full_cycles", "cycles"),
        "fb_full_pct": 100 * ratio("l1d_pend_miss.fb_full", "cycles"),
        "l2miss_out_per_thread": ratio("offcore_requests_outstanding.data_rd", "cycles"),
        "min_running_pct": info["min_running_pct"], "markers": info["markers"],
    }
    if is_bw:
        out["printed_gibps"] = prog["bw_printed_gibps"]
        out["lines_per_s"] = prog["bw_printed_gibps"] * 2 ** 30 / 64
        out["program_window_s"] = prog["time_s"]
    else:
        assert prog["found"] == prog["find_ops"]
        out["get_mops"] = prog["get_mops"]
        out["lines_per_s"] = prog["get_mops"] * 1e6
        out["program_window_s"] = prog["find_ops"] / (prog["get_mops"] * 1e6)
    out["cycles_per_line"] = 64 * out["core_ghz"] * 1e9 / out["lines_per_s"]
    return out


def cmd_stream(a):
    base = Path(a.dir or r.HERE / "logs" / "E1_stream")
    names = sorted({p.name.rsplit("_r", 1)[0] for p in base.glob("*_r*")})
    TABLES.mkdir(exist_ok=True)
    keys = [("lines/s (G) [program]", "lines_per_s", 1e-9, 3), ("HBM GB/s [controllers]", "hbm_gbps", 1, 1),
            ("core GHz", "core_ghz", 1, 3), ("mesh GHz", "mesh_ghz", 1, 3), ("IPC", "ipc", 1, 2),
            ("package W", "power_w", 1, 1), ("xq full %", "xq_full_pct", 1, 1), ("fb_full %", "fb_full_pct", 1, 1),
            ("L2-miss outstanding / thread", "l2miss_out_per_thread", 1, 1), ("cycles/line [from rate]", "cycles_per_line", 1, 2)]
    res = {}
    for n in names:
        res[n] = {"all": [stream_run(d) for d in sorted(base.glob(f"{n}_r*"))],
                  "late": [stream_run(d, skip_s=1.2 if n.startswith("bw") else 0.0) for d in sorted(base.glob(f"{n}_r*"))]}
    out = ["## As-shipped interval stream (settled intervals; first and last of the phase dropped), median (min–max) over reps\n",
           "| metric | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
    for label, k, s, p in keys:
        out.append(f"| {label} | " + " | ".join(fmt([x[k] * s if x[k] is not None else None for x in res[n]["all"]], p) for n in names) + " |")
    out += ["", "Same, bandwidth_rand restricted to t >= 1.2 s into its window (after the ~1 s unthrottled burst):", "",
            "| metric | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
    for label, k, s, p in keys:
        out.append(f"| {label} | " + " | ".join(fmt([x[k] * s if x[k] is not None else None for x in res[n]["late"]], p) for n in names) + " |")
    out += ["", "Consistency checks (per workload, first rep): window length from perf rows vs the program's own, intervals used, min %running:", ""]
    for n in names:
        x = res[n]["all"][0]
        out.append(f"- {n}: rows {x['window_s_from_rows']} s, program {x['program_window_s']:.2f} s, intervals {x['intervals_used']}/{x['intervals_total']}, min running {x['min_running_pct']:.0f}%")
    txt = "\n".join(out)
    tag = "" if base.name == "E1_stream" else f"_{base.name}"
    (TABLES / f"stream{tag}.md").write_text(txt + "\n")
    (TABLES / f"stream{tag}.json").write_text(json.dumps({n: res[n] for n in names} if tag else {n: res[n]["all"] for n in names}, indent=1, default=str))
    print(txt)


def cmd_ladder(a):
    base = Path(a.dir or r.HERE / "logs" / "E2_totals_ladder")
    res = collect_totals(base)
    out = ["## Ladder: independent (t1pad) vs dependent (t1dpad) extra instructions, differential totals, median over reps\n",
           "| kind | N | instr/line | cycles/line | core GHz | IPC | lines/s (G) | decimal GB/s of lines |", "|---|---|---|---|---|---|---|---|"]
    for n, rows in res.items():
        kind, p = n.rsplit("_p", 1)
        out.append(f"| {kind} | {p} | {med([x['instr_per_line'] for x in rows]):.1f} | {med([x['cycles_per_line'] for x in rows]):.2f} | "
                   f"{med([x['core_ghz'] for x in rows]):.3f} | {med([x['ipc'] for x in rows]):.2f} | {med([x['lines_per_s'] for x in rows]) * 1e-9:.3f} | "
                   f"{med([x['gbps_decimal_of_lines'] for x in rows]):.1f} |")
    txt = "\n".join(out)
    (TABLES / "ladder.md").write_text(txt + "\n")
    print(txt)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("what", choices=["totals", "stream", "ladder", "all"])
    ap.add_argument("--dir")
    a = ap.parse_args()
    if a.what in ("totals", "all"):
        cmd_totals(a)
    if a.what in ("stream", "all"):
        cmd_stream(a)
    if a.what in ("ladder", "all"):
        cmd_ladder(a)


if __name__ == "__main__":
    main()
