'''
HBM variant of run_intel_bandwidth.py, for Intel Xeon Max (Sapphire Rapids + HBM)
running in HBM Flat mode, where the HBM shows up as cpu-less NUMA nodes:

    node 0 / node 1 -> DDR5 attached to socket 0 / socket 1
    node 2 / node 3 -> HBM2e attached to socket 0 / socket 1

Same structure as run_intel_bandwidth.py; the differences are all forced by the
HBM uncore PMUs and were validated on this machine:

    - The HBM controllers are NOT reachable through unc_m_*. perf enumerates them
      via the uncore discovery table (alias uncore_type_14_N), so they carry no
      event list and must be driven with raw event codes. CAS is event 0x05 with
      umask 0xcf (rd) / 0xf0 (wr) / 0xff (all); clockticks is event 0x01.
    - There are 32 uncore_hbm_* boxes per socket (vs 8 DDR channels), and unlike
      the unc_m_* aliases perf does NOT merge them, so every event comes back as
      32 separate rows per socket and the parser has to sum them.
    - An HBM CAS moves 32 bytes, not 64. Verified twice against a known-size
      workload: 30.1 GB read -> 957,726,472 rd CAS * 32 B = 30.65 GB, and
      146 GB written -> 4.69G wr CAS * 32 B = 150 GB.
    - HBM DCLK is not fixed: 0.333 GHz idle vs 0.798 GHz under load. Calibrating
      it with an idle "sleep 1" the way the DDR script does would inflate every
      bandwidth number by ~2.4x, so detect_frequencies() runs a real memory load
      and takes the peak per-interval frequency.

The workload binary uses MAP_HUGETLB, so 2 MB hugepages must be reserved on the
nodes under test before running this (see check_hugepages).
'''
import subprocess
import os
import sys
import glob
import statistics
import json
from collections import defaultdict

# --- Configuration ---
BIN_PATH = "/opt/DRAMHiT/scripts/eurosys_2026/machine_stats/build/bandwidth_rand"

# CPUs still live on node 0 / node 1; only the memory target moves to the HBM
# nodes 2 (local to socket 0) and 3 (local to socket 1).
NUMA_PATTERNS = {
    "single_local": "n0a2t64",
    "single_remote": "n0a3t64",
    "single_mixed": "n0a2,3t64",
    "dual_local": "n0a2t64 n1a3t64",
    "dual_remote": "n0a3t64 n1a2t64",
    "dual_mixed": "n0a2,3t64 n1a2,3t64"
}

MODES = {"read": "r", "write": "w"}

PER_THREAD_SIZE = "128mb"

NUM_HBM_CHANNELS = len(glob.glob("/sys/devices/uncore_hbm_*"))
NUM_UPI_LINKS = len(glob.glob("/sys/devices/uncore_upi_*"))

# Raw encodings for the HBM boxes -- these PMUs expose no events/ directory.
HBM_EVENT_ENCODINGS = {
    "unc_hbm_cas_count.all": "event=0x05,umask=0xff",
    "unc_hbm_cas_count.rd": "event=0x05,umask=0xcf",
    "unc_hbm_cas_count.wr": "event=0x05,umask=0xf0",
    "unc_hbm_clockticks": "event=0x01,umask=0x00",
}


def hbm_events(names):
    """Expand event names across all 32 uncore_hbm_* boxes, tagging each with
    name= so the log parser can group them back together."""
    return ",".join(
        "uncore_hbm_{i}/{enc},name={n}/".format(i=i, enc=HBM_EVENT_ENCODINGS[n], n=n)
        for i in range(NUM_HBM_CHANNELS)
        for n in names
    )


# Included clockticks for accurate hardware timing
EVENTS_BW = hbm_events(["unc_hbm_cas_count.all", "unc_hbm_cas_count.rd",
                        "unc_hbm_cas_count.wr", "unc_hbm_clockticks"])
EVENTS_UPI = "unc_upi_txl_flits.all_data,unc_upi_txl_flits.non_data,unc_upi_clockticks"

