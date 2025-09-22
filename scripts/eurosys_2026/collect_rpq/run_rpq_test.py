#!/bin/env python3

import subprocess
import re
import matplotlib.pyplot as plt
import csv
import seaborn as sns
import pandas as pd

# --- Step 0: Compile rpq_test.c ---
compile_cmd = "gcc -O1 -lnuma -pthread rpq_test.c -o rpq"
print("Compiling rpq_test.c...")
comp_proc = subprocess.run(compile_cmd, shell=True, capture_output=True, text=True)
if comp_proc.returncode != 0:
    print("Compilation failed!")
    print(comp_proc.stdout)
    print(comp_proc.stderr)
    exit(1)
print("Compilation succeeded.\n")

# Command template
cmd_template = "sudo /usr/bin/perf stat -e unc_m_rpq_inserts.pch0,unc_m_rpq_occupancy_pch0,unc_m_rpq_inserts.pch1,unc_m_rpq_occupancy_pch1 -- ./rpq 10 {num_threads} 2>&1"

results = []

for num_threads in range(1, 32):
    cmd = cmd_template.format(num_threads=num_threads)
    proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    output = proc.stdout + proc.stderr  # combine stdout + stderr

    run_data = {}

    # Helper function to match and store value
    def parse_field(pattern, field_name, cast=int, default=None):
        m = re.search(pattern, output)
        if m:
            run_data[field_name] = cast(m.group(1))
        else:
            print(f"[ERROR] Could not find {field_name} in output for num_threads={num_threads}")
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
            print(f"[ERROR] Could not find perf counter {counter_name} for num_threads={num_threads}")
            run_data[counter_name] = None

    results.append(run_data)

# Save CSV
with open("data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=results[0].keys())
    writer.writeheader()
    writer.writerows(results)
