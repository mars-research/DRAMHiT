#!/usr/bin/env python3
"""Reprobe factor and lookup throughput per probing variant, Intel Xeon Gold
6548Y+ (DDR), mode 11.

Four builds of the 2025 cas table (ht-type 3), each adding one piece of the
probing scheme the paper uses:

    linear                        BUCKETIZATION=OFF BRANCH=branched UNIFORM=OFF
    linear+bucket                 BUCKETIZATION=ON  BRANCH=branched UNIFORM=OFF
    linear+bucket+simd            BUCKETIZATION=ON  BRANCH=simd     UNIFORM=OFF
    linear+bucket+simd+uniform    BUCKETIZATION=ON  BRANCH=simd     UNIFORM=ON

    python3 collect_data.py --dry-run          # print the plan, run nothing
    python3 collect_data.py                    # build each variant, full sweep
    python3 collect_data.py --variant linear   # just one variant
    python3 collect_data.py --fill 70 --reps 2 # a quick smoke test

Structure follows ../macro_uniform/collect_data_intel.py. Every point is
measured REPS times; the json keeps every sample plus the per-point median,
which is what plot_merge.py draws (with a min/max band). The previous version
of this script ran each point once, and the run-to-run spread was large enough
to reorder variants that are only a few percent apart.

Results are written after every point, so an interrupted run leaves a readable
json and the logs of everything that finished. The output is never
overwritten unless --force is given: intel-paper.json, intel-hbm.json and
amd-r6615.json in this directory are older single-run collections that
plot_merge.py still reads.
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

MACHINE = "intel-6548y"
DATA_DIR = SCRIPT_DIR / "intel_ddr"
DEFAULT_OUT = SCRIPT_DIR / "intel-ddr.json"

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"

# --- mirrored from include/types.hpp -----------------------------------------
MODE_UNIFORM = 11
HT_CAS = 3

# --- machine ------------------------------------------------------------------
# 2 sockets x 64 threads. The box is pinned to its 2.5 GHz base clock by
# scripts/setup.sh; CPUFREQ_MHZ is the divisor the binary turns rdtsc cycles
# into seconds with, so it has to agree or every mops number is rescaled.
# --numa-split 1: threads split over both nodes, table interleaved over both.
# This is the 128-thread dual-socket sweep plot_merge.py draws for Intel DDR
# (the old single-socket policy-4 sweep is not re-collected).
CPUFREQ_MHZ = 2500
NUM_THREADS = 128
NUMA_SPLIT = 1

# 536870912 entries x 16 B = 8 GiB, as in every earlier reprobe collection.
HT_SIZE = 1 << 29

# Unchanged from the earlier collections so the numbers stay comparable. Only
# get_mops is plotted; the read factor makes the find phase long enough that
# it is not dominated by thread start-up.
INSERT_FACTOR = 1
READ_FACTOR = 100

SEED = 1775762440565610239

FILLS = list(range(10, 100, 10))
REPS = 5

# The DRAMHiT tables drive memory from their own software prefetch queue and
# are measured with the hardware prefetchers off, the state scripts/setup.sh
# leaves this box in. The old collector never set it, so a run could inherit
# whatever the last experiment left behind. --hw-pref is inert (see
# ../macro_uniform/collect_data_intel.py); passed only so the log says it.
PREFETCHER = "off"

# Knobs common to every variant. Pinned explicitly rather than left to the
# CMakeLists defaults: cmake caches options, so a build dir somebody else
# configured keeps THEIR value for anything not listed (e.g. a leftover
# DRAMHiT_VARIANT=2025_INLINE forces BUCKETIZATION and SIMD on regardless of
# the variant flags below, and AGGR changes what an insert does).
# CALC_STATS=ON is what prints reprobe_factor; its counters are per-thread
# table instances, so it adds no shared-cacheline traffic.
CMAKE_FLAGS = [
    f"-DCPUFREQ_MHZ={CPUFREQ_MHZ}",
    "-DDRAMHiT_VARIANT=2025",
    "-DCALC_STATS=ON",
    "-DAVX_SUPPORT=ON",
    "-DPREFETCH=DOUBLE",
    "-DCAS_PREFETCH_INSERTION=AUTO",
    "-DREAD_BEFORE_CAS=ON",
    "-DCAS_NO_ABSTRACT=OFF",
    "-DGROWT=OFF",
    "-DAGGR=OFF",
    "-DBQ_KMER_TEST=OFF",
    "-DBQUEUE=OFF",
    "-DPART_ID=OFF",
    "-DCLHT=OFF",
    "-DLATENCY_COLLECTION=OFF",
]

BUILD_JOBS = 64

# name -> the flags that make that variant. Same four builds as before;
# linear+uniform (only in intel-paper.json) is not collected.
VARIANTS = {
    "linear": {
        "BUCKETIZATION": "OFF", "BRANCH": "branched", "UNIFORM_PROBING": "OFF",
    },
    "linear+bucket": {
        "BUCKETIZATION": "ON", "BRANCH": "branched", "UNIFORM_PROBING": "OFF",
    },
    "linear+bucket+simd": {
        "BUCKETIZATION": "ON", "BRANCH": "simd", "UNIFORM_PROBING": "OFF",
    },
    "linear+bucket+simd+uniform": {
        "BUCKETIZATION": "ON", "BRANCH": "simd", "UNIFORM_PROBING": "ON",
    },
}
PLOT_ORDER = list(VARIANTS)

SET_RE = re.compile(r"set_mops\s*:\s*([\d.]+)")
GET_RE = re.compile(r"get_mops\s*:\s*([\d.]+)")
REPROBE_RE = re.compile(r"reprobe_factor\s*:\s*([\d.]+)")
CACHELINES_RE = re.compile(r"avg_cachelines_accessed\s*:\s*([\d.]+)")
# mode 11 ends with "find_ops : N, found : M". Every inserted key is looked up,
# so M must equal N; a short count means the table lost keys.
FOUND_RE = re.compile(r"find_ops\s*:\s*(\d+),\s*found\s*:\s*(\d+)")


# =============================================================================
# SHELL
# =============================================================================


def sh(cmd, check=True):
    print(f"[cmd] {cmd}")
    return subprocess.run(cmd, shell=True, check=check)


def cmake_cmd(variant):
    flags = CMAKE_FLAGS + [f"-D{k}={v}" for k, v in VARIANTS[variant].items()]
    return f"cmake -S {SOURCE_DIR} -B {BUILD_DIR} " + " ".join(flags)


def build(variant):
    sh(cmake_cmd(variant))
    sh(f"cmake --build {BUILD_DIR} -j {BUILD_JOBS}")


def set_prefetcher(state):
    # Needs root; sudo's secure_path drops msr-tools, so PATH is carried
    # across. The script reads the MSR back and exits non-zero on a miss.
    sh(f'sudo env PATH="$PATH" {PREFETCH_SCRIPT} {state}')


def dramhit_cmd(fill):
    args = [
        DRAMHIT,
        "--mode", str(MODE_UNIFORM),
        "--ht-type", str(HT_CAS),
        "--ht-size", str(HT_SIZE),
        "--ht-fill", str(fill),
        "--num-threads", str(NUM_THREADS),
        "--numa-split", str(NUMA_SPLIT),
        "--batch-len", "16",
        "--find_queue", "64",
        "--no-prefetch", "0",
        "--hw-pref", "1" if PREFETCHER == "on" else "0",
        "--insert-factor", str(INSERT_FACTOR),
        "--read-factor", str(READ_FACTOR),
        "--skew", "0.01",
        "--seed", str(SEED),
    ]
    return "sudo " + " ".join(shlex.quote(a) for a in args)


def parse_output(text):
    """Metrics from one run's output. Returns (metrics, None) or (None, reason)."""
    sets = SET_RE.findall(text)
    gets = GET_RE.findall(text)
    if not sets or not gets:
        tail = "\n".join(text.strip().splitlines()[-5:])
        return None, f"no mops in output; tail: {tail}"

    found = FOUND_RE.search(text)
    if not found:
        return None, "no 'find_ops : N, found : M' line to check against"
    if found.group(1) != found.group(2):
        return None, f"found {found.group(2)} of {found.group(1)} find_ops"

    reprobe = REPROBE_RE.findall(text)
    if not reprobe:
        return None, "no reprobe_factor in output (built without CALC_STATS?)"
    lines = CACHELINES_RE.findall(text)
    return {
        "set_mops": float(sets[-1]),
        "get_mops": float(gets[-1]),
        "reprobe_factor": float(reprobe[-1]),
        "avg_cachelines_accessed": float(lines[-1]) if lines else None,
    }, None