OUTPUT_DIR = "perf_logs_hbm"
JSON_OUTPUT_FILE = "benchmark_results_hbm.json"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Conversion Factors ---
EVENT_CONVERSIONS = {
    "unc_hbm_cas_count.all": 32,          # 32 bytes per HBM CAS, NOT 64
    "unc_hbm_cas_count.rd": 32,
    "unc_hbm_cas_count.wr": 32,
    "unc_upi_txl_flits.all_data": 64 / 9, # 9 data flits per 64-byte payload
    "unc_upi_txl_flits.non_data": 8,      # Control/Non-data payload equivalent
}

# Fallbacks if detection fails. Both are the values measured on this machine
# under load: HBM DCLK 0.798 GHz, UPI link clock 1.995 GHz.
DEFAULT_HBM_FREQ_GHZ = 0.8
DEFAULT_UPI_FREQ_GHZ = 2.0

# Memory nodes this sweep touches, and the calibration load used to pin the
# uncore frequency at its ceiling before we measure it.
HBM_NODES = [2, 3]
CALIBRATION_PATTERN = "n0a2t32 n1a3t32"
CALIBRATION_SIZE = "64mb"


def check_hugepages():
    """bandwidth.c mmaps with MAP_HUGETLB. Without a hugepage pool every worker
    dies at mmap ('Cannot allocate memory') and never reaches its
    pthread_barrier_wait, so the binary HANGS FOREVER rather than exiting -- both
    here and inside detect_frequencies(). Fail loudly up front instead."""
    per_thread = 128 * 1024 * 1024   # PER_THREAD_SIZE
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


def detect_frequencies():
    """
    Measures the actual hardware frequency of the HBM controllers and UPI links
    per socket.

    Two things differ from the DDR script:

    1. This must be done *under load*. HBM DCLK idles at ~0.333 GHz and only
       reaches its ~0.798 GHz ceiling once traffic is flowing, so calibrating
       against an idle "sleep 1" would inflate every bandwidth number by ~2.4x.
       We sample in 100ms intervals during a real memory workload and take the
       peak per-interval rate.

    2. Frequency is derived as sum(ticks) / sum(run_ns) over the rows that make
       up one (interval, socket) group, NOT ticks / num_units / wall_time. perf
       merges the 3 uncore_upi_* boxes into a single row whose run_ns is the sum
       of all three counters' runtimes, while the 32 raw uncore_hbm_* boxes stay
       unmerged as 32 rows of ~1 interval each. Because run_ns is aggregated
       exactly the way the counts are, the ratio is the true per-unit clock rate
       in both cases and no num_units division is needed. Pairing the 32-box tick
       sum with the UPI row's 3x-inflated run_ns is what previously reported
       0.270 GHz instead of 0.798 GHz.
    """
    events = hbm_events(["unc_hbm_clockticks"]) + ",unc_upi_clockticks"
    cmd = [
        "perf", "stat", "-a", "--per-socket",
        "-e", events,
        "-x", ",", "-I", "1",
        "--",
        BIN_PATH,
        "-m", CALIBRATION_SIZE,
        "-pattern", CALIBRATION_PATTERN,
        "-freq", "2.5",
        "-inst", "t1",
        "-lookahead", "64",
        "-mode", "r",
    ]

    print("Detecting uncore frequencies under load...")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error detecting frequencies. Make sure you run with sudo and that")
        print("hugepages are reserved.")
        print(result.stderr)
        print("Falling back to defaults: HBM={} GHz, UPI={} GHz".format(
            DEFAULT_HBM_FREQ_GHZ, DEFAULT_UPI_FREQ_GHZ))
        return (defaultdict(lambda: DEFAULT_HBM_FREQ_GHZ),
                defaultdict(lambda: DEFAULT_UPI_FREQ_GHZ))

    # (event, timestamp, socket) -> [summed ticks, summed counter runtime in ns]
    acc = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: [0.0, 0.0])))

    for line in result.stderr.strip().split('\n'):
        parts = line.split(',')
        if len(parts) < 7 or not parts[0].strip()[:1].isdigit():
            continue

        socket = parts[1].strip()
        if not socket.startswith("S"):
            continue

        try:
            timestamp = float(parts[0].strip())
            count = float(parts[3].strip())
            event_name = parts[5].strip()
            run_ns = float(parts[6].strip())
        except ValueError:
            continue

        if event_name not in ("unc_hbm_clockticks", "unc_upi_clockticks"):
            continue

        slot = acc[event_name][timestamp][socket]
        slot[0] += count
        slot[1] += run_ns

    def peak_freq(event_name, default):
        by_socket = defaultdict(float)
        # Skip the first interval: it carries the counter-enable time, which
        # stretches run_ns and skews the ratio.
        timestamps = sorted(acc[event_name].keys())[1:]
        for timestamp in timestamps:
            for socket, (ticks, run_ns) in acc[event_name][timestamp].items():
                if run_ns <= 0:
                    continue
                # ticks per ns == GHz
                by_socket[socket] = max(by_socket[socket], ticks / run_ns)
        return defaultdict(lambda: default, by_socket)

    hbm_freq_map = peak_freq("unc_hbm_clockticks", DEFAULT_HBM_FREQ_GHZ)
    upi_freq_map = peak_freq("unc_upi_clockticks", DEFAULT_UPI_FREQ_GHZ)

    print("-" * 55)
    for socket in sorted(set(list(hbm_freq_map.keys()) + list(upi_freq_map.keys()))):
        print("Socket: {}".format(socket))
        print("  HBM Controller Freq    : {:.3f} GHz".format(hbm_freq_map[socket]))
        print("  UPI Link Freq          : {:.3f} GHz".format(upi_freq_map[socket]))
    print("-" * 55 + "\n")

    return hbm_freq_map, upi_freq_map


