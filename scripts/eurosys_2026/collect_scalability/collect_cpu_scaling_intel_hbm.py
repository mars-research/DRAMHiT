#!/usr/bin/env python3
"""Core-count sweep against HBM on the Xeon CPU Max 9462: how does bandwidth
scale with threads, and what does the access instruction change?

The HBM sibling of collect_cpu_scaling_intel.py, which asks the same question of
the 6548Y's DDR. Same shape, same json schema, same CLI; the differences are all
forced by the memory being HBM:

  placement   cpus on node 0, memory bound to **node 2** -- socket 0's own HBM
              (pattern "n0a2tN"). Nothing crosses UPI, so the only variable is
              how many cores are pulling. Nodes 2/3 are cpu-less HBM nodes.

  counters    the HBM controllers are NOT uncore_imc. perf enumerates them off
              the uncore discovery table, so they carry no event list and must
              be driven with raw codes: CAS is event 0x05, umask 0xcf (rd) /
              0xf0 (wr). There are **32 uncore_hbm_* boxes per socket** and perf
              does not merge them, so each event returns 32 rows that have to be
              summed. An HBM CAS moves **32 B, not 64**.

  rates       from each row's own run_ns, not from the timestamp delta:
              32 B * boxes * sum(count) / sum(run_ns). The interval that enables
              the counters is stretched, and at 1 thread it is a large fraction
              of a short run.

Two workloads, because the hint that helps one is meaningless for the other:

  rand read   a dependent-free stream of random 64 B loads. The software
              prefetch is the only thing generating memory-level parallelism, so
              load vs t0 vs t1 vs t2 vs nta is the whole experiment. On this
              machine it is worth ~50%: one core sustains ~18 outstanding lines
              with plain loads (the 16 L1 fill buffers) against ~28 when
              prefetching into L2.

  1r1w        an 8 B store into a random 64 B line. At DRAM that is TWO
              transactions: the line is fetched (RFO) and written back later.
              prefetchw fetches it for write up front. ntstore is the control --
              a full-line non-temporal store never fetches, so it is 0r1w and
              should move roughly half the HBM traffic per store.

So bandwidth.c's own number cannot be compared across the two: it reports GB/s
from the bytes it *asked for*, and in write mode the controllers move about
twice that. Both are recorded and the ratio is the interesting part.

    python3 collect_cpu_scaling_intel_hbm.py --dry-run
    python3 collect_cpu_scaling_intel_hbm.py
    python3 collect_cpu_scaling_intel_hbm.py --series read_t1 --threads 1 2 4

Needs sudo (uncore PMUs) and 2 MB hugepages on node 2 -- bandwidth.c mmaps with
MAP_HUGETLB, and without them the mmap fails and the workers hang on their
barrier rather than exiting:

    echo 9216 | sudo tee \\
      /sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages
"""

import argparse
import glob
import json
import os
import re
import shlex
import statistics
import subprocess
import sys
import time
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
BIN = (SCRIPT_DIR.parent / "machine_stats" / "build" / "bandwidth_rand").resolve()

MACHINE = "intel-max9462"
OUT_JSON = SCRIPT_DIR / f"{MACHINE}_hbm_cpu_scaling.json"
LOG_DIR = SCRIPT_DIR / "logs" / "hbm_cpu_scaling"

# --- machine -----------------------------------------------------------------
# Node 0 is cpus 0,2,...,62 then 64,66,...,126. bandwidth.c pins thread N to the
# Nth cpu of the node in ascending order, so threads 1..32 are one per physical
# core and thread 33 is the SMT sibling of cpu 0. Verified against the pinning
# lines in a 64-thread run log, not assumed.
CPU_NODE = 0
MEM_NODE = 2              # socket 0's HBM
SMT_BOUNDARY = 32
CPU_FREQ_GHZ = "2.7"      # pinned by scripts/setup_hbm.sh; bandwidth.c turns
                          # rdtsc into seconds with it
LOOKAHEAD = "64"

THREADS = [1, 2, 4, 8, 12, 16, 24, 32, 40, 48, 56, 64]
REPS = 3

# Footprint. A per-thread size held constant across a core sweep is not a
# constant experiment: at 1 thread the 128 MB the other collectors pass sits
# inside this socket's 75 MB L3 + 2 MB L2 and a third of the accesses never
# reach HBM. Measured at 1 thread: 13.95 GB/s over 128 MB, 12.73 over 512 MB,
# 12.15 over 2 GB. So aim at a fixed total, and cap the per-thread chunk so the
# 1- and 2-thread runs finish -- bandwidth.c always makes 100 passes over
# whatever it is given, so runtime is chunk x 100 / per-thread bandwidth.
TOTAL_FOOTPRINT_BYTES = 16 * 1024 ** 3
MAX_PER_THREAD_BYTES = 2 * 1024 ** 3
MIN_PER_THREAD_BYTES = 256 * 1024 ** 2

