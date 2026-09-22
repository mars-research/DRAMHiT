#!/usr/bin/env python3
"""Core-count sweep on one socket of the Xeon Gold 6548Y+: how does DRAM
bandwidth scale with threads, and what does the prefetch instruction change?

Modelled on ../intel_hbm/collect_cpu_scaling.py, cut down to the case that
matters here: one socket, its own memory, no UPI and no HBM. Every run is
`machine_stats/bandwidth.c` built for random access, with cpus pinned to node 0
and memory bound to node 0 -- pattern "n0a0tN". The only thing changing across
a sweep is how many cores are pulling.

Two workloads, because the prefetch hint that helps one is meaningless for the
other:

  rand read   a dependent-free stream of random 64 B loads. The software
              prefetch is the only thing generating memory-level parallelism,
              so t0 vs t1 vs none is the whole experiment.

  1r1w        an 8 B store into a random 64 B line. At DRAM that is TWO
              transactions, not one: the line must be fetched (RFO) before it
              can be modified and written back later. prefetchw fetches it for
              write up front, so the store does not stall on an ownership
              upgrade. ntstore is the control -- a full-line non-temporal store
              never fetches the line at all, so it is 0r1w and should move
              roughly half the DRAM traffic of the others per store.

That distinction is why this collector measures the memory controllers and not
just the program. bandwidth.c reports GB/s from the bytes it *asked for*; in
write mode the DRAM moves about twice that. Both numbers are recorded, and the
ratio is the interesting part.

    python3 collect_cpu_scaling_intel.py --dry-run
    python3 collect_cpu_scaling_intel.py
    python3 collect_cpu_scaling_intel.py --series read_t0 --threads 1 2 4

Needs sudo (uncore PMUs) and 2 MB hugepages on node 0: bandwidth.c mmaps with
MAP_HUGETLB, and without them the mmap fails and the workers hang on their
barrier rather than exiting.
"""

import argparse
import json
import re
import shlex
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
BIN = (SCRIPT_DIR.parent / "machine_stats" / "build" / "bandwidth_rand").resolve()

MACHINE = "intel-6548y"
OUT_JSON = SCRIPT_DIR / f"{MACHINE}_cpu_scaling.json"
LOG_DIR = SCRIPT_DIR / "logs" / "cpu_scaling"

# --- machine -----------------------------------------------------------------
# Node 0 is cpus 0,2,...,62 then 64,66,...,126. bandwidth.c pins thread N to the
# Nth cpu of the node in ascending order, so threads 1..32 are one per physical
# core and 33..64 add the SMT sibling of an already-busy core. Where the curve
# bends relative to 32 is the finding.
CPU_NODE = 0
MEM_NODE = 0
SMT_BOUNDARY = 32
CPU_FREQ_GHZ = "2.5"      # pinned by scripts/constant_freq.sh; bandwidth.c
                          # turns rdtsc into seconds with it
LOOKAHEAD = "64"

THREADS = [1, 2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64]
REPS = 3

# Footprint. A per-thread size held constant across a core sweep is not a
# constant experiment -- at 1 thread a small chunk sits inside the 60 MiB L3 and
# never reaches DRAM. Aim at a fixed total instead, split across the threads.
#
# The cap is set by hugepages, not by taste: node 0 has 4096 2 MB pages
# reserved, and bandwidth.c will not fall back to 4 KB. 4 GiB (2048 pages)
# leaves room for anything else on the box. Against a 60 MiB L3 that is a 1.5%
# cache-to-footprint ratio at every point, which is enough.
TOTAL_FOOTPRINT_BYTES = 4 * 1024 ** 3
MAX_PER_THREAD_BYTES = 1024 ** 3
MIN_PER_THREAD_BYTES = 64 * 1024 ** 2

# --- what to sweep -----------------------------------------------------------
# `inst` is bandwidth.c's -inst; `mode` its -mode. "load" means no software
# prefetch at all, which is the baseline each prefetch hint is judged against.
SERIES = {
    "read_load":       {"mode": "r", "inst": "load",
                        "label": "rand read, no sw prefetch"},
    "read_t0":         {"mode": "r", "inst": "t0",
                        "label": "rand read, prefetcht0"},
    "read_t1":         {"mode": "r", "inst": "t1",
                        "label": "rand read, prefetcht1"},
    "write_load":      {"mode": "w", "inst": "load",
                        "label": "1r1w, no sw prefetch"},
    "write_prefetchw": {"mode": "w", "inst": "prefetchw",
                        "label": "1r1w, prefetchw"},
    "write_ntstore":   {"mode": "w", "inst": "ntstore",
                        "label": "0r1w, nt store (control)"},
}