def run_and_collect(pattern_name, pattern_str, mode_name, mode_char, run_type, events):
    cmd = [
        "stdbuf", "-o0", "-e0",
        "perf", "stat", "--per-socket", "-e", events, "-I", "10", "-x", ",",
        "--",
        BIN_PATH,
        "-m", PER_THREAD_SIZE,
        "-pattern", pattern_str,
        "-freq", "2.7",
        "-inst", "t1",
        "-lookahead", "64",
        "-mode", mode_char
    ]

    log_filename = os.path.join(OUTPUT_DIR, f"{pattern_name}_{mode_name}_{run_type}.log")
    print(f"Running: {pattern_name} | {mode_name} | {run_type}")

    with open(log_filename, "w") as log_file:
        process = subprocess.Popen(
            cmd,
            stdout=log_file,
            stderr=subprocess.STDOUT,
            text=True
        )
        process.wait()

    return log_filename


def parse_perf_log(log_filename, clock_event_name, num_units, freq_map):
    in_collection = False

    # 1st Pass: Group all events by their exact printed timestamp.
    # NOTE: unlike the unc_m_* aliases, the raw uncore_hbm_* events are not
    # merged by perf -- each of the 32 boxes emits its own row per socket, so we
    # accumulate instead of assigning.
    raw_interval_data = defaultdict(lambda: defaultdict(lambda: defaultdict(float)))

    with open(log_filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            if "Start perf collection" in line:
                in_collection = True
                continue
            elif "End perf collection" in line:
                in_collection = False
                continue

            if in_collection:
                parts = line.split(",")
                if len(parts) >= 6:
                    try:
                        timestamp = float(parts[0].strip())
                        socket_id = parts[1].strip()

                        if "<not counted>" in parts[3] or "<not supported>" in parts[3]:
                            continue

                        count = float(parts[3].strip())
                        event_name = parts[5].strip()

                        if "S" in socket_id:
                            raw_interval_data[timestamp][socket_id][event_name] += count

                    except ValueError:
                        pass

    # 2nd Pass: Calculate GB/s using the detected hardware frequencies
    samples = defaultdict(lambda: defaultdict(list))

    for timestamp, sockets in sorted(raw_interval_data.items()):
        for socket_id, events in sockets.items():

            if clock_event_name not in events:
                continue

            total_clockticks = events[clock_event_name]
            if total_clockticks <= 0:
                continue

            # Divide by the number of channels/links to get the true ticks per channel
            true_clockticks = total_clockticks / num_units

            # Retrieve the exact frequency we measured earlier for this socket
            freq_ghz = freq_map[socket_id]

            # Convert hardware ticks to actual seconds
            actual_time_sec = true_clockticks / (freq_ghz * 1_000_000_000)

            if actual_time_sec <= 0:
                continue

            for event_name, count in events.items():
                if event_name == clock_event_name:
                    continue

                multiplier = EVENT_CONVERSIONS.get(event_name, 1.0)
                rate_per_sec = (count * multiplier) / actual_time_sec
                rate_giga = rate_per_sec / 1_000_000_000

                samples[socket_id][event_name].append(rate_giga)

    return samples


def calculate_and_print_statistics(samples):
    stats_dict = {}

    if not samples:
        print("    No valid samples collected between the markers.")
        return stats_dict

    for socket_id, events in sorted(samples.items()):
        print(f"    Socket: {socket_id}")
        stats_dict[socket_id] = {}

        for event, values in events.items():
            if not values:
                print(f"      {event}: No valid samples found.")
                continue

            # Calculate stats on the entire list
            avg_val = statistics.mean(values)
            min_val = min(values)
            max_val = max(values)

            # Select the middle element of the time series
            mid_val = values[len(values) // 2]

            # Save to dictionary for JSON output
            stats_dict[socket_id][event] = {
                "mid": mid_val,
                "avg": avg_val,
                "min": min_val,
                "max": max_val
            }

            print(f"      {event:<35} | Mid: {mid_val:>8.2f} GB/s | Avg: {avg_val:>8.2f} GB/s | Min: {min_val:>8.2f} GB/s | Max: {max_val:>8.2f} GB/s")

    return stats_dict


def main():
    if NUM_HBM_CHANNELS == 0:
        print("ERROR: no uncore_hbm_* PMUs found. This script needs a Xeon Max")
        print("(Sapphire Rapids + HBM) with the HBM exposed as its own NUMA nodes.")
        sys.exit(1)

    print("Starting HBM Benchmark Collection...")
    print("Detected {} HBM channels/socket, {} UPI links/socket\n".format(
        NUM_HBM_CHANNELS, NUM_UPI_LINKS))

    if "--skip-hugepage-check" not in sys.argv:
        check_hugepages()

    # Step 1: Detect actual hardware frequencies
    hbm_freq_map, upi_freq_map = detect_frequencies()

    # Step 2: Run benchmarks
    all_results = {}

    for pattern_name, pattern_str in NUMA_PATTERNS.items():
        all_results[pattern_name] = {}

        for mode_name, mode_char in MODES.items():
            all_results[pattern_name][mode_name] = {}
            print(f"=== Configuration: {pattern_name} ({mode_name.upper()}) ===")

            # --- RUN 1: Bandwidth ---
            bw_log = run_and_collect(pattern_name, pattern_str, mode_name, mode_char, "bw", EVENTS_BW)
            # Pass the dynamically detected HBM frequency map
            bw_samples = parse_perf_log(bw_log, "unc_hbm_clockticks", NUM_HBM_CHANNELS, hbm_freq_map)

            # --- RUN 2: UPI ---
            upi_log = run_and_collect(pattern_name, pattern_str, mode_name, mode_char, "upi", EVENTS_UPI)
            # Pass the dynamically detected UPI frequency map
            upi_samples = parse_perf_log(upi_log, "unc_upi_clockticks", NUM_UPI_LINKS, upi_freq_map)

            # --- Print Stats and Capture for JSON ---
            print("\n  [HBM Bandwidth Results]")
            bw_stats = calculate_and_print_statistics(bw_samples)

            print("\n  [UPI Results]")
            upi_stats = calculate_and_print_statistics(upi_samples)

            all_results[pattern_name][mode_name]["bw"] = bw_stats
            all_results[pattern_name][mode_name]["upi"] = upi_stats

            print("-" * 80 + "\n")

    # --- Save JSON ---
    print(f"Saving aggregated statistics to {JSON_OUTPUT_FILE}...")
    with open(JSON_OUTPUT_FILE, "w") as json_file:
        json.dump(all_results, json_file, indent=4)
    print("Done!")


if __name__ == "__main__":
    main()
