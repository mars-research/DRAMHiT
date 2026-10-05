#!/usr/bin/env python3
"""E12: bw_t1 vs dramblast (rck, keys bound to HBM) from 100 ms perf-stat interval streams.

    python3 analyze_100ms.py [--dir logs/E12_100ms] [--steady-from 1.0]

Per interval (socket 0, S0 rows of `perf stat -a --per-socket -I 100 -x,`):
  HBM GB/s     (rd+wr CAS counts of the 32 uncore_hbm boxes x 32 B) / interval length
  core GHz     2.7 x cycles / ref-cycles
  mesh GHz     uncore_cha_0 clock ticks / time enabled
  IPC          instructions / cycles (all privilege levels)        instr rate = instructions / 64 cpus / dt
  package W    power/energy-pkg/ joules / dt
  xq / fb_full cycles fractions
The phase window is the program's own (dramblast: between its "find start"/"find end" log lines;
bandwidth_rand: between "Start/End perf collection"). The first and last interval of the window
straddle the marker and are dropped; with --steady-from S the first S seconds after the window
start are also excluded (bandwidth_rand runs ~1 s unthrottled first). Writes tables/E12_*.
"""
import argparse, json, statistics as st
from pathlib import Path
import runlib as r
from analyze_gap import DH_MARK, BW_MARK

TABLES = r.HERE / "tables"