PLOT_ORDER = ["read_load", "read_t0", "read_t1",
              "write_load", "write_prefetchw", "write_ntstore"]

# --- DRAM counters -----------------------------------------------------------
# Same PMU macro_uniform uses. -a covers both sockets; node 1 is idle for the
# whole sweep, so its controllers contribute nothing. Values are MiB per
# interval, so a rate needs the real timestamp delta (perf's -I is best-effort
# and its intervals run ~0.8% long, with a short partial one at the end).
BW_INTERVAL_MS = 100
BW_EVENTS = "uncore_imc/cas_count_read/,uncore_imc/cas_count_write/"
PERF_RE = re.compile(
    r"^([\d.]+),([\d.]+),(\w+),uncore_imc/cas_count_(read|write)/,")

# bandwidth.c brackets its measured loop with these, so allocation and
# first-touch traffic stays out of the window.
MARK_START = "Start perf collection"
MARK_END = "End perf collection"

PROG_BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s")
PROG_TIME_RE = re.compile(r"Time Taken\s*:\s*([\d.]+)\s*seconds")
PROG_GB_RE = re.compile(r"Total Data Proc\s*:\s*([\d.]+)\s*GB")


# =============================================================================
# RUN
# =============================================================================


def per_thread_bytes(threads):
    """Per-thread chunk, as a power of two (bandwidth.c rounds down anyway)."""
    target = min(MAX_PER_THREAD_BYTES, TOTAL_FOOTPRINT_BYTES // threads)
    size = MIN_PER_THREAD_BYTES
    while size * 2 <= target:
        size *= 2
    return size


def cmd_for(cfg, threads):
    chunk_mb = per_thread_bytes(threads) // (1024 ** 2)
    args = [
        str(BIN),
        "-m", f"{chunk_mb}mb",
        "-pattern", f"n{CPU_NODE}a{MEM_NODE}t{threads}",
        "-freq", CPU_FREQ_GHZ,
        "-inst", cfg["inst"],
        "-lookahead", LOOKAHEAD,
        "-mode", cfg["mode"],
    ]
    inner = " ".join(shlex.quote(a) for a in args)
    return (f"sudo perf stat -I {BW_INTERVAL_MS} -x, -a -e {BW_EVENTS} -- "
            + inner)


def parse_dram(output):
    """Median DRAM read/write GB/s over the intervals inside the markers."""
    inside = False
    prev_ts = 0.0
    pending = {}
    rows = []
    for line in output.splitlines():
        if MARK_START in line:
            inside = True
        elif MARK_END in line:
            inside = False
        m = PERF_RE.match(line)
        if not m:
            continue
        ts, val, unit, kind = (float(m.group(1)), float(m.group(2)),
                               m.group(3), m.group(4))
        if unit != "MiB":
            continue
        slot = pending.setdefault(ts, {"inside": inside})
        slot[kind] = val
        if "read" not in slot or "write" not in slot:
            continue
        dt = ts - prev_ts
        prev_ts = ts
        del pending[ts]
        if not slot["inside"] or dt <= 0:
            continue
        to_gbps = (1 << 20) / 1e9 / dt
        rows.append((slot["read"] * to_gbps, slot["write"] * to_gbps))

    # Both boundary intervals straddle a marker.
    if len(rows) > 4:
        rows = rows[1:-1]
    if not rows:
        return None
    return {
        "dram_rd_gbps": round(statistics.median(r for r, _ in rows), 1),
        "dram_wr_gbps": round(statistics.median(w for _, w in rows), 1),
        "dram_gbps": round(statistics.median(r + w for r, w in rows), 1),
        "intervals": len(rows),
    }


def run_one(name, cfg, threads, rep):
    cmd = cmd_for(cfg, threads)
    proc = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True)
    log = LOG_DIR / name / f"t{threads:02d}_rep{rep}.log"
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(f"$ {cmd}\n\n{proc.stdout}")

    prog = PROG_BW_RE.search(proc.stdout)
    if not prog:
        tail = "\n".join(proc.stdout.strip().splitlines()[-5:])
        return None, f"rc={proc.returncode}, no Bandwidth line; tail: {tail}"
    point = {"prog_gbps": float(prog.group(1))}
    t = PROG_TIME_RE.search(proc.stdout)
    if t:
        point["seconds"] = float(t.group(1))
    dram = parse_dram(proc.stdout)
    if dram:
        point.update(dram)
    else:
        print("      [!] no DRAM intervals parsed")
    return point, None


