import subprocess
import re
import os
import matplotlib.pyplot as plt
import csv
import argparse

# --- Hardware Event Definitions ---
# Local CCM: Data Fabric to Compute Die (GMI Links). 32 Bytes per beat.
CCM_EVENTS = [f"amd_df/local_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]
CCM_BYTES_PER_BEAT = 32

# Remote CCM: Remote socket Data Fabric to Compute Die. 32 Bytes per beat.
REMOTE_CCM_EVENTS = [f"amd_df/remote_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]

# Local CS: Unified Memory Controllers to DDR5 RAM. 64 Bytes per beat.
CS_EVENTS = [f"amd_df/local_processor_read_data_beats_cs{i}/" for i in range(12)]
CS_BYTES_PER_BEAT = 64

# UMC CAS Commands
UMC_EVENTS = [f"amd_umc_{i}/umc_cas_cmd.rd/" for i in range(12)]
UMC_BYTES_PER_READ = 64  # Assuming 64-byte cache line reads

# --- Configuration ---
SOURCE_FILE = "benchmark.c"
BIN_RAND = "./benchmark_rand"
BIN_SEQ = "./benchmark_seq"
MEMORY_SIZE = "128m"
LOOKAHEAD = 16
THREADS = list(range(20, 21))
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
        parts.append(f"n{node}a{0}t{t_node}")
        threads_left -= t_node
        node += 1
    return ",".join(parts)

def run_isolated_collection(binary, inst, threads, events, bytes_per_event, run_label):
    """Runs the benchmark for a specific subset of events to avoid PMU multiplexing."""
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

        avg_cycles = 0.0
        predicted_bw = 0.0
        timer_started = False
        total_counts = 0
        time_points = set()

        for line in output.split('\n'):
            if "Timer started." in line:
                timer_started = True

            match_cycles = re.search(r"Average cycle per operation:\s+([\d\.]+)", line)
            if match_cycles:
                avg_cycles = float(match_cycles.group(1))

            match_pred = re.search(r"Predicted peak ban[d]?width:\s+([\d\.]+)", line, re.IGNORECASE)
            if match_pred:
                predicted_bw = float(match_pred.group(1))

            if not timer_started:
                continue

            parts = line.split(',')
            if len(parts) >= 4:
                try:
                    ts = float(parts[0])
                    val_str = parts[1]

                    if val_str == '<not counted>' or val_str == '':
                        continue

                    val = int(val_str)
                    time_points.add(ts)
                    total_counts += val

                except ValueError:
                    pass

        # Calculate active elapsed duration (0.1s intervals)
        duration_s = len(time_points) * 0.1 if time_points else 0.001

        # Calculate GB/s
        calculated_bw = (total_counts * bytes_per_event) / (duration_s * (1024**3))

        return calculated_bw, predicted_bw, avg_cycles

    except subprocess.CalledProcessError:
        print(f"Error running {run_label} collection. Check {log_filename}.")
        return 0.0, 0.0, 0.0


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

    results = {config[0]: {"threads": [], "ccm_bw": [], "remote_ccm_bw": [], "total_ccm_bw": [], "cs_bw": [], "umc_bw": [], "pred_bw": [], "avg_cycles": []} for config in configs}

    if os.path.exists(csv_filename):
        print(f"Found existing data in '{csv_filename}'.")
        print("Skipping benchmark execution and generating plots directly...\n")

        with open(csv_filename, mode='r') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for row in csv_reader:
                label = row["Configuration"]
                if label in results:
                    results[label]["threads"].append(int(row["Threads"]))
                    results[label]["ccm_bw"].append(float(row["CCM_BW_GBs"]))
                    results[label]["remote_ccm_bw"].append(float(row["Remote_CCM_BW_GBs"]))

                    total_ccm = float(row.get("Total_CCM_BW_GBs", float(row["CCM_BW_GBs"]) + float(row["Remote_CCM_BW_GBs"])))
                    results[label]["total_ccm_bw"].append(total_ccm)

                    results[label]["cs_bw"].append(float(row["CS_BW_GBs"]))
                    results[label]["umc_bw"].append(float(row["UMC_BW_GBs"]))
                    results[label]["pred_bw"].append(float(row["Predicted_BW_GBs"]))
                    results[label]["avg_cycles"].append(float(row["Avg_Cycles_Per_Op"]))
    else:
        if not os.path.exists(SOURCE_FILE):
            print(f"Error: {SOURCE_FILE} not found.")
            return

        compile_binaries()

        print(f"{'Threads':<8} | {'Config':<12} | {'Local CCM':<12} | {'Rem CCM':<10} | {'Total CCM':<12} | {'CS (GB/s)':<12} | {'UMC (GB/s)':<12} | {'Pred BW':<10} | {'Cycles'}")
        print("-" * 115)

        with open(csv_filename, mode='w', newline='') as csv_file:
            csv_writer = csv.writer(csv_file)
            csv_writer.writerow(["Threads", "Pattern", "Configuration", "CCM_BW_GBs", "Remote_CCM_BW_GBs", "Total_CCM_BW_GBs", "CS_BW_GBs", "UMC_BW_GBs", "Predicted_BW_GBs", "Avg_Cycles_Per_Op"])

            for t in THREADS:
                pattern_str = generate_pattern(t)
                for label, binary, inst in configs:
                    ccm_bw, pred_bw, cycles = run_isolated_collection(binary, inst, t, CCM_EVENTS, CCM_BYTES_PER_BEAT, "ccm")
                    remote_ccm_bw, _, _     = run_isolated_collection(binary, inst, t, REMOTE_CCM_EVENTS, CCM_BYTES_PER_BEAT, "remote_ccm")
                    cs_bw, _, _             = run_isolated_collection(binary, inst, t, CS_EVENTS, CS_BYTES_PER_BEAT, "cs")
                    umc_bw, _, _            = run_isolated_collection(binary, inst, t, UMC_EVENTS, UMC_BYTES_PER_READ, "umc")

                    total_ccm_bw = ccm_bw + remote_ccm_bw

                    results[label]["threads"].append(t)
                    results[label]["ccm_bw"].append(ccm_bw)
                    results[label]["remote_ccm_bw"].append(remote_ccm_bw)
                    results[label]["total_ccm_bw"].append(total_ccm_bw)
                    results[label]["cs_bw"].append(cs_bw)
                    results[label]["umc_bw"].append(umc_bw)
                    results[label]["pred_bw"].append(pred_bw)
                    results[label]["avg_cycles"].append(cycles)

                    csv_writer.writerow([t, pattern_str, label, ccm_bw, remote_ccm_bw, total_ccm_bw, cs_bw, umc_bw, pred_bw, cycles])

                    print(f"{t:<8} | {label:<12} | {ccm_bw:<12.2f} | {remote_ccm_bw:<10.2f} | {total_ccm_bw:<12.2f} | {cs_bw:<12.2f} | {umc_bw:<12.2f} | {pred_bw:<10.2f} | {cycles:.2f}")
            print("-" * 115)

        print(f"\nData successfully saved to {csv_filename}")
        print(f"Raw logs saved in the '{LOG_DIR}' directory.")

    # --- Plotting (Merged) ---
    fig, ax = plt.subplots(figsize=(14, 8))

    # Define standard colors and markers mapping directly to the specific hardware metrics
    metrics_style = {
        "ccm_bw": {"color": "#1f77b4", "marker": "o", "label": "Local CCM BW"},
        "remote_ccm_bw": {"color": "#8c564b", "marker": "x", "label": "Remote CCM BW"},
        "total_ccm_bw": {"color": "#d62728", "marker": "D", "label": "Total CCM BW"},
        "cs_bw": {"color": "#ff7f0e", "marker": "s", "label": "Local CS BW"},
        "umc_bw": {"color": "#2ca02c", "marker": "^", "label": "UMC BW"},
        "pred_bw": {"color": "grey", "marker": "", "label": "Predicted Target BW"}
    }

    # Use distinct line styles for the memory patterns
    config_style = {
        "Sequential": {"linestyle": "-", "alpha": 1.0},
        "Random": {"linestyle": "--", "alpha": 0.8}
    }

    # Plot both Sequential and Random configurations
    for conf_label in ["Sequential", "Random"]:
        th_data = results[conf_label]["threads"]
        ls = config_style[conf_label]["linestyle"]
        alpha = config_style[conf_label]["alpha"]

        for metric_key, style in metrics_style.items():
            metric_data = results[conf_label][metric_key]

            if metric_key == "pred_bw":
                # Thinner lines, no markers for predicted bandwidth to reduce visual clutter
                ax.plot(th_data, metric_data, linestyle=ls, alpha=0.5, linewidth=1.5, color=style["color"],
                        label=f'{style["label"]} ({conf_label})')
            else:
                ax.plot(th_data, metric_data, marker=style["marker"], linestyle=ls, linewidth=2,
                        alpha=alpha, color=style["color"], label=f'{style["label"]} ({conf_label})')

    # Formatting the Plot
    ax.set_title(f"Memory Bandwidth: Sequential vs Random (Inst: {args.inst})", fontsize=16, pad=15)
    ax.set_xlabel('Number of Threads', fontsize=12)
    ax.set_ylabel('Bandwidth (GB/s)', fontsize=12)
    ax.set_xticks(range(1, 65, 4))
    ax.grid(True, linestyle=':', alpha=0.7)

    # Move legend to the right side so it doesn't cover up important lines
    ax.legend(fontsize=10, loc='center left', bbox_to_anchor=(1.02, 0.5), borderaxespad=0.)

    plt.tight_layout()
    output_img = f"benchmark_counters_{args.inst}.png"
    plt.savefig(output_img, dpi=300, bbox_inches='tight')
    print(f"Benchmark complete! Graph saved as '{output_img}'.")

if __name__ == "__main__":
    main()
