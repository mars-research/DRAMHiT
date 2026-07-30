import subprocess
import re
import os
import matplotlib.pyplot as plt
import statistics
import csv

# --- Configuration ---
SOURCE_FILE = "benchmark.c"
BIN_RAND = "./benchmark_rand"
BIN_SEQ = "./benchmark_seq"
MEMORY_SIZE = "128m"
LOOKAHEAD = 16
THREADS = list(range(1, 65))

# Ensure a logs directory exists
LOG_DIR = "benchmark_logs"
os.makedirs(LOG_DIR, exist_ok=True)

# The 4 lines to collect: (Label, Binary, Instruction Type)
CONFIGS = [
    ("Random + T0", BIN_RAND, "t0"),
    ("Sequential + T0", BIN_SEQ, "t0"),
    ("Random + T1", BIN_RAND, "t1"),
    ("Sequential + T1", BIN_SEQ, "t1"),
]

def compile_binaries():
    print("Compiling binaries...")
    base_cmd = ["gcc", "-O3", "-mavx512f", "-msse4.2", "-mcrc32", "-lnuma", "-lpthread", SOURCE_FILE]

    cmd_rand = base_cmd + ["-DRANDOM", "-o", BIN_RAND]
    print(f" -> {' '.join(cmd_rand)}")
    subprocess.run(cmd_rand, check=True)

    cmd_seq = base_cmd + ["-DSEQUENTIAL", "-o", BIN_SEQ]
    print(f" -> {' '.join(cmd_seq)}")
    subprocess.run(cmd_seq, check=True)
    print("Compilation successful!\n")

def generate_pattern(total_threads):
    parts = []
    threads_left = total_threads
    node = 0
    while threads_left > 0:
        t_node = min(threads_left, 16)
        parts.append(f"n{node}a{node}t{t_node}")
        threads_left -= t_node
        node += 1
    return ",".join(parts)

def run_benchmark(binary, inst, threads):
    pattern = generate_pattern(threads)
    binary_name = os.path.basename(binary)
    log_filename = os.path.join(LOG_DIR, f"run_{binary_name}_{inst}_{threads}threads.log")

    # Command updated with stdbuf
    cmd = [
        "stdbuf", "-oL", "-eL",
        "perf", "stat", "-I100", "-a", "-M", "umc_mem_bandwidth", "--",
        binary,
        "-m", MEMORY_SIZE,
        "-pattern", pattern,
        "-inst", inst,
        "-lookahead", str(LOOKAHEAD)
    ]

    try:
        # 1. Execute and route stdout/stderr directly to the file (> foo 2>&1)
        with open(log_filename, "w") as log_file:
            subprocess.run(cmd, stdout=log_file, stderr=subprocess.STDOUT, check=True)

        # 2. Read the log file back to parse the results
        with open(log_filename, "r") as log_file:
            output = log_file.read()

        bw_samples = []
        avg_cycles = 0.0
        predicted_bw = 0.0
        timer_started = False

        for line in output.split('\n'):
            if "Timer started." in line:
                timer_started = True

            if timer_started:
                match_perf = re.search(r"#\s+([\d\.]+)\s*MB/s\s+umc_mem_bandwidth", line)
                if match_perf:
                    bw_samples.append(float(match_perf.group(1)))

            match_cycles = re.search(r"Average cycle per operation:\s+([\d\.]+)\s*cycles/op", line)
            if match_cycles:
                avg_cycles = float(match_cycles.group(1))

            match_pred = re.search(r"Predicted peak ban[d]?width:\s+([\d\.]+)\s*GB/s", line, re.IGNORECASE)
            if match_pred:
                predicted_bw = float(match_pred.group(1))

        median_bw = (statistics.median(bw_samples) / 1024.0) if bw_samples else 0.0
        return median_bw, predicted_bw, avg_cycles

    except subprocess.CalledProcessError as e:
        print(f"Error running benchmark. Check {log_filename} for details.")
        return 0.0, 0.0, 0.0

