#!/bin/env python3

import subprocess
import re
import matplotlib.pyplot as plt
import csv
import seaborn as sns

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
cmd_template = "/usr/bin/perf stat -e unc_m_rpq_inserts.pch0,unc_m_rpq_occupancy_pch0,unc_m_cas_count.all,unc_m_cas_count.rd -- ./rpq 100 {num_threads} 2>&1"

results = []

for num_threads in range(1, 64):
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
        "unc_m_cas_count.all",
        "unc_m_cas_count.rd"
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


with open("data.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=results[0].keys())
    writer.writeheader()   # writes column names
    writer.writerows(results) # writes rows
    
# Extract data for plotting
num_threads_list = [r["num_threads"] for r in results]
bw_list = [r.get("bw", 0) for r in results]
occupancy_list = [
    r.get("unc_m_rpq_occupancy_pch0", 0) for r in results
]

inserts_list = [
    r.get("unc_m_rpq_inserts.pch0", 0) for r in results
]



sns.set_theme()

# Create figure with 2 subplots
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(10, 8))

# Graph 1: num_threads vs estimated bandwidth
ax1.plot(num_threads_list, bw_list, marker='o', color='red')
ax1.set_xlabel("Number of Threads")
ax1.set_ylabel("Estimated Bandwidth (GB/s)")
ax1.set_title("Num Threads vs Estimated Bandwidth")
ax1.grid(True)

# Graph 2: num_threads vs occupancy counter/sec
ax2.plot(num_threads_list, occupancy_list, marker='o', color='orange')
ax2.set_xlabel("Number of Threads")
ax2.set_ylabel("unc_m_rpq_occupancy_pch0")
ax2.set_title("Num Threads vs unc_m_rpq_occupancy_pch0")
ax2.grid(True)

ax3.plot(num_threads_list, inserts_list, marker='o', color='blue')
ax3.set_xlabel("Number of Threads")
ax3.set_ylabel("unc_m_rpq_insert_pch0")
ax3.set_title("Num Threads vs unc_m_rpq_insert_pch0")
ax3.grid(True)

plt.tight_layout()
plt.savefig("perf_results.png")
print("Saved plot to perf_results.png")
