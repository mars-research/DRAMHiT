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
        ht_type: int,
        s_size: int,
        r_size: int,
        ht_fill: int,
        skew: float,
    ):
        self.ht_type = ht_type
        self.ht_fill = ht_fill
        self.s_size = s_size
        self.r_size = r_size
        self.skew = skew


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
        --ht-fill {config.ht_fill}
        --relation_r_size {config.r_size}
        --relation_s_size {config.s_size}
        --skew {config.skew}
        --seed 1775762435926593848
        --hw-pref 0
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


def run(cmd: str):
    out, err = run_once(cmd)
    matches = re.findall(r"throughput_mops\s*:\s*([\d.]+)", out)

    print(f"Command: {cmd}")
    print("---- Output  ----")
    print(out)
    print("---- End of output ----")

    if not matches:
        print("\nError: could not parse mops values")
        print(err)
        sys.exit(1)

    return float(matches[0])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    json_out_file = sys.argv[1]

    # rebuild project
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

    r_size = one_gb * 1
    s_size = one_gb * 8
    configs = [
        # Join config for 10 - 90 htfill for r_size (build) 1g, s_size 8g, skewness 0.01 (uniform)
        # Join config for 10 - 90 htfill for r_size (build) 1g, s_size 8g, skewness 0.05 (some skewness)
        #
        JoinRunConfig(
            ht_type=DRAMHIT25,
            ht_fill=50,
            r_size=r_size,
            s_size=s_size,
            skew=0.01,
        ),
        JoinRunConfig(
            ht_type=DRAMHIT23,
            ht_fill=50,
            r_size=r_size,
            s_size=s_size,
            skew=0.01,
        ),
    ]

    for c in configs:
        mops = run(get_cmd(c))
        key = str(c.ht_type)
        # This ensures the list exists before you try to append to it
        all_results.setdefault(key, []).append({"mops": mops})

    # save to JSON
    with open(json_out_file, "w") as f:
        json.dump(all_results, f, indent=2)
    print("\nFinal results saved to " + json_out_file)
