#!/bin/python3

import json
import os
import re
import statistics
import subprocess
import sys

SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"


def build(defines):
    define_flags = [f"-D{k}={v}" for k, v in defines.items()]
    cmake_cmd = ["cmake", "-S", SOURCE_DIR, "-B", BUILD_DIR] + define_flags
    build_cmd = ["cmake", "--build", BUILD_DIR]

    print("Running:", " ".join(cmake_cmd))
    subprocess.run(cmake_cmd, check=True)

    print("Running:", " ".join(build_cmd))
    subprocess.run(build_cmd, check=True)


def make_perf_command(counters, dramhit_args):
    counters_str = ",".join(counters)
    cmd = ["perf", "stat", "-I", "1000", "-e", counters_str, "--"] + dramhit_args
    return cmd


counters = [
    "cycles",
    "l1d_pend_miss.fb_full",  # cycles demand load has waited to enter lfb.
    "exe_activity.bound_on_loads",  # numbers of stalls due to demand load is outstanding
    "cycle_activity.stalls_total",  # total number of stalls
]


def run(run_cfg):
    fill = run_cfg["fill_factor"]
    dramhit_args = [
        os.path.join(BUILD_DIR, "dramhit"),
        "--find_queue",
        "64",
        "--ht-fill",
        str(fill),
        "--ht-type",
        "3",
        "--insert-factor",
        str(run_cfg["insertFactor"]),
        "--read-factor",
        str(run_cfg["readFactor"]),
        "--num-threads",
        str(run_cfg["numThreads"]),
        "--numa-split",
        str(run_cfg["numa_policy"]),
        "--no-prefetch",
        "0",
        "--mode",
        "11",
        "--ht-size",
        str(run_cfg["size"]),
        "--skew",
        "0.01",
        "--hw-pref",
        "0",
        "--batch-len",
        "16",
        "--seed",
        "1776656037950831164",
    ]

    cmd = make_perf_command(counters, dramhit_args)
    print("Running:", " ".join(cmd))

    # Redirect stderr to stdout to merge the streams chronologically
    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    merged_output, _ = proc.communicate()

    print(merged_output)
    if proc.returncode != 0:
        print("Error during execution. Check output above.")
        return None

    return merged_output


def parse_results(merged_output, counters, run_cfg, build_cfg, identifier):
    """
    Parse a single run's merged output into a single dictionary.

    Parameters
    ----------
    merged_output : str (combined stdout and stderr)
    counters      : list of perf counter names to extract
    run_cfg       : dict (runtime configuration)
    build_cfg     : dict (build configuration)
    identifier    : str

    Returns
    -------
    dict : one consolidated record
    """

    # Helper: stable string for configs
    def dict_to_str(d):
        return "-".join(f"{k}={d[k]}" for k in sorted(d.keys()))

    row = {
        "build_cfg": build_cfg,
        "build_cfg_str": dict_to_str(build_cfg),
        "run_cfg": run_cfg,
        "run_cfg_str": dict_to_str(run_cfg),
        "identifier": identifier,
    }

    # 1. Parse program metrics (e.g., { set_mops : 320000.000 ... })
    kv_pattern = re.compile(r"(\w+)\s:\s([\d\.]+)")
    metrics = {k: float(v) for k, v in kv_pattern.findall(merged_output)}
    row.update(metrics)

    # 2. Capture Overall Summary
    # By iterating through all matches, the dictionary naturally keeps the last
    # seen value, which corresponds to the final perf summary block at the end.
    cnt_pattern = re.compile(r"([\d,]+)\s+(\S+)")
    counter_dic = {k: None for k in counters}
    for val, name in cnt_pattern.findall(merged_output):
        clean_val = int(val.replace(",", ""))
        if name in counters:
            counter_dic[name] = clean_val
    row.update(counter_dic)

    # 3. Capture and process interval samples between markers
    state = None
    samples = {"find": {c: [] for c in counters}, "insert": {c: [] for c in counters}}

    # Matches interval lines e.g.: "  4.006025360    139,817,801,090      cycles"
    interval_pattern = re.compile(r"^\s*[\d\.]+\s+([\d,]+)\s+([\w\.-]+)")

    for line in merged_output.splitlines():
        if "zipfian test find start" in line:
            state = "find"
            continue
        elif "zipfian test find end" in line:
            state = None
            continue
        elif "zipfian test insert start" in line:
            state = "insert"
            continue
        elif "zipfian test insert end" in line:
            state = None
            continue

        if state:
            match = interval_pattern.search(line)
            if match:
                val_str, name = match.groups()
                if name in counters:
                    clean_val = int(val_str.replace(",", ""))
                    samples[state][name].append(clean_val)

    # 4. Calculate min, max, avg, and median for each phase
    for phase in ["find", "insert"]:
        for c in counters:
            data = samples[phase][c]
            prefix = f"{phase}_{c}"

            if data:
                row[f"{prefix}_avg"] = statistics.mean(data)
                row[f"{prefix}_median"] = statistics.median(data)
                row[f"{prefix}_max"] = max(data)
                row[f"{prefix}_min"] = min(data)
            else:
                row[f"{prefix}_avg"] = None
                row[f"{prefix}_median"] = None
                row[f"{prefix}_max"] = None
                row[f"{prefix}_min"] = None

    return row


def save_json(data, filename):
    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"[OK] Saved {filename}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    out_file = sys.argv[1]

    # subprocess.run("rm -f /opt/DRAMHiT/build/", shell=True)
    # Build configurations
    build_cfgs = [
        {
            "DRAMHiT_VARIANT": "2023",
            "PREFETCH": "L1",
            "BUCKETIZATION": "ON",
            "BRANCH": "simd",
            "UNIFORM_PROBING": "ON",
            "CPUFREQ_MHZ": "2500",
        },
        {
            "DRAMHiT_VARIANT": "2025",
            "PREFETCH": "L1",
            "BUCKETIZATION": "ON",
            "BRANCH": "simd",
            "UNIFORM_PROBING": "ON",
            "CPUFREQ_MHZ": "2500",
        },
    ]

    run_cfgs = [
        {
            "insertFactor": 10,
            "readFactor": 1000,
            "numThreads": 64,
            "numa_policy": 4,
            "size": 536870912,
            "fill_factor": 10,
        },
        {
            "insertFactor": 10,
            "readFactor": 1000,
            "numThreads": 64,
            "numa_policy": 4,
            "size": 536870912,
            "fill_factor": 70,
        },
        # for f in range(10, 20, 10)
    ]

    def get_name(bcfg):
        return bcfg["DRAMHiT_VARIANT"]

    all_results = []

    for bcfg in build_cfgs:
        build(bcfg)
        for rcfg in run_cfgs:
            merged_output = run(rcfg)
            if merged_output:
                obj = parse_results(merged_output, counters, rcfg, bcfg, get_name(bcfg))
                all_results.append(obj)

    # Save all results into a single JSON file
    save_json(all_results, out_file)
