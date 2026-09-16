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
#   DRAMHiT_VARIANT=2025_INLINE   the manually inlined find_batch/insert_batch
#   PREFETCH=DOUBLE               double prefetch on the find path
#   CAS_PREFETCH_INSERTION=DOUBLE double prefetch on the insert path
#                                 (prefetcht1 on enqueue, prefetchw on dequeue)
#   BUCKETIZATION / BRANCH=simd / UNIFORM_PROBING
#
# CAS_NO_ABSTRACT is OFF on purpose and must stay off for this benchmark.
# It devirtualises CASHashTable by making insert_batch/find_batch empty
# overrides and exposing *_inline instead, and src/tests/uniform_test.cpp then
# (a) still calls the now-empty ht->insert_batch(), so nothing is inserted, and
# (b) static_casts every table to CASHashTable to call find_batch_inline, which
# is wrong for cas23/dlht/folklore. It is usable only for a cas-only find
# experiment; see ../inline_analysis/ANALYSIS.md for what it buys.
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

# name -> what to run. 'prefetcher' is the hardware prefetcher state: the two
# DRAMHiT tables drive the memory system from their own software prefetch
# queue and are measured with it off; the baselines get it on, which is their
# best case.
#
# That state is set by prefetch_control_amd.sh (MSR 0xC0000108), once per
# table, and that script is the only thing that actually changes it. The
# matching --hw-pref this script also passes is inert: Application.cpp guards
# it with #ifdef HARDCODE_PREFETCH_H14A, which nothing defines, and the code
# behind it writes MSR 0x1a4 -- Intel's prefetch control register, not the
# EPYC's. It is passed anyway so each logged command says which state it was
# meant to run under; do not mistake it for the mechanism.
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
        "prefetcher": "on",
        "batch_len": 16,
    },
    "dlht": {
        "display": "dlht",
        "ht_type": HT_DLHT,
        "prefetcher": "on",
        "batch_len": 32,
        # DLHT's primary buckets hold 3 KV each while the benchmark's capacity
        # counts 4 per 64 B, and its link pool is only capacity/8. Past ~45%
        # reported fill the pool is exhausted and the table aborts with
        # "Resize required: Global link bucket pool exhausted". Measured on
        # this box: 45 is the last fill that completes, 50 aborts. The sweep is
        # capped rather than left to fail so the log tree stays clean; raising
        # this needs a bigger link pool in dlht_kht.hpp, not a flag.
        "max_fill": 40,
        "max_fill_reason": (
            "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% "
            "reported fill; the table aborts with 'Resize required: Global "
            "link bucket pool exhausted'"
        ),
    },
}

PLOT_ORDER = ["cas", "cas23", "folklore", "dlht"]

SKIPPED = {
    "growt": "excluded by request; it collapses past ~50% fill (see intel.json)",
}

SET_RE = re.compile(r"set_mops\s*:\s*([\d.]+)")
GET_RE = re.compile(r"get_mops\s*:\s*([\d.]+)")
# mode 11 ends with "find_ops : N, found : M". Every key the run inserted is
# looked up exactly once, so M must equal N; a short count means the table
# lost keys and the throughput number is meaningless.
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


def dramhit_cmd(table, fill):
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
    return "sudo " + " ".join(shlex.quote(a) for a in args)


def run_point(cmd, log_path):
    """One dramhit run. Returns (set_mops, get_mops) or (None, reason)."""
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

    return (float(sets[-1]), float(gets[-1])), None


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


def collect_table(name, table, fills, reps, out_path, results):
    max_fill = table.get("max_fill", 100)
    capped = [f for f in fills if f > max_fill]
    fills = [f for f in fills if f <= max_fill]

    entry = {
        "display": table["display"],
        "ht_type": table["ht_type"],
        "prefetcher": table["prefetcher"],
        "batch_len": table["batch_len"],
        "fills": [],
        "set_mops": [],
        "get_mops": [],
        "set_samples": [],
        "get_samples": [],
        "failures": [],
    }
    if capped:
        entry["not_swept"] = {
            "fills": capped,
            "reason": table.get("max_fill_reason", f"max_fill={max_fill}"),
        }
    results["tables"][name] = entry

    set_prefetcher(table["prefetcher"])

    for fill in fills:
        cmd = dramhit_cmd(table, fill)
        sets, gets = [], []
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
            sets.append(point[0])
            gets.append(point[1])
            print(f"  {name} fill={fill:2d} rep={rep}/{reps}  "
                  f"set {point[0]:7.1f}  get {point[1]:7.1f}  ({dt:.0f}s)")

        if not sets:
            print(f"  [!] {name} fill={fill}: every rep failed, no point recorded")
            save(results, out_path)
            continue

        entry["fills"].append(fill)
        entry["set_mops"].append(statistics.median(sets))
        entry["get_mops"].append(statistics.median(gets))
        entry["set_samples"].append(sets)
        entry["get_samples"].append(gets)
        print(f"  => {name} fill={fill:2d} median set "
              f"{statistics.median(sets):.1f} get {statistics.median(gets):.1f}")
        save(results, out_path)


# =============================================================================
# MAIN
# =============================================================================


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
    ap.add_argument("--dry-run", action="store_true",
                    help="print the build and every command, run nothing")
    args = ap.parse_args()

    names = args.table or PLOT_ORDER
    fills = args.fill or FILLS
    out_path = Path(args.out)

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
                print(dramhit_cmd(table, fill))
            total += len(todo) * args.reps
        print(f"\n# {total} dramhit runs -> {out_path}")
        return 0

    if not args.no_build:
        build()
    elif not Path(DRAMHIT).exists():
        raise SystemExit(f"[!] --no-build but {DRAMHIT} does not exist")

    results = new_results(args.reps)
    save(results, out_path)

    for name in names:
        print(f"\n=== {name} ({TABLES[name]['display']}) ===")
        collect_table(name, TABLES[name], fills, args.reps, out_path, results)

    # Leave the machine in its default state rather than whatever the last
    # table wanted.
    set_prefetcher("on")

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
