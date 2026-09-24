#!/usr/bin/env python3
"""Uniform-workload macro benchmark on the AMD EPYC 9354P (mode 11).

Sweeps fill factor and measures set/get throughput for the four hashtables
the paper compares:

    cas       ht-type 3   dramblast, the 2025 inlined CAS table
    cas23     ht-type 8   dramhit, the 2023 table
    folklore  ht-type 11
    dlht      ht-type 10

growt is deliberately not collected -- see SKIPPED below.

    python3 collect_data_amd.py --dry-run        # print the plan, run nothing
    python3 collect_data_amd.py                  # build, then the full matrix
    python3 collect_data_amd.py --table dlht     # just one table
    python3 collect_data_amd.py --no-build       # reuse the current build/

Every point is measured REPS times. The json keeps all samples plus the
per-point median, which is what plot_data.py draws (with a min/max band),
because the run-to-run spread here is a few percent and single-run points
cannot resolve the gaps between these tables at low fill.

Results are written after every point, so an interrupted run leaves a
readable json and the logs of everything that finished.
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

MACHINE = "amd-9354p"
DATA_DIR = SCRIPT_DIR / "amd"

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_amd.sh"

# --- mirrored from include/types.hpp -----------------------------------------
MODE_UNIFORM = 11
HT_CAS = 3
HT_CAS23 = 8
HT_DLHT = 10
HT_FOLKLORE = 11

# --- machine ------------------------------------------------------------------
# 1 socket, 32 cores / 64 threads, BIOS in NPS4 so the socket presents 4 numa
# nodes of 16 cpus and ~47 GiB each. --numa-split 1 is
# THREADS_SPLIT_SEPARATE_NODES: threads split evenly over the 4 nodes, global
# hashtable MPOL_INTERLEAVE'd over all of them.
CPUFREQ_MHZ = 3250
NUM_THREADS = 64
NUMA_SPLIT = 1

# 536870912 entries x 16 B = 8 GiB, the same table size the earlier
# macro_uniform collections and intel.json used, so the numbers are comparable.
HT_SIZE = 1 << 29

# The workload is replayed this many times per measured run; the timer covers
# all of them. Unchanged from the earlier collections for the same reason.
INSERT_FACTOR = 100
READ_FACTOR = 100

SEED = 1775762440565610239

FILLS = list(range(10, 100, 10))
REPS = 5

# Build knobs. All four tables are measured from ONE binary, so the build has
# to be one that every table can run:
CMAKE_FLAGS = [
    f"-DCPUFREQ_MHZ={CPUFREQ_MHZ}",
    "-DDRAMHiT_VARIANT=2025_INLINE",
    "-DBUCKETIZATION=ON",
    "-DBRANCH=simd",
    "-DAVX_SUPPORT=ON",
    "-DPREFETCH=DOUBLE",
    "-DCAS_PREFETCH_INSERTION=DOUBLE",
    "-DUNIFORM_PROBING=ON",
    "-DREAD_BEFORE_CAS=ON",
    "-DCAS_NO_ABSTRACT=OFF",
    "-DGROWT=OFF",
    "-DCALC_STATS=OFF",
]

TABLES = {
    "cas": {
        "display": "dramblast",
        "ht_type": HT_CAS,
        "prefetcher": "off",
        "batch_len": 16,
    },
    "cas23": {
        "display": "dramhit",
        "ht_type": HT_CAS23,
        "prefetcher": "off",
        "batch_len": 16,
    },
    "folklore": {
        "display": "folklore",
        "ht_type": HT_FOLKLORE,
        "prefetcher": "off",
        "batch_len": 16,
    },
    "dlht": {
        "display": "dlht",
        "ht_type": HT_DLHT,
        "prefetcher": "off",
        "batch_len": 32,
        "max_fill": 40,
        "max_fill_reason": (
            "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% "
            "reported fill; the table aborts with 'Resize required: Global "
            "link bucket pool exhausted'"
        ),
    },
    # Same table, same prefetcher setting, only --batch-len differs. dlht is the
    # one table here whose batch length IS its prefetch depth:
    # DlhtHashTable::find_batch fires one __builtin_prefetch per key for the whole
    # batch as a burst and then drains the batch with nothing further in flight,
    # where cas/cas23 issue one prefetch per result consumed out of a persistent
    # queue. At 64 threads on 32 SMT cores a 32-deep burst is 64 outstanding
    # requests per core, past what Zen4 will accept: 39% of the prefetches are
    # discarded for want of a Miss Address Buffer entry and come back as exposed
    # demand misses (profile_dlht_prefetch_amd.py). sweep_dlht_batch_amd.py puts
    # the knee at 16. Kept as a separate key so the published dlht series is not
    # silently replaced by a differently-configured one.
    # See amd_vs_intel_lookup.md section 7.
    "dlht_batch16": {
        "display": "dlht (batch 16)",
        "ht_type": HT_DLHT,
        "prefetcher": "off",
        "batch_len": 16,
        "max_fill": 40,
        "max_fill_reason": (
            "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% "
            "reported fill; the table aborts with 'Resize required: Global "
            "link bucket pool exhausted'. Unchanged by batch length -- it is an "
            "insert-capacity limit, not a batching one."
        ),
    },
}

PLOT_ORDER = ["cas", "cas23", "folklore", "dlht", "dlht_batch16"]

SKIPPED = {
    "growt": "excluded by request; it collapses past ~50% fill (see intel.json)",
}

# --- bandwidth sampling -------------------------------------------------------
BW_INTERVAL_MS = 100
# Read and write are asked for separately rather than via the combined
# umc_mem_bandwidth. The combined metric gives a total and nothing else, which is
# what left set_bw_wr_gbps at a hardcoded 0.0 in every collection before this one --
# and the insert path is a 1r1w stream at the DRAM (each store fetches its line and
# writes it back), so the split is the interesting half of the measurement.
# Their sum reproduces umc_mem_bandwidth.
BW_METRIC = "umc_mem_read_bandwidth,umc_mem_write_bandwidth"
BW_METRIC_RD = "umc_mem_read_bandwidth"
BW_METRIC_WR = "umc_mem_write_bandwidth"

BW_WARMUP_S = 1.5
BW_WINDDOWN_FRAC = 0.9
BW_MIN_INTERVALS = 3

PHASE_MARKS = [
    ("test insert start", "set"),
    ("test insert end", None),
    ("test find start", "get"),
    ("test find end", None),
]

SET_RE = re.compile(r"set_mops\s*:\s*([\d.]+)")
GET_RE = re.compile(r"get_mops\s*:\s*([\d.]+)")
FOUND_RE = re.compile(r"find_ops\s*:\s*(\d+),\s*found\s*:\s*(\d+)")


# =============================================================================
# SHELL
# =============================================================================

def sh(cmd, check=True):
    print(f"[cmd] {cmd}")
    return subprocess.run(cmd, shell=True, check=check)

def build():
    sh(f"cmake -S {SOURCE_DIR} -B {BUILD_DIR} " + " ".join(CMAKE_FLAGS))
    sh(f"cmake --build {BUILD_DIR} -j 32")

def set_prefetcher(state):
    sh(f"{PREFETCH_SCRIPT} {state}")

def dramhit_cmd(table, fill, with_bw=True):
    args = [
        DRAMHIT,
        "--mode", str(MODE_UNIFORM),
        "--ht-type", str(table["ht_type"]),
        "--ht-size", str(HT_SIZE),
        "--ht-fill", str(fill),
        "--num-threads", str(NUM_THREADS),
        "--numa-split", str(NUMA_SPLIT),
        "--batch-len", str(table["batch_len"]),
        "--find_queue", "64",
        "--no-prefetch", "0",
        "--hw-pref", "1" if table["prefetcher"] == "on" else "0",
        "--insert-factor", str(INSERT_FACTOR),
        "--read-factor", str(READ_FACTOR),
        "--skew", "0.01",
        "--seed", str(SEED),
    ]
    inner = " ".join(shlex.quote(a) for a in args)
    if not with_bw:
        return "sudo " + inner
    return (f"sudo perf stat -I {BW_INTERVAL_MS} -x, -a -M {BW_METRIC} -- "
            + inner)

def interval_scale(start, end):
    """nominal / actual length of the perf interval ending at `end`."""
    return (BW_INTERVAL_MS / 1000.0) / (end - start) if end > start else 1.0

def parse_bw(output):
    """Per-phase DRAM read/write bandwidth from the interleaved perf -I / dramhit log.

    perf -M emits one row per constituent event per interval, carrying the metric in
    the last two CSV columns:

      ts,count,,umc_cas_cmd.rd,run_ns,pct,12540.2,MB/s  umc_mem_read_bandwidth
      ts,count,,umc_cas_cmd.wr,run_ns,pct,8550.1,MB/s  umc_mem_write_bandwidth

    so read and write are told apart by the metric name in the unit column, and each
    lands in its own accumulator instead of being summed into one number.

    The metric column is count * 64 B over the NOMINAL -I interval, but perf's
    intervals actually run 101-105 ms, which left every value ~2.5% high. Each
    interval is rescaled by nominal / actual, the actual length being the gap
    between consecutive perf timestamps.
    """
    phase = None
    prev_ts = 0.0
    interval_start = 0.0
    pending_rd = 0.0
    pending_wr = 0.0
    rows = {"set": [], "get": []}
    phase_t0 = {}

    for line in output.splitlines():
        for mark, target in PHASE_MARKS:
            if mark in line:
                phase = target
                break

        parts = [p.strip() for p in line.split(',')]
        if len(parts) < 8:
            continue
        try:
            ts = float(parts[0])
        except ValueError:
            continue

        if ts != prev_ts:
            if prev_ts > 0.0 and (pending_rd + pending_wr) > 0.0 and phase is not None:
                phase_t0.setdefault(phase, prev_ts)
                k = interval_scale(interval_start, prev_ts)
                rows[phase].append((prev_ts - phase_t0[phase],
                                    pending_rd * k, pending_wr * k))
            interval_start = prev_ts
            prev_ts = ts
            pending_rd = 0.0
            pending_wr = 0.0

        try:
            val = float(parts[6])
        except ValueError:
            continue
        unit = parts[7]
        if "MB" in unit:
            val /= 1000.0
        elif "MiB" in unit:
            val *= (1 << 20) / 1e9
        elif "GB" not in unit:
            continue

        if BW_METRIC_RD in unit:
            pending_rd += val
        elif BW_METRIC_WR in unit:
            pending_wr += val

    if prev_ts > 0.0 and (pending_rd + pending_wr) > 0.0 and phase is not None:
        phase_t0.setdefault(phase, prev_ts)
        k = interval_scale(interval_start, prev_ts)
        rows[phase].append((prev_ts - phase_t0[phase], pending_rd * k, pending_wr * k))

    out = {}
    for name, samples in rows.items():
        if not samples:
            continue
        span = samples[-1][0]
        if len(samples) > 4:
            samples = samples[1:-1]

        settled = [s for s in samples if s[0] >= BW_WARMUP_S]
        transient_only = len(settled) < BW_MIN_INTERVALS
        if not transient_only:
            samples = settled

        def med(rs):
            return statistics.median(r + w for _, r, w in rs)

        while len(samples) > BW_MIN_INTERVALS and \
                samples[-1][1] + samples[-1][2] < BW_WINDDOWN_FRAC * med(samples):
            samples.pop()
        if not samples:
            continue

        out[name] = {
            "gbps": round(med(samples), 1),
            "rd_gbps": round(statistics.median(r for _, r, _ in samples), 1),
            "wr_gbps": round(statistics.median(w for _, _, w in samples), 1),
            "intervals": len(samples),
            "phase_s": round(span, 2),
            "transient_only": transient_only,
        }
    return out

def run_point(cmd, log_path, with_bw=True):
    """One dramhit run. Returns (metrics, None) or (None, reason)."""
    proc = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(f"$ {cmd}\n\n{proc.stdout}")

    sets = SET_RE.findall(proc.stdout)
    gets = GET_RE.findall(proc.stdout)
    if not sets or not gets:
        tail = "\n".join(proc.stdout.strip().splitlines()[-5:])
        return None, f"rc={proc.returncode}, no mops in output; tail: {tail}"

    found = FOUND_RE.search(proc.stdout)
    if not found:
        return None, "no 'find_ops : N, found : M' line to check against"
    if found.group(1) != found.group(2):
        return None, f"found {found.group(2)} of {found.group(1)} find_ops"

    metrics = {"set_mops": float(sets[-1]), "get_mops": float(gets[-1])}
    if with_bw:
        bw = parse_bw(proc.stdout)
        if not bw:
            print("      [!] no bandwidth intervals parsed from this run")
        metrics["bw"] = bw
    return metrics, None

# =============================================================================
# COLLECTION
# =============================================================================

def new_results(reps):
    return {
        "machine": MACHINE,
        "mode": "uniform",
        "param_name": "fill",
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "reps": reps,
        "bw_interval_ms": BW_INTERVAL_MS,
        "bw_metric": BW_METRIC,
        "bw_unit": "decimal GB/s (derived from perf metrics)",
        "bw_warmup_s": BW_WARMUP_S,
        "ht_size": HT_SIZE,
        "ht_size_gib": HT_SIZE * 16 // (1 << 30),
        "num_threads": NUM_THREADS,
        "numa_split": NUMA_SPLIT,
        "insert_factor": INSERT_FACTOR,
        "read_factor": READ_FACTOR,
        "seed": SEED,
        "cmake_flags": CMAKE_FLAGS,
        "plot_order": PLOT_ORDER,
        "skipped": SKIPPED,
        "tables": {},
    }

def save(results, out_path):
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))

def table_entry(name, table, capped):
    entry = {
        "display": table["display"],
        "ht_type": table["ht_type"],
        "prefetcher": table["prefetcher"],
        "batch_len": table["batch_len"],
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "fills": [],
        "set_mops": [],
        "get_mops": [],
        "set_samples": [],
        "get_samples": [],
        "set_bw_gbps": [],
        "get_bw_gbps": [],
        "set_bw_rd_gbps": [],
        "get_bw_rd_gbps": [],
        "set_bw_wr_gbps": [],
        "get_bw_wr_gbps": [],
        "set_bw_samples": [],
        "get_bw_samples": [],
        "set_bw_intervals": [],
        "get_bw_intervals": [],
        "set_bw_transient_only": [],
        "get_bw_transient_only": [],
        "failures": [],
    }
    if capped:
        entry["not_swept"] = {
            "fills": capped,
            "reason": table.get("max_fill_reason", f"max_fill={table.get('max_fill', 100)}"),
        }
    return entry

def record_point(entry, fill, points):
    entry["fills"].append(fill)
    for phase in ("set", "get"):
        vals = [p[f"{phase}_mops"] for p in points]
        entry[f"{phase}_mops"].append(statistics.median(vals))
        entry[f"{phase}_samples"].append(vals)

        reps_bw = [p["bw"][phase] for p in points if p.get("bw", {}).get(phase)]
        for key, field in (("gbps", ""), ("rd_gbps", "_rd"), ("wr_gbps", "_wr")):
            got = [r[key] for r in reps_bw]
            entry[f"{phase}_bw{field}_gbps"].append(
                round(statistics.median(got), 1) if got else None)
        entry[f"{phase}_bw_samples"].append([r["gbps"] for r in reps_bw])
        entry[f"{phase}_bw_intervals"].append(
            min(r["intervals"] for r in reps_bw) if reps_bw else 0)
        entry[f"{phase}_bw_transient_only"].append(
            any(r["transient_only"] for r in reps_bw) if reps_bw else None)

def collect_table(name, table, fills, reps, out_path, results, with_bw=True):
    max_fill = table.get("max_fill", 100)
    capped = [f for f in fills if f > max_fill]
    fills = [f for f in fills if f <= max_fill]

    entry = table_entry(name, table, capped)
    results["tables"][name] = entry

    set_prefetcher(table["prefetcher"])

    for fill in fills:
        cmd = dramhit_cmd(table, fill, with_bw)
        points = []
        for rep in range(1, reps + 1):
            log = DATA_DIR / "logs" / name / f"fill{fill:02d}_rep{rep}.log"
            t0 = time.monotonic()
            point, err = run_point(cmd, log, with_bw)
            dt = time.monotonic() - t0
            if err:
                print(f"  [!] {name} fill={fill} rep={rep} FAILED after "
                      f"{dt:.0f}s: {err}")
                entry["failures"].append({"fill": fill, "rep": rep, "error": err})
                continue
            points.append(point)
            line = (f"  {name} fill={fill:2d} rep={rep}/{reps}  "
                    f"set {point['set_mops']:7.1f}  get {point['get_mops']:7.1f}")
            for phase in ("set", "get"):
                got = point.get("bw", {}).get(phase)
                if got:
                    line += f"  {phase}_bw {got['gbps']:5.0f}"
            print(line + f"  ({dt:.0f}s)")

        if not points:
            print(f"  [!] {name} fill={fill}: every rep failed, no point recorded")
            save(results, out_path)
            continue

        record_point(entry, fill, points)

        msg = (f"  => {name} fill={fill:2d} median set "
               f"{entry['set_mops'][-1]:.1f} get {entry['get_mops'][-1]:.1f}")
        if entry["set_bw_gbps"][-1] is not None:
            msg += (f" | bw set {entry['set_bw_gbps'][-1]:.0f}"
                    f" get {entry['get_bw_gbps'][-1]:.0f} GB/s")
            if entry["get_bw_transient_only"][-1]:
                msg += "  [get bw transient only]"
        print(msg)
        save(results, out_path)

# =============================================================================
# MAIN
# =============================================================================

def rederive(out_path, names, fills, reps):
    results = new_results(reps)
    for name in names:
        table = TABLES[name]
        max_fill = table.get("max_fill", 100)
        entry = table_entry(name, table, [f for f in fills if f > max_fill])
        results["tables"][name] = entry
        for fill in [f for f in fills if f <= max_fill]:
            logs = sorted((DATA_DIR / "logs" / name).glob(f"fill{fill:02d}_rep*.log"))
            points = []
            for log in logs:
                text = log.read_text()
                if "umc" not in text and "MB" not in text and "GB" not in text:
                    continue
                sets = SET_RE.findall(text)
                gets = GET_RE.findall(text)
                if not sets or not gets:
                    continue
                points.append({"set_mops": float(sets[-1]),
                               "get_mops": float(gets[-1]),
                               "bw": parse_bw(text)})
            if not points:
                print(f"  [--] {name} fill={fill}: no usable logs")
                continue
            record_point(entry, fill, points)
            print(f"  {name} fill={fill:2d} from {len(points)} logs -> "
                  f"set {entry['set_mops'][-1]:.0f} get {entry['get_mops'][-1]:.0f} | "
                  f"bw set {entry['set_bw_gbps'][-1]} get {entry['get_bw_gbps'][-1]}"
                  + ("  [transient only]"
                     if entry["get_bw_transient_only"][-1] else ""))
    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    results["rederived_from_logs"] = True
    save(results, out_path)
    print(f"\n[OK] re-derived results written to {out_path}")
    return 0

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(DATA_DIR / f"{MACHINE}_uniform.json"),
                    help="output json (default: amd/amd-9354p_uniform.json)")
    ap.add_argument("--table", action="append", choices=list(TABLES),
                    help="collect only these tables (repeatable)")
    ap.add_argument("--fill", action="append", type=int,
                    help="collect only these fills (repeatable)")
    ap.add_argument("--reps", type=int, default=REPS)
    ap.add_argument("--no-build", action="store_true",
                    help="reuse build/ as-is instead of reconfiguring")
    ap.add_argument("--no-bw", action="store_true",
                    help="skip the perf bandwidth sampling (mops only)")
    ap.add_argument("--rederive-bw", action="store_true",
                    help="recompute from the saved logs; runs no benchmarks")
    ap.add_argument("--dry-run", action="store_true",
                    help="print the build and every command, run nothing")
    args = ap.parse_args()

    names = args.table or PLOT_ORDER
    fills = args.fill or FILLS
    out_path = Path(args.out)

    if args.rederive_bw:
        return rederive(out_path, names, fills, args.reps)

    if args.dry_run:
        print("cmake -S {} -B {} {}".format(SOURCE_DIR, BUILD_DIR,
                                            " ".join(CMAKE_FLAGS)))
        total = 0
        for name in names:
            table = TABLES[name]
            todo = [f for f in fills if f <= table.get("max_fill", 100)]
            print(f"\n# {name} ({table['display']}), hw prefetcher "
                  f"{table['prefetcher']}, {len(todo)} fills x {args.reps} reps")
            for fill in todo:
                print(dramhit_cmd(table, fill, not args.no_bw))
            total += len(todo) * args.reps
        print(f"\n# {total} dramhit runs -> {out_path}")
        return 0

    if not args.no_build:
        build()
    elif not Path(DRAMHIT).exists():
        raise SystemExit(f"[!] --no-build but {DRAMHIT} does not exist")

    # A --table run updates only the tables it was asked for. Rebuilding the json
    # from scratch here would silently drop the other three, which is a bad way to
    # find out you wanted --table.
    results = None
    if args.table and out_path.exists():
        backup = out_path.with_suffix(f".json.pre-{'-'.join(names)}.bak")
        backup.write_text(out_path.read_text())
        try:
            results = json.loads(out_path.read_text())
        except json.JSONDecodeError as exc:
            raise SystemExit(f"[!] {out_path} is not readable json ({exc}); "
                             f"move it aside or pass --out")
        results["reps"] = args.reps
        results["plot_order"] = PLOT_ORDER
        results["skipped"] = SKIPPED
        results.pop("finished_utc", None)
        keep = [t for t in results.get("tables", {}) if t not in names]
        print(f"[merge] {out_path} exists: recollecting {', '.join(names)}, "
              f"keeping {', '.join(keep) if keep else 'nothing'} "
              f"(backup: {backup.name})")
    if results is None:
        results = new_results(args.reps)
    save(results, out_path)

    for name in names:
        print(f"\n=== {name} ({TABLES[name]['display']}) ===")
        collect_table(name, TABLES[name], fills, args.reps, out_path, results,
                      not args.no_bw)

    # Leave the machine in its default state rather than whatever the last
    # table wanted.
    set_prefetcher("on")

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0

if __name__ == "__main__":
    sys.exit(main())