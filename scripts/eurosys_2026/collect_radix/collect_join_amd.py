import json
import math
import re
import subprocess
from unittest.loader import defaultTestLoader

import matplotlib.pyplot as plt

THREAD_NUM = 64
L1_BYTES = int(1 * 1024 * 1024 / THREAD_NUM)
L2_BYTES = 1 * 1024 * 1024
L3_BYTES = int(256 * 1024 * 1024 / THREAD_NUM)


# the goal here is reduce keep radix high enough to make each paritition size fit into l2
# while keep radix low enough parition runtime doesn't blow up because partition must maintin
# 2^radix amount of cachelines.
def get_optimal_radix(build_sz):
    radix = max(6, math.ceil(math.log(build_sz * 16 / L2_BYTES, 2)))

    if pow(2, radix) * 64 > L2_BYTES:
        print("input size is too big, partition runtime must spill out")

    return radix


one_mb = int(1024 * 1024 / 16)
one_gb = int(1024 * 1024 * 1024 / 16)
# =============================================================================
# CONFIGURATION
# =============================================================================

# 1. Define the parameter to vary (X-axis)
PARAM_NAME = "skew"
PARAM_VALUES = [round(0.1 + i * 0.1, 1) for i in range(12)]
default_build_sz = one_gb

# --- Examples for exploring other directions ---


# PARAM_NAME = "relation_size"
# PARAM_VALUES = [
#     256 * one_mb,
#     512 * one_mb,
#     1 * one_gb,
#     2 * one_gb,
#     4 * one_gb,
#     8 * one_gb,
#     16 * one_gb,
# ]

# PARAM_NAME = "relation_s_size"
# default_build_sz = 256 * one_mb
# PARAM_VALUES = [
#     default_build_sz,  # ht fill 50%, 2x, 0.5 gb
#     3 * default_build_sz,  # ht fill 25%, 4x, 1 gb
#     7 * default_build_sz,  # ht fill 13%, 8x, 2gb
#     15 * default_build_sz,  # ht fill 7%, 16x, 4gb
#     31 * default_build_sz,  # ht fill 4%, 32x, 8gb
#     63 * default_build_sz,  # ht fill 2%, 64x, 16gb
# ]

# Paths to the executables
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_amd.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"

# Default arguments for Hash Join
HASH_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 7,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "find_queue": 64,
    "num-threads": 64,
    "numa-split": 4,
    "no-prefetch": 0,
    "mode": 13,
    "batch-len": 16,
    "skew": 0.01,
    "associativity": 1.0,
    "seed": 1774551337382868027,
}

# Default arguments for Radix Join
RADIX_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 50,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "num-threads": 64,
    "numa-split": 4,
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


def build_command(defaults_dict, param_name, param_value):
    """Builds the command list dynamically based on defaults + varied parameter."""
    args = defaults_dict.copy()

    if param_name == "relation_size":
        args["relation_r_size"] = param_value
        args["relation_s_size"] = param_value
        args["radix"] = get_optimal_radix(args["relation_r_size"])
    elif param_name == "relation_s_size":
        args["relation_r_size"] = default_build_sz
        args["relation_s_size"] = param_value
        target_size = param_value + default_build_sz
        ht_fill = math.ceil((default_build_sz * 100) / target_size)
        args["ht-fill"] = ht_fill
        args["radix"] = get_optimal_radix(args["relation_r_size"])
    else:
        args[param_name] = param_value  # Override the specific parameter being tested
        args["radix"] = get_optimal_radix(args["relation_r_size"])

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


def main():
    print(f"Starting Benchmark. Varying '--{PARAM_NAME}' across: {PARAM_VALUES}\n")

    results = {
        "param_name": PARAM_NAME,
        "param_values": PARAM_VALUES,
        "hash_join_throughput": [],
        "radix_join_throughput": [],
    }

    for val in PARAM_VALUES:
        print(f"=== Testing {PARAM_NAME} = {val} ===")

        # --- HASH JOIN ---
        set_prefetcher("off")
        cmd_hash = build_command(HASH_JOIN_DEFAULTS, PARAM_NAME, val)
        perf_hash = run_and_parse(cmd_hash)
        results["hash_join_throughput"].append(perf_hash)

        # --- RADIX JOIN ---
        set_prefetcher("on")
        cmd_radix = build_command(RADIX_JOIN_DEFAULTS, PARAM_NAME, val)
        perf_radix = run_and_parse(cmd_radix)
        results["radix_join_throughput"].append(perf_radix)

        print("\n")

    # =========================================================================
    # SAVE DATA TO JSON
    # =========================================================================
    json_filename = f"benchmark_results_{PARAM_NAME}.json"
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"[*] Data saved to {json_filename}")

    # =========================================================================
    # PLOT AND SAVE TO PNG
    # =========================================================================
    plt.figure(figsize=(10, 6))

    plt.plot(
        PARAM_VALUES,
        results["hash_join_throughput"],
        label="Hash Join (Prefetch OFF)",
        marker="o",
        color="blue",
        linewidth=2,
    )

    plt.plot(
        PARAM_VALUES,
        results["radix_join_throughput"],
        label="Radix Join (Prefetch ON)",
        marker="s",
        color="orange",
        linewidth=2,
    )

    # Styling the plot
    plt.title(f"Join Performance vs. {PARAM_NAME.capitalize()}", fontsize=14)
    plt.xlabel(PARAM_NAME, fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend(fontsize=11)
    plt.tight_layout()

    # Save to PNG
    png_filename = f"benchmark_plot_{PARAM_NAME}.png"
    plt.savefig(png_filename, dpi=300)
    print(f"[*] Plot saved to {png_filename}")


if __name__ == "__main__":
    main()
