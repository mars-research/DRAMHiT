#!/usr/bin/env python3
"""dramblast (cas, ht-type 3) uniform benchmark on HBM node 2, CPU-placement experiments.

This reuses ../macro_uniform/collect_data_intel_hbm.py without changes: the same
build flags, the same dramhit command line, and the same perf HBM-bandwidth
parsing and json layout. Only the thread count and the cpu node mask differ
between configs. The table stays bound to node 2 (socket 0's HBM) in every
config.

    baseline  64 threads, cpus of node 0 (np_cpu_node_msk 0x1)
    allcpu    128 threads, cpus of node 0 + node 1 (np_cpu_node_msk 0x3); the
              node-1 threads reach node 2 over UPI

    python3 run_uniform_hbm.py --config baseline [--fill 50] [--reps 3] [--dry-run]
    python3 run_uniform_hbm.py --config baseline --binary <dramhit> --tag <name>
    python3 run_uniform_hbm.py ... --energy     # + package power, core clock, nJ/op

--energy adds power/energy-pkg/, cycles and ref-cycles to the collector's perf
command (made system-wide with -a, which --per-socket then needs) and records per
phase, for socket 0, over the same settled intervals the bandwidth uses:
  pkg_w      median package power (RAPL Joules / interval length)
  core_ghz   median cycles / ref-cycles x 2.7 GHz over socket 0's 64 cpus, all of
             which run benchmark threads here
  nj_per_op  pkg_w / Mops x 1000, i.e. package energy per insert (set) / find (get)
  mesh_ghz   median UNC_CHA_CLOCKTICKS of uncore_cha_0 / time enabled, the mesh clock
             (2.494 GHz when the package is under its power limit; see report-uncore.md)
"""

import argparse
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "macro_uniform"))
import collect_data_intel_hbm as c  # noqa: E402

CONFIGS = {
    "baseline": {"threads": 64, "cpu_msk": 0x1,
                 "memory": "hbm (numa node 2), 64 threads on node 0"},
    "allcpu": {"threads": 128, "cpu_msk": 0x3,
               "memory": "hbm (numa node 2), 128 threads on nodes 0+1"},
}
TABLE = "cas_hwpf_off"   # dramblast, hardware prefetcher off (MSR 0x1a4 = 0x2f)
REF_GHZ = 2.7            # ref-cycles tick at the TSC rate


def parse_energy(output):
    """Per-phase median socket-0 package W and core GHz from the perf -I stream.

    Mirrors the collector's parse_bw: the phase of a row is the last phase marker
    seen before it, both boundary intervals are dropped, and intervals within the
    first BW_WARMUP_S of a phase are skipped when enough remain.
    """
    import statistics
    phase, prev_ts = None, None
    rows = {"set": {}, "get": {}}          # phase -> ts -> {"j", "cyc", "ref", "dt"}
    rows["_mesh"] = {}                     # ts -> mesh GHz (not phase-tagged)
    for line in output.splitlines():
        for mark, target in c.PHASE_MARKS:
            if mark in line:
                phase = target
                break
        p = line.strip().split(",")
        if len(p) < 6 or not p[0][:1].isdigit() or p[1].strip() != "S0":
            continue
        try:
            ts, cnt = float(p[0]), float(p[3])
        except ValueError:
            continue
        ev = p[5].strip()
        if ev == "clk_cha":
            try:
                rows.setdefault("_mesh", {})[ts] = cnt / float(p[6])
            except (ValueError, IndexError, ZeroDivisionError):
                pass
            continue
        if ev not in ("power/energy-pkg/", "cycles", "ref-cycles"):
            continue
        if ev == "power/energy-pkg/":
            dt = ts - prev_ts if prev_ts is not None else None
            prev_ts = ts
        if phase is None:
            continue
        r = rows[phase].setdefault(ts, {})
        if ev == "power/energy-pkg/":
            r["j"], r["dt"] = cnt, dt
        else:
            r["cyc" if ev == "cycles" else "ref"] = cnt
    out = {}
    mesh = rows.pop("_mesh")
    for ph, byts in rows.items():
        ts_sorted = sorted(t for t, r in byts.items() if r.get("dt") and "ref" in r)
        if len(ts_sorted) > 4:
            ts_sorted = ts_sorted[1:-1]
        t0 = ts_sorted[0] if ts_sorted else 0
        settled = [t for t in ts_sorted if t - t0 >= c.BW_WARMUP_S]
        if len(settled) >= c.BW_MIN_INTERVALS:
            ts_sorted = settled
        if not ts_sorted:
            continue
        out[ph] = {
            "pkg_w": round(statistics.median(byts[t]["j"] / byts[t]["dt"] for t in ts_sorted), 1),
            "core_ghz": round(statistics.median(REF_GHZ * byts[t]["cyc"] / byts[t]["ref"]
                                                for t in ts_sorted), 3),
            "mesh_ghz": round(statistics.median(mesh[t] for t in ts_sorted if t in mesh), 3)
                        if any(t in mesh for t in ts_sorted) else None,
        }
    return out


