#!/bin/python3

import os
import subprocess
import json
import re
import sys

SOURCE_DIR = "/opt/DRAMHiT"
BUILD_DIR = "/opt/DRAMHiT/build"
USE_PERF = False

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
    "br_inst_retired.all_branches",
    "uops_issued.any",
    "br_misp_retired.all_branches"
]

def run(run_cfg):
    results = []

    dramhit_args = [
        os.path.join(BUILD_DIR, "dramhit"),
        "--find_queue", "64",
        "--ht-fill", str(run_cfg["fill_factor"]),
        "--ht-type", "3",
        "--insert-factor", str(run_cfg["insertFactor"]),
        "--read-factor", str(run_cfg["readFactor"]),
        "--num-threads", str(run_cfg["numThreads"]),
        "--numa-split", str(run_cfg["numa_policy"]),
        "--no-prefetch", "0",
        "--mode", "14",
        "--ht-size", str(run_cfg["size"]),
        "--skew", "0.01",
        "--hw-pref", "0",
        "--batch-len", "16"
    ]

    cmd = []
    if USE_PERF:
        cmd = make_perf_command(counters, dramhit_args)
    else:
        cmd = ["sudo"] + dramhit_args
        
    print("Running:", " ".join(cmd))

    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, stderr = proc.communicate()

    if proc.returncode != 0:
        print("Error:", stderr)
        return None

    return (stdout, stderr)



def parse_results(result, counters, run_cfg, build_cfg, identifier):
    """
    Parse a single run's output (stdout, stderr) into a single dictionary.

    Parameters
    ----------
    result    : tuple (stdout, stderr)
    counters  : list of perf counter names to extract
    run_cfg   : dict (runtime configuration)
    build_cfg : dict (build configuration)  

    Returns
    -------
    dict : one consolidated record
    """
    stdout, stderr = result

    # Helper: stable string for configs
    def dict_to_str(d):
        return "-".join(f"{k}={d[k]}" for k in sorted(d.keys()))

    row = {
        "build_cfg": build_cfg,                 # full dict
        "build_cfg_str": dict_to_str(build_cfg),
        "run_cfg": run_cfg,                     # full dict
        "run_cfg_str": dict_to_str(run_cfg),
        "identifier": identifier,
    }

    # Parse stdout metrics like: { set_mops : 320000.000, get_mops : 4250.550, ... }
    kv_pattern = re.compile(r"(\w+)\s:\s([\d\.]+)")
    metrics = {k: float(v) for k, v in kv_pattern.findall(stdout)}
    row.update(metrics)

    # Parse perf counters from stderr
    
    if USE_PERF:
        cnt_pattern = re.compile(r"([\d,]+)\s+(\S+)")
        counter_dic = {k: None for k in counters}
        for val, name in cnt_pattern.findall(stderr):
            clean_val = int(val.replace(",", ""))
            if name in counters:
                counter_dic[name] = clean_val
        row.update(counter_dic)

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

    # Build configurations
    build_cfgs = [
        {"DRAMHiT_VARIANT": "2025", "READ_BEFORE_CAS" : "OFF", "CAS_FAST_PATH" : "OFF", "CAS_NO_ABSTRACT" : "OFF", "DATA_GEN": "HASH", "BUCKETIZATION": "ON", "BRANCH": "branched", "UNIFORM_PROBING": "OFF"},
        {"DRAMHiT_VARIANT": "2025", "READ_BEFORE_CAS" : "ON", "CAS_FAST_PATH" : "OFF", "CAS_NO_ABSTRACT" : "OFF", "DATA_GEN": "HASH", "BUCKETIZATION": "ON", "BRANCH": "branched", "UNIFORM_PROBING": "OFF"},
    ]

    run_cfgs = [
    {"insertFactor": 10, "readFactor": 1, "numThreads": 64, "numa_policy": 4, "size": 536870912, "fill_factor": f}
    for f in range(10, 100, 10)
] + [
    {"insertFactor": 10, "readFactor": 1, "numThreads": 128, "numa_policy": 1, "size": 536870912, "fill_factor": f}
    for f in range(10, 100, 10)
]

    all_results = []
    
    def get_name(bcfg):
        keys = ["READ_BEFORE_CAS"] 
        ret = ""
        for k in keys:
            ret += "{" + k + "-" + bcfg[k] + "}" 
        
        return ret

    for bcfg in build_cfgs:
        build(bcfg)
        for rcfg in run_cfgs:
            output = run(rcfg)
            obj = parse_results(output, counters, rcfg, bcfg, get_name(bcfg))
            all_results.append(obj)

    # Save all results into a single JSON file
    save_json(all_results, out_file)
