#!/usr/bin/env python3

import json
import os
import subprocess
import sys

# --- Configuration ---
SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"

# Path to the bandwidth collector script we just created
BW_COLLECTOR_SCRIPT = "/opt/DRAMHiT/scripts/eurosys_2026/collect_bandwidth/bw_collector.py"

def build(defines):
    """Compiles the DRAMHiT application with the provided definitions."""
    define_flags = [f"-D{k}={v}" for k, v in defines.items()]
    cmake_cmd = ["cmake", "-S", SOURCE_DIR, "-B", BUILD_DIR] + define_flags
    build_cmd = ["cmake", "--build", BUILD_DIR]

    print("Running:", " ".join(cmake_cmd))
    subprocess.run(cmake_cmd, check=True)

    print("Running:", " ".join(build_cmd))
    subprocess.run(build_cmd, check=True)

def run_bw_collection(dramhit_args, start_marker, end_marker):
    """
    Executes the dramhit application wrapped by bw_collector.py
    to extract bandwidth over a specific region of interest.
    """
    cmd = [
        BW_COLLECTOR_SCRIPT,
        "--start", start_marker,
        "--end", end_marker,
        "--"
    ] + dramhit_args

    print(f"Executing: {' '.join(cmd)}")

    # Capture standard output (JSON) and standard error (logs) from bw_collector.py
    proc = subprocess.run(cmd, capture_output=True, text=True)

    if proc.returncode != 0:
        print(f"Error running bw_collector (Return Code {proc.returncode}):", file=sys.stderr)
        print(proc.stderr, file=sys.stderr)
        return None

    # Parse the resulting JSON from bw_collector's stdout
    try:
        data = json.loads(proc.stdout)
        return data.get("results", {})
    except json.JSONDecodeError:
        print("Failed to decode JSON from bw_collector. Raw Output:", file=sys.stderr)
        print(proc.stdout, file=sys.stderr)
        return None

def save_json(data, filename):
    """Saves the aggregated results to the output file."""
    with open(filename, "w") as f:
        json.dump(data, f, indent=4)
    print(f"\n[OK] Saved all aggregated results to {filename}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: sudo python3 run_experiments.py <output_results.json>")
        sys.exit(1)

    out_file = sys.argv[1]

    # --- Experiment Matrix ---
    build_cfgs = [
        {
            "DRAMHiT_VARIANT": "2025_INLINE",
            "BUCKETIZATION": "ON",
            "BRANCH": "simd",
            "UNIFORM_PROBING": "ON",
            "PREFETCH": "DOUBLE",
            "CPUFREQ_MHZ": "2500",
        },
    ]

    run_cfgs = [
        {
            "insertFactor": 1,
            "readFactor": 1,
            "numThreads": 128,
            "numa_policy": 1,
            "size": 536870912,
            "fill_factor": f,
        }
        for f in range(10, 20, 10)  # Fill factors from 10 to 90
    ]

    all_results = []

    def dict_to_str(d):
        return "-".join(f"{k}={d[k]}" for k in sorted(d.keys()))

    def get_name(bcfg):
        ret = bcfg["DRAMHiT_VARIANT"]
        for k, v in bcfg.items():
            if k == "BUCKETIZATION" and v == "ON":
                ret += "+bucket"
            elif k == "BRANCH" and v == "simd":
                ret += "+simd"
            elif k == "UNIFORM_PROBING" and v == "ON":
                ret += "+uniform"
        return ret

    # --- Run Loop ---
    for bcfg in build_cfgs:
        build(bcfg)
        identifier = get_name(bcfg)
        build_cfg_str = dict_to_str(bcfg)

        for rcfg in run_cfgs:
            dramhit_args = [
                os.path.join(BUILD_DIR, "dramhit"),
                "--find_queue", "64",
                "--ht-fill", str(rcfg["fill_factor"]),
                "--ht-type", "3",
                "--insert-factor", str(rcfg["insertFactor"]),
                "--read-factor", str(rcfg["readFactor"]),
                "--num-threads", str(rcfg["numThreads"]),
                "--numa-split", str(rcfg["numa_policy"]),
                "--no-prefetch", "0",
                "--mode", "11",
                "--ht-size", str(rcfg["size"]),
                "--hw-pref", "0",
                "--batch-len", "16",
            ]

            print(f"\n{'='*55}")
            print(f"Testing Configuration: {identifier} | Fill Factor: {rcfg['fill_factor']}")
            print(f"{'='*55}")

            # ---------------------------------------------------------
            # Run 1: Collect bandwidth during the INSERT phase (Write)
            # ---------------------------------------------------------
            print(">> Collecting Insert Phase Bandwidth (Write-Heavy)...")
            insert_start = "zipfian test insert start"
            insert_end = "zipfian test insert end"
            insert_bw_stats = run_bw_collection(dramhit_args, insert_start, insert_end)

            # ---------------------------------------------------------
            # Run 2: Collect bandwidth during the FIND phase (Read)
            # ---------------------------------------------------------
            print(">> Collecting Find Phase Bandwidth (Read-Heavy)...")
            find_start = "zipfian test find start"
            find_end = "zipfian test find end"
            find_bw_stats = run_bw_collection(dramhit_args, find_start, find_end)

            # --- Merge logic ---
            row = {
                "identifier": identifier,
                "build_cfg": bcfg,
                "build_cfg_str": build_cfg_str,
                "run_cfg": rcfg,
                "run_cfg_str": dict_to_str(rcfg),
                "insert_phase_bw": insert_bw_stats,
                "find_phase_bw": find_bw_stats,
            }

            all_results.append(row)

    # Save final aggregated results
    save_json(all_results, out_file)
