'''
VTune backend for the same sweep as run_intel_hbm_bandwidth.py: enumerate NUMA
configurations on an Intel Xeon Max (Sapphire Rapids + HBM) in HBM Flat mode and
report per-socket HBM / DDR / UPI bandwidth for each.

    node 0 / node 1 -> DDR5 attached to socket 0 / socket 1
    node 2 / node 3 -> HBM2e attached to socket 0 / socket 1

Why this exists alongside the perf version:

    - One collection instead of two. The perf script runs each configuration
      twice (once for the memory counters, once for UPI) because the boxes run
      out of counters. VTune's memory-access analysis programs HBM, DDR and UPI
      together, so every number below comes from the same run.
    - No hand-rolled event encodings. VTune ships the SPR-HBM event database, so
      UNC_MCHBM_CAS_COUNT.RD/WR are resolved by name.
    - It is an independent cross-check of the perf numbers. VTune's own
      config/query_library/uncore_hbm_metrics.cfg defines
      HBMReadBandwidth = UNC_MCHBM_CAS_COUNT.RD * 32 / 1e9, i.e. Intel agrees
      with the 32-bytes-per-HBM-CAS scale the perf script uses.

The one thing this CANNOT do that the perf version can: window the measurement.
The perf script brackets its samples with the binary's "Start/End perf
collection" markers and so excludes the allocation + memset phase. VTune totals
cover the whole process lifetime, which drags the average down and shows a few
GB/sec of writes even in read mode (that is the memset faulting pages in). Use
--resume-after N (seconds) to skip the setup phase if you want closer agreement.

Requirements:
    - The VTune SEP sampling driver must be LOADED, not merely installed.
      Driverless (perf-based) collection cannot program these boxes: the
      uncore_hbm_* PMUs expose no events/ directory for VTune to resolve
      UNC_MCHBM_CAS_COUNT against, and collection fails with
      "The following events cannot be collected". See check_driver().
    - 2MB hugepages reserved on the HBM nodes (bandwidth.c uses MAP_HUGETLB).
'''
import argparse
import csv
import glob
import json
import os
import re
import shutil
import subprocess
import sys

# --- Configuration ---
BIN_PATH = "/opt/DRAMHiT/scripts/eurosys_2026/machine_stats/build/bandwidth_rand"

VTUNE_CANDIDATES = [
    os.environ.get("VTUNE_BIN", ""),
    "vtune",
    "/opt/intel/oneapi/vtune/latest/bin64/vtune",
    "/opt/intel/oneapi/vtune/2025.0/bin64/vtune",
]

# CPUs live on node 0 / node 1; the memory target is the HBM node 2 (local to
# socket 0) or node 3 (local to socket 1).
NUMA_PATTERNS = {
    "single_local": "n0a2t64",
    "single_remote": "n0a3t64",
    "single_mixed": "n0a2,3t64",
    "dual_local": "n0a2t64 n1a3t64",
    "dual_remote": "n0a3t64 n1a2t64",
    "dual_mixed": "n0a2,3t64 n1a2,3t64",
}

MODES = {"read": "r", "write": "w"}

DEFAULT_PER_THREAD_SIZE = "128mb"

OUTPUT_DIR = "vtune_results"
JSON_OUTPUT_FILE = "benchmark_results_vtune.json"

HBM_NODES = [2, 3]

# --- Conversion Factors ---
# Bytes moved per counter increment. HBM CAS is 32B (VTune's own metric
# definition uses the same factor); DDR CAS is 64B. UPI matches the factors in
# run_intel_bandwidth.py.
EVENT_CONVERSIONS = {
    "UNC_MCHBM_CAS_COUNT.RD": 32,
    "UNC_MCHBM_CAS_COUNT.WR": 32,
    "UNC_M_CAS_COUNT.RD": 64,
    "UNC_M_CAS_COUNT.WR": 64,
    "UNC_UPI_TxL_FLITS.ALL_DATA": 64 / 9,   # 9 data flits per 64-byte payload
    "UNC_UPI_TxL_FLITS.NON_DATA": 8,        # Control/Non-data payload equivalent
}