def intervals(d):
    meta = json.loads((d / "meta.json").read_text())
    is_bw = "bw_" in meta["label"] or meta["label"].startswith("mimic")
    phases, info = r.parse_stream(d / "combined.log", BW_MARK if is_bw else DH_MARK)
    iv = phases["run" if is_bw else "find"]
    prog = r.parse_program((d / "combined.log").read_text())
    rows, prev = [], None
    for x in iv:
        dt = None if prev is None else x["t"] - prev
        prev = x["t"]
        rows.append((x, dt))
    t0 = rows[0][0]["t"]
    out = []
    for k, (x, dt) in enumerate(rows):
        if k == 0 or k == len(rows) - 1 or dt is None or "hbm_ns" not in x:
            continue                         # boundary intervals straddle a marker
        c = x["cnt"]
        out.append({
            "t_rel": x["t"] - t0, "dt": dt,
            "hbm_gbps": (x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"],
            "hbm_rd_gbps": x["hbm_rd_B"] / x["hbm_ns"],
            "core_ghz": r.REF_GHZ * c["cycles"] / c["ref-cycles"],
            "mesh_ghz": x["clk_cha_ghz"],
            "ipc": c["instructions"] / c["cycles"],
            "instr_gps_per_thread": c["instructions"] / dt / 64 / 1e9,
            "pkg_w": c["power/energy-pkg/"] / dt,
            "joules": c["power/energy-pkg/"],
            "xq_pct": 100 * c["xq.full_cycles"] / c["cycles"],
            "fb_pct": 100 * c["l1d_pend_miss.fb_full"] / c["cycles"],
        })
    return meta, prog, out, is_bw


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dir", default=str(r.HERE / "logs" / "E12_100ms"))
    ap.add_argument("--steady-from", type=float, default=1.0)
    a = ap.parse_args()
    base = Path(a.dir)
    names = sorted({p.name.rsplit("_r", 1)[0] for p in base.glob("*_r*")})
    data, csv = {}, ["workload,rep,t_rel_s,dt_s,hbm_gbps,core_ghz,mesh_ghz,ipc,instr_gps_per_thread,pkg_w,joules,xq_pct,fb_pct"]
    for n in names:
        data[n] = []
        for d in sorted(base.glob(f"{n}_r*")):
            meta, prog, iv, is_bw = intervals(d)
            rep = int(d.name.rsplit("_r", 1)[1])
            for x in iv:
                csv.append(f"{n},{rep},{x['t_rel']:.2f},{x['dt']:.3f},{x['hbm_gbps']:.1f},{x['core_ghz']:.3f},{x['mesh_ghz']:.3f},"
                           f"{x['ipc']:.3f},{x['instr_gps_per_thread']:.3f},{x['pkg_w']:.1f},{x['joules']:.2f},{x['xq_pct']:.1f},{x['fb_pct']:.1f}")
            steady = [x for x in iv if x["t_rel"] >= a.steady_from]
            if is_bw:
                lines_s = prog["bw_printed_gibps"] * 2 ** 30 / 64
                window = prog["time_s"]
            else:
                lines_s = prog["get_mops"] * 1e6
                window = prog["find_ops"] / lines_s
            data[n].append({"rep": rep, "all": iv, "steady": steady, "lines_s": lines_s, "window_s": window, "prog": prog})
    (TABLES / "E12_intervals.csv").write_text("\n".join(csv) + "\n")
    M = lambda xs: st.median(xs)
    keys = [("HBM GB/s [controllers]", "hbm_gbps", 1), ("core GHz", "core_ghz", 3), ("mesh GHz", "mesh_ghz", 3), ("IPC", "ipc", 2),
            ("instr rate per thread (G/s)", "instr_gps_per_thread", 2), ("package W", "pkg_w", 1),
            ("xq full %", "xq_pct", 1), ("fb_full %", "fb_pct", 1)]
    out = [f"## E12: 100 ms interval streams, steady state (t >= {a.steady_from} s into the window, boundary intervals dropped)\n",
           "Median over all steady intervals of all reps [median of per-rep medians; min-max of per-rep medians].\n",
           "| metric | " + " | ".join(names) + " |", "|---|" + "---|" * len(names)]
    for label, k, p in keys:
        cells = []
        for n in names:
            per = [M([x[k] for x in rep["steady"]]) for rep in data[n]]
            allv = M([x[k] for rep in data[n] for x in rep["steady"]])
            cells.append(f"{allv:.{p}f} [{M(per):.{p}f}; {min(per):.{p}f}-{max(per):.{p}f}]")
        out.append(f"| {label} | " + " | ".join(cells) + " |")
    # program-side numbers and derived energies
    prog_row = lambda f: [f(n) for n in names]
    out.append("| intervals used / run (reps) | " + " | ".join(f"{M([len(rep['steady']) for rep in data[n]]):.0f} ({len(data[n])})" for n in names) + " |")
    out.append("| window length from program (s) | " + " | ".join(f"{M([rep['window_s'] for rep in data[n]]):.2f}" for n in names) + " |")
    out.append("| lines (finds) per s, program (G) | " + " | ".join(f"{M([rep['lines_s'] for rep in data[n]])/1e9:.3f}" for n in names) + " |")
    ratio = lambda n: M([M([x["hbm_gbps"] for x in rep["steady"]]) for rep in data[n]])
    out.append("| energy per program line (nJ) = steady W / program lines/s | " + " | ".join(
        f"{M([M([x['pkg_w'] for x in rep['steady']]) / rep['lines_s'] * 1e9 for rep in data[n]]):.1f}" for n in names) + " |")
    out.append("| energy per HBM line (nJ) = steady W / (HBM GB/s / 64 B) | " + " | ".join(
        f"{M([M([x['pkg_w'] / (x['hbm_gbps'] * 1e9 / 64) * 1e9 for x in rep['steady']]) for rep in data[n]]):.1f}" for n in names) + " |")
    out.append("| HBM lines per program line (HBM GB/s / (lines/s x 64 B)) | " + " | ".join(
        f"{M([M([x['hbm_gbps'] for x in rep['steady']]) * 1e9 / (rep['lines_s'] * 64) for rep in data[n]]):.3f}" for n in names) + " |")
    out.append("| cycles per HBM line = 64 x core GHz / (HBM lines/s per thread...) | " + " | ".join(
        f"{M([M([64 * x['core_ghz'] * 1e9 / (x['hbm_gbps'] * 1e9 / 64) for x in rep['steady']]) for rep in data[n]]):.1f}" for n in names) + " |")
    # time series: median over reps in 0.5 s bins of the whole window
    out += ["", "### Time series (median over reps, 0.5 s bins from the start of the window; all intervals, boundary ones dropped)\n"]
    for n in names:
        out += [f"**{n}**\n", "| t (s) | HBM GB/s | core GHz | mesh GHz | IPC | package W |", "|---|---|---|---|---|---|"]
        bins = {}
        for rep in data[n]:
            for x in rep["all"]:
                bins.setdefault(int(x["t_rel"] / 0.5), []).append(x)
        for b in sorted(bins):
            xs = bins[b]
            if len(xs) < 3:
                continue
            out.append(f"| {b*0.5:.1f} | {M([x['hbm_gbps'] for x in xs]):.0f} | {M([x['core_ghz'] for x in xs]):.3f} | {M([x['mesh_ghz'] for x in xs]):.3f} | "
                       f"{M([x['ipc'] for x in xs]):.2f} | {M([x['pkg_w'] for x in xs]):.0f} |")
        out.append("")
    txt = "\n".join(out)
    (TABLES / "E12_summary.md").write_text(txt + "\n")
    print(txt)


if __name__ == "__main__":
    main()
