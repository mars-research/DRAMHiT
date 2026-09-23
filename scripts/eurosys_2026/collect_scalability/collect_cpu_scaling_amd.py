#!/usr/bin/env python3
"""Core-count sweep on the AMD EPYC 9354P: how does DRAM bandwidth scale from 1 to
64 threads, and what does the prefetch instruction change?

Same experiment and same json shape as collect_cpu_scaling_intel.py and
collect_cpu_scaling_intel_hbm.py, so the three plot side by side. What differs is
how a thread count turns into a placement, and that difference is the point.

--- this machine is one package, not four ------------------------------------
The BIOS is in NPS4, so the OS sees 4 NUMA nodes:

    node 0: cpus 0-7,32-39     node 1: cpus 8-15,40-47
    node 2: cpus 16-23,48-55   node 3: cpus 24-31,56-63

but it is a single socket -- one package, one Infinity Fabric, 12 DDR5 channels.
The nodes are a partition of that one memory system (3 channels each), not separate
memory systems. So this sweep treats it as one package:

  * **memory is interleaved across all 4 nodes** on every run (`a0-3`), so all 12
    channels serve every point and the sweep measures the package's bandwidth rather
    than one quarter of it;
  * **threads ramp package-wide**: fill node 0's 8 physical cores, then node 1's,
    then node 2's, then node 3's -- 32 threads is one per physical core on the whole
    package -- and then the SMT siblings in the same node order, 33-40 on node 0 and
    so on to 64.

        threads  1..8   9..16  17..24  25..32 | 33..40  41..48  49..56  57..64
        node        0       1       2       3 |     0       1       2       3
        which    physical cores               | SMT siblings

    bandwidth.c pins thread N to the Nth cpu of its node in ascending order, and each
    node lists its 8 physical cores before their 8 siblings, so asking a node for t<=8
    gets physical cores and t=16 gets the node's full 16.

That ramp is why the interesting x positions here are 8/16/24/32 (a node's cores
joining) and 32 (SMT starting), not the single SMT boundary the Intel sweeps have.
Each node is 2 CCDs of 4 cores, so 4 and 8 threads into a node are also the points
where that node's second CCD lights up -- see local_interleave_analysis.md section 1.

Two workloads, because the prefetch hint that helps one is meaningless for the other:

  rand read   a dependent-free stream of random 64 B loads. The software prefetch is
              the only thing generating memory-level parallelism.

  1r1w        an 8 B store into a random 64 B line. At DRAM that is TWO transactions:
              the line is fetched (RFO) before it can be modified and written back.
              ntstore is the control -- a full-line non-temporal store never fetches,
              so it is 0r1w and moves about half the DRAM traffic per store.

    python3 collect_cpu_scaling_amd.py --dry-run
    python3 collect_cpu_scaling_amd.py
    python3 collect_cpu_scaling_amd.py --series read_t1 --threads 1 8 16 32 64

Needs sudo (uncore PMUs) and 2 MB hugepages on all four nodes
(scripts/enable_hugepages.sh): bandwidth.c mmaps with MAP_HUGETLB and the workers hang
on their barrier rather than exiting if that fails.
"""

import argparse
import json
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

MACHINE = "amd-9354p"
OUT_JSON = SCRIPT_DIR / f"{MACHINE}_cpu_scaling.json"
LOG_DIR = SCRIPT_DIR / "logs" / "cpu_scaling_amd"

# --- machine -----------------------------------------------------------------
NUM_NODES = 4
PHYS_CORES_PER_NODE = 8
CPUS_PER_NODE = 16          # 8 physical + 8 SMT siblings
SMT_BOUNDARY = 32           # threads 1..32 are one per physical core, package-wide
NODE_BOUNDARIES = [8, 16, 24, 32]   # where each node's cores join the ramp
MEM_SPEC = "0-3"            # MPOL_INTERLEAVE over all 4 nodes: one package
CPU_FREQ_GHZ = "3.25"       # this part's base clock; bandwidth.c turns rdtsc into
                            # seconds with it (see cpu_scaling_analysis_amd.md)
LOOKAHEAD = "64"

THREADS = [1, 2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64]
REPS = 3

