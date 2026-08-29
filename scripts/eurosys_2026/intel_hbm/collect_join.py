import argparse
import json
import math
import re
import subprocess
from unittest.loader import defaultTestLoader

import matplotlib.pyplot as plt

L2_BYTES = 1 * 1024 * 1024  # 1mb per hyperthread

# single
num_threads = 64
numa = 10
numa_name = "intel_hbm_single"

# the goal here is reduce keep radix high enough to make each paritition size fit into l2
# while keep radix low enough parition runtime doesn't blow up because partition must maintin
# 2^radix amount of cachelines.
def get_optimal_radix(build_sz, ht_fill):
    # fit into l2.
    optimal_join_size = L2_BYTES * ht_fill / 100
    radix = max(6, math.ceil(math.log(build_sz * 16 / optimal_join_size, 2)))

    # if build size is too large, then give a warning for partition.
    if pow(2, radix) * 64 >= L2_BYTES:
        print(
            f"input size is too big, partition runtime will go up, build_sz {build_sz / (1024 * 1024)} MB radix {radix}"
        )

    return radix


one_mb = int(1024 * 1024 / 16)
one_gb = int(1024 * 1024 * 1024 / 16)
# =============================================================================
# CONFIGURATION
# =============================================================================

default_build_sz = one_gb

# Parameters (X-axis) that can be swept, selected via --param-name on the
# command line instead of commenting/uncommenting blocks.
PARAM_CONFIGS = {
    "skew": [round(0.1 + i * 0.1, 1) for i in range(12)],
    "relation_size": [
        #256 * one_mb,
        #512 * one_mb,
        1 * one_gb,
        2 * one_gb,
        4 * one_gb,
        8 * one_gb,
        16 * one_gb,
    ],
}

# Paths to the executables
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"

# Default arguments for Hash Join
HASH_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 7,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "find_queue": 64,
    "num-threads": num_threads,
    "numa-split": numa,
    "np_cpu_node_msk": 1,
    "np_mem_node_msk": 4,
    "no-prefetch": 0,
    "mode": 13,
    "batch-len": 16,  # per-variant override in HASH_JOIN_VARIANTS
    "skew": 0.01,
    "associativity": 1.0,
    "seed": 1774551337382868027,
}

# ht-type values, mirrored from include/types.hpp (ht_type_t).
# Only types actually wired up by the current build flags (see
# collect_join.py's cmake invocation: GROWT=ON, no PART_ID, no CLHT)
# are usable here -- see init_ht() in src/misc_lib.cpp.
HT_TYPES = {
    "cas": 3,  # CASHTPP
    # "array": 4,  # ARRAY_HT
    # "growt": 6,  # GROWHT
    "cas23": 8,  # CAS23HTPP
    # "tbb": 9,  # TBB_HT
    "dlht": 10,  # DLHT_HT, needs 32 batch, needs low fill for build or increase link.....
    "folklore": 11,  # FOLKLORE_HT
}

# Hash join variants to sweep the chosen --param-name over.
# Manually add/remove entries here to control which (hashtable, hw-prefetcher)
# combinations get run. Each value overrides HASH_JOIN_DEFAULTS; "prefetcher"
# is special-cased to select the *hardware* prefetcher state ("on"/"off") via
# set_prefetcher(), it is not passed to the dramhit binary.
HASH_JOIN_VARIANTS = {
    "cas": {"ht-type": HT_TYPES["cas"], "prefetcher": "off", "batch-len": 16},
    # "cas_hwpf_on": {"ht-type": HT_TYPES["cas"], "prefetcher": "on"},
    # "array_hwpf_off": {"ht-type": HT_TYPES["array"], "prefetcher": "off"},
    # "growt_hwpf_off": {"ht-type": HT_TYPES["growt"], "prefetcher": "off"},
    "cas23": {"ht-type": HT_TYPES["cas23"], "prefetcher": "off", "batch-len": 16},
    # "tbb_hwpf_off": {"ht-type": HT_TYPES["tbb"], "prefetcher": "off"},
    "dlht": {"ht-type": HT_TYPES["dlht"], "prefetcher": "on", "batch-len": 32},
    "folklore": {"ht-type": HT_TYPES["folklore"], "prefetcher": "on", "batch-len": 16},
}

# Default arguments for Radix Join
RADIX_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 50,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "num-threads": num_threads,
    "numa-split": numa,
    "np_cpu_node_msk": 1,
    "np_mem_node_msk": 4,
    "mode": 16,
    "skew": 0.01,
    "seed": 1774551337382868027,
    "radix": 10,
    "associativity": 1.0,
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


def set_prefetcher(state):
    """Turns the hardware prefetcher 'on' or 'off'."""
    print(f"[*] Setting prefetcher to: {state.upper()}")
    subprocess.run([PREFETCH_SCRIPT, state], check=True)


