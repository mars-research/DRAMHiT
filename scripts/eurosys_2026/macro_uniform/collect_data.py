import subprocess
import re
import statistics
import json
import sys

numThreads = 128
numa_policy = 1
DRAMHIT25 = 3
GROWT = 6
DRAMHIT23 = 8
MODE = 14

fill = 30
op = 300647680

def run_once(cmd: str):
    """Run a command and return its stdout as string."""
    proc = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return proc.stdout, proc.stderr 

def run_ht_dual(name: str, ht_type: int
                , hw_pref: int, results: dict):
    results[name] = []
    fills = [10,30,50,70]
    for fill in range(10,100,20): 
        basesize = int(1024 * 1024 * 1024 / 32) # 1GB, 2GB, 4GB, 8GB, 16GB 
        for exp in range(4, 6, 1):
            htsize = int(basesize << exp)
            repeat = 100
            cmd_base = f"""
            /opt/DRAMHiT/build/dramhit
            --find_queue 64 
            --ht-type {ht_type}
            --num-threads {numThreads} 
            --numa-split {numa_policy} 
            --no-prefetch 0 
            --insert-factor {repeat}
            --read-factor {repeat}
            --mode {MODE} 
            --ht-size {htsize} 
            --ht-fill {fill}
            --hw-pref {hw_pref} 
            --batch-len 16
            """
            cmd_base = " ".join(cmd_base.split())  # clean whitespace
            
            print(cmd_base)

            out, err = run_once("sudo " + cmd_base)
            setmatch = re.findall(r"set_mops\s*:\s*([\d.]+)", out)
            getmatch = re.findall(r"get_mops\s*:\s*([\d.]+)", out)

            if not setmatch or not getmatch:
                print("\nError: could not parse mops values")
                print(f"Command: {cmd_base}")
                print("---- Output  ----")
                print(out)
                print(err)
                print("---- End of output ----")
                sys.exit(1)
                
            results[name].append({
                "fill": fill,
                "htsize": htsize,
                "set_mops": setmatch[-1],
                "get_mops": getmatch[-1],
            })
            print(f"fill: {fill}, table sz: {int(htsize*16/(1<<30))} GB, set mops: {setmatch[-1]}, get mops: {getmatch[-1]}")


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    json_out_file = sys.argv[1]
    # rebuild project
    subprocess.run("rm -f /opt/DRAMHiT/build/", shell=True)
    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON "
        "-DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON "
        "-DGROWT=ON", shell=True, check=True
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    # store results
    all_results = {}

    run_ht_dual("dramhit_2023", DRAMHIT23, 0, all_results)
    run_ht_dual("dramhit_2025", DRAMHIT25, 0, all_results)
    run_ht_dual("GROWT", GROWT, 1, all_results)
    # save to JSON
    with open(json_out_file, "w") as f:
        json.dump(all_results, f, indent=2)

    print("\nFinal results saved to "+json_out_file)
