#!/usr/bin/env python3

import csv
import re
import subprocess

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# --- Step 0: Compile both versions of rpq_test.c ---
builds = {
    "sequential": {
        "compile_cmd": "gcc -O3 rpq_test.c -lnuma -o rpq_seq -DPREFETCH_T1",
        "exe": "./rpq_seq",
    },
    "random": {
        "compile_cmd": "gcc -O3 rpq_test.c -lnuma -o rpq_rand -DRANDOM_ACCESS -DPREFETCH_T1",
        "exe": "./rpq_rand",
    },
}

for mode, build in builds.items():
    print(f"Compiling rpq_test.c for {mode} access...")
    comp_proc = subprocess.run(
        build["compile_cmd"], shell=True, capture_output=True, text=True
    )
    if comp_proc.returncode != 0:
        print(f"Compilation failed for {mode} mode!")
        print(comp_proc.stdout)
        print(comp_proc.stderr)
        exit(1)
    print(f"Compilation succeeded for {mode} mode.\n")

# Command template dynamically accepts the executable now
cmd_template = "sudo /usr/bin/perf stat -e unc_m_rpq_inserts.pch0,unc_m_rpq_occupancy_pch0,unc_m_rpq_inserts.pch1,unc_m_rpq_occupancy_pch1 -- {exe} 10 {num_threads} 2>&1"

results = []

for mode, build in builds.items():
    print(f"Running experiments for {mode} access...")

    for num_threads in range(1, 32):
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

# Save CSV
print("\nSaving results to data.csv...")
with open("data_pref_l2.csv", "w", newline="") as f:
    # Ensure 'access_pattern' is the very first column in the CSV for readability
    fieldnames = ["access_pattern"] + [
        k for k in results[0].keys() if k != "access_pattern"
    ]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(results)
print("Data extraction complete.")
