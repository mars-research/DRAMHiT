import csv
import re
import subprocess
import sys
from pathlib import Path

# --- Configuration Settings ---
BENCHMARK_BIN = "./build/prefetch_rand_nonbind"
OUTPUT_CSV = "prefetch_results.csv"

# Benchmark parameters
OPS = 1000000000
AHEAD = 64# Updated default ahead distance per usage
MEM_NODE = 0
CPU_NODE = 0

# Instruction mapping based on benchmark usage (<0-5>)
PREFETCH_TYPES = {
    #0: "Load",
    #1: "AVX512 Load",
    2: "PF_T0",
    3: "PF_T1",
    4: "PF_T2",
    5: "PF_NTA",
}

# Sweep configurations: threads (1, 2) and loaded state (0, 1)
THREADS_LIST = [1, 2]
LOADED_LIST = [0, 1]


def parse_thread0_cycles(stdout_text: str) -> float | None:
    """Extracts the 'Cycles/Op' value specifically under Thread 0 section."""
    pattern = r"Thread 0 \([^)]+\):[\s\S]*?Cycles/Op:\s*([0-9.]+)"
    match = re.search(pattern, stdout_text)
    if match:
        return float(match.group(1))
    return None


def run_benchmarks():
    bin_path = Path(BENCHMARK_BIN)
    if not bin_path.exists():
        print(f"Error: Executable '{BENCHMARK_BIN}' not found. Build the target first.")
        sys.exit(1)

    results = []

    fieldnames = [
        "inst_type",
        "inst_label",
        "threads",
        "loaded",
        "thread0_cycles_per_op",
        "command",
    ]

    print("=== Starting Benchmark Collection ===\n")

    for inst_type, inst_label in PREFETCH_TYPES.items():
        for threads in THREADS_LIST:
            for loaded in LOADED_LIST:
                cmd = [
                    str(bin_path),
                    "-inst_type", str(inst_type),
                    "-ops", str(OPS),
                    "-threads", str(threads),
                    "-mem_node", str(MEM_NODE),
                    "-cpu_node", str(CPU_NODE),
                    "-ahead", str(AHEAD),
                    "-loaded", str(loaded),
                ]

                cmd_str = " ".join(cmd)
                
                # Print command run for each data point
                print(f"[RUNNING] {cmd_str}")

                try:
                    process = subprocess.run(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                        text=True,
                        check=True,
                    )

                    cycles_per_op = parse_thread0_cycles(process.stdout)

                    if cycles_per_op is not None:
                        print(f"  --> Thread 0 Cycles/Op: {cycles_per_op:.2f}\n")
                    else:
                        print("  --> WARNING: Failed to parse Thread 0 Cycles/Op from output.\n")

                    results.append({
                        "inst_type": inst_type,
                        "inst_label": inst_label,
                        "threads": threads,
                        "loaded": loaded,
                        "thread0_cycles_per_op": cycles_per_op,
                        "command": cmd_str,
                    })

                except subprocess.CalledProcessError as e:
                    print(f"  --> ERROR: Command failed with return code {e.returncode}\n")
                    results.append({
                        "inst_type": inst_type,
                        "inst_label": inst_label,
                        "threads": threads,
                        "loaded": loaded,
                        "thread0_cycles_per_op": "ERROR",
                        "command": cmd_str,
                    })

    # Save output to CSV
    with open(OUTPUT_CSV, mode="w", newline="") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    print(f"=== Sweep Complete. Data saved to '{OUTPUT_CSV}' ===")


if __name__ == "__main__":
    run_benchmarks()
