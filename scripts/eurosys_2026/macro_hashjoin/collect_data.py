import json
import re
import subprocess
import sys

numThreads = 128
numa_policy = 1
DRAMHIT25 = 3
GROWT = 6
DRAMHIT23 = 8
TBB = 9
MODE = 13
fill = 70
base = int(1024 * 1024 * 1024 / 16)  # 1GB, 2GB, 4GB, 8GB


def run_once(cmd: str):
    """Run a command and return its stdout as string."""
    proc = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    return proc.stdout, proc.stderr


def run_ht_dual(name: str, ht_type: int, hw_pref: int, results: dict):
    # htsizes = [base_size // (2**i) for i in range(10)]
    results[name] = []
    for fill in [10, 70]:
        for exp in range(0, 4, 1):
            htsize = int(base << exp)
            rsize = int((htsize * float(fill / 100)) // numThreads * numThreads)
            repeat = 100

            cmd_base = f"""
            /opt/DRAMHiT/build/dramhit
            --find_queue 64 --ht-type {ht_type}
            --num-threads {numThreads} --numa-split {numa_policy}
            --no-prefetch 0 --insert-factor {repeat}
            --mode {MODE} --ht-fill {ht_fill}
            --batch-len 16 --relation_r_size {rsize}
            --relation_s_size {ssize}
            """
            cmd_base = " ".join(cmd_base.split())  # clean whitespace

            print(cmd_base)

            out, err = run_once("sudo " + cmd_base)
            matches = re.findall(r"mops\s*:\s*([\d.]+)", out)

            if not matches:
                print("\nError: could not parse mops values")
                print(f"Command: {cmd_base}")
                print("---- Output  ----")
                print(out)
                print(err)
                print("---- End of output ----")
                sys.exit(1)

            mops = matches[-1]
            print(f"htsize={htsize} fill={fill} mops={mops}")
            results[name].append(
                {"rsize": rsize, "htsize": htsize, "mops": mops, "fill": fill}
            )


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
        "-DGROWT=ON",
        shell=True,
        check=True,
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

    print("\nFinal results saved to " + json_out_file)
