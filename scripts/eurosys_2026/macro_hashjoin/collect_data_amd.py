import json
import re
import subprocess
import sys
from webbrowser import get

DRAMHIT25 = 3
GROWT = 6
DRAMHIT23 = 8
TBB = 9
one_gb = 1 << 26  # kvpair is 16 bytes


class JoinRunConfig:
    def __init__(
        self,
        name: str,
        ht_type: int,
        hw_pref: int,
        s_size: int,
        r_size: int,
        ht_fill: int,
        skew: float,
    ):
        self.name = name
        self.ht_type = ht_type
        self.ht_fill = ht_fill
        self.hw_pref = hw_pref
        self.s_size = s_size
        self.r_size = r_size
        self.skew = skew


class RegexStatsMatch:
    def __init__(self, mops: float):
        self.mops = mops


def run_once(cmd: str):
    """Run a command and return its stdout as string."""
    proc = subprocess.run(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    return proc.stdout, proc.stderr


def get_cmd(config: JoinRunConfig):
    cmd = f"""
        /opt/DRAMHiT/build/dramhit
        --ht-type {config.ht_type}
        --hw-pref {config.hw_pref}
        --ht-fill {config.ht_fill}
        --relation_r_size {config.r_size}
        --relation_s_size {config.s_size}
        --skew {config.skew}
        --find_queue 64
        --num-threads 64
        --numa-split 4
        --no-prefetch 0
        --insert-factor 1
        --read-factor 1
        --mode 13
        --batch-len 16
        """

    cmd = " ".join(cmd.split())
    return cmd


def run_collect(config, results):
    out, err = run_once(get_cmd(config))
    matches = re.findall(r"mops\s*:\s*([\d.]+)", out)
    if not matches:
        print("\nError: could not parse mops values")
        print(f"Command: {get_cmd(config)}")
        print("---- Output  ----")
        print(out)
        print(err)
        print("---- End of output ----")
        sys.exit(1)
    mops = float(matches[0])


# def run(name: str, ht_type: int, hw_pref: int, results: dict):
#     for rsize in join_workload:
#         htsize = int(rsize * 2)  # 50% fill factor
#         repeat = 100

#         print(cmd_base)
#         out, err = run_once("sudo " + cmd_base)
#         matches = re.findall(r"mops\s*:\s*([\d.]+)", out)

#         if not matches:
#             print("\nError: could not parse mops values")
#             print(f"Command: {cmd_base}")
#             print("---- Output  ----")
#             print(out)
#             print(err)
#             print("---- End of output ----")
#             sys.exit(1)

#         mops = matches[-1]
#         fill = rsize / htsize * 100
#         print(f"rsize={rsize} htsize={htsize} fill={fill} mops={mops}")
#         results[name].append(
#             {"rsize": rsize, "htsize": htsize, "mops": mops, "fill": fill}
#         )

# fix on a size and vary skew ness.
#
# skew gives us different amount of overlaps between r and s
# we know lower skew meaning we are just simply inserting and reading
# on seperate data sets
#
# On high skew, 1.00 skew is about 30% overlaps between r and s
#
# a plot of mops vs skew. expect,
# so we need to either prefetch carefully to avoid
#

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    r_size = one_gb * 4
    s_size = one_gb * 4

    print(
        get_cmd(
            JoinRunConfig(
                name="dramhit_2025",
                ht_type=DRAMHIT25,
                hw_pref=0,
                s_size=s_size,
                r_size=r_size,
                ht_fill=50,
                skew=0.01,
            )
        )
    )

    exit()

    json_out_file = sys.argv[1]
    # rebuild project
    subprocess.run("rm -f /opt/DRAMHiT/build/", shell=True)
    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DCAS_NO_ABSTRACT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON "
        "-DGROWT=ON",
        shell=True,
        check=True,
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    # store results
    all_results = {}

    r_size = one_gb * 4
    s_size = one_gb * 4

    print(
        get_cmd(
            JoinRunConfig(
                name="dramhit_2025",
                ht_type=DRAMHIT25,
                hw_pref=0,
                s_size=s_size,
                r_size=r_size,
                ht_fill=0.5,
            )
        )
    )
    # run_ht_dual("dramhit_2023", DRAMHIT23, 0, all_results)
    # run_ht_dual("dramhit_2025", DRAMHIT25, 0, all_results)
    # run_ht_dual("GROWT", GROWT, 1, all_results)

    # save to JSON
    # with open(json_out_file, "w") as f:
    # json.dump(all_results, f, indent=2)

    # print("\nFinal results saved to " + json_out_file)