def build_command(defaults_dict, param_name, param_value, overrides=None):
    """Builds the command list dynamically based on defaults + varied parameter.

    `overrides` (e.g. a HASH_JOIN_VARIANTS entry, minus the "prefetcher" key)
    are applied on top of defaults_dict, before the swept param_name/param_value.
    """
    args = defaults_dict.copy()
    if overrides:
        args.update(overrides)

    if param_name == "relation_size":
        args["relation_r_size"] = param_value
        args["relation_s_size"] = param_value
    else:
        args[param_name] = param_value  # Override the specific parameter being tested

    if args["mode"] == 13:
        # hash join can use same space as used by radix join
        build_sz = args["relation_r_size"]
        probe_sz = args["relation_s_size"]
        ht_fill = math.ceil((build_sz * 100) / (build_sz + probe_sz)) # on skew, this is 7% to get a 16gb table.

        if args["ht-type"] == 10 and param_name == "relation_size": # dlht can only holds up to 30%
            ht_fill = 30

        args["ht-fill"] = ht_fill
    else:
        args["radix"] = get_optimal_radix(args["relation_r_size"], args["ht-fill"])

    cmd = [DRAMHIT_EXEC]

    for key, val in args.items():
        cmd.extend([f"--{key}", str(val)])
    return cmd


def run_and_parse(cmd):
    """Runs the benchmark command and extracts throughput_mops."""
    print(f"    Running: {' '.join(cmd)}")
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )

    # Regex to find "throughput_mops : <number>" (handles optional spaces)
    match = re.search(r"throughput_mops\s*:\s*([0-9.]+)", result.stdout)
    if match:
        throughput = float(match.group(1))
        print(f"    -> throughput_mops: {throughput}")
        return throughput
    else:
        print("    -> ERROR: Could not find throughput_mops in output!")
        print("    --- Output Log ---")
        print(result.stdout)
        return 0.0


# =============================================================================
# MAIN EXECUTION
# =============================================================================


def main(param_name):
    param_values = PARAM_CONFIGS[param_name]
    print(f"Starting Benchmark. Varying '--{param_name}' across: {param_values}\n")


    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON "
        "-DGROWT=ON -DCPUFREQ_MHZ=2700",
        shell=True,
        check=True,
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    results = {
        "param_name": param_name,
        "param_values": param_values,
        "hash_join_throughput": {name: [] for name in HASH_JOIN_VARIANTS},
        "radix_join_throughput": [],
    }

    for val in param_values:
        print(f"=== Testing {param_name} = {val} ===")

        # --- HASH JOIN (one run per variant in HASH_JOIN_VARIANTS) ---
        for variant_name, variant_cfg in HASH_JOIN_VARIANTS.items():
            print(f"  -- hash join variant: {variant_name} --")
            overrides = {k: v for k, v in variant_cfg.items() if k != "prefetcher"}
            set_prefetcher(variant_cfg.get("prefetcher", "off"))
            cmd_hash = build_command(HASH_JOIN_DEFAULTS, param_name, val, overrides)
            perf_hash = run_and_parse(cmd_hash)
            results["hash_join_throughput"][variant_name].append(perf_hash)

        # --- RADIX JOIN ---
        set_prefetcher("on")
        cmd_radix = build_command(RADIX_JOIN_DEFAULTS, param_name, val)
        perf_radix = run_and_parse(cmd_radix)
        results["radix_join_throughput"].append(perf_radix)

        print("\n")

    # =========================================================================
    # SAVE DATA TO JSON
    # =========================================================================
    json_filename = f"{numa_name}_{param_name}.json"
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"[*] Data saved to {json_filename}")

    # =========================================================================
    # PLOT AND SAVE TO PNG
    # =========================================================================
    plt.figure(figsize=(10, 6))

    for variant_name, throughput in results["hash_join_throughput"].items():
        plt.plot(
            param_values,
            throughput,
            label=f"Hash Join ({variant_name})",
            marker="o",
            linewidth=2,
        )

    plt.plot(
        param_values,
        results["radix_join_throughput"],
        label="Radix Join (Prefetch ON)",
        marker="s",
        color="black",
        linewidth=2,
        linestyle="--",
    )

    # Styling the plot
    plt.title(f"Join Performance vs. {param_name.capitalize()}", fontsize=14)
    plt.xlabel(param_name, fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend(fontsize=9)
    plt.tight_layout()

    # Save to PNG
    png_filename = f"{numa_name}_{param_name}.png"
    plt.savefig(png_filename, dpi=300)
    print(f"[*] Plot saved to {png_filename}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Collect hash/radix join throughput while sweeping a parameter."
    )
    parser.add_argument(
        "--param-name",
        choices=sorted(PARAM_CONFIGS.keys()),
        default="skew",
        help="Which parameter to sweep on the x-axis (default: skew).",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    main(args.param_name)