# --- what to sweep -----------------------------------------------------------
# `inst` is bandwidth.c's -inst, `mode` its -mode. "load" means no software
# prefetch at all, the baseline every hint is judged against. The first three
# reads and all three writes are exactly the 6548Y set, so the two machines'
# jsons line up series for series; t2 and nta are added because on this part
# they are the two ends of the L2-prefetch story (t2 ties t1, nta is worst).
SERIES = {
    "read_load":       {"mode": "r", "inst": "load",
                        "label": "rand read, no sw prefetch"},
    "read_t0":         {"mode": "r", "inst": "t0",
                        "label": "rand read, prefetcht0"},
    "read_t1":         {"mode": "r", "inst": "t1",
                        "label": "rand read, prefetcht1"},
    "read_t2":         {"mode": "r", "inst": "t2",
                        "label": "rand read, prefetcht2"},
    "read_nta":        {"mode": "r", "inst": "nta",
                        "label": "rand read, prefetchnta"},
    "write_load":      {"mode": "w", "inst": "load",
                        "label": "1r1w, no sw prefetch"},
    "write_prefetchw": {"mode": "w", "inst": "prefetchw",
                        "label": "1r1w, prefetchw"},
    # The prefetch hints matter for stores too, and much more than prefetchw
    # does: the RFO is a read, so the same L2 concurrency that carries the read
    # sweep carries the fetch half of a store. Leaving these out is what made an
    # earlier version of this sweep disagree with machine_spec_analysis.md's
    # 571 GB/s for read-modify-write -- that figure was measured with t1, and a
    # write series of load/prefetchw/ntstore alone never reaches it.
    "write_t0":        {"mode": "w", "inst": "t0",
                        "label": "1r1w, prefetcht0"},
    "write_t1":        {"mode": "w", "inst": "t1",
                        "label": "1r1w, prefetcht1"},
    "write_t2":        {"mode": "w", "inst": "t2",
                        "label": "1r1w, prefetcht2"},
    "write_ntstore":   {"mode": "w", "inst": "ntstore",
                        "label": "0r1w, nt store (control)"},
}

PLOT_ORDER = ["read_load", "read_t0", "read_t1", "read_t2", "read_nta",
              "write_load", "write_prefetchw", "write_t0", "write_t1",
              "write_t2", "write_ntstore"]

# --- HBM counters ------------------------------------------------------------
# uncore_hbm_free_running_* would also match a "uncore_hbm_*" glob and ends in a
# digit, so the name is matched to the end. Getting this wrong is silent: the
# boxes matched twice are counted twice and the reported bandwidth doubles.
HBM_PREFIX = "uncore_hbm"
BYTES_PER_CAS = 32
HBM_ENCODINGS = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
BW_INTERVAL_MS = 20

# bandwidth.c brackets its measured loop with these, so allocation and
# first-touch traffic stays out of the window.
MARK_START = "Start perf collection"
MARK_END = "End perf collection"

PROG_BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s")
PROG_TIME_RE = re.compile(r"Time Taken\s*:\s*([\d.]+)\s*seconds")


def hbm_boxes():
    pattern = re.compile(re.escape(HBM_PREFIX) + r"_(\d+)$")
    return sorted(
        int(m.group(1))
        for m in (pattern.match(os.path.basename(p))
                  for p in glob.glob(f"/sys/devices/{HBM_PREFIX}_*"))
        if m
    )


def hbm_event_string():
    return ",".join(
        f"{HBM_PREFIX}_{i}/{HBM_ENCODINGS[k]},name=mem_{k}/"
        for i in hbm_boxes()
        for k in HBM_ENCODINGS
    )


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
    return (f"sudo perf stat --per-socket -I {BW_INTERVAL_MS} -x, "
            f"-e {hbm_event_string()} -- " + inner)


