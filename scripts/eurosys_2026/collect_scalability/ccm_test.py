import subprocess
import os
import matplotlib.pyplot as plt
import csv
import argparse

# --- Hardware Event Definitions ---
# Local CCM: Data Fabric to Compute Die (GMI Links). 32 Bytes per beat.
CCM_EVENTS = [f"amd_df/local_socket_inf0_inbound_data_beats_ccm0/"]
CCM_BYTES_PER_BEAT = 32

# --- Configuration ---
SOURCE_FILE = "benchmark.c"
BIN_RAND = "./benchmark_rand"
BIN_SEQ = "./benchmark_seq"
MEMORY_SIZE = "128m"
LOOKAHEAD = 16
THREADS = list(range(1, 9))
LOG_DIR = "benchmark_logs_bw_foo"

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

def run_isolated_collection(binary, inst, threads, events, bytes_per_event, run_label):
    """Runs the benchmark and calculates the max bandwidth from interval samples."""
    pattern = generate_pattern(threads)
    binary_name = os.path.basename(binary)
    log_filename = os.path.join(LOG_DIR, f"run_{binary_name}_{inst}_{threads}th_{run_label}.log")

    events_str = ",".join(events)

    cmd = [
        "stdbuf", "-oL", "-eL",
        "perf", "stat", "-x,", "-I", "100", "-a", "-e", events_str, "--",
        binary,
        "-m", MEMORY_SIZE,
        "-pattern", pattern,
        "-inst", inst,
        "-lookahead", str(LOOKAHEAD)
    ]

    try:
        with open(log_filename, "w") as log_file:
            subprocess.run(cmd, stdout=log_file, stderr=subprocess.STDOUT, check=True)

        with open(log_filename, "r") as log_file:
            output = log_file.read()

        collecting = False
        timestamps = []
        counts = []

        for line in output.split('\n'):
            # Marker tracking
            if "Start perf collection" in line:
                collecting = True
                continue

            if collecting and "End perf collection" in line:
                collecting = False
                continue

            # CSV Collection inside the block
            if collecting:
                parts = line.split(',')
                if len(parts) >= 2:
                    try:
                        ts = float(parts[0].strip())
                        val_str = parts[1].strip()
                        if val_str not in ('<not counted>', ''):
                            timestamps.append(ts)
                            counts.append(int(val_str))
                    except ValueError:
                        pass

        # Calculate max bandwidth among all sampled intervals
        max_bw = 0.0

        if len(timestamps) > 1:
            for i in range(1, len(timestamps)):
                delta_t = timestamps[i] - timestamps[i-1]
                if delta_t > 0:
                    bw = (counts[i] * bytes_per_event) / (delta_t * (1024**3))
                    if bw > max_bw:
                        max_bw = bw
        elif len(timestamps) == 1:
            # Fallback if execution was extremely fast and only 1 interval was captured
            bw = (counts[0] * bytes_per_event) / (0.1 * (1024**3))
            max_bw = bw

        return max_bw

    except subprocess.CalledProcessError:
        print(f"Error running {run_label} collection. Check {log_filename}.")
        return 0.0

def main():
    parser = argparse.ArgumentParser(description="Run Memory Benchmarks isolated to prevent multiplexing.")
    parser.add_argument('--inst', type=str, required=True, help="Instruction type (e.g., t0, t1)")
    args = parser.parse_args()

    os.makedirs(LOG_DIR, exist_ok=True)
    csv_filename = f"benchmark_data_{args.inst}.csv"

    configs = [
        ("Random", BIN_RAND, args.inst),
        ("Sequential", BIN_SEQ, args.inst)
    ]

    results = {config[0]: {"threads": [], "ccm_bw": []} for config in configs}

    if not os.path.exists(SOURCE_FILE):
        print(f"Error: {SOURCE_FILE} not found.")
        return

    compile_binaries()

    print(f"{'Threads':<8} | {'Config':<12} | {'Max Local CCM0 BW (GB/s)':<25}")
    print("-" * 50)

    with open(csv_filename, mode='w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(["Threads", "Pattern", "Configuration", "Max_CCM_BW_GBs"])

        for t in THREADS:
            pattern_str = generate_pattern(t)
            for label, binary, inst in configs:
                ccm_bw = run_isolated_collection(binary, inst, t, CCM_EVENTS, CCM_BYTES_PER_BEAT, "ccm")

                results[label]["threads"].append(t)
                results[label]["ccm_bw"].append(ccm_bw)

                csv_writer.writerow([t, pattern_str, label, ccm_bw])

                print(f"{t:<8} | {label:<12} | {ccm_bw:<25.2f}")
        print("-" * 50)

    print(f"\nData successfully saved to {csv_filename}")
    print(f"Raw logs saved in the '{LOG_DIR}' directory.")

    # --- Plotting (Merged) ---
    fig, ax = plt.subplots(figsize=(14, 8))

    metrics_style = {
        "ccm_bw": {"color": "#1f77b4", "marker": "o", "label": "Max Local CCM0 BW"}
    }

    config_style = {
        "Sequential": {"linestyle": "-", "alpha": 1.0},
        "Random": {"linestyle": "--", "alpha": 0.8}
    }

    for conf_label in ["Sequential", "Random"]:
        th_data = results[conf_label]["threads"]
        ls = config_style[conf_label]["linestyle"]
        alpha = config_style[conf_label]["alpha"]

        for metric_key, style in metrics_style.items():
            metric_data = results[conf_label][metric_key]

            ax.plot(th_data, metric_data, marker=style["marker"], linestyle=ls, linewidth=2,
                    alpha=alpha, color=style["color"], label=f'{style["label"]} ({conf_label})')

    ax.set_title(f"Max Memory Bandwidth: Sequential vs Random (Inst: {args.inst})", fontsize=16, pad=15)
    ax.set_xlabel('Number of Threads', fontsize=12)
    ax.set_ylabel('Bandwidth (GB/s)', fontsize=12)
    ax.set_xticks(range(1, 9, 1))
    ax.grid(True, linestyle=':', alpha=0.7)

    ax.legend(fontsize=10, loc='center left', bbox_to_anchor=(1.02, 0.5), borderaxespad=0.)

    plt.tight_layout()
    output_img = f"benchmark_counters_{args.inst}.png"
    plt.savefig(output_img, dpi=300, bbox_inches='tight')
    print(f"Benchmark complete! Graph saved as '{output_img}'.")

if __name__ == "__main__":
    main()