def run_point(cmd, log_path):
    proc = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(f"$ {cmd}\n\n{proc.stdout}")
    metrics, err = parse_output(proc.stdout)
    if err:
        err = f"rc={proc.returncode}, {err}"
    return metrics, err


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
        "cpufreq_mhz": CPUFREQ_MHZ,
        "ht_type": HT_CAS,
        "ht_size": HT_SIZE,
        "ht_size_gib": HT_SIZE * 16 // (1 << 30),
        "num_threads": NUM_THREADS,
        "numa_split": NUMA_SPLIT,
        "insert_factor": INSERT_FACTOR,
        "read_factor": READ_FACTOR,
        "seed": SEED,
        "prefetcher": PREFETCHER,
        "cmake_flags": CMAKE_FLAGS,
        "plot_order": PLOT_ORDER,
        "variants": {},
    }


def save(results, out_path):
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))


METRICS = ["set_mops", "get_mops", "reprobe_factor", "avg_cachelines_accessed"]


def samples_key(metric):
    """get_mops -> get_samples (as in macro_uniform), else <metric>_samples."""
    if metric.endswith("_mops"):
        return metric[:-len("_mops")] + "_samples"
    return f"{metric}_samples"


def variant_entry(name):
    entry = {"build_cfg": VARIANTS[name], "fills": [], "failures": []}
    for m in METRICS:
        entry[m] = []
        entry[samples_key(m)] = []
    return entry


