#!/usr/bin/env python3
import sys
import argparse
import subprocess
import re
import json
import matplotlib.pyplot as plt
import numpy as np

def run_dramhit(skew_val):
    cmd = [
        "/opt/DRAMHiT/build/dramhit",
        "--ht-type", "3",
        "--ht-fill", "50",
        "--relation_r_size", "67108864",
        "--relation_s_size", "1006632960",
        "--num-threads", "128",
        "--numa-split", "1",
        "--mode", "16",
        "--skew", str(skew_val),
        "--seed", "1774551337382868027",
        "--radix", "11",
        "--associativity", "1.0"
    ]

    print(f"Running command: {' '.join(cmd)}")
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return result.stdout

def parse_output(output_text):
    pattern = re.compile(r'tid:\s*(\d+),\s*insert:\s*(\d+),\s*find:\s*(\d+)')

    records = []
    for line in output_text.splitlines():
        match = pattern.search(line)
        if match:
            tid, insert_cnt, find_cnt = map(int, match.groups())
            records.append((tid, insert_cnt, find_cnt))

    if not records:
        print("Error: No matching logs found in program output.")
        sys.exit(1)

    # Sort strictly by thread ID (tid 0 to x)
    records.sort(key=lambda x: x[0])

    tids = np.array([r[0] for r in records])
    inserts = np.array([r[1] for r in records])
    finds = np.array([r[2] for r in records])

    return tids, inserts, finds

def plot_per_tid(tids, values, metric_name, skew_val):
    plt.figure(figsize=(12, 6))

    # Calculate statistics
    min_val, max_val = np.min(values), np.max(values)
    median_val = np.median(values)

    max_tid = tids[np.argmax(values)]
    min_tid = tids[np.argmin(values)]

    # Plot bar chart: X = Thread ID (0 to x), Y = Metric Count
    plt.bar(tids, values, color='skyblue', edgecolor='navy', alpha=0.7, width=0.8)

    # Horizontal reference lines for Min, Max, Median across all TIDs
    plt.axhline(max_val, color='red', linestyle='--', linewidth=1.5, label=f'Max: {max_val:,.0f} (tid {max_tid})')
    plt.axhline(median_val, color='green', linestyle='-', linewidth=1.5, label=f'Median: {median_val:,.0f}')
    plt.axhline(min_val, color='orange', linestyle='--', linewidth=1.5, label=f'Min: {min_val:,.0f} (tid {min_tid})')

    plt.title(f'Per-Thread {metric_name.capitalize()} Distribution (Skew: {skew_val})')
    plt.xlabel('Thread ID (tid)')
    plt.ylabel(f'Total {metric_name.capitalize()} Count')
    plt.legend(loc='upper right')
    plt.grid(True, linestyle=':', alpha=0.5)

    filename = f"tid_vs_{metric_name}_skew_{skew_val}.png"
    plt.savefig(filename, bbox_inches='tight')
    plt.close()

    print(f"\n--- {metric_name.upper()} Summary ---")
    print(f"Max {metric_name}: {max_val:,} on tid {max_tid}")
    print(f"Min {metric_name}: {min_val:,} on tid {min_tid}")
    print(f"Median {metric_name}: {median_val:,.1f}")
    print(f"Saved plot to {filename}")

def main():
    parser = argparse.ArgumentParser(description="Plot per-thread Insert/Find distributions from DRAMHiT output.")
    parser.add_argument("--skew", type=float, required=True, help="Skew parameter for dramhit")
    args = parser.parse_args()

    # 1. Run binary
    output = run_dramhit(args.skew)

    # 2. Parse results
    tids, inserts, finds = parse_output(output)
    print(f"\nSuccessfully parsed {len(tids)} threads (tid {tids[0]} to {tids[-1]}).")

    # 3. Save parsed data to JSON
    json_data = {
        "skew": args.skew,
        "threads": []
    }

    for t, i, f in zip(tids, inserts, finds):
        # We explicitly cast to int() because numpy data types (like np.int64)
        # are not natively JSON serializable
        json_data["threads"].append({
            "tid": int(t),
            "insert": int(i),
            "find": int(f)
        })

    json_filename = f"tid_distribution_skew_{args.skew}.json"
    with open(json_filename, "w") as json_file:
        json.dump(json_data, json_file, indent=4)
    print(f"Saved data to {json_filename}")

    # 4. Plot per-tid graphs for Inserts and Finds
    plot_per_tid(tids, inserts, "insert", args.skew)
    plot_per_tid(tids, finds, "find", args.skew)

if __name__ == "__main__":
    main()
