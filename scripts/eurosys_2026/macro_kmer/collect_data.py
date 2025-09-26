import subprocess
import re
import statistics
import json
import sys
import json
import csv
from pathlib import Path
# constants
REPEAT = 1   # number of times to repeat each run
numThreads = 128
numa_policy = 1
DRAMHIT25 = 3
GROWT = 6
CLHT = 7
DRAMHIT23 = 8
TBB = 9
MODE = 4
datapath = "/opt/datasets/ERR4846928.fastq"
ht_size = 4294967296 #64GB
MAX_K=32
def run_once(cmd: str):
    """Run a command and return its stdout as string."""
    proc = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return proc.stdout, proc.stderr 

import math

def run_ht_dual(name: str, ht_type: int, hw_pref: int, results: dict):
    results[name] = []

    for k in range(4, MAX_K+1):
        print(f"Running {name} (k={k})")
        cmd_base = f"""
        /opt/DRAMHiT/build/dramhit
        --find_queue 64 --batch-len 16 --ht-type {ht_type}
        --num-threads {numThreads} --numa-split {numa_policy} --no-prefetch 0 --k {k}
        --mode {MODE} --ht-size {ht_size} --hw-pref {hw_pref}  --in-file {datapath}
        """
        cmd_base = " ".join(cmd_base.split())
        out, err = run_once("sudo " + cmd_base)
        matches = re.findall(r"mops\s*:\s*([\d.]+)", out)

        if not matches:
            print("\nError: could not parse mops values")
            print(f"Command: {cmd_base}")
            print("---- Output  ----")
            print(out)
            print(err)
            print("---- End of output ----")
            raise Exception("catch me")
        
        mops = matches[-1]
        print(f"name: {name}, k: {k}, mops: {mops}")
        results[name].append({
            "k": k,
            "mops": mops,
        })

def json_dict_to_csv(all_results, out_csv="results_flat.csv"):
    # Flatten dict-of-lists into rows with a 'table' column.
    rows = []
    fieldnames = set()

    for table_name, entries in all_results.items():
        for e in entries:
            if not isinstance(e, dict):
                # if entries are primitives, store under "value"
                row = {"table": table_name, "value": e}
            else:
                row = {"table": table_name, **e}
            rows.append(row)
            fieldnames.update(row.keys())

    # ensure deterministic column order: table first, then sorted remaining keys
    fieldnames = ["table"] + sorted(k for k in fieldnames if k != "table")

    with open(out_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for r in rows:
            # convert non-str values if necessary; DictWriter handles basic types
            writer.writerow(r)

    print(f"Wrote {len(rows)} rows to {out_csv}")
    
if __name__ == "__main__":
    # rebuild project
    #subprocess.run("rm -f /opt/DRAMHiT/build/", shell=True)
    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON "
        "-DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE -DREAD_BEFORE_CAS=ON -DGROWT=ON"
        , shell=True, check=True
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    # store results
    all_results = {}
    try:
        #run_ht_dual("dramhit", DRAMHIT23, 0, all_results)
        #run_ht_dual("dramblast", DRAMHIT25, 0, all_results)
        run_ht_dual("growt", GROWT, 1, all_results)
    except Exception as e:
        # save to JSON
        print("error occured")
    finally:
        json_dict_to_csv(all_results)
