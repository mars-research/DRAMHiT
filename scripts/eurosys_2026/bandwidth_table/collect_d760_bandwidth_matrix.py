import subprocess
import json
import re
import argparse
import statistics

def run_experiment(script_path, numa_policy, num_threads, test_pattern):
    """
    Runs the bash wrapper script for Intel platform and parses the output.
    """
    cmd = [
        "bash", script_path,
        numa_policy,
        str(num_threads),
        "intel",          # Hardcoded platform to intel
        test_pattern
    ]

    print(f"Running: {' '.join(cmd)}")

    # Run command and merge stderr into stdout to capture perf and log output
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    in_test_window = False
    prog_bandwidth = None

    # Dictionary to group perf counts by timestamp
    # Format: { timestamp_float: {'all': count, 'rd': count, 'wr': count} }
    perf_samples = {}

    # Regex patterns for Intel perf and program log output
    perf_pattern = re.compile(r'^\s*([\d\.]+)\s+([\d\,]+)\s+unc_m_cas_count\.(all|rd|wr)')
    prog_bw_pattern = re.compile(r'bandwidth:\s+([\d\.]+)\s+GB/s')

    for line in result.stdout.splitlines():
        # Track start and end window of the actual benchmark
        if "Bandwidth test start" in line:
            in_test_window = True
            continue
        elif "Bandwidth test end" in line:
            in_test_window = False
            continue

        # Parse hardware performance counter samples inside the test window
        if in_test_window:
            match = perf_pattern.search(line)
            if match:
                ts = float(match.group(1))
                counts_str = match.group(2).replace(',', '')
                counts = int(counts_str)
                evt_type = match.group(3) # 'all', 'rd', or 'wr'

                if ts not in perf_samples:
                    perf_samples[ts] = {}
                perf_samples[ts][evt_type] = counts

        # Parse program self-reported bandwidth
        prog_match = prog_bw_pattern.search(line)
        if prog_match:
            prog_bandwidth = float(prog_match.group(1))

    # Time series lists for the different operations
    hw_bw_all = []
    hw_bw_rd = []
    hw_bw_wr = []

    # Sort timestamps to calculate delta times properly
    sorted_ts = sorted(perf_samples.keys())

    # We start from index 1 because we need a previous timestamp to calculate delta_time
    for i in range(1, len(sorted_ts)):
        prev_ts = sorted_ts[i-1]
        curr_ts = sorted_ts[i]
        delta_time = curr_ts - prev_ts

        if delta_time > 0:
            counts = perf_samples[curr_ts]

            # Convert CAS count to Bandwidth in GB/s (counts * 64 bytes / (delta_time * 1e9))
            bw_all = (counts.get('all', 0) * 64) / (delta_time * 1e9)
            bw_rd = (counts.get('rd', 0) * 64) / (delta_time * 1e9)
            bw_wr = (counts.get('wr', 0) * 64) / (delta_time * 1e9)

            hw_bw_all.append(round(bw_all, 2))
            hw_bw_rd.append(round(bw_rd, 2))
            hw_bw_wr.append(round(bw_wr, 2))

    # Calculate max bandwidths
    max_hw_bw_all = max(hw_bw_all) if hw_bw_all else None
    max_hw_bw_rd = max(hw_bw_rd) if hw_bw_rd else None
    max_hw_bw_wr = max(hw_bw_wr) if hw_bw_wr else None

    # Calculate average bandwidths
    avg_hw_bw_all = round(statistics.mean(hw_bw_all), 2) if hw_bw_all else None
    avg_hw_bw_rd = round(statistics.mean(hw_bw_rd), 2) if hw_bw_rd else None
    avg_hw_bw_wr = round(statistics.mean(hw_bw_wr), 2) if hw_bw_wr else None

    return {
        "numa_policy": numa_policy,
        "test_pattern": test_pattern,
        "threads": num_threads,
        "hardware_max_bandwidth_GBps": {
            "all": max_hw_bw_all,
            "rd": max_hw_bw_rd,
            "wr": max_hw_bw_wr
        },
        "hardware_avg_bandwidth_GBps": {
            "all": avg_hw_bw_all,
            "rd": avg_hw_bw_rd,
            "wr": avg_hw_bw_wr
        },
        "program_bandwidth_GBps": prog_bandwidth,
        "raw_hw_samples": {
            "all": hw_bw_all,
            "rd": hw_bw_rd,
            "wr": hw_bw_wr
        }
    }

def main():
    parser = argparse.ArgumentParser(description="Automate and Parse DRAMHiT Bandwidth Tests (Intel)")
    parser.add_argument("--script", type=str, default="./run_dramhit_bw.sh", help="Path to your bash wrapper script")
    parser.add_argument("--out", type=str, default="bandwidth_results.json", help="Output JSON file name")
    args = parser.parse_args()

    numa_policies = [
        "single-local", "single-remote", "single-mixed",
        "dual-local", "dual-remote", "dual-even"
    ]
    workloads = ["rand_r", "seq_r", "rand_rw", "seq_rw"]

    results = []

    print("Starting DRAMHiT Benchmark Suite (24 combinations - Intel)")
    print("=" * 65)

    for numa in numa_policies:
        # Set 64 threads for single NUMA policies, 128 for dual NUMA policies
        num_threads = 128 if "dual" in numa else 64

        for workload in workloads:
            data = run_experiment(
                script_path=args.script,
                numa_policy=numa,
                num_threads=num_threads,
                test_pattern=workload
            )

            results.append(data)

            # Updated print logging to show both Max and Avg for 'all'
            hw_max_all = data['hardware_max_bandwidth_GBps']['all']
            hw_avg_all = data['hardware_avg_bandwidth_GBps']['all']
            prog_bw = data['program_bandwidth_GBps']
            print(f"  -> Result: HW Max (All) = {hw_max_all} GB/s | HW Avg (All) = {hw_avg_all} GB/s | Prog BW = {prog_bw} GB/s\n")

            # Save incrementally after each iteration
            with open(args.out, 'w') as f:
                json.dump(results, f, indent=4)

    print("=" * 65)
    print(f"Successfully ran all {len(results)} tests. Saved data to {args.out}")

if __name__ == "__main__":
    main()
