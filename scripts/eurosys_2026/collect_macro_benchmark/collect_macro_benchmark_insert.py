import os
import subprocess
import csv

# Constants
size = 268435456/2  # 2gb / 2
insertFactor = 100
readFactor = 100
numThreads = 128
numa_policy = 1

# Hash table types
DRAMHIT = 3
GROWT = 6
CLHT = 7
UMAP = 8
TBB = 9

# Fill factors
fills = list(range(10, 100, 10))

import re

def parse_metrics(output: str):
    """
    Extract set_mops and get_mops from JSON-like dramhit output lines.
    Returns a list of (set_mops, get_mops) tuples.
    """
    results = []
    # Regex to capture floating-point values for set_mops and get_mops
    pattern = re.compile(r"set_mops\s*:\s*([0-9.]+).*get_mops\s*:\s*([0-9.]+)")
    for line in output.splitlines():
        match = pattern.search(line)
        if match:
            set_val = float(match.group(1))
            get_val = float(match.group(2))
            results.append((set_val, get_val))
    return results


def run_ht_dual_once(name, ht_type, hw_pref):
    """Run all fill levels for 100 iterations and aggregate results."""
    results = {fill: {"set": [], "get": []} for fill in fills}

    run_num = 2 
    for run in range(0, run_num):  # 100 runs
        for fill in fills:
            cmd = [
                "sudo", "/opt/DRAMHiT/build/dramhit",
                "--perf_cnt_path", "./perf_cnt.txt",
                "--perf_def_path", "./perf-cpp/perf_list.csv",
                "--find_queue", "64",
                "--ht-fill", str(fill),
                "--ht-type", str(ht_type),
                "--insert-factor", str(insertFactor),
                "--read-factor", str(readFactor),
                "--read-snapshot", "1",
                "--num-threads", str(numThreads),
                "--numa-split", str(numa_policy),
                "--no-prefetch", "0",
                "--mode", "11",
                "--ht-size", str(size),
                "--skew", "0.01",
                "--hw-pref", str(hw_pref),
                "--batch-len", "16",
            ]

            proc = subprocess.run(cmd, capture_output=True, text=True)
            output = proc.stdout
        
            # Parse output lines
            set_val = None
            get_val = None
            for set_val, get_val in parse_metrics(output):
                results[fill]["set"].append(set_val)
                results[fill]["get"].append(get_val)

            if set_val is not None and get_val is not None:
                results[fill]["set"].append(set_val)
                results[fill]["get"].append(get_val)
            else: 
                raise Exception("value are empty, parsing is not right")

    # Write aggregated CSV
    os.makedirs("results", exist_ok=True)
    file_name_csv = f"results/{name}-insert.csv"
    with open(file_name_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["fill", "set_mops_avg", "get_mops_avg"])
        for fill in fills:
            set_avg = sum(results[fill]["set"]) / run_num
            get_avg = sum(results[fill]["get"]) / run_num
            writer.writerow([fill, set_avg, get_avg])

    print(f"Aggregated results written to {file_name_csv}")


def rebuild_and_run(cmake_args, name, ht_type, hw_pref):
    """Rebuild DRAMHiT with given cmake args and run benchmark."""
    subprocess.run([
        "cmake", "-S", "/opt/DRAMHiT/", "-B", "/opt/DRAMHiT/build"
    ] + cmake_args)
    subprocess.run(["cmake", "--build", "/opt/DRAMHiT/build"])
    run_ht_dual_once(name, ht_type, hw_pref)


if __name__ == "__main__":
    print('Collecting reprobe stats on: <8gb> <dual> <128 threads> ʕ•ᴥ•ʔ')

    rebuild_and_run(
        ["-DDRAMHiT_VARIANT=2023", "-DDATA_GEN=HASH", "-DBUCKETIZATION=OFF",
         "-DBRANCH=branched", "-DUNIFORM_PROBING=OFF", "-DGROWT=OFF", "-DCLHT=OFF"],
        "dramhit_2023", DRAMHIT, 0
    )

    rebuild_and_run(
        ["-DDRAMHiT_VARIANT=2025_INLINE", "-DDATA_GEN=HASH", "-DBUCKETIZATION=ON",
         "-DBRANCH=simd", "-DUNIFORM_PROBING=ON", "-DCAS_NO_ABSTRACT=ON",
         "-DREAD_BEFORE_CAS=ON"],
        "dramhit_inline_uniform", DRAMHIT, 0
    )

    rebuild_and_run(
        ["-DDATA_GEN=HASH", "-DGROWT=ON", "-DCLHT=ON", "-DCAS_NO_ABSTRACT=OFF"],
        "GROWT", GROWT, 1
    )

    rebuild_and_run(
        ["-DDATA_GEN=HASH", "-DGROWT=ON", "-DCLHT=ON", "-DCAS_NO_ABSTRACT=OFF"],
        "TBB", TBB, 1
    )

    rebuild_and_run(
        ["-DDATA_GEN=HASH", "-DGROWT=ON", "-DCLHT=ON", "-DCAS_NO_ABSTRACT=OFF"],
        "CLHT", CLHT, 1
    )