def enable_energy():
    orig_events, orig_cmd = c.perf_event_string, c.dramhit_cmd
    orig_parse, orig_record = c.parse_bw, c.record_point
    c.perf_event_string = lambda: (orig_events() + ",power/energy-pkg/,cycles,ref-cycles,"
                                   "uncore_cha_0/event=0x01,name=clk_cha/")
    c.dramhit_cmd = lambda *a, **k: orig_cmd(*a, **k).replace(
        "sudo perf stat --per-socket", "sudo perf stat -a --per-socket")

    def parse(output):
        bw = orig_parse(output)
        for ph, e in parse_energy(output).items():
            bw.setdefault(ph, {}).update(e)
        return bw

    def record(entry, fill, points):
        orig_record(entry, fill, points)
        import statistics
        for ph in ("set", "get"):
            for key in ("pkg_w", "core_ghz", "mesh_ghz"):
                got = [p["bw"][ph][key] for p in points if key in p.get("bw", {}).get(ph, {})]
                entry.setdefault(f"{ph}_{key}", []).append(
                    round(statistics.median(got), 3) if got else None)
            nj = [p["bw"][ph]["pkg_w"] * 1000 / p[f"{ph}_mops"] for p in points
                  if "pkg_w" in p.get("bw", {}).get(ph, {})]
            entry.setdefault(f"{ph}_nj_per_op", []).append(
                round(statistics.median(nj), 2) if nj else None)
        print(f"     energy fill={fill}: set {entry['set_pkg_w'][-1]} W "
              f"{entry['set_core_ghz'][-1]} GHz (mesh {entry['set_mesh_ghz'][-1]}) "
              f"{entry['set_nj_per_op'][-1]} nJ/op | "
              f"get {entry['get_pkg_w'][-1]} W {entry['get_core_ghz'][-1]} GHz "
              f"(mesh {entry['get_mesh_ghz'][-1]}) {entry['get_nj_per_op'][-1]} nJ/op", flush=True)

    c.parse_bw, c.record_point = parse, record


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True, choices=list(CONFIGS))
    ap.add_argument("--fill", action="append", type=int)
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-hugepages", action="store_true")
    ap.add_argument("--binary", default=c.DRAMHIT,
                    help="dramhit binary to run (default: the collector's build/)")
    ap.add_argument("--tag", default=None,
                    help="results/<tag>/ instead of results/<config>/")
    ap.add_argument("--batch-len", type=int, default=None,
                    help="keys per find_batch/insert_batch call (collector default 16)")
    ap.add_argument("--energy", action="store_true",
                    help="also record package power, core clock and nJ/op per phase")
    args = ap.parse_args()
    if args.energy:
        enable_energy()
    if args.batch_len:
        c.TABLES[TABLE]["batch_len"] = args.batch_len

    cfg = CONFIGS[args.config]
    c.NUM_THREADS = cfg["threads"]
    c.NP_CPU_NODE_MSK = cfg["cpu_msk"]
    c.DRAMHIT = args.binary
    tag = args.tag or args.config
    c.DATA_DIR = HERE / "results" / tag
    fills = args.fill or c.FILLS
    out = c.DATA_DIR / f"{tag}_uniform.json"

    if args.dry_run:
        for f in fills:
            print(c.dramhit_cmd(c.TABLES[TABLE], f, with_bw=False))
        return 0

    if not args.no_hugepages:
        # Each thread's key buffer is allocated on that thread's own node, so
        # with node-1 threads, node 1 needs a 2 MB pool as well.
        c.sh(f"{c.HUGEPAGE_SCRIPT} reset")
        c.sh(f"{c.HUGEPAGE_SCRIPT} n{c.HBM_NODE}_{c.HT_1GB_PAGES}gb_{c.HBM_NODE_2MB_MB}mb "
             f"n0_0gb_{c.CPU_NODE_2MB_MB}mb n1_0gb_{c.CPU_NODE_2MB_MB}mb")

    results = c.new_results(args.reps)
    results["memory"] = cfg["memory"]
    results["config"] = args.config
    results["binary"] = args.binary
    results["energy"] = args.energy
    results["batch_len"] = c.TABLES[TABLE]["batch_len"]
    c.save(results, out)
    c.collect_table(TABLE, c.TABLES[TABLE], fills, args.reps, out, results, True)
    c.save(results, out)
    print(f"[OK] {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
