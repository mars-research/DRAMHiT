'''
This script collects enumerates different numa node and studies workload over different numa configuration.
Few important technical notes:
    - It uses clockticks counter to calculate bw because perf internal OS clock is not accurate enough
    - It dynamically detects clock frequencies (upi and memory) using 1 sec internal
    - It assume each socket has 8 memory channel and 3 upi links
    - The program (workload) only runs over set memory pool (256mb) once, to ensure we capture directory state changes as addition writeback traffic.
'''
import subprocess
import os
import sys
import statistics
import json
from collections import defaultdict

# --- Configuration ---
BIN_PATH = "/opt/DRAMHiT/scripts/eurosys_2026/machine_stats/build/bandwidth_rand"

NUMA_PATTERNS = {
    "single_local": "n0a0t64",
    "single_remote": "n0a1t64",
    "single_mixed": "n0a0,1t64",
    "dual_local": "n0a0t64 n1a1t64",
    "dual_remote": "n0a1t64 n1a0t64",
    "dual_mixed": "n0a0,1t64 n1a0,1t64"
}

MODES = {"read": "r", "write": "w"}

# Included clockticks for accurate hardware timing
EVENTS_BW = "unc_m_cas_count.all,unc_m_cas_count.rd,unc_m_cas_count.wr,unc_m_clockticks"
EVENTS_UPI = "unc_upi_txl_flits.all_data,unc_upi_txl_flits.non_data,unc_upi_clockticks"

NUM_MEM_CHANNELS = 8
NUM_UPI_LINKS = 3

OUTPUT_DIR = "perf_logs"
JSON_OUTPUT_FILE = "benchmark_results.json"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Conversion Factors ---
EVENT_CONVERSIONS = {
    "unc_m_cas_count.all": 64,          # 64 bytes per cache line
    "unc_m_cas_count.rd": 64,
    "unc_m_cas_count.wr": 64,
    "unc_upi_txl_flits.all_data": 64 / 9, # 9 data flits per 64-byte payload
    "unc_upi_txl_flits.non_data": 8,      # Control/Non-data payload equivalent
}

def detect_frequencies():
    """
    Runs a 1-second perf measurement to dynamically calculate the actual
    hardware frequency of the Memory Controllers and UPI links per socket.
    """
    cmd = [
        "perf", "stat", "-a", "--per-socket",
        "-e", "unc_m_clockticks,unc_upi_clockticks",
        "-x", ",",
        "sleep", "1"
    ]

    print("Dynamically detecting uncore frequencies (1-second sleep)...")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error detecting frequencies. Make sure you run with sudo.")
        print(result.stderr)
        print("Falling back to defaults: Memory=2.6GHz, UPI=2.5GHz")
        return defaultdict(lambda: 2.6), defaultdict(lambda: 2.5)

    lines = result.stderr.strip().split('\n')

    m_ticks = {}
    upi_ticks = {}
    elapsed_time = 1.0

    for line in lines:
        parts = line.split(',')
        if not parts or len(parts) < 3:
            continue

        if "time elapsed" in line:
            try:
                elapsed_time = float(parts[0].strip())
            except ValueError:
                pass
            continue

        socket = parts[0].strip()

        if "unc_m_clockticks" in line:
            try:
                m_ticks[socket] = float(parts[2].strip())
            except ValueError:
                pass
        elif "unc_upi_clockticks" in line:
            try:
                upi_ticks[socket] = float(parts[2].strip())
            except ValueError:
                pass

    m_freq_map = {}
    upi_freq_map = {}

    print(f"\nDetection Elapsed Time: {elapsed_time:.4f} seconds")
    print("-" * 55)

    for socket in sorted(set(list(m_ticks.keys()) + list(upi_ticks.keys()))):
        print(f"Socket: {socket}")

        if socket in m_ticks:
            total_m = m_ticks[socket]
            per_channel = total_m / NUM_MEM_CHANNELS
            m_freq_ghz = (per_channel / elapsed_time) / 1_000_000_000
            m_freq_map[socket] = m_freq_ghz
            print(f"  Memory Controller Freq : {m_freq_ghz:.3f} GHz")
        else:
            m_freq_map[socket] = 2.6

        if socket in upi_ticks:
            total_upi = upi_ticks[socket]
            per_link = total_upi / NUM_UPI_LINKS
            upi_freq_ghz = (per_link / elapsed_time) / 1_000_000_000
            upi_freq_map[socket] = upi_freq_ghz
            print(f"  UPI Link Freq          : {upi_freq_ghz:.3f} GHz")
        else:
            upi_freq_map[socket] = 2.5

    print("-" * 55 + "\n")
    return m_freq_map, upi_freq_map

def run_and_collect(pattern_name, pattern_str, mode_name, mode_char, run_type, events):
    cmd = [
        "stdbuf", "-o0", "-e0",
        "perf", "stat", "--per-socket", "-e", events, "-I", "10", "-x", ",",
        "--",
        BIN_PATH,
        "-m", "256mb",
        "-pattern", pattern_str,
        "-freq", "2.5", # Benchmark CPU mesh flag
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

    # 1st Pass: Group all events by their exact printed timestamp
    raw_interval_data = defaultdict(lambda: defaultdict(dict))

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
                            raw_interval_data[timestamp][socket_id][event_name] = count

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
            # Fallback to 2.5 GHz if for some reason the socket wasn't detected
            freq_ghz = freq_map.get(socket_id, 2.5)

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
    print("Starting Benchmark Collection...\n")

    # Step 1: Detect actual hardware frequencies
    m_freq_map, upi_freq_map = detect_frequencies()

    # Step 2: Run benchmarks
    all_results = {}

    for pattern_name, pattern_str in NUMA_PATTERNS.items():
        all_results[pattern_name] = {}

        for mode_name, mode_char in MODES.items():
            all_results[pattern_name][mode_name] = {}
            print(f"=== Configuration: {pattern_name} ({mode_name.upper()}) ===")

            # --- RUN 1: Bandwidth ---
            bw_log = run_and_collect(pattern_name, pattern_str, mode_name, mode_char, "bw", EVENTS_BW)
            # Pass the dynamically detected memory frequency map
            bw_samples = parse_perf_log(bw_log, "unc_m_clockticks", NUM_MEM_CHANNELS, m_freq_map)

            # --- RUN 2: UPI ---
            upi_log = run_and_collect(pattern_name, pattern_str, mode_name, mode_char, "upi", EVENTS_UPI)
            # Pass the dynamically detected UPI frequency map
            upi_samples = parse_perf_log(upi_log, "unc_upi_clockticks", NUM_UPI_LINKS, upi_freq_map)

            # --- Print Stats and Capture for JSON ---
            print("\n  [Bandwidth Results]")
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
