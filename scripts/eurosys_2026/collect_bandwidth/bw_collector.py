#!/usr/bin/env python3
import subprocess
import sys
import statistics
import json
import argparse
from collections import defaultdict

# --- Configuration ---
# Included clockticks for accurate hardware timing
EVENTS_BW = "unc_m_cas_count.all,unc_m_cas_count.rd,unc_m_cas_count.wr,unc_m_clockticks"

NUM_MEM_CHANNELS = 8

# --- Conversion Factors ---
EVENT_CONVERSIONS = {
    "unc_m_cas_count.all": 64,          # 64 bytes per cache line
    "unc_m_cas_count.rd": 64,
    "unc_m_cas_count.wr": 64,
}

def print_err(*args, **kwargs):
    """Helper to print logs to stderr to keep stdout clean for JSON output."""
    print(*args, file=sys.stderr, **kwargs)

def detect_frequencies():
    """
    Runs a 1-second perf measurement to dynamically calculate the actual
    hardware frequency of the Memory Controllers per socket.
    """
    cmd = [
        "perf", "stat", "-a", "--per-socket",
        "-e", "unc_m_clockticks",
        "-x", ",",
        "sleep", "1"
    ]

    print_err("Dynamically detecting memory controller frequencies (1-second sleep)...")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print_err("Error detecting frequencies. Make sure you run with sudo/appropriate permissions.")
        print_err(result.stderr)
        print_err("Falling back to defaults: Memory=2.6GHz")
        return defaultdict(lambda: 2.6)

    lines = result.stderr.strip().split('\n')
    m_ticks = {}
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

    m_freq_map = {}
    print_err(f"Detection Elapsed Time: {elapsed_time:.4f} seconds")
    print_err("-" * 55)

    for socket in sorted(m_ticks.keys()):
        total_m = m_ticks[socket]
        per_channel = total_m / NUM_MEM_CHANNELS
        m_freq_ghz = (per_channel / elapsed_time) / 1_000_000_000
        m_freq_map[socket] = m_freq_ghz
        print_err(f"Socket: {socket} | Memory Controller Freq: {m_freq_ghz:.3f} GHz")

    print_err("-" * 55)
    return m_freq_map

def run_and_collect(command, start_marker, end_marker, freq_map, interval):
    """
    Wraps the user command with stdbuf and perf stat, streaming output to check for markers.
    """
    cmd = [
        "stdbuf", "-o0", "-e0",
        "perf", "stat", "--per-socket", "-e", EVENTS_BW, "-I", str(interval), "-x", ",",
        "--"
    ] + command

    print_err(f"Executing: {' '.join(cmd)}")

    # Merge stdout and stderr so we capture both the application's markers and perf's logs
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )

    in_collection = False
    raw_interval_data = defaultdict(lambda: defaultdict(dict))

    for line in process.stdout:
        line = line.strip()
        if not line:
            continue

        if start_marker in line:
            in_collection = True
            print_err("[MARKER] Started perf collection.")
            continue
        elif end_marker in line:
            in_collection = False
            print_err("[MARKER] Ended perf collection.")
            continue

        if in_collection:
            parts = line.split(",")
            # Perf format with -x, -I: <timestamp>,<socket>,<cores>,<count>,<unit>,<event>
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

    process.wait()

    # Calculate GB/s using the detected hardware frequencies
    samples = defaultdict(lambda: defaultdict(list))
    clock_event_name = "unc_m_clockticks"

    for timestamp, sockets in sorted(raw_interval_data.items()):
        for socket_id, events in sockets.items():

            if clock_event_name not in events:
                continue

            total_clockticks = events[clock_event_name]
            if total_clockticks <= 0:
                continue

            # Divide by the number of channels to get the true ticks per channel
            true_clockticks = total_clockticks / NUM_MEM_CHANNELS
            freq_ghz = freq_map.get(socket_id, 2.6) # Fallback to 2.6 if undetected

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

def calculate_statistics(samples):
    stats_dict = {}

    if not samples:
        print_err("Warning: No valid samples collected between the specified markers.")
        return stats_dict

    for socket_id, events in sorted(samples.items()):
        stats_dict[socket_id] = {}

        for event, values in events.items():
            if not values:
                continue

            stats_dict[socket_id][event] = {
                "sample_points": len(values), # Added sample points count here
                "mid": values[len(values) // 2],
                "avg": statistics.mean(values),
                "min": min(values),
                "max": max(values)
            }

    return stats_dict

def main():
    parser = argparse.ArgumentParser(description="General Purpose Memory Bandwidth Profiler")
    parser.add_argument("--start", required=True, help="String marker in stdout/stderr to START data collection.")
    parser.add_argument("--end", required=True, help="String marker in stdout/stderr to END data collection.")
    parser.add_argument("--interval", type=int, default=10, help="Perf collection interval in milliseconds (default: 10).")
    parser.add_argument("command", nargs=argparse.REMAINDER, help="The program and its arguments to execute")

    args = parser.parse_args()

    # Clean up the command array if '--' was passed to separate args
    user_command = args.command
    if user_command and user_command[0] == "--":
        user_command = user_command[1:]

    if not user_command:
        print_err("Error: You must provide a command to execute.")
        sys.exit(1)

    print_err("Starting Benchmark Collection...\n")

    # Step 1: Detect actual hardware frequencies
    m_freq_map = detect_frequencies()

    # Step 2: Run benchmarks & parse
    bw_samples = run_and_collect(user_command, args.start, args.end, m_freq_map, args.interval)

    # Step 3: Calculate stats
    bw_stats = calculate_statistics(bw_samples)
    final_output = {
        "command": " ".join(user_command),
        "interval_ms": args.interval,
        "results": bw_stats
    }

    # Step 4: Dump JSON to stdout
    print(json.dumps(final_output, indent=4))

if __name__ == "__main__":
    main()