# =============================================================================
# COLLECTION
# =============================================================================


def new_results(reps, threads):
    return {
        "machine": MACHINE,
        "experiment": "cpu scaling, one socket",
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "binary": str(BIN),
        "cpu_node": CPU_NODE,
        "mem_node": MEM_NODE,
        "smt_boundary": SMT_BOUNDARY,
        "cpu_freq_ghz": float(CPU_FREQ_GHZ),
        "lookahead": int(LOOKAHEAD),
        "reps": reps,
        "threads": threads,
        "total_footprint_bytes": TOTAL_FOOTPRINT_BYTES,
        "bw_interval_ms": BW_INTERVAL_MS,
        "bw_unit": "decimal GB/s (bytes / 1e9)",
        "prog_bw_note": (
            "prog_gbps is what bandwidth.c computes from the bytes it asked "
            "for. In write mode DRAM moves about twice that (RFO + writeback); "
            "dram_gbps is the measured controller traffic."
        ),
        "plot_order": PLOT_ORDER,
        "series": {},
    }


def save(results, out_path):
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))


def collect_series(name, cfg, threads, reps, results, out_path):
    entry = {
        "label": cfg["label"],
        "mode": cfg["mode"],
        "inst": cfg["inst"],
        "threads": [],
        "prog_gbps": [],
        "dram_gbps": [],
        "dram_rd_gbps": [],
        "dram_wr_gbps": [],
        "footprint_mb": [],
        "prog_samples": [],
        "dram_samples": [],
        "failures": [],
    }
    results["series"][name] = entry

    for t in threads:
        points = []
        for rep in range(1, reps + 1):
            t0 = time.monotonic()
            point, err = run_one(name, cfg, t, rep)
            dt = time.monotonic() - t0
            if err:
                print(f"  [!] {name} t={t} rep={rep} FAILED after {dt:.0f}s: {err}")
                entry["failures"].append({"threads": t, "rep": rep, "error": err})
                continue
            points.append(point)
            print(f"  {name} t={t:2d} rep={rep}/{reps}  prog "
                  f"{point['prog_gbps']:7.1f}  dram "
                  f"{point.get('dram_gbps', float('nan')):7.1f} GB/s  ({dt:.0f}s)")
        if not points:
            print(f"  [!] {name} t={t}: every rep failed")
            save(results, out_path)
            continue

        entry["threads"].append(t)
        entry["footprint_mb"].append(
            per_thread_bytes(t) * t // (1024 ** 2))
        prog = [p["prog_gbps"] for p in points]
        entry["prog_gbps"].append(round(statistics.median(prog), 1))
        entry["prog_samples"].append(prog)
        for key in ("dram_gbps", "dram_rd_gbps", "dram_wr_gbps"):
            vals = [p[key] for p in points if key in p]
            entry[key].append(round(statistics.median(vals), 1) if vals else None)
        entry["dram_samples"].append(
            [p["dram_gbps"] for p in points if "dram_gbps" in p])
        print(f"  => {name} t={t:2d}  prog {entry['prog_gbps'][-1]:.1f}  "
              f"dram {entry['dram_gbps'][-1]} GB/s")
        save(results, out_path)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(OUT_JSON))
    ap.add_argument("--series", action="append", choices=list(SERIES))
    ap.add_argument("--threads", nargs="+", type=int)
    ap.add_argument("--reps", type=int, default=REPS)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    names = args.series or PLOT_ORDER
    threads = args.threads or THREADS
    out_path = Path(args.out)

    if not BIN.exists():
        raise SystemExit(f"[!] {BIN} does not exist; build it with\n"
                         f"    make -C {BIN.parent.parent} all")

    if args.dry_run:
        total = 0
        for name in names:
            print(f"\n# {name}: {SERIES[name]['label']}")
            for t in threads:
                print(cmd_for(SERIES[name], t))
            total += len(threads) * args.reps
        print(f"\n# {total} runs -> {out_path}")
        return 0

    results = new_results(args.reps, threads)
    save(results, out_path)
    for name in names:
        print(f"\n=== {name}: {SERIES[name]['label']} ===")
        collect_series(name, SERIES[name], threads, args.reps, results, out_path)

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
