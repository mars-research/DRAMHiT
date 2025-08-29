#!/bin/python3

import os
import subprocess
import json
import re

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
    cmd = [
        "sudo", "/usr/bin/perf", "stat",
        "-e", counters_str,
        "--"
    ] + dramhit_args
    return cmd


counters = [
    "cycles",
    "l1d_pend_miss.fb_full",
    "memory_activity.cycles_l1d_miss",
    "cycle_activity.stalls_total"
]


def run(insertFactor=1, readFactor=100, numThreads=64,
        numa_policy=4, size=536870912):
    results = []
    for fill in range(10, 100, 10):
        dramhit_args = [
            os.path.join(BUILD_DIR, "dramhit"),
            "--find_queue", "64",
            "--ht-fill", str(fill),
            "--ht-type", "3",
            "--insert-factor", str(insertFactor),
            "--read-factor", str(readFactor),
            "--num-threads", str(numThreads),
            "--numa-split", str(numa_policy),
            "--no-prefetch", "0",
            "--mode", "11",
            "--ht-size", str(size),
            "--skew", "0.01",
            "--hw-pref", "0",
            "--batch-len", "16"
        ]

        cmd = make_perf_command(counters, dramhit_args)
        print("Running:", " ".join(cmd))

        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = proc.communicate()

        if proc.returncode != 0:
            print("Error:", stderr)
            continue

        results.append((stdout, stderr, fill))

    return results


def parse_results(results, counters, title):
    rows = []
    kv_pattern = re.compile(r"(\w+)\s*:\s*([\d\.]+)")
    cnt_pattern = re.compile(r"([\d,]+)\s+(\S+)")

    for stdout, stderr, fill_factor in results:
        row = {"fill_factor": fill_factor, "title": title}

        # parse stdout metrics
        metrics = {k: float(v) for k, v in kv_pattern.findall(stdout)}
        row.update(metrics)

        # parse perf counters
        counter_values = {k: None for k in counters}
        for val, name in cnt_pattern.findall(stderr):
            clean_val = int(val.replace(",", ""))
            if name in counter_values:
                counter_values[name] = clean_val
        row.update(counter_values)

        rows.append(row)

    return rows


def save_json(data, filename):
    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"[OK] Saved {filename}")


if __name__ == "__main__":
    cfgs = [
        {"DRAMHiT_VARIANT": "2023", "DATA_GEN": "HASH", "BUCKETIZATION": "OFF", "BRANCH": "branched", "UNIFORM_PROBING": "OFF"},
        {"DRAMHiT_VARIANT": "2025", "DATA_GEN": "HASH", "BUCKETIZATION": "OFF", "BRANCH": "branched", "UNIFORM_PROBING": "OFF"},
        {"DRAMHiT_VARIANT": "2023", "DATA_GEN": "HASH", "BUCKETIZATION": "ON", "BRANCH": "simd", "UNIFORM_PROBING": "OFF"},
        {"DRAMHiT_VARIANT": "2025", "DATA_GEN": "HASH", "BUCKETIZATION": "ON", "BRANCH": "simd", "UNIFORM_PROBING": "OFF"},
    ]

    all_results = []

    for cfg in cfgs:
        build(cfg)
        title = f"{cfg['DRAMHiT_VARIANT']}_{cfg['BRANCH']}_{cfg['BUCKETIZATION']}"
        outputs = run(insertFactor=1, readFactor=100)
        parsed = parse_results(outputs, counters, title)
        all_results.extend(parsed)

    # Save all results into a single JSON file
    save_json(all_results, "all_dramhit_results.json")

        


