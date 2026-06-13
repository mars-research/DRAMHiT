#!/usr/bin/env python3
import os
import subprocess

import matplotlib.pyplot as plt
import pandas as pd

# Configuration
C_FILE = "batch_test.c"
EXECUTABLE = "./batch_test"
MIN_BATCH = 10
MAX_BATCH = 40
ITERATIONS = 1000

# Mapping descriptive names to the C program's mode integers
# 0: REGULAR_LOAD, 2: PREFETCH_L1 (T0), 3: PREFETCH_L2 (T1)
MODES = {"Regular Load": 0, "Prefetch T0 (L1)": 2, "Prefetch T1 (L2)": 3}


def compile_c_program():
    """Compiles the C benchmark program."""
    print(f"Compiling {C_FILE}...")
    compile_cmd = ["gcc", C_FILE, "-O3", "-mcrc32", "-o", "batch_test"]
    try:
        subprocess.run(compile_cmd, check=True)
        print("Compilation successful.\n")
    except subprocess.CalledProcessError:
        print("Compilation failed. Please check your C code and compiler flags.")
        exit(1)


def run_benchmark():
    """Runs the benchmark for each mode and collects the data."""
    results = {}

    for name, mode_int in MODES.items():
        csv_filename = f"data_mode_{mode_int}.csv"
        cmd = [
            "taskset",
            "-c",
            "1",
            EXECUTABLE,
            "-m",
            str(mode_int),
            "-b",
            f"{MIN_BATCH}-{MAX_BATCH}",
            "-i",
            str(ITERATIONS),
            "-o",
            csv_filename,
        ]

        print(f"Running mode: {name} (Command: {' '.join(cmd)})")
        subprocess.run(cmd, check=True)

        # Load the generated CSV into a pandas DataFrame
        df = pd.read_csv(csv_filename)

        # Calculate derived metrics
        # 1. Cycle per operation = avg / batch_size
        df["cycle_per_op"] = df["median"] / df["batch_size"]

        # 2. Nth operation cycle (marginal cost) = avg[n] - avg[n-1]
        # Because the batch sizes are sequential, we can use the pandas diff() function
        df["nth_op_cycle"] = df["median"].diff()

        results[name] = df

    return results


def plot_results(results):
    """Generates and saves the required plots."""
    print("\nGenerating plots...")

    # --- Plot 1: Batch Size vs. Cycles per Operation ---
    plt.figure(figsize=(10, 6))
    for name, df in results.items():
        plt.plot(
            df["batch_size"], df["cycle_per_op"], marker="o", linewidth=2, label=name
        )

    plt.title("Batch Size vs. Cycles Per Operation")
    plt.xlabel("Batch Size (Number of Operations)")
    plt.ylabel("Average Cycles Per Operation")
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.savefig("cycles_per_op.png")
    print("Saved 'cycles_per_op.png'")

    # --- Plot 2: Nth Operation vs. Nth Operation Cycle Cost ---
    plt.figure(figsize=(10, 6))
    for name, df in results.items():
        # Drop the first row (NaN) since diff() has no previous value to subtract from
        valid_df = df.dropna(subset=["nth_op_cycle"])
        plt.plot(
            valid_df["batch_size"],
            valid_df["nth_op_cycle"],
            marker="s",
            linewidth=2,
            label=name,
        )

    plt.title("Nth Operation vs. Marginal Cycle Cost")
    plt.xlabel("Nth Operation Issued (Batch Size)")
    plt.ylabel("Marginal Cycles (Total[N] - Total[N-1])")
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.savefig("nth_op_cycle.png")
    print("Saved 'nth_op_cycle.png'")


def main():
    if not os.path.exists(C_FILE):
        print(f"Error: {C_FILE} not found in the current directory.")
        return

    compile_c_program()
    data = run_benchmark()
    plot_results(data)


if __name__ == "__main__":
    main()