def parse_hbm(output):
    """Per-interval HBM rates on socket 0, from the rows inside the markers.

    Both a median and a peak are returned. The median is the honest number where
    the thread placement is balanced (1..32, one thread per core, and 64, two on
    every core). From 33 to 63 it is not: at 40 threads, 8 cores run two threads
    and 24 run one, the paired threads take ~2x as long, and bandwidth.c gives
    every thread the same fixed work -- so the machine sits nearly idle while
    they straggle and the median collapses. The peak interval samples the
    machine while every thread is still running and stays comparable across the
    whole sweep; at the balanced points it sits a few percent above the median.
    """
    inside = False
    # ts -> event -> [summed count, summed run_ns, rows]
    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))

    for line in output.splitlines():
        if MARK_START in line:
            inside = True
            continue
        if MARK_END in line:
            inside = False
            continue
        if not inside:
            continue
        parts = line.split(",")
        if len(parts) < 7 or not parts[0][:1].isdigit():
            continue
        if "<not counted>" in parts[3] or "<not supported>" in parts[3]:
            continue
        if parts[1].strip() != "S0":
            continue
        try:
            ts = float(parts[0])
            count = float(parts[3])
            event = parts[5].strip()
            run_ns = float(parts[6])
        except ValueError:
            continue
        slot = acc[ts][event]
        slot[0] += count
        slot[1] += run_ns
        slot[2] += 1

    rows = []
    stamps = sorted(acc)
    # Both boundary intervals straddle a marker.
    for ts in (stamps[1:-1] if len(stamps) > 2 else stamps):
        events = acc[ts]
        if not {"mem_rd", "mem_wr"} <= set(events):
            continue
        rates = {}
        for key in ("rd", "wr"):
            count, run_ns, boxes = events[f"mem_{key}"]
            if run_ns <= 0:
                break
            # count * B / (run_ns * 1e-9 s) / 1e9 == count * B / run_ns, in
            # GB/s, once run_ns is the per-box mean (sum_run_ns / boxes).
            rates[key] = BYTES_PER_CAS * boxes * count / run_ns
        else:
            rows.append((rates["rd"], rates["wr"]))

    if not rows:
        return None
    totals = [r + w for r, w in rows]
    return {
        "dram_rd_gbps": round(statistics.median(r for r, _ in rows), 1),
        "dram_wr_gbps": round(statistics.median(w for _, w in rows), 1),
        "dram_gbps": round(statistics.median(totals), 1),
        "dram_peak_gbps": round(max(totals), 1),
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
    hbm = parse_hbm(proc.stdout)
    if hbm:
        point.update(hbm)
    else:
        print("      [!] no HBM intervals parsed")
    return point, None


# =============================================================================
# COLLECTION
# =============================================================================


def new_results(reps, threads):
    return {
        "machine": MACHINE,
        "experiment": "cpu scaling, one socket -> its own HBM node",
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "binary": str(BIN),
        "cpu_node": CPU_NODE,
        "mem_node": MEM_NODE,
        "mem_kind": "HBM2e (cpu-less NUMA node, flat mode)",
        "smt_boundary": SMT_BOUNDARY,
        "cpu_freq_ghz": float(CPU_FREQ_GHZ),
        "lookahead": int(LOOKAHEAD),
        "reps": reps,
        "threads": threads,
        "total_footprint_bytes": TOTAL_FOOTPRINT_BYTES,
        "bw_interval_ms": BW_INTERVAL_MS,
        "bw_unit": "decimal GB/s (bytes / 1e9)",
        "hbm_boxes_per_socket": len(hbm_boxes()),
        "bytes_per_cas": BYTES_PER_CAS,
        "prog_bw_note": (
            "prog_gbps is what bandwidth.c computes from the bytes it asked "
            "for. In write mode the controllers move about twice that (RFO + "
            "writeback); dram_gbps is the measured HBM traffic."
        ),
        "peak_note": (
            "dram_gbps is the median interval, dram_peak_gbps the largest. Use "
            "the peak from 33 to 63 threads: the placement there is unbalanced "
            "(some cores run two threads, some one), and with fixed work per "
            "thread the stragglers leave the machine idle and drag the median "
            "down. At the balanced points the two agree within a few percent."
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
        "dram_peak_gbps": [],
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
                  f"{point['prog_gbps']:7.1f}  hbm "
                  f"{point.get('dram_gbps', float('nan')):7.1f} GB/s  ({dt:.0f}s)")
        if not points:
            print(f"  [!] {name} t={t}: every rep failed")
            save(results, out_path)
            continue

        entry["threads"].append(t)
        entry["footprint_mb"].append(per_thread_bytes(t) * t // (1024 ** 2))
        prog = [p["prog_gbps"] for p in points]
        entry["prog_gbps"].append(round(statistics.median(prog), 1))
        entry["prog_samples"].append(prog)
        for key in ("dram_gbps", "dram_peak_gbps", "dram_rd_gbps", "dram_wr_gbps"):
            vals = [p[key] for p in points if key in p]
            entry[key].append(round(statistics.median(vals), 1) if vals else None)
        entry["dram_samples"].append(
            [p["dram_gbps"] for p in points if "dram_gbps" in p])
        print(f"  => {name} t={t:2d}  prog {entry['prog_gbps'][-1]:.1f}  "
              f"hbm {entry['dram_gbps'][-1]} GB/s "
              f"(peak {entry['dram_peak_gbps'][-1]})")
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
    if not hbm_boxes():
        raise SystemExit("[!] no uncore_hbm_* PMUs; this needs a Xeon Max in "
                         "flat mode, with the HBM as its own NUMA nodes")

    if args.dry_run:
        total = 0
        for name in names:
            print(f"\n# {name}: {SERIES[name]['label']}")
            for t in threads:
                print(cmd_for(SERIES[name], t))
            total += len(threads) * args.reps
        print(f"\n# {total} runs -> {out_path}")
        return 0

    # Re-running a subset must not discard the rest. Without this, one
    # `--series write_t1` overwrites a whole sweep with a single series.
    if args.series and out_path.exists():
        results = json.loads(out_path.read_text())
        results["amended_utc"] = datetime.now(timezone.utc).isoformat(
            timespec="seconds")
        existing = [t for t in results.get("threads", []) if t not in threads]
        if existing:
            print(f"[i] merging into {out_path.name}; note the existing sweep "
                  f"also covers threads {existing}")
        for name in names:
            if name in results.get("series", {}):
                print(f"[i] replacing existing series {name}")
    else:
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