def main():
    csv_filename = "benchmark_data.csv"
    results = {config[0]: {"threads": [], "perf_bw": [], "pred_bw": [], "avg_cycles": []} for config in CONFIGS}

    if os.path.exists(csv_filename):
        print(f"Found existing data in '{csv_filename}'.")
        print("Skipping benchmark execution and generating plots directly...\n")

        with open(csv_filename, mode='r') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for row in csv_reader:
                label = row["Configuration"]
                if label in results:
                    results[label]["threads"].append(int(row["Threads"]))
                    results[label]["perf_bw"].append(float(row["Median_Perf_BW_GBs"]))
                    results[label]["pred_bw"].append(float(row["Predicted_BW_GBs"]))
                    results[label]["avg_cycles"].append(float(row["Avg_Cycles_Per_Op"]))
    else:
        if not os.path.exists(SOURCE_FILE):
            print(f"Error: {SOURCE_FILE} not found in the current directory.")
            return

        compile_binaries()

        print(f"{'Threads':<8} | {'Pattern':<25} | {'Configuration':<18} | {'Perf BW (GB/s)':<14} | {'Pred BW (GB/s)':<14} | {'Cycles/Op'}")
        print("-" * 105)

        with open(csv_filename, mode='w', newline='') as csv_file:
            csv_writer = csv.writer(csv_file)
            csv_writer.writerow(["Threads", "Pattern", "Configuration", "Median_Perf_BW_GBs", "Predicted_BW_GBs", "Avg_Cycles_Per_Op"])

            for t in THREADS:
                pattern_str = generate_pattern(t)
                for label, binary, inst in CONFIGS:
                    perf_bw, pred_bw, cycles = run_benchmark(binary, inst, t)

                    results[label]["threads"].append(t)
                    results[label]["perf_bw"].append(perf_bw)
                    results[label]["pred_bw"].append(pred_bw)
                    results[label]["avg_cycles"].append(cycles)

                    csv_writer.writerow([t, pattern_str, label, perf_bw, pred_bw, cycles])

                    print(f"{t:<8} | {pattern_str:<25} | {label:<18} | {perf_bw:<14.2f} | {pred_bw:<14.2f} | {cycles:.2f}")
                print("-" * 105)

        print(f"\nData successfully saved to {csv_filename}")
        print(f"Raw logs saved in the '{LOG_DIR}' directory.")

    # Plotting
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 7))
    markers = ['o', 's', '^', 'D']
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

    for i, (label, _, _) in enumerate(CONFIGS):
        th_data = results[label]["threads"]
        perf_bw_data = results[label]["perf_bw"]
        pred_bw_data = results[label]["pred_bw"]
        cycles_data = results[label]["avg_cycles"]

        ax1.plot(th_data, perf_bw_data, marker=markers[i], color=colors[i],
                 linewidth=2, markersize=6, label=f'{label} (Perf Median)')
        ax1.plot(th_data, pred_bw_data, linestyle='--', color=colors[i],
                 linewidth=1.5, alpha=0.7, label=f'{label} (Predicted)')

        ax2.plot(th_data, cycles_data, marker=markers[i], color=colors[i],
                 linewidth=2, markersize=6, label=label)

    ax1.set_title(f'Memory Bandwidth vs Thread Count ({MEMORY_SIZE} Total)', fontsize=14)
    ax1.set_xlabel('Number of Threads', fontsize=12)
    ax1.set_ylabel('Bandwidth (GB/s)', fontsize=12)
    ax1.set_xticks(range(1, 64, 2))
    ax1.grid(True, linestyle='--', alpha=0.7)
    ax1.legend(fontsize=9, loc='upper left')

    ax2.set_title('Average Cycles per Operation vs Thread Count', fontsize=14)
    ax2.set_xlabel('Number of Threads', fontsize=12)
    ax2.set_ylabel('Cycles per Operation', fontsize=12)
    ax2.set_xticks(range(1, 64, 2))
    ax2.grid(True, linestyle='--', alpha=0.7)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    output_img = "benchmark_metrics_side_by_side.png"
    plt.savefig(output_img, dpi=300, bbox_inches='tight')
    print(f"Benchmark complete! Graph saved as '{output_img}'.")

if __name__ == "__main__":
    main()
