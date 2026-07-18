import subprocess
import re
import statistics
import matplotlib.pyplot as plt
import time
import csv

# --- CONFIGURATION ---
EXECUTABLE = "./main"  # Update this if your compiled C binary is named differently (e.g., ./dramhit_barrier)
MEMORY_SIZE = "1600m"
MAX_THREADS = 8
INTERVAL_MS = 100
INTERVAL_SEC = INTERVAL_MS / 1000.0

# Hardware Event Definitions
# Local CCM: Data Fabric to Compute Die (GMI Links). 32 Bytes per beat.
CCM_EVENTS = [f"amd_df/local_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]
CCM_BYTES_PER_BEAT = 32

# Remote CCM: Remote socket Data Fabric to Compute Die. 32 Bytes per beat.
REMOTE_CCM_EVENTS = [f"amd_df/remote_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]

# Local CS: Unified Memory Controllers to DDR5 RAM. 64 Bytes per beat.
CS_EVENTS = [f"amd_df/local_processor_read_data_beats_cs{i}/" for i in range(12)]
CS_BYTES_PER_BEAT = 64


# TODO: Update below to amd_umc_ events. and DON't add line to combine remote cs and local cs.
REMOTE_CS_EVENTS = [f"amd_umc_{i}/umc_cas_cmd.rd/" for i in range(12)]

def build_pattern(num_threads):
    """
    Generates a NUMA binding pattern string that keeps all threads on CPU node 0,
    but round-robins their memory accesses across NUMA nodes 0, 1, 2, and 3.
    """
    tokens = []
    num_numa_nodes = 4

    for i in range(num_threads):
        cpu_node = 0
        mem_node = i % num_numa_nodes
        tokens.append(f"n{cpu_node}a{mem_node}t1")

    return ", ".join(tokens)

# def build_pattern(num_threads):
#     """
#     Allocates threads to NUMA nodes.
#     1 to 4 threads: All on Node 0 accessing Memory on Node 0.
#     5 to 8 threads: 4 on Node 0, the rest spill to Node 1, all accessing Memory on Node 0.
#     """
#     if num_threads <= 4:
#         return f"n0a0t{num_threads}"
#     else:
#         spillover_threads = num_threads - 4
#         return f"n0a0t4, n0a1t{spillover_threads}"

def run_and_parse(threads, pattern, events, bytes_per_beat):
    """
    Runs the benchmark with perf, parses the 100ms intervals, and returns the median GB/s.
    """
    event_str = ",".join(events)
    cmd = [
        "sudo", "perf", "stat", "-a", "-I", str(INTERVAL_MS), "-e", event_str,
        "--", EXECUTABLE, "-size", MEMORY_SIZE, "-pattern", pattern
    ]

    print(f"  [>] Running pattern '{pattern}' for {len(events)} events...")

    # Run the command and capture stdout & stderr separately
    result = subprocess.run(cmd, capture_output=True, text=True)

    intervals = {}
    software_bw = 0.0

    # Regex patterns
    perf_regex = re.compile(r'^\s*([\d\.]+)\s+([\d\,]+|<not counted>)\s+(amd_df/.*)')
    sw_bw_regex = re.compile(r'Bandwidth\s+:\s+([\d\.]+)\s+GB/s')

    # Parse Software Bandwidth from stdout
    for line in result.stdout.split('\n'):
        sw_match = sw_bw_regex.search(line)
        if sw_match:
            software_bw = float(sw_match.group(1))

    # Parse Hardware Telemetry from stderr (perf outputs here)
    for line in result.stderr.split('\n'):
        match = perf_regex.search(line)
        if match:
            ts_str = match.group(1)
            count_str = match.group(2).replace(',', '')

            # Handle multiplexing/busy hardware if it occurs
            if count_str == "<not counted>":
                count = 0
            else:
                count = int(count_str)

            ts = float(ts_str)

            # Accumulate all counters belonging to this exact timestamp interval
            if ts not in intervals:
                intervals[ts] = 0
            intervals[ts] += count

    # Calculate GB/s for each valid interval
    bandwidths_gbps = []
    for ts, total_beats in intervals.items():
        # GB/s = (beats * bytes_per_beat) / (1024^3) / interval_in_seconds
        bw = (total_beats * bytes_per_beat) / (1024**3) / INTERVAL_SEC
        bandwidths_gbps.append(bw)

    # Return the median hardware bandwidth and the software reported bandwidth
    median_hw_bw = statistics.median(bandwidths_gbps) if bandwidths_gbps else 0.0
    return median_hw_bw, software_bw

def main():
    threads_list = list(range(1, MAX_THREADS + 1))

    # Raw Data Lists
    ccm_results = []
    remote_ccm_results = []
    cs_results = []
    remote_cs_results = []
    sw_results = []

    # Combined Totals Lists
    total_ccm_results = []
    total_cs_results = []

    print("=========================================================")
    print(" Starting EPYC Memory Bandwidth Architecture Telemetry   ")
    print("=========================================================")

    for t in threads_list:
        print(f"\n--- Testing with {t} Threads ---")
        pattern = build_pattern(t)

        # 1. Collect Local CCM (IOD to Compute Die)
        print("  Collecting Local CCM (GMI Links) telemetry...")
        ccm_bw, sw_bw_from_ccm = run_and_parse(t, pattern, CCM_EVENTS, CCM_BYTES_PER_BEAT)

        # 2. Collect Remote CCM (Remote IOD to Compute Die)
        print("  Collecting Remote CCM telemetry...")
        remote_ccm_bw, sw_bw_from_remote_ccm = run_and_parse(t, pattern, REMOTE_CCM_EVENTS, CCM_BYTES_PER_BEAT)

        # 3. Collect Local CS (Memory Controllers to IOD)
        print("  Collecting Local CS (Memory Channel) telemetry...")
        cs_bw, sw_bw_from_cs = run_and_parse(t, pattern, CS_EVENTS, CS_BYTES_PER_BEAT)

        # 4. Collect Remote CS (Remote Memory Controllers to DDR5)
        print("  Collecting Remote CS telemetry...")
        remote_cs_bw, sw_bw_from_remote_cs = run_and_parse(t, pattern, REMOTE_CS_EVENTS, CS_BYTES_PER_BEAT)

        # Calculate Averages and Totals
        avg_sw_bw = (sw_bw_from_ccm + sw_bw_from_remote_ccm + sw_bw_from_cs + sw_bw_from_remote_cs) / 4.0
        total_ccm_bw = ccm_bw + remote_ccm_bw
        total_cs_bw = cs_bw + remote_cs_bw

        # Append to lists
        ccm_results.append(ccm_bw)
        remote_ccm_results.append(remote_ccm_bw)
        cs_results.append(cs_bw)
        remote_cs_results.append(remote_cs_bw)
        sw_results.append(avg_sw_bw)
        total_ccm_results.append(total_ccm_bw)
        total_cs_results.append(total_cs_bw)

        print(f"  [Result] SW: {avg_sw_bw:.2f} GB/s")
        print(f"           Total CS : {total_cs_bw:.2f} GB/s (Local: {cs_bw:.2f} | Remote: {remote_cs_bw:.2f})")
        print(f"           Total CCM: {total_ccm_bw:.2f} GB/s (Local: {ccm_bw:.2f} | Remote: {remote_ccm_bw:.2f})")

    # --- Saving the Results to CSV ---
    csv_filename = "ccm_stress_test_data.csv"
    print(f"\nSaving data to CSV: {csv_filename}")
    with open(csv_filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([
            "Threads", "Software Reported (GB/s)",
            "Local CS (GB/s)", "Remote CS (GB/s)", "Total Combined CS (GB/s)",
            "Local CCM (GB/s)", "Remote CCM (GB/s)", "Total Combined CCM (GB/s)"
        ])
        for t, sw, cs, r_cs, t_cs, ccm, r_ccm, t_ccm in zip(
                threads_list, sw_results, cs_results, remote_cs_results, total_cs_results,
                ccm_results, remote_ccm_results, total_ccm_results):
            writer.writerow([
                t, f"{sw:.2f}",
                f"{cs:.2f}", f"{r_cs:.2f}", f"{t_cs:.2f}",
                f"{ccm:.2f}", f"{r_ccm:.2f}", f"{t_ccm:.2f}"
            ])

    # --- Plotting the Results ---
    print("Generating plot: ccm_stress_test.png")

    plt.figure(figsize=(12, 7))

    # 1. Plot the combined totals prominently
    plt.plot(threads_list, total_cs_results, marker='o', linestyle='-', linewidth=3, color='black', label='Total Mem Controller (CS Local+Remote)')
    plt.plot(threads_list, total_ccm_results, marker='s', linestyle='-', linewidth=3, color='darkred', label='Total Die Inbound (CCM Local+Remote)')

    # 2. Plot the breakdown components transparently so they don't clutter the main view
    plt.plot(threads_list, cs_results, marker='.', linestyle='--', linewidth=1.5, color='blue', alpha=0.6, label='Local CS')
    plt.plot(threads_list, remote_cs_results, marker='.', linestyle='--', linewidth=1.5, color='cyan', alpha=0.8, label='Remote CS')
    plt.plot(threads_list, ccm_results, marker='.', linestyle='-.', linewidth=1.5, color='red', alpha=0.6, label='Local CCM')
    plt.plot(threads_list, remote_ccm_results, marker='.', linestyle='-.', linewidth=1.5, color='orange', alpha=0.8, label='Remote CCM')

    # 3. Plot software reported
    plt.plot(threads_list, sw_results, marker='^', linestyle=':', linewidth=2, color='green', label='Software Reported Bandwidth')

    # Mark the architectural boundary where threads spill to the second NUMA node
    plt.axvline(x=4.5, color='gray', linestyle='-.', alpha=0.6, label='Spillover to Node 1')

    plt.title('AMD EPYC Memory Bandwidth Architecture Scaling (w/ Totals)', fontsize=14, fontweight='bold')
    plt.xlabel('Number of Threads', fontsize=12)
    plt.ylabel('Bandwidth (GB/s)', fontsize=12)
    plt.xticks(threads_list)
    plt.grid(True, linestyle='--', alpha=0.7)

    # Put the legend outside the plot to avoid covering lines
    plt.legend(bbox_to_anchor=(1.04, 1), loc="upper left", fontsize=10)
    plt.tight_layout()

    plt.savefig("ccm_stress_test.png", dpi=300, bbox_inches="tight")
    print("Done! Data visualization saved successfully.")

if __name__ == "__main__":
    main()