# Grouped for reporting; anything missing from a result is simply skipped.
EVENT_GROUPS = {
    "hbm": ["UNC_MCHBM_CAS_COUNT.RD", "UNC_MCHBM_CAS_COUNT.WR"],
    "dram": ["UNC_M_CAS_COUNT.RD", "UNC_M_CAS_COUNT.WR"],
    "upi": ["UNC_UPI_TxL_FLITS.ALL_DATA", "UNC_UPI_TxL_FLITS.NON_DATA"],
}

CSV_EVENT_PREFIX = "Uncore Event Count:"


def find_vtune():
    for candidate in VTUNE_CANDIDATES:
        if not candidate:
            continue
        resolved = shutil.which(candidate) if os.path.basename(candidate) == candidate \
            else (candidate if os.path.isfile(candidate) else None)
        if resolved:
            return resolved
    print("ERROR: could not find the vtune binary. Source the environment first:")
    print("  source /opt/intel/oneapi/vtune/latest/env/vars.sh")
    print("or set VTUNE_BIN=/path/to/vtune.")
    sys.exit(1)


def check_driver():
    """Driverless collection cannot read the HBM boxes, so refuse to start
    without the SEP driver rather than burning a full sweep on failures."""
    if glob.glob("/dev/sep*") or glob.glob("/dev/pax"):
        return
    print("ERROR: the VTune SEP sampling driver is not loaded.")
    print("VTune falls back to driverless perf collection, which cannot program")
    print("the HBM boxes (uncore_hbm_* exposes no events/ directory), and the run")
    print("fails with 'The following events cannot be collected:")
    print("UNC_MCHBM_CAS_COUNT.RD,UNC_MCHBM_CAS_COUNT.WR'.")
    print("\nLoad it with (see scripts/install_vtune.sh):")
    print("  cd /opt/intel/oneapi/vtune/latest/sepdk/src")
    print("  sudo ./build-driver -ni          # only if sep5.ko is not built yet")
    print("  sudo ./insmod-sep -r -g $(id -gn)")
    print("  ./insmod-sep -q")
    sys.exit(1)