# Footprint. A per-thread size held constant across a core sweep is not a constant
# experiment -- at 1 thread a small chunk sits inside the 256 MiB L3 and never reaches
# DRAM. Aim at a fixed total instead, split across the threads. 16 GiB against a
# 256 MiB L3 is a 1.6% cache-to-footprint ratio at every point, and the four nodes hold
# 4092 2 MB pages each (~8 GiB), so an interleaved 16 GiB needs 4 GiB per node.
TOTAL_FOOTPRINT_BYTES = 16 * 1024 ** 3
MAX_PER_THREAD_BYTES = 2 * 1024 ** 3
MIN_PER_THREAD_BYTES = 256 * 1024 ** 2

# --- what to sweep -----------------------------------------------------------
SERIES = {
    "read_load":       {"mode": "r", "inst": "load",
                        "label": "rand read, no sw prefetch"},
    "read_t0":         {"mode": "r", "inst": "t0",
                        "label": "rand read, prefetcht0"},
    "read_t1":         {"mode": "r", "inst": "t1",
                        "label": "rand read, prefetcht1"},
    # The rest of the prefetch hints on the read side. t0/nta target L1, t1/t2 target
    # L2, prefetchw asks for the line in Modified state. Measured here because t0 reads
    # SLOWER than no prefetch at all on this part and the lookahead sweep shows it is
    # flat from lookahead 1 to 256 -- see cpu_scaling_analysis_amd_package.md.
    "read_t2":         {"mode": "r", "inst": "t2",
                        "label": "rand read, prefetcht2"},
    "read_nta":        {"mode": "r", "inst": "nta",
                        "label": "rand read, prefetchnta"},
    "read_prefetchw":  {"mode": "r", "inst": "prefetchw",
                        "label": "rand read, prefetchw"},
    "write_load":      {"mode": "w", "inst": "load",
                        "label": "1r1w, no sw prefetch"},
    "write_prefetchw": {"mode": "w", "inst": "prefetchw",
                        "label": "1r1w, prefetchw"},
    "write_ntstore":   {"mode": "w", "inst": "ntstore",
                        "label": "0r1w, nt store (control)"},
    "write_t0":        {"mode": "w", "inst": "t0",
                        "label": "1r1w, prefetcht0"},
    "write_t1":        {"mode": "w", "inst": "t1",
                        "label": "1r1w, prefetcht1"},
    "write_t2":        {"mode": "w", "inst": "t2",
                        "label": "1r1w, prefetcht2"},
}

PLOT_ORDER = ["read_load", "read_t0", "read_t1", "read_t2", "read_nta",
              "read_prefetchw",
              "write_load", "write_prefetchw", "write_t0", "write_t1",
              "write_t2", "write_ntstore"]

# --- DRAM counters -----------------------------------------------------------
# AMD has no uncore_imc. The equivalent is amd_umc_<0..11>, one per DDR5 channel,
# 3 per NUMA node, and unlike Intel's PMU it publishes no scale/unit -- the counters
# are raw CAS commands at 64 B each. Memory is interleaved over all four nodes here,
# so all 12 boxes are counted on every run. 2 events per box against 4 counters per
# box, so nothing multiplexes; the parser asserts that.
BW_INTERVAL_MS = 100
UMC_BOXES = list(range(12))
BYTES_PER_CAS = 64
BW_EVENTS = ",".join(
    f"amd_umc_{b}/umc_cas_cmd.{k},name={k}_b{b}/"
    for b in UMC_BOXES for k in ("rd", "wr")
)
PERF_RE = re.compile(r"^([\d.]+),([\d.]+),,(rd|wr)_b(\d+),([\d.]+),([\d.]+)")

# bandwidth.c brackets its measured loop with these, so allocation and first-touch
# traffic stays out of the window.
MARK_START = "Start perf collection"
MARK_END = "End perf collection"

PROG_BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s")
PROG_TIME_RE = re.compile(r"Time Taken\s*:\s*([\d.]+)\s*seconds")


# =============================================================================
# PLACEMENT
# =============================================================================


