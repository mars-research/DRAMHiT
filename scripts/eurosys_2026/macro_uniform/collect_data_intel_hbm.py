#!/usr/bin/env python3
"""Uniform-workload macro benchmark on the Intel Xeon Max 9462, in HBM (mode 11).

The HBM twin of collect_data_intel.py: same workload, same table size, same
repeat count and the same build, so the two Intel panels differ only in where
the hashtable lives and how much of the machine it gets.

    collect_data_intel.py       Xeon Gold 6548Y+, 128 threads over 2 sockets,
                                table interleaved over both DDR nodes
    this script                 Xeon Max 9462, 64 threads on socket 0, table
                                bound to node 2 -- socket 0's own HBM

Every table is measured in BOTH hardware-prefetcher states, so the four
hashtables give eight series. The older collector picked one state per table
(off for the DRAMHiT tables, on for the baselines) and only the baselines were
measured both ways; here nothing is assumed.

    cas       ht-type 3   dramblast, the 2025 inlined CAS table
    cas23     ht-type 8   dramhit, the 2023 table
    folklore  ht-type 11
    dlht      ht-type 10

    python3 collect_data_intel_hbm.py --dry-run     # print the plan, run nothing
    python3 collect_data_intel_hbm.py               # build, reserve, full matrix
    python3 collect_data_intel_hbm.py --table cas_hwpf_on
    python3 collect_data_intel_hbm.py --no-build    # reuse the current build/

Results are written after every point, so an interrupted run leaves a readable
json and the logs of everything that finished.
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

MACHINE = "intel-max9462-hbm"
DATA_DIR = SCRIPT_DIR / "intel_hbm"

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"
# prefetch_control_hbm.sh, not prefetch_control.sh: on this part the latter's
# 0xf leaves a prefetcher enabled (bit 5 of MSR 0x1a4), which on a sequential
# access pattern fetches ~2 extra cache lines per operation while still
# reporting "all prefetchers off". The hbm variant writes 0x2f. See its header.
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_hbm.sh"
PREFETCH_MASKS = {"on": "0x0", "off": "0x2f"}
HUGEPAGE_SCRIPT = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"

# --- mirrored from include/types.hpp -----------------------------------------
MODE_UNIFORM = 11
HT_CAS = 3
HT_CAS23 = 8
HT_DLHT = 10
HT_FOLKLORE = 11

# --- machine ------------------------------------------------------------------
# Xeon Max 9462: 2 sockets x 32 cores / 64 threads, and 64 GiB of HBM per
# socket exposed as its own cpu-less numa node in flat mode --
#   node 0/1  cpus + 128 GiB DDR each
#   node 2/3  64 GiB HBM each, node 2 attached to socket 0
# The cpus are pinned to their 2.7 GHz base clock, which is what CPUFREQ_MHZ
# has to agree with: it is the divisor the binary turns rdtsc cycles into
# seconds with, so a wrong value silently rescales every mops number.
#
# --numa-split 10 is THREADS_CUSTOM, the only policy that can place threads and
# memory independently, which a cpu-less HBM node needs: np_cpu_node_msk picks
# the cpus (0x1 = node 0) and np_mem_node_msk is what calloc_ht() mbinds the
# hashtable to (0x4 = node 2). Every other policy derives the memory node from
# the thread's own node and can therefore never name an HBM node here.
CPUFREQ_MHZ = 2700
NUM_THREADS = 64
NUMA_SPLIT = 10
NP_CPU_NODE_MSK = 0x1   # cpus of numa node 0
NP_MEM_NODE_MSK = 0x4   # hashtable in numa node 2 = socket 0's hbm
HBM_NODE = 2

# 536870912 entries x 16 B = 8 GiB, the same table size collect_data_intel.py
# and collect_data_amd.py use, so the three panels are comparable. It is one
# allocation of 8 1 GiB pages, all of it on the hbm node.
HT_SIZE = 1 << 29
HT_1GB_PAGES = 12   # 8 for the table itself, plus slack

# 2 MB pages, which three things want and which are easy to under-reserve --
# every shortage here shows up as "huge_page_allocator ... failed" followed by
# a run that produces no mops at all, not as a slow run:
#   node 0  each thread's key buffer, ops_per_thread * 8 B, unbound so it lands
#           on the thread's own node. It scales with fill: ~40 MB per thread at
#           fill 60 and ~60 MB at fill 90, i.e. ~3.9 GB over 64 threads.
#   hbm     dlht maps its link pool (capacity/8 = 1 GiB here) separately and
#           mbinds it to the hbm node, so that node needs 2 MB pages of its own
#           on top of the table's 1 GiB pages. The other three tables do not.
CPU_NODE_2MB_MB = 8192
HBM_NODE_2MB_MB = 2048

# The workload is replayed this many times per measured run; the timer covers
# all of them. Unchanged from the other collectors for the same reason.
INSERT_FACTOR = 100
READ_FACTOR = 100

SEED = 1775762440565610239

FILLS = list(range(10, 100, 10))
REPS = 5

# Identical to collect_data_intel.py's list except for CPUFREQ_MHZ, which is
# this machine's clock. See that file for why CAS_NO_ABSTRACT must stay OFF.
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

BUILD_JOBS = 64

# DLHT's primary buckets hold 3 KV each while the benchmark's capacity counts 4
# per 64 B, and its link pool is only capacity/8. Past ~45% reported fill the
# pool is exhausted and the table aborts with "Resize required: Global link
# bucket pool exhausted". Both limits are sized from capacity alone, so the cap
# does not move with the machine -- it is the same 40 the DDR and EPYC
# collections used at this HT_SIZE.
DLHT_MAX_FILL = 40
DLHT_MAX_FILL_REASON = (
    "DLHT's link-bucket pool (capacity/8) is exhausted past ~45% reported "
    "fill; the table aborts with 'Resize required: Global link bucket pool "
    "exhausted'"
)

_BASE_TABLES = {
    "cas": {"display": "dramblast", "ht_type": HT_CAS, "batch_len": 16},
    "cas23": {"display": "dramhit", "ht_type": HT_CAS23, "batch_len": 16},
    "folklore": {"display": "folklore", "ht_type": HT_FOLKLORE, "batch_len": 16},
    "dlht": {"display": "dlht", "ht_type": HT_DLHT, "batch_len": 32,
             "max_fill": DLHT_MAX_FILL, "max_fill_reason": DLHT_MAX_FILL_REASON},
}

# Each table twice, once per hardware-prefetcher state. That state is set by
# prefetch_control_hbm.sh, which wrmsr's 0x1a4 on every cpu once per series
# (0x0 = every prefetcher on, 0x2f = every one this part lets us turn off); it
# is invoked as `sudo env PATH="$PATH" ...` and verifies the write by reading
# the MSR back.
# The --hw-pref this script also passes is inert (Application.cpp guards it
# with HARDCODE_PREFETCH_H14A, which nothing defines); it is passed so each
# logged command says which state it was meant to run under. Do not mistake it
# for the mechanism.
TABLES = {}
for _name, _cfg in _BASE_TABLES.items():
    for _state in ("on", "off"):
        TABLES[f"{_name}_hwpf_{_state}"] = dict(
            _cfg, prefetcher=_state,
            display=f"{_cfg['display']} (hw pref {_state})")

PLOT_ORDER = [f"{n}_hwpf_{s}" for n in _BASE_TABLES for s in ("on", "off")]

SKIPPED = {
    "growt": "excluded by request, as in collect_data_intel.py",
}

# --- bandwidth sampling -------------------------------------------------------
# HBM is not counted at uncore_imc. The recipe here is the one
# ../intel_hbm/collect_cpu_scaling.py established on this machine:
#   - the HBM boxes carry no event list (perf enumerates them off the uncore
#     discovery table), so CAS is raw event 0x05, umask 0xcf (rd) / 0xf0 (wr);
#   - there are 32 uncore_hbm_* boxes per socket and perf does NOT merge them,
#     so every event returns one row per box that has to be summed;
#   - an HBM CAS moves 32 B, not the 64 B an imc CAS moves.
# Each row carries its own run_ns, so a rate is bytes * boxes * count / run_ns
# rather than count / wall clock.
#
# The phases here are ~1.4 s, not the ~24 s they are on the DDR box, so the
# interval is 50 ms (~28 samples per phase) and the leading cut is 0.3 s rather
# than that collector's 1.5 s -- a 1.5 s cut would discard every sample.
BW_PMU_PREFIX = "uncore_hbm"
BW_BYTES_PER_CAS = 32
BW_EVENT_ENCODINGS = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
BW_INTERVAL_MS = 50
BW_WARMUP_S = 0.3
BW_WINDDOWN_FRAC = 0.9
BW_MIN_INTERVALS = 3

# Phase markers printed by shard 0. Mode 11 runs through ZipfianTest::run, so
# the lines read "zipfian test insert start"; the marker is a substring match.
PHASE_MARKS = [
    ("test insert start", "set"),
    ("test insert end", None),
    ("test find start", "get"),
    ("test find end", None),
]

SET_RE = re.compile(r"set_mops\s*:\s*([\d.]+)")
GET_RE = re.compile(r"get_mops\s*:\s*([\d.]+)")
# Every key the run inserted is looked up exactly once, so found must equal
# find_ops; a short count means the table lost keys and the mops are meaningless.
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


def reserve_hugepages():
    """1 GiB pages on the hbm node, because that is where the table goes.

    calloc_ht() maps anything over 1 GiB with MAP_HUGETLB|1GB and only then
    mbinds it to np_mem_node_msk, so the pages have to exist on THAT node, not
    on the node the allocating thread runs on. Without them the mmap fails and
    the run dies before it measures anything. The same is true of the 2 MB
    pools -- see CPU_NODE_2MB_MB / HBM_NODE_2MB_MB for who wants which.
    """
    sh(f"{HUGEPAGE_SCRIPT} reset")
    sh(f"{HUGEPAGE_SCRIPT} n{HBM_NODE}_{HT_1GB_PAGES}gb_{HBM_NODE_2MB_MB}mb "
       f"n0_0gb_{CPU_NODE_2MB_MB}mb")


def set_prefetcher(state):
    # The script writes MSR 0x1a4 and needs root. It does not call sudo
    # itself, and sudo's secure_path drops msr-tools from PATH, so PATH is
    # carried across explicitly. It reads the MSR back and exits non-zero if
    # the write did not land, and sh() checks that -- a run cannot proceed
    # with the prefetchers in the wrong state.
    sh(f'sudo env PATH="$PATH" {PREFETCH_SCRIPT} {state}')


def pmu_boxes():
    """Indices of the uncore_hbm boxes.

    Matched to the end of the name: a prefix match alone would also catch
    sibling PMUs that share the prefix and end in a digit, and every event on
    those boxes would then be requested twice -- which is not visible as an
    error, it just doubles the reported bandwidth.
    """
    pattern = re.compile(re.escape(BW_PMU_PREFIX) + r"_(\d+)$")
    return sorted(
        int(m.group(1))
        for m in (pattern.match(p.name)
                  for p in Path("/sys/devices").glob(f"{BW_PMU_PREFIX}_*"))
        if m
    )


def perf_event_string():
    return ",".join(
        f"{BW_PMU_PREFIX}_{i}/{enc},name=mem_{n}/"
        for i in pmu_boxes()
        for n, enc in BW_EVENT_ENCODINGS.items()
    )


def dramhit_cmd(table, fill, with_bw=True):
    args = [
        DRAMHIT,
        "--mode", str(MODE_UNIFORM),
        "--ht-type", str(table["ht_type"]),
        "--ht-size", str(HT_SIZE),
        "--ht-fill", str(fill),
        "--num-threads", str(NUM_THREADS),
        "--numa-split", str(NUMA_SPLIT),
        "--np_cpu_node_msk", str(NP_CPU_NODE_MSK),
        "--np_mem_node_msk", str(NP_MEM_NODE_MSK),
        "--np_mem_local", "0",
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
    return (f"sudo perf stat --per-socket -e {perf_event_string()} "
            f"-I {BW_INTERVAL_MS} -x, -- " + inner)


def parse_bw(output):
    """Per-phase HBM bandwidth from the interleaved perf -I / dramhit log.

    perf writes its interval rows and dramhit writes its phase markers into the
    same merged stream, so which phase a row belongs to is decided by the last
    marker seen before it. Rows are summed over every box (and over both
    sockets: the far socket's HBM is idle here, and counting it makes a stray
    allocation on the wrong node visible instead of invisible).

    Returns {"set": {...}, "get": {...}} with median total/read/write GB/s, or
    an empty dict for a phase with no usable intervals.
    """
    phase = None
    # ts -> event -> [summed count, summed run_ns, rows]
    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))
    ts_phase = {}

    for line in output.splitlines():
        for mark, target in PHASE_MARKS:
            if mark in line:
                phase = target
                break

        parts = line.strip().split(",")
        # 0.050112,S0,32,<count>,<unit/ns>,mem_rd,... -- the layout varies with
        # perf version, so match on the fields actually used instead.
        if len(parts) < 7 or not parts[0][:1].isdigit():
            continue
        if "<not counted>" in line or "<not supported>" in line:
            continue
        if not parts[1].strip().startswith("S"):
            continue
        try:
            ts = float(parts[0])
            count = float(parts[3])
            event = parts[5].strip()
            run_ns = float(parts[6])
        except (ValueError, IndexError):
            continue
        if event not in ("mem_rd", "mem_wr") or phase is None:
            continue

        ts_phase.setdefault(ts, phase)
        slot = acc[ts][event]
        slot[0] += count
        slot[1] += run_ns
        slot[2] += 1

    rows = {"set": [], "get": []}
    phase_t0 = {}
    for ts in sorted(acc):
        events = acc[ts]
        if not {"mem_rd", "mem_wr"} <= set(events):
            continue
        rates = {}
        for key in ("mem_rd", "mem_wr"):
            count, run_ns, boxes = events[key]
            if run_ns <= 0:
                break
            # count * boxes * B / run_ns == bytes per ns == GB/s, once run_ns
            # is turned back into the per-box mean.
            rates[key] = BW_BYTES_PER_CAS * boxes * count / run_ns
        else:
            ph = ts_phase[ts]
            phase_t0.setdefault(ph, ts)
            rows[ph].append((ts - phase_t0[ph], rates["mem_rd"], rates["mem_wr"]))

    out = {}
    for name, samples in rows.items():
        if not samples:
            continue
        span = samples[-1][0]
        # Both boundary intervals straddle a marker and mix two phases.
        if len(samples) > 4:
            samples = samples[1:-1]

        settled = [s for s in samples if s[0] >= BW_WARMUP_S]
        transient_only = len(settled) < BW_MIN_INTERVALS
        if not transient_only:
            samples = settled

        def med(rs):
            return statistics.median(r + w for _, r, w in rs)

        # Trailing wind-down: threads straggling to the closing barrier.
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
        "memory": "hbm (numa node 2), single socket",
        "param_name": "fill",
        "collected_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "reps": reps,
        "bw_pmu": BW_PMU_PREFIX,
        "bw_bytes_per_cas": BW_BYTES_PER_CAS,
        "bw_interval_ms": BW_INTERVAL_MS,
        "bw_unit": "decimal GB/s (bytes / 1e9); / 1.0737 for GiB/s",
        "bw_warmup_s": BW_WARMUP_S,
        "prefetch_script": PREFETCH_SCRIPT,
        "prefetch_masks": PREFETCH_MASKS,
        "ht_size": HT_SIZE,
        "ht_size_gib": HT_SIZE * 16 // (1 << 30),
        "num_threads": NUM_THREADS,
        "numa_split": NUMA_SPLIT,
        "np_cpu_node_msk": NP_CPU_NODE_MSK,
        "np_mem_node_msk": NP_MEM_NODE_MSK,
        "cpufreq_mhz": CPUFREQ_MHZ,
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


def table_entry(table, capped):
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

    Every array stays index-aligned with `fills`, so a phase whose bandwidth
    did not parse still takes a slot (None) rather than shifting the rest.
    """
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

    # --resume keeps whatever the earlier invocation measured and runs only the
    # fills missing from it. Every array in the entry is index-aligned with
    # entry["fills"], and the fills are swept in ascending order, so appending
    # the missing ones keeps that alignment -- as long as the ones already
    # there are a prefix of the sweep, which is what an interrupted or
    # partially failed run leaves behind.
    entry = results["tables"].get(name)
    if entry is None:
        entry = table_entry(table, capped)
        results["tables"][name] = entry
    done = set(entry["fills"])
    if done:
        todo = [f for f in fills if f not in done]
        if not todo:
            print(f"  (all {len(done)} fills already collected, skipping)")
            return
        print(f"  resuming: have {sorted(done)}, running {todo}")
        fills = todo
    # Drop the stale failures for the fills about to be re-run, so the record
    # says what this collection found rather than what the last one hit. This
    # has to happen whether or not the series kept any points: a series that
    # failed at every fill has no fills left but plenty of failures, and those
    # are exactly the ones a re-run makes obsolete.
    rerunning = set(fills)
    entry["failures"] = [f for f in entry["failures"] if f["fill"] not in rerunning]

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
            print(line + f"  ({dt:.0f}s)", flush=True)

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
        print(msg, flush=True)
        save(results, out_path)


