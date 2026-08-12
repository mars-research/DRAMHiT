import subprocess
import json
import re
import statistics
import argparse

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
    hw_time_series = []
    prog_bandwidth = None

    # Regex patterns for Intel perf and program log output
    perf_pattern = re.compile(r'^\s*([\d\.]+)\s+([\d\,]+)\s+unc_m_cas_count\.all')
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
                counts_str = match.group(2).replace(',', '')
                counts = int(counts_str)

                # Convert CAS count to Bandwidth in GB/s (counts * 64 bytes / 1e9)
                bw_gbps = (counts * 64) / 1e9
                hw_time_series.append(bw_gbps)

        # Parse program self-reported bandwidth
        prog_match = prog_bw_pattern.search(line)
        if prog_match:
            prog_bandwidth = float(prog_match.group(1))

    # Pick the "middle" (stable) hardware bandwidth using the median
    stable_hw_bandwidth = None
    if hw_time_series:
        # Ignore the first and last 1-second sample to strip ramp-up / cool-down noise
        stable_samples = hw_time_series[1:-1] if len(hw_time_series) > 2 else hw_time_series
        stable_hw_bandwidth = round(statistics.median(stable_samples), 2)

    return {
        "numa_policy": numa_policy,
        "test_pattern": test_pattern,
        "threads": num_threads,
        "hardware_bandwidth_GBps": stable_hw_bandwidth,
        "program_bandwidth_GBps": prog_bandwidth,
        "raw_hw_samples": [round(x, 2) for x in hw_time_series]
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

            hw_bw = data['hardware_bandwidth_GBps']
            prog_bw = data['program_bandwidth_GBps']
            print(f"  -> Result: HW BW = {hw_bw} GB/s | Prog BW = {prog_bw} GB/s\n")

            # Save incrementally after each iteration
            with open(args.out, 'w') as f:
                json.dump(results, f, indent=4)

    print("=" * 65)
    print(f"Successfully ran all {len(results)} tests. Saved data to {args.out}")

if __name__ == "__main__":
    main()
