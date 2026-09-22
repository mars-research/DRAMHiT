#!/usr/bin/env python3
"""Uniform-workload macro benchmark on the Intel Xeon Gold 6548Y+ (mode 11).

The Intel twin of collect_data_amd.py: same sweep, same table size, same
repeat count, so the two machines' panels are directly comparable. Sweeps
fill factor and measures set/get throughput for the four hashtables the
paper compares:

    cas       ht-type 3   dramblast, the 2025 inlined CAS table
    cas23     ht-type 8   dramhit, the 2023 table
    folklore  ht-type 11
    dlht      ht-type 10

growt is deliberately not collected -- see SKIPPED below.

    python3 collect_data_intel.py --dry-run        # print the plan, run nothing
    python3 collect_data_intel.py                  # build, then the full matrix
    python3 collect_data_intel.py --table dlht     # just one table
    python3 collect_data_intel.py --no-build       # reuse the current build/

Every point is measured REPS times. The json keeps all samples plus the
per-point median, which is what plot_data.py draws (with a min/max band),
because the run-to-run spread here is a few percent and single-run points
cannot resolve the gaps between these tables at low fill.

Results are written after every point, so an interrupted run leaves a
readable json and the logs of everything that finished.

This replaces the pre-2026 collector of the same name, which produced the
flat intel.json in this directory: one run per point, no recorded config,
and growt instead of folklore/dlht. plot_data.py still reads that json
through its legacy path, so the old figure is not lost.
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
DATA_DIR = SCRIPT_DIR / "intel"

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"

# --- mirrored from include/types.hpp -----------------------------------------
MODE_UNIFORM = 11
HT_CAS = 3
HT_CAS23 = 8
HT_DLHT = 10
HT_FOLKLORE = 11

# --- machine ------------------------------------------------------------------
# 2 sockets, 32 cores / 64 threads each, so 2 numa nodes of 64 cpus and ~128
# GiB each (~256 GiB total). 2 MiB L2 per core, 60 MiB L3 per socket. The box
# is pinned to its 2.5 GHz base clock by scripts/setup.sh (constant_freq.sh
# 2.5GHZ), which is what CPUFREQ_MHZ has to agree with: it is the divisor the
# binary turns rdtsc cycles into seconds with, so a wrong value silently
# rescales every mops number. --numa-split 1 is THREADS_SPLIT_SEPARATE_NODES:
# threads split evenly over the 2 nodes, global hashtable MPOL_INTERLEAVE'd
# over both.
CPUFREQ_MHZ = 2500
NUM_THREADS = 128
NUMA_SPLIT = 1

# 536870912 entries x 16 B = 8 GiB, the same table size collect_data_amd.py,
# the earlier macro_uniform collections and intel.json used, so the numbers
# are comparable. Interleaved over 2 nodes that is 4 GiB of 1 GiB pages per
# node; scripts/setup.sh reserves 8 per node.
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
# Identical to the AMD list except for CPUFREQ_MHZ -- none of these knobs is
# machine specific, and keeping them byte-for-byte equal is the point: the
# two collections differ only in the hardware.
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
    # Pinned OFF rather than left to the CMakeLists default. cmake caches every
    # option, so `cmake -S . -B build` on a directory somebody else configured
    # keeps THEIR value for anything this list does not mention. That is not
    # hypothetical: a build left AGGR / BQ_KMER_TEST / PART_ID ON, and AGGR is
    # not cosmetic -- cas_kht.hpp's duplicate-insert path branches on
    # `std::is_same_v<KV, Aggr_KV>` and does an atomic counter increment in
    # place of the value store, which changes what "insert" means. Anything
    # that alters the measured path belongs here explicitly.
    "-DAGGR=OFF",
    "-DBQ_KMER_TEST=OFF",
    "-DBQUEUE=OFF",
    "-DPART_ID=OFF",
    "-DCLHT=OFF",
    "-DLATENCY_COLLECTION=OFF",
]

BUILD_JOBS = 64

# name -> what to run. 'prefetcher' is the hardware prefetcher state: the two
# DRAMHiT tables drive the memory system from their own software prefetch
# queue and are measured with it off; the baselines get it on, which is their
# best case.
#
# That state is set by prefetch_control.sh, which wrmsr's 0x1a4 (0x0 = all
# four prefetchers on, 0xf = all off) on every cpu, once per table, and that
# script is the only thing that actually changes it. It is invoked as
# `sudo env PATH="$PATH" ...` and verifies the write by reading the MSR back;
# see set_prefetcher() for why both halves of that are needed.
#
# The matching --hw-pref this script also passes is inert: Application.cpp
# guards it with
# #ifdef HARDCODE_PREFETCH_H14A, which nothing in the tree defines. The code
# behind it would write the same 0x1a4 -- unlike on the EPYC, where it is the
# wrong register entirely -- but it is still dead. It is passed anyway so each
# logged command says which state it was meant to run under; do not mistake it
# for the mechanism.
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
        # "Resize required: Global link bucket pool exhausted". Both limits are
        # sized from capacity alone, so the cap does not move with the machine:
        # measured here on the Xeon at the same 8 GiB HT_SIZE, 45 is the last
        # fill that completes and 50 aborts -- exactly as on the EPYC. The
        # sweep is capped rather than left to fail so the log tree stays clean;
        # raising this needs a bigger link pool in dlht_kht.hpp, not a flag.
        # max_fill filters --fill too, so reproducing the abort means running
        # dramhit --ht-type 10 --ht-fill 50 by hand.
        "max_fill": 40,
        "max_fill_reason": (
            "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% "
            "reported fill; the table aborts with 'Resize required: Global "
            "link bucket pool exhausted'"
        ),
    },
    # Same two baselines, hardware prefetcher off. Identical in every other
    # respect, so the pair isolates what the prefetcher is worth to them.
    "folklore_nopref": {
        "display": "folklore (hw pref off)",
        "ht_type": HT_FOLKLORE,
        "prefetcher": "off",
        "batch_len": 16,
    },
    "dlht_nopref": {
        "display": "dlht (hw pref off)",
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
    # dlht at the batch length every other table uses. dlht is the only table
    # the collector runs at 32, so its numbers carry a second difference on
    # top of the table itself; this row isolates that by holding batch_len at
    # 16 with the prefetcher off, which is dlht's better state (see PLOT_ORDER).
    "dlht_batch16": {
        "display": "dlht (batch 16, hw pref off)",
        "ht_type": HT_DLHT,
        "prefetcher": "off",
        "batch_len": 16,
        "max_fill": 40,
        "max_fill_reason": (
            "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% "
            "reported fill; the table aborts with 'Resize required: Global "
            "link bucket pool exhausted'"
        ),
    },
}

# The two baselines are collected twice, once in each hardware-prefetcher
# state, and both are kept. The collector's original premise was that "on" is
# the baselines' best case; on this machine that is false, and badly so on the
# find path -- folklore's lookup throughput is 34% higher with the prefetcher
# OFF at fill 10, because ~60% of the traffic the prefetcher generates on a
# random-access probe scan is never used. Rather than silently switch the
# setting, both are measured and plotted so the gap is visible.
PLOT_ORDER = ["cas", "cas23", "folklore", "folklore_nopref", "dlht",
              "dlht_nopref", "dlht_batch16"]

SKIPPED = {
    "growt": "excluded by request; it collapses past ~50% fill (see intel.json)",
}

# --- bandwidth sampling -------------------------------------------------------
# Each run is wrapped in `perf stat -I` so the DRAM traffic is a time series
# rather than one number for the whole process: the run also allocates and
# zeroes 8 GiB before it starts timing, and that would otherwise be averaged
# into the result. 100 ms is short enough to resolve the insert and find phases
# (the shortest, find at high throughput, is still ~1 s = ~10 samples) and long
# enough that per-interval counter noise stays small.
#
# The counters are the memory controllers' CAS counts, i.e. actual DRAM traffic,
# reported by perf in MiB per interval. Bandwidth is decimal GB/s (bytes / 1e9),
# the convention DDR5 part numbers use; divide by 1.0737 for GiB/s.
BW_INTERVAL_MS = 100
BW_EVENTS = "uncore_imc/cas_count_read/,uncore_imc/cas_count_write/"

# Neither end of a phase runs at its steady rate, and both have to be cut out
# or the median measures the wrong thing:
#
#   warm-up    The find phase starts at ~366 GB/s and steps down to ~345 after
#              about 1.5 s, at every fill. The insert phase shows no such step
#              (flat 354-357 from the first interval out to 24 s), so this is
#              specific to the read-only phase and is NOT machine warm-up --
#              insert runs at full bandwidth for seconds immediately before it.
#              The cause is still unidentified. Whatever it is, a phase shorter
#              than the transient is measured entirely inside it: at fill 10 the
#              find phase lasts 0.9 s and reads 366, while fill 30 onwards reads
#              ~346. That produced an 18 GB/s "step" between fill 20 and 30 that
#              was pure measurement artifact.
#
#   wind-down  A phase does not stop all at once. At fill 90 the last ~1.9 s
#              before "test find end" decays 284 -> 7 GB/s as threads straggle
#              to the closing barrier. The median is robust enough that this
#              barely moves it, but it is not steady-state and does not belong.
#
# A point whose phase is too short to survive the warm-up cut is still recorded,
# flagged transient_only, so it is visible rather than silently different.
BW_WARMUP_S = 1.5
BW_WINDDOWN_FRAC = 0.9
BW_MIN_INTERVALS = 3

# perf -I -x, lines look like
#   0.100062267,16.28,MiB,uncore_imc/cas_count_read/,1610869735,100.00,,
PERF_RE = re.compile(
    r"^([\d.]+),([\d.]+),(\w+),uncore_imc/cas_count_(read|write)/,")

# Phase markers printed by shard 0 in src/tests/uniform_test.cpp. They bracket
# the whole insert_factor / read_factor loop, not one iteration.
PHASE_MARKS = [
    ("test insert start", "set"),
    ("test insert end", None),
    ("test find start", "get"),
    ("test find end", None),
]

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
    sh(f"cmake --build {BUILD_DIR} -j {BUILD_JOBS}")


def set_prefetcher(state):
    # prefetch_control.sh writes MSR 0x1a4 and needs root. It no longer calls
    # sudo itself, and sudo's secure_path drops msr-tools from PATH, so PATH
    # has to be carried across explicitly. The script reads the MSR back and
    # exits non-zero if the write did not land, and sh() checks that -- so a
    # run can no longer proceed with the prefetchers in the wrong state.
    sh(f'sudo env PATH="$PATH" {PREFETCH_SCRIPT} {state}')


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
    return (f"sudo perf stat -I {BW_INTERVAL_MS} -x, -a -e {BW_EVENTS} -- "
            + inner)


def parse_bw(output):
    """Per-phase DRAM bandwidth from the interleaved perf -I / dramhit log.

    perf writes its interval lines and dramhit writes its phase markers into
    the same merged stream, so which phase an interval belongs to is decided
    by the last marker seen before it. Returns {"set": {...}, "get": {...}}
    with median total/read/write GB/s, or an empty dict for a phase with no
    usable intervals.

    Each perf line carries MiB accumulated since the previous line, so the
    rate needs the real timestamp delta -- the interval that closes a phase is
    short, and assuming 100 ms there would invent a low sample. The first and
    last interval of each phase are dropped anyway: both straddle a boundary
    and mix the phase with whatever ran next to it.
    """
    phase = None
    prev_ts = 0.0
    pending = {}        # ts -> {"read": MiB, "write": MiB, "phase": ...}
    rows = {"set": [], "get": []}
    phase_t0 = {}

    for line in output.splitlines():
        for mark, target in PHASE_MARKS:
            if mark in line:
                phase = target
                break

        m = PERF_RE.match(line)
        if not m:
            continue
        ts, val, unit, kind = (float(m.group(1)), float(m.group(2)),
                               m.group(3), m.group(4))
        if unit != "MiB":
            continue
        slot = pending.setdefault(ts, {"phase": phase})
        slot[kind] = val
        if "read" not in slot or "write" not in slot:
            continue

        dt = ts - prev_ts
        prev_ts = ts
        del pending[ts]
        ph = slot["phase"]
        if ph is None or dt <= 0:
            continue
        phase_t0.setdefault(ph, ts)
        to_gbps = (1 << 20) / 1e9 / dt
        rows[ph].append((ts - phase_t0[ph], slot["read"] * to_gbps,
                         slot["write"] * to_gbps))

    out = {}
    for name, samples in rows.items():
        if not samples:
            continue
        span = samples[-1][0]
        # Both boundary intervals straddle a marker and mix two phases.
        if len(samples) > 4:
            samples = samples[1:-1]

        # Leading transient.
        settled = [s for s in samples if s[0] >= BW_WARMUP_S]
        transient_only = len(settled) < BW_MIN_INTERVALS
        if not transient_only:
            samples = settled

        # Trailing wind-down: threads straggling to the closing barrier.
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
        # A run that produced mops but no bandwidth is not a failed point --
        # the throughput is still good -- but it is worth saying out loud,
        # because it means the perf/marker interleaving stopped working.
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
        "bw_events": BW_EVENTS,
        "bw_unit": "decimal GB/s (bytes / 1e9); / 1.0737 for GiB/s",
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
    """The empty per-table record both the live and re-derive paths fill in."""
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
            "reason": table.get("max_fill_reason",
                                f"max_fill={table.get('max_fill', 100)}"),
        }
    return entry


def record_point(entry, fill, points):
    """Fold one fill's repeats into the table's arrays.

    `points` is a list of per-run {set_mops, get_mops, bw}. Every array stays
    index-aligned with `fills`, so a phase whose bandwidth did not parse still
    takes a slot (None) rather than shifting everything after it.
    """
    entry["fills"].append(fill)
    for phase in ("set", "get"):
        vals = [p[f"{phase}_mops"] for p in points]
        entry[f"{phase}_mops"].append(statistics.median(vals))
        entry[f"{phase}_samples"].append(vals)

        reps_bw = [p["bw"][phase] for p in points
                   if p.get("bw", {}).get(phase)]
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
    """Recompute bandwidth from saved logs, running nothing.

    Every run's full perf time series is kept in its log, so a change to how
    the steady state is picked out does not need the matrix re-run. Throughput
    is re-read from the same logs, so the result is a complete json.
    """
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
                if "uncore_imc" not in text:
                    continue          # pre-bandwidth collection, skip
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
                    help="output json (default: intel/intel-6548y_uniform.json)")
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

    results = new_results(args.reps)
    save(results, out_path)

    for name in names:
        print(f"\n=== {name} ({TABLES[name]['display']}) ===")
        collect_table(name, TABLES[name], fills, args.reps, out_path, results,
                      not args.no_bw)

    # Leave the machine in the state scripts/setup.sh leaves it in, rather
    # than whatever the last table wanted. NOTE: that is prefetchers OFF on
    # this box -- the opposite of the AMD collector's final state, which
    # restores 'on'.
    set_prefetcher("off")

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
