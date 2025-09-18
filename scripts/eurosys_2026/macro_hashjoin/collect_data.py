import subprocess
import re
import statistics
import json
import sys

# constants
REPEAT = 1   # number of times to repeat each run
base_size = 268435456
numThreads = 128
numa_policy = 1

DRAMHIT25 = 3
GROWT = 6
CLHT = 7
DRAMHIT23 = 8
TBB = 9
MODE = 13
fill = 0.7
#htsize = 4096

htsize = 268435456


def run_once(cmd: str):
    """Run a command and return its stdout as string."""
    proc = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return proc.stdout, proc.stderr 

import math

def run_ht_dual(name: str, ht_type: int, hw_pref: int, results: dict):
    # htsizes = [base_size // (2**i) for i in range(10)]
    results[name] = []

    for fill in range(10, 80,10):
        rsize = int(htsize * fill/100.0) // numThreads * numThreads
        print(f"Running {name} (htsize={htsize}, rsize={rsize})")

        cmd_base = f"""
        /opt/DRAMHiT/build/dramhit
        --find_queue 64 --ht-type {ht_type}
        --num-threads {numThreads} --numa-split {numa_policy} --no-prefetch 0
        --mode {MODE} --ht-size {htsize} --hw-pref {hw_pref} --batch-len 16 --relation_r_size {rsize}
        """
        cmd_base = " ".join(cmd_base.split())  # clean whitespace

        mops = []
        for r in range(REPEAT):
            out, err = run_once("sudo " + cmd_base)
            matches = re.findall(r"mops\s*:\s*([\d.]+)", out)
            print(out)

            if not matches:
                print("\nError: could not parse mops values")
                print(f"Command: {cmd_base}")
                print(f"Repeat #{r+1} / {REPEAT}, htsize={htsize}, ht={name}")
                print("---- Output  ----")
                print(out)
                print(err)
                print("---- End of output ----")
                sys.exit(1)

            mops.append(float(matches[-1]))

        avg = round(statistics.mean(mops), 1)
        results[name].append({
            "rsize": rsize,
            "htsize": htsize,
            "mops": avg,
        })


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    json_out_file = sys.argv[1]
    # rebuild project
    subprocess.run("rm -f /opt/DRAMHiT/build/", shell=True)
    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON "
        "-DGROWT=ON -DCLHT=ON", shell=True, check=True
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    # store results
    all_results = {}

    run_ht_dual("dramhit_2023", DRAMHIT23, 0, all_results)
    #run_ht_dual("dramhit_2025", DRAMHIT25, 0, all_results)
    #run_ht_dual("GROWT", GROWT, 1, all_results)
    #run_ht_dual("CLHT", CLHT, 1, all_results)
    #run_ht_dual("TBB", TBB, 1, all_results)

    # save to JSON
    with open(json_out_file, "w") as f:
        json.dump(all_results, f, indent=2)

    print("\nFinal results saved to "+json_out_file)
