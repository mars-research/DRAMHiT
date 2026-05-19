import json
import re
import subprocess
import matplotlib.pyplot as plt

# =============================================================================
# CONFIGURATION
# =============================================================================

# 1. Define the parameter to vary (X-axis)
PARAM_NAME = "skew"

# 2. Define the values to test
# For skew 0.1 to 1.2:
PARAM_VALUES = [round(0.1 + i * 0.1, 1) for i in range(12)]

# --- Examples for exploring other directions ---
# PARAM_NAME = "relation_s_size"
# PARAM_VALUES = [16000000, 32000000, 64000000, 128000000]
#
# PARAM_NAME = "associativity"
# PARAM_VALUES = [1.0, 2.0, 4.0, 8.0]

# Paths to the executables
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_amd.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"

# Default arguments for Hash Join
HASH_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 50,
    "relation_r_size": 64000000,
    "relation_s_size": 64000000,
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
    "relation_r_size": 64000000,
    "relation_s_size": 64000000,
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
    args[param_name] = param_value  # Override the specific parameter being tested

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
