#!/usr/bin/env python3

import csv
import re
import subprocess

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# Define the variants you want to test
prefetch_variants = ["READ", "PREFETCH_T0", "PREFETCH_T1"]

# Command template dynamically accepts the executable now
cmd_template = "sudo /usr/bin/perf stat -e unc_m_rpq_inserts.pch0,unc_m_rpq_occupancy_pch0,unc_m_rpq_inserts.pch1,unc_m_rpq_occupancy_pch1 -- {exe} 10 {num_threads} 2>&1"

for variant in prefetch_variants:
    print(f"\n{'=' * 50}")
    print(f"Starting experiments for variant: {variant}")
    print(f"{'=' * 50}")

    # --- Step 0: Compile both versions of rpq_test.c for the current variant ---
    builds = {
        "sequential": {
            "compile_cmd": f"gcc -O3 rpq_test.c -lnuma -o rpq_seq_{variant} -D{variant}",
            "exe": f"./rpq_seq_{variant}",
        },
        "random": {
            "compile_cmd": f"gcc -O3 rpq_test.c -lnuma -o rpq_rand_{variant} -DRANDOM_ACCESS -D{variant}",
            "exe": f"./rpq_rand_{variant}",
        },
    }

    for mode, build in builds.items():
        print(f"Compiling rpq_test.c for {mode} access ({variant})...")
        comp_proc = subprocess.run(
            build["compile_cmd"], shell=True, capture_output=True, text=True
        )
        if comp_proc.returncode != 0:
            print(f"Compilation failed for {mode} mode ({variant})!")
            print(comp_proc.stdout)
            print(comp_proc.stderr)
            exit(1)
        print(f"Compilation succeeded for {mode} mode ({variant}).\n")

    results = []

    for mode, build in builds.items():
        print(f"Running experiments for {mode} access ({variant})...")

        for num_threads in range(2, 34, 2):
            cmd = cmd_template.format(exe=build["exe"], num_threads=num_threads)
            proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            output = proc.stdout + proc.stderr  # combine stdout + stderr

            # Initialize dictionary with the current access pattern mode
            run_data = {"access_pattern": mode}

            # Helper function to match and store value
            def parse_field(pattern, field_name, cast=int, default=None):
                m = re.search(pattern, output)
                if m:
                    run_data[field_name] = cast(m.group(1))
                else:
                    print(
                        f"[ERROR] Could not find {field_name} in output for {mode} mode, num_threads={num_threads}"
                    )
                    run_data[field_name] = default

            # Parse program output (space-separated format)
            parse_field(r"iter\s+(\d+)", "iter")
            parse_field(r"num_threads\s+(\d+)", "num_threads")
            parse_field(r"cachelines\s+(\d+)", "cachelines")
            parse_field(r"duration\s+(\d+)", "duration")
            parse_field(r"sec\s+([\d\.]+)", "sec", cast=float)
            parse_field(r"bw\s+([\d\.]+)\s*GB", "bw", cast=float)

            perf_counter_names = [
                "unc_m_rpq_inserts.pch0",
                "unc_m_rpq_occupancy_pch0",
                "unc_m_rpq_inserts.pch1",
                "unc_m_rpq_occupancy_pch1",
            ]

            # Parse only the specific perf counters
            for counter_name in perf_counter_names:
                # Regex: number (with optional commas) followed by whitespace + exact counter name
                pattern = rf"([\d,]+)\s+{re.escape(counter_name)}"
                m = re.search(pattern, output)
                if m:
                    run_data[counter_name] = int(m.group(1).replace(",", ""))
                else:
                    print(
                        f"[ERROR] Could not find perf counter {counter_name} for {mode} mode, num_threads={num_threads}"
                    )
                    run_data[counter_name] = None

            results.append(run_data)

    # Save CSV for this specific variant
    csv_filename = f"data_{variant}.csv"
    print(f"\nSaving {variant} results to {csv_filename}...")

    if results:
        with open(csv_filename, "w", newline="") as f:
            # Ensure 'access_pattern' is the very first column in the CSV for readability
            fieldnames = ["access_pattern"] + [
                k for k in results[0].keys() if k != "access_pattern"
            ]
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(results)
        print(f"Data extraction complete for {variant}.\n")
    else:
        print(f"No results collected for {variant}. Skipping CSV generation.\n")