def thread_layout(total):
    """total threads -> {node: threads on it}, for this machine's package-wide ramp.

    Thread i goes to node (i // 8) % 4: the first 32 walk the four nodes' physical
    cores 8 at a time, the next 32 walk their SMT siblings in the same order.
    """
    counts = defaultdict(int)
    for i in range(total):
        counts[(i // PHYS_CORES_PER_NODE) % NUM_NODES] += 1
    return dict(sorted(counts.items()))


def pattern_for(total):
    """bandwidth.c -pattern. Groups are separated by SPACES -- its parser is
    strtok(s, " ") -- and a comma only ever lists memory nodes inside one group,
    which is exactly what the a0-3 interleave uses."""
    return " ".join(
        f"n{node}a{MEM_SPEC}t{count}" for node, count in thread_layout(total).items()
    )


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
        "-pattern", pattern_for(threads),
        "-freq", CPU_FREQ_GHZ,
        "-inst", cfg["inst"],
        "-lookahead", LOOKAHEAD,
        "-mode", cfg["mode"],
    ]
    inner = " ".join(shlex.quote(a) for a in args)
    return (f"sudo perf stat -I {BW_INTERVAL_MS} -x, -a -e {BW_EVENTS} -- " + inner)


# =============================================================================
# RUN
# =============================================================================


def parse_dram(output):
    """Median DRAM read/write GB/s over the intervals inside the markers.

    Each box reports its own count and its own run_ns, and the 12 run_ns values are
    summed along with the counts, so the rate is
        bytes_per_cas * boxes * sum(count) / sum(run_ns)
    -- the boxes factor cancels the one hidden in the summed denominator and leaves a
    package total. Deriving it from each row's own run_ns rather than from wall time
    matters because perf's -I is best-effort.
    """
    inside = False
    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))
    window = {}
    pcts = []
    for line in output.splitlines():
        if MARK_START in line:
            inside = True
        elif MARK_END in line:
            inside = False
        m = PERF_RE.match(line)
        if not m:
            continue
        ts, count, kind, run_ns, pct = (float(m.group(1)), float(m.group(2)),
                                        m.group(3), float(m.group(5)),
                                        float(m.group(6)))
        window.setdefault(ts, inside)
        pcts.append(pct)
        slot = acc[ts][kind]
        slot[0] += count
        slot[1] += run_ns
        slot[2] += 1

    rows = []
    for ts in sorted(acc):
        if not window.get(ts):
            continue
        ev = acc[ts]
        if "rd" not in ev or "wr" not in ev or ev["rd"][1] <= 0 or ev["wr"][1] <= 0:
            continue
        rows.append((BYTES_PER_CAS * ev["rd"][2] * ev["rd"][0] / ev["rd"][1],
                     BYTES_PER_CAS * ev["wr"][2] * ev["wr"][0] / ev["wr"][1]))

    # Both boundary intervals straddle a marker.
    if len(rows) > 4:
        rows = rows[1:-1]
    if not rows:
        return None
    out = {
        "dram_rd_gbps": round(statistics.median(r for r, _ in rows), 1),
        "dram_wr_gbps": round(statistics.median(w for _, w in rows), 1),
        "dram_gbps": round(statistics.median(r + w for r, w in rows), 1),
        "intervals": len(rows),
    }
    if pcts and min(pcts) < 99.5:
        out["min_pct_enabled"] = min(pcts)
    return out


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
        if "min_pct_enabled" in dram:
            print(f"      [!] counters multiplexed at {dram['min_pct_enabled']:.0f}%")
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
        "experiment": "cpu scaling, one package, memory interleaved over all 4 nodes",
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "binary": str(BIN),
        "mem_spec": MEM_SPEC,
        "num_nodes": NUM_NODES,
        "phys_cores_per_node": PHYS_CORES_PER_NODE,
        "smt_boundary": SMT_BOUNDARY,
        "node_boundaries": NODE_BOUNDARIES,
        "ramp_note": (
            "thread i -> node (i//8)%4: threads 1-32 fill the four nodes' physical "
            "cores 8 at a time, 33-64 add their SMT siblings in the same node order"
        ),
        "cpu_freq_ghz": float(CPU_FREQ_GHZ),
        "lookahead": int(LOOKAHEAD),
        "reps": reps,
        "threads": threads,
        "total_footprint_bytes": TOTAL_FOOTPRINT_BYTES,
        "bw_interval_ms": BW_INTERVAL_MS,
        "bw_unit": "decimal GB/s (bytes / 1e9)",
        "dram_counter": "amd_umc_0..11 umc_cas_cmd.rd/.wr x 64 B",
        "prog_bw_note": (
            "prog_gbps is what bandwidth.c computes from the bytes it asked for. In "
            "write mode DRAM moves about twice that (RFO + writeback); dram_gbps is "
            "the measured controller traffic."
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
        "node_threads": [],
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
        entry["node_threads"].append(thread_layout(t))
        entry["footprint_mb"].append(per_thread_bytes(t) * t // (1024 ** 2))
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

    # Re-running a subset must not discard the rest.
    if args.series and out_path.exists():
        results = json.loads(out_path.read_text())
        results["amended_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
        results["plot_order"] = PLOT_ORDER
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