def record_point(entry, fill, points):
    """Fold one fill's repeats into index-aligned arrays: median + samples."""
    entry["fills"].append(fill)
    for m in METRICS:
        vals = [p[m] for p in points if p.get(m) is not None]
        entry[m].append(statistics.median(vals) if vals else None)
        entry[samples_key(m)].append(vals)


def collect_variant(name, fills, reps, out_path, results, do_build):
    entry = variant_entry(name)
    results["variants"][name] = entry
    if do_build:
        build(name)

    for fill in fills:
        cmd = dramhit_cmd(fill)
        points = []
        for rep in range(1, reps + 1):
            log = DATA_DIR / "logs" / name / f"fill{fill:02d}_rep{rep}.log"
            t0 = time.monotonic()
            point, err = run_point(cmd, log)
            dt = time.monotonic() - t0
            if err:
                print(f"  [!] {name} fill={fill} rep={rep} FAILED after "
                      f"{dt:.0f}s: {err}")
                entry["failures"].append({"fill": fill, "rep": rep, "error": err})
                continue
            points.append(point)
            print(f"  {name} fill={fill:2d} rep={rep}/{reps}  "
                  f"get {point['get_mops']:7.1f}  "
                  f"reprobe {point['reprobe_factor']:.4f}  ({dt:.0f}s)")

        if not points:
            print(f"  [!] {name} fill={fill}: every rep failed, no point recorded")
            save(results, out_path)
            continue

        record_point(entry, fill, points)
        gets = entry["get_samples"][-1]
        spread = (max(gets) - min(gets)) / entry["get_mops"][-1] * 100
        reprobes = set(entry["reprobe_factor_samples"][-1])
        print(f"  => {name} fill={fill:2d} median get {entry['get_mops'][-1]:.1f}"
              f" (spread {spread:.1f}%) reprobe {entry['reprobe_factor'][-1]:.4f}"
              + ("" if len(reprobes) == 1 else f"  [!] reprobe varies: {sorted(reprobes)}"))
        save(results, out_path)


# =============================================================================
# MAIN
# =============================================================================


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(DEFAULT_OUT),
                    help=f"output json (default: {DEFAULT_OUT.name})")
    ap.add_argument("--variant", action="append", choices=list(VARIANTS),
                    help="collect only these variants (repeatable)")
    ap.add_argument("--fill", action="append", type=int,
                    help="collect only these fills (repeatable)")
    ap.add_argument("--reps", type=int, default=REPS)
    ap.add_argument("--no-build", action="store_true",
                    help="reuse build/ as-is (only sensible with one --variant)")
    ap.add_argument("--force", action="store_true",
                    help="overwrite --out if it already exists")
    ap.add_argument("--dry-run", action="store_true",
                    help="print every build and command, run nothing")
    args = ap.parse_args()

    names = args.variant or PLOT_ORDER
    fills = args.fill or FILLS
    out_path = Path(args.out)

    if args.dry_run:
        for name in names:
            print(f"\n# {name}: {len(fills)} fills x {args.reps} reps")
            print(cmake_cmd(name))
            for fill in fills:
                print(dramhit_cmd(fill))
        print(f"\n# {len(names) * len(fills) * args.reps} dramhit runs -> {out_path}")
        return 0

    if out_path.exists() and not args.force:
        raise SystemExit(f"[!] {out_path} exists; pick another --out or pass --force")
    if args.no_build and len(names) > 1:
        raise SystemExit("[!] --no-build with several variants would measure "
                         "one binary under every name")

    results = new_results(args.reps)
    save(results, out_path)
    set_prefetcher(PREFETCHER)

    for name in names:
        print(f"\n=== {name} ===")
        collect_variant(name, fills, args.reps, out_path, results,
                        not args.no_build)

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
