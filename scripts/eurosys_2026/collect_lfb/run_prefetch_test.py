#!/usr/bin/env python3
import csv
import os
import re
import statistics
import subprocess

# --- Configuration ---
SOURCE_FILE = "prefetch_test.c"
NUM_OPS = 1000000000
THREADS = 1
OUTPUT_CSV = "benchmark_results.csv"

# The 4 program variants and their GCC compilation flags
PROGRAMS = {
    "seq_bind": ["-DSEQUENTIAL"],
    "seq_non_bind": ["-DSEQUENTIAL", "-DNONE_BIND"],
    "rand_bind": ["-DRANDOM"],
    "rand_non_bind": ["-DRANDOM", "-DNONE_BIND"],
}

# The instruction types to loop through
INST_TYPES = {
    0: "Load",
    1: "AVX512_Load",
    2: "Prefetch_T0",
    3: "Prefetch_T1",
    4: "Prefetch_T2",
    5: "Prefetch_NTA",
}

# The counters passed to perf
COUNTERS = [
    "ls_any_fills_from_sys.all",
    "ls_pref_instr_disp.all",
    "ls_mab_alloc.all_allocations",
    "ls_hw_pf_dc_fills.all",
]


def compile_programs():
    print("--- Compiling Programs ---")
    for prog_name, flags in PROGRAMS.items():
        # Added -mavx512f and -msse4.2 to ensure the compiler understands intrinsic types globally if needed
        cmd = [
            "gcc",
            "-O3",
            "-mavx512f",
            "-msse4.2",
            SOURCE_FILE,
            "-o",
            prog_name,
            "-pthread",
        ] + flags
        print(f"Compiling {prog_name}: {' '.join(cmd)}")

        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error compiling {prog_name}:\n{result.stderr}")
            exit(1)
    print("Compilation successful.\n")


def run_benchmark_and_parse(prog_name, inst_type):
    out_file = f"test_out_{prog_name}_{inst_type}.txt"

    # stdbuf and perf stat command exactly as requested
    cmd = [
        "stdbuf",
        "-oL",
        "-eL",
        "perf",
        "stat",
        "-I100",
        "-e",
        f"{COUNTERS[0]}",
        "-e",
        f"{COUNTERS[1]}",
        "-e",
        f"{COUNTERS[2]}",
        "-e",
        f"{COUNTERS[3]}",
        "--",
        f"./{prog_name}",
        str(inst_type),
        str(NUM_OPS),
        str(THREADS),
    ]

    print(f"Running: {prog_name} (Inst: {INST_TYPES[inst_type]})")
    with open(out_file, "w") as f:
        # Redirect stdout and stderr directly to the file to capture both standard prints and perf output
        subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT)

    return parse_output(out_file)


def parse_output(file_path):
    data = {c: [] for c in COUNTERS}
    cycles_per_op = None
    in_benchmark = False

    # Regex to capture: <timestamp> <value> <counter_name>
    # Handles numbers with or without commas
    perf_re = re.compile(r"^\s*\d+\.\d+\s+([\d\,]+)\s+([a-zA-Z0-9_\.]+)")
    cpo_re = re.compile(r"^\s*Cycles/Op:\s+([0-9\.]+)")

    with open(file_path, "r") as f:
        for line in f:
            line = line.strip()

            # Start gathering counter data
            if "--- Executing Benchmark ---" in line:
                in_benchmark = True
                continue

            # Stop gathering counter data (prevents parsing summary perf outputs if they appear)
            if "--- Results ---" in line:
                in_benchmark = False
                continue

            if in_benchmark:
                match = perf_re.match(line)
                if match:
                    val_str, counter = match.groups()
                    if counter in data:
                        val = int(val_str.replace(",", ""))
                        data[counter].append(val)

            # Keep an eye out for our specific cycles output
            cpo_match = cpo_re.match(line)
            if cpo_match:
                cycles_per_op = float(cpo_match.group(1))

    # Calculate min, max, median for each counter
    stats = {}
    for c in COUNTERS:
        pts = data[c]
        if len(pts) > 0:
            stats[f"{c}_min"] = min(pts)
            stats[f"{c}_max"] = max(pts)
            stats[f"{c}_median"] = statistics.median(pts)
        else:
            stats[f"{c}_min"] = "N/A"
            stats[f"{c}_max"] = "N/A"
            stats[f"{c}_median"] = "N/A"

    stats["Cycles/Op"] = cycles_per_op if cycles_per_op is not None else "N/A"
    return stats


def write_csv(results):
    # Set up our columns
    headers = ["Program", "InstType", "Cycles/Op"]
    for c in COUNTERS:
        headers.extend([f"{c}_min", f"{c}_median", f"{c}_max"])

    with open(OUTPUT_CSV, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        for row in results:
            writer.writerow(row)


if __name__ == "__main__":
    compile_programs()

    all_results = []
    print("--- Running Benchmarks ---")
    for prog in PROGRAMS.keys():
        for inst, inst_name in INST_TYPES.items():
            stats = run_benchmark_and_parse(prog, inst)

            # Structure the row data for CSV
            row = {
                "Program": prog,
                "InstType": inst_name,
                "Cycles/Op": stats["Cycles/Op"],
            }
            for c in COUNTERS:
                row[f"{c}_min"] = stats[f"{c}_min"]
                row[f"{c}_median"] = stats[f"{c}_median"]
                row[f"{c}_max"] = stats[f"{c}_max"]

            all_results.append(row)

    write_csv(all_results)
    print(f"\nDone. Results successfully written to {OUTPUT_CSV}")