def check_hugepages(per_thread_size):
    """bandwidth.c mmaps with MAP_HUGETLB. Without a hugepage pool every worker
    dies at mmap and never reaches its pthread_barrier_wait, so the binary HANGS
    FOREVER rather than exiting. Fail loudly up front instead."""
    per_thread = parse_size(per_thread_size)
    # Worst case in this sweep: dual_mixed interleaves 128 threads over both HBM
    # nodes, i.e. half the total footprint lands on each node.
    needed_per_node = (128 * per_thread // 2) // (2 * 1024 * 1024)

    missing = []
    for node in HBM_NODES:
        path = "/sys/devices/system/node/node{}/hugepages/hugepages-2048kB/free_hugepages".format(node)
        try:
            with open(path) as f:
                free = int(f.read().strip())
        except OSError:
            free = 0
        if free < needed_per_node:
            missing.append((node, free, needed_per_node))

    if missing:
        print("ERROR: not enough 2MB hugepages reserved on the HBM nodes.")
        for node, free, needed in missing:
            print("  node{}: {} free, need {}".format(node, free, needed))
        print("\nReserve them with, e.g.:")
        for node, _, needed in missing:
            print("  echo {} | sudo tee /sys/devices/system/node/node{}/hugepages/hugepages-2048kB/nr_hugepages".format(needed, node))
        print("\nRe-run with --skip-hugepage-check to bypass this check.")
        sys.exit(1)


def parse_size(text):
    match = re.match(r"^\s*([0-9.]+)\s*([kKmMgG]?)[bB]?\s*$", text)
    if not match:
        raise ValueError("cannot parse size: {}".format(text))
    value = float(match.group(1))
    return int(value * {"": 1, "k": 1024, "m": 1024 ** 2, "g": 1024 ** 3}[match.group(2).lower()])


def run_and_collect(vtune, result_dir, pattern_str, mode_char, per_thread_size,
                    resume_after, log_path):
    if os.path.exists(result_dir):
        shutil.rmtree(result_dir)

    cmd = [
        vtune, "-collect", "memory-access",
        # Skip VTune's peak-bandwidth calibration micro-benchmark. It costs a
        # minute per run and only scales the Low/Medium/High thresholds, which
        # we do not use -- the reported "Platform Maximum" is then a placeholder.
        "-knob", "dram-bandwidth-limits=false",
        "-knob", "analyze-mem-objects=false",
        # The default 1000MB cap truncates a 128-thread collection.
        "-data-limit=0",
        "-r", result_dir,
    ]
    if resume_after > 0:
        # Delay collection to skip the allocation + memset phase that the perf
        # script excludes with its markers. This implies start-paused on its
        # own; adding -start-paused separately leaves it paused forever. Takes
        # SECONDS (fractions allowed) and must use '=' syntax.
        cmd += ["-resume-after={}".format(resume_after)]
    cmd += [
        "--",
        BIN_PATH,
        "-m", per_thread_size,
        "-pattern", pattern_str,
        "-freq", "2.5",       # Benchmark CPU mesh flag
        "-inst", "t1",
        "-lookahead", "64",
        "-mode", mode_char,
    ]

    with open(log_path, "w") as log_file:
        proc = subprocess.run(cmd, stdout=log_file, stderr=subprocess.STDOUT, text=True)
    return proc.returncode


def report_summary(vtune, result_dir):
    """Returns (collection_seconds, elapsed, paused, bandwidth_utilization_rows).

    collection_seconds is Elapsed Time minus Paused Time -- the window the
    counters were actually running. With --resume-after those differ, and
    dividing counts by the raw elapsed time understates bandwidth by exactly the
    paused fraction.
    """
    out = subprocess.run([vtune, "-report", "summary", "-r", result_dir],
                         capture_output=True, text=True).stdout

    elapsed = None
    match = re.search(r"^Elapsed Time:\s*([0-9.]+)s", out, re.M)
    if match:
        elapsed = float(match.group(1))

    paused = 0.0
    match = re.search(r"^\s*Paused Time:\s*([0-9.]+)s", out, re.M)
    if match:
        paused = float(match.group(1))

    collection = (elapsed - paused) if elapsed is not None else None

    # The "Bandwidth Utilization" table is fixed-width, e.g.
    #   HBM Single-Package, GB/sec  150   128.000  109.539  92.1%
    utilization = {}
    for line in out.splitlines():
        match = re.match(r"^([A-Za-z][^,]*,\s*(?:GB/sec|\(%\)))\s+"
                         r"([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)%", line)
        if match:
            utilization[match.group(1).strip()] = {
                "platform_max": float(match.group(2)),
                "observed_max": float(match.group(3)),
                "average": float(match.group(4)),
                "pct_elapsed_high_bw": float(match.group(5)),
            }
    return collection, elapsed, paused, utilization


def report_per_package(vtune, result_dir, collection_sec):
    """Per-package uncore event totals converted to GB/s.

    Columns are looked up by header name ('Uncore Event Count:<EVENT>') rather
    than position -- the column set shifts with the analysis type and CPU.
    """
    out = subprocess.run([vtune, "-report", "hw-events", "-r", result_dir,
                          "-group-by=package", "-format=csv",
                          "-csv-delimiter=comma"],
                         capture_output=True, text=True).stdout

    rows = list(csv.DictReader(out.splitlines()))
    packages = {}

    for row in rows:
        package = (row.get("Package") or "").strip()
        if not package:
            continue

        entry = {}
        for group, events in EVENT_GROUPS.items():
            for event in events:
                raw = row.get(CSV_EVENT_PREFIX + event)
                if raw is None or raw.strip() == "":
                    continue
                try:
                    count = float(raw)
                except ValueError:
                    continue
                gigabytes = count * EVENT_CONVERSIONS[event] / 1e9
                entry.setdefault(group, {})[event] = {
                    "count": count,
                    "GB": gigabytes,
                    "GB/s": (gigabytes / collection_sec) if collection_sec else None,
                }
        if entry:
            packages[package] = entry

    return packages


def print_result(packages, utilization):
    if not packages:
        print("    No per-package uncore counts in the result.")
    for package, groups in sorted(packages.items()):
        print("    {}".format(package))
        for group in ("hbm", "dram", "upi"):
            if group not in groups:
                continue
            for event, values in sorted(groups[group].items()):
                rate = values["GB/s"]
                rate_text = "{:>8.2f} GB/s".format(rate) if rate is not None else "     n/a"
                print("      {:<34} | {} | {:>12.0f} events".format(
                    event, rate_text, values["count"]))

    if utilization:
        print("    [VTune Bandwidth Utilization]")
        for domain, values in sorted(utilization.items()):
            print("      {:<34} | Avg: {:>8.2f} | Observed Max: {:>8.2f}".format(
                domain, values["average"], values["observed_max"]))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-m", "--per-thread-size", default=DEFAULT_PER_THREAD_SIZE,
                        help="per-thread buffer size passed to bandwidth_rand (default: %(default)s)")
    parser.add_argument("--resume-after", type=float, default=0.0, metavar="SEC",
                        help="delay collection by SEC seconds (fractions allowed) to skip "
                             "the allocation/memset phase (default: 0, profile everything)")
    parser.add_argument("--patterns", default=None,
                        help="comma-separated subset of: " + ",".join(NUMA_PATTERNS))
    parser.add_argument("--modes", default=None,
                        help="comma-separated subset of: " + ",".join(MODES))
    parser.add_argument("--output-dir", default=OUTPUT_DIR)
    parser.add_argument("--json", default=JSON_OUTPUT_FILE)
    parser.add_argument("--skip-hugepage-check", action="store_true")
    args = parser.parse_args()

    vtune = find_vtune()
    check_driver()
    if not args.skip_hugepage_check:
        check_hugepages(args.per_thread_size)

    patterns = {k: v for k, v in NUMA_PATTERNS.items()
                if args.patterns is None or k in args.patterns.split(",")}
    modes = {k: v for k, v in MODES.items()
             if args.modes is None or k in args.modes.split(",")}
    if not patterns or not modes:
        print("ERROR: --patterns/--modes selected nothing.")
        sys.exit(1)

    os.makedirs(args.output_dir, exist_ok=True)
    print("Starting VTune HBM Benchmark Collection...")
    print("vtune: {}".format(vtune))
    print("per-thread size: {}   patterns: {}   modes: {}\n".format(
        args.per_thread_size, ",".join(patterns), ",".join(modes)))

    all_results = {}

    for pattern_name, pattern_str in patterns.items():
        all_results[pattern_name] = {}

        for mode_name, mode_char in modes.items():
            print("=== Configuration: {} ({}) ===".format(pattern_name, mode_name.upper()))

            tag = "{}_{}".format(pattern_name, mode_name)
            result_dir = os.path.join(args.output_dir, tag)
            log_path = os.path.join(args.output_dir, tag + ".log")

            print("Running: {} | {}".format(pattern_name, mode_name))
            rc = run_and_collect(vtune, result_dir, pattern_str, mode_char,
                                 args.per_thread_size, args.resume_after, log_path)
            if rc != 0:
                print("  Collection FAILED (rc={}). See {}".format(rc, log_path))
                for line in open(log_path):
                    if "Error" in line:
                        print("  " + line.strip())
                all_results[pattern_name][mode_name] = {"error": "collection failed"}
                print("-" * 80 + "\n")
                continue

            collection, elapsed, paused, utilization = report_summary(vtune, result_dir)
            packages = report_per_package(vtune, result_dir, collection)

            print("\n  [Per-Package Results]  collection={}s (elapsed={}s, paused={}s)".format(
                collection, elapsed, paused))
            print_result(packages, utilization)

            all_results[pattern_name][mode_name] = {
                "collection_sec": collection,
                "elapsed_sec": elapsed,
                "paused_sec": paused,
                "packages": packages,
                "bandwidth_utilization": utilization,
            }
            print("-" * 80 + "\n")

    print("Saving aggregated statistics to {}...".format(args.json))
    with open(args.json, "w") as json_file:
        json.dump(all_results, json_file, indent=4)
    print("Done!")


if __name__ == "__main__":
    main()
