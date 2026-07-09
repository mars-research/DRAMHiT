#!/usr/bin/env python3

import subprocess
import re
import statistics
import csv
import os

# --- Configuration ---
NUM_OPS = 1000000000
NUM_THREADS = 1
OUT_FILE = "test_out"

# Instruction mappings based on your provided usage
INST_TYPES = {
    0: "Load",
    1: "AVX512 Load",
    2: "Prefetch T0",
    3: "Prefetch T1",
    4: "Prefetch T2",
    5: "Prefetch NTA"
}

# The specific perf counters we are looking for
EXPECTED_EVENTS = [
    "ls_alloc_mab_count",
    "ls_mab_alloc.all_allocations",
    "cycles",
    "ls_sw_pf_dc_fills.all"
]

def run_benchmark():
    # Dictionary to hold all raw samples: data[inst_name][event_name] = [list of values]
    all_data = {name: {event: [] for event in EXPECTED_EVENTS} for name in INST_TYPES.values()}
    
    # Regex to capture the counter value and the event name from perf stat -I output
    # Example line: "     0.100123456           45,123 ls_alloc_mab_count"
    perf_pattern = re.compile(r'^\s*\d+\.\d+\s+([\d,]+)\s+([a-zA-Z0-9_\.]+)')

    for inst_type, inst_name in INST_TYPES.items():
        print(f"[*] Running benchmark for: {inst_name} (Type {inst_type})...")
        
        # Construct the exact command provided
        cmd = (
            f"stdbuf -oL -eL perf stat -I100 "
            f"-e ls_alloc_mab_count -e ls_mab_alloc.all_allocations "
            f"-e cycles -e ls_sw_pf_dc_fills.all "
            f"-- ./prefetch_test {inst_type} {NUM_OPS} {NUM_THREADS} > {OUT_FILE} 2>&1"
        )
        
        # Execute the command
        subprocess.run(cmd, shell=True, check=True)
        
        # Parse the output file
        collect_data = False
        
        if not os.path.exists(OUT_FILE):
            print(f"Error: {OUT_FILE} was not created.")
            continue

        with open(OUT_FILE, "r") as f:
            for line in f:
                # Wait until we see the benchmark start string
                if "--- Executing Benchmark ---" in line:
                    collect_data = True
                    continue
                
                # Only process lines if we are past the initialization phase
                if collect_data:
                    match = perf_pattern.search(line)
                    if match:
                        raw_val = match.group(1).replace(',', '')
                        event_name = match.group(2)
                        
                        try:
                            val = int(raw_val)
                            # Ensure we only track the events we care about
                            if event_name in EXPECTED_EVENTS:
                                all_data[inst_name][event_name].append(val)
                        except ValueError:
                            # Safely ignore <not counted> or corrupted lines
                            pass
                            
    return all_data

def generate_reports(all_data):
    # 1. Print formatted table to Terminal
    print("\n" + "="*95)
    print(f"{'Instruction Type':<15} | {'Event Name':<30} | {'Samples':<7} | {'Min':<10} | {'Median':<10} | {'Max':<10}")
    print("-" * 95)
    
    # Prepare data for summary CSV
    summary_rows = []
    
    for inst_name, events in all_data.items():
        for event_name, samples in events.items():
            if not samples:
                # Handle cases where an event wasn't counted or benchmark failed early
                print(f"{inst_name:<15} | {event_name:<30} | {'0':<7} | {'N/A':<10} | {'N/A':<10} | {'N/A':<10}")
                continue
                
            s_min = min(samples)
            s_max = max(samples)
            s_med = int(statistics.median(samples))
            s_count = len(samples)
            
            # Print to stdout
            print(f"{inst_name:<15} | {event_name:<30} | {s_count:<7} | {s_min:<10} | {s_med:<10} | {s_max:<10}")
            
            # Save for summary CSV
            summary_rows.append({
                "Instruction": inst_name,
                "Event": event_name,
                "Sample_Count": s_count,
                "Min": s_min,
                "Median": s_med,
                "Max": s_max
            })
            
        print("-" * 95)

    # 2. Save Statistics to CSV
    summary_file = "benchmark_summary_stats.csv"
    with open(summary_file, mode='w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["Instruction", "Event", "Sample_Count", "Min", "Median", "Max"])
        writer.writeheader()
        writer.writerows(summary_rows)
    print(f"\n[+] Summary statistics saved to: {summary_file}")

    # 3. Save Raw Samples to CSV
    raw_file = "benchmark_raw_samples.csv"
    with open(raw_file, mode='w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Instruction", "Event", "Sample_Index", "Value"])
        
        for inst_name, events in all_data.items():
            for event_name, samples in events.items():
                for idx, val in enumerate(samples):
                    writer.writerow([inst_name, event_name, idx + 1, val])
                    
    print(f"[+] Raw samples saved to: {raw_file}")

if __name__ == "__main__":
    print("Starting Benchmark Suite...")
    try:
        data = run_benchmark()
        generate_reports(data)
    except KeyboardInterrupt:
        print("\nBenchmark interrupted by user.")
    except Exception as e:
        print(f"\nAn error occurred: {e}")