# =============================================================================
# MAIN
# =============================================================================


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(DATA_DIR / f"{MACHINE}_uniform.json"))
    ap.add_argument("--table", action="append", choices=list(TABLES),
                    help="collect only these series (repeatable)")
    ap.add_argument("--fill", action="append", type=int,
                    help="collect only these fills (repeatable)")
    ap.add_argument("--reps", type=int, default=REPS)
    ap.add_argument("--no-build", action="store_true",
                    help="reuse build/ as-is instead of reconfiguring")
    ap.add_argument("--no-hugepages", action="store_true",
                    help="skip the hugepage reset/reservation")
    ap.add_argument("--no-bw", action="store_true",
                    help="skip the perf bandwidth sampling (mops only)")
    ap.add_argument("--resume", action="store_true",
                    help="keep the points already in --out and run only the "
                         "fills missing from it")
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
            print(f"\n# {name} ({table['display']}), {len(todo)} fills "
                  f"x {args.reps} reps")
            for fill in todo:
                print(dramhit_cmd(table, fill, not args.no_bw))
            total += len(todo) * args.reps
        print(f"\n# {total} dramhit runs -> {out_path}")
        return 0

    if not args.no_build:
        build()
    elif not Path(DRAMHIT).exists():
        raise SystemExit(f"[!] --no-build but {DRAMHIT} does not exist")

    if not args.no_hugepages:
        reserve_hugepages()

    if not args.no_bw and not pmu_boxes():
        raise SystemExit("[!] no uncore_hbm_* PMUs; this needs a Xeon Max in "
                         "flat mode (or pass --no-bw)")

    if args.resume and out_path.exists():
        results = json.loads(out_path.read_text())
        # Refresh everything except the measurements themselves: a resume is
        # usually a resume because something about the setup was WRONG, and a
        # file that still describes the old setup is worse than no record. The
        # per-point data is what carries over, not the provenance.
        kept = results["tables"]
        results = {**new_results(args.reps), **results}
        results.update({k: v for k, v in new_results(args.reps).items()
                        if k != "tables"})
        results["tables"] = kept
        results["resumed_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
        results.pop("finished_utc", None)
        print(f"[*] resuming from {out_path}")
    else:
        results = new_results(args.reps)
    save(results, out_path)

    for name in names:
        print(f"\n=== {name} ({TABLES[name]['display']}) ===", flush=True)
        collect_table(name, TABLES[name], fills, args.reps, out_path, results,
                      not args.no_bw)

    # Leave the machine the way scripts/setup.sh leaves it: prefetchers off.
    set_prefetcher("off")

    results["finished_utc"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    save(results, out_path)
    print(f"\n[OK] results written to {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
