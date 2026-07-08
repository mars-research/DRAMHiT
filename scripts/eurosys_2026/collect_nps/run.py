import subprocess
import re
import statistics
import matplotlib.pyplot as plt
import time
import csv

# --- CONFIGURATION ---
EXECUTABLE = "./main"  # Update this if your compiled C binary is named differently (e.g., ./dramhit_barrier)
MEMORY_SIZE = "1600m"
MAX_THREADS = 16
INTERVAL_MS = 100
INTERVAL_SEC = INTERVAL_MS / 1000.0

# Hardware Event Definitions
# Local CCM: Data Fabric to Compute Die (GMI Links). 32 Bytes per beat.
CCM_EVENTS = [f"amd_df/local_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]
CCM_BYTES_PER_BEAT = 32

# Remote CCM: Remote socket Data Fabric to Compute Die. 32 Bytes per beat.
REMOTE_CCM_EVENTS = [f"amd_df/remote_socket_inf0_inbound_data_beats_ccm{i}/" for i in range(8)]

# CS: Unified Memory Controllers to DDR5 RAM. 64 Bytes per beat.
CS_EVENTS = [f"amd_df/local_processor_read_data_beats_cs{i}/" for i in range(12)]
CS_BYTES_PER_BEAT = 64

def build_pattern(num_threads):
    """
    Allocates threads to NUMA nodes.
    1 to 8 threads: All on Node 0 accessing Memory on Node 0.
    9 to 16 threads: 8 on Node 0, the rest spill to Node 1, all accessing Memory on Node 0.
    """
    if num_threads <= 8:
        return f"n0a0t{num_threads}"
    else:
        spillover_threads = num_threads - 8
        return f"n0a0t8 n1a0t{spillover_threads}"

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
    
    ccm_results = []
    remote_ccm_results = []
    cs_results = []
    sw_results = []

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
        
        # 3. Collect CS (Memory Controllers to IOD)
        print("  Collecting CS (Memory Channel) telemetry...")
        cs_bw, sw_bw_from_cs = run_and_parse(t, pattern, CS_EVENTS, CS_BYTES_PER_BEAT)
        
        # Average the software reported bandwidth from all runs for the plot
        avg_sw_bw = (sw_bw_from_ccm + sw_bw_from_remote_ccm + sw_bw_from_cs) / 3.0
        
        ccm_results.append(ccm_bw)
        remote_ccm_results.append(remote_ccm_bw)
        cs_results.append(cs_bw)
        sw_results.append(avg_sw_bw)
        
        print(f"  [Result] SW: {avg_sw_bw:.2f} GB/s | CS (Mem): {cs_bw:.2f} GB/s | Local CCM: {ccm_bw:.2f} GB/s | Remote CCM: {remote_ccm_bw:.2f} GB/s")

    # --- Saving the Results to CSV ---
    csv_filename = "bandwidth_architecture_data.csv"
    print(f"\nSaving data to CSV: {csv_filename}")
    with open(csv_filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Threads", "Software Reported (GB/s)", "Mem Controller to IOD (CS) (GB/s)", "Local IOD to Compute Die (CCM) (GB/s)", "Remote IOD to Compute Die (Remote CCM) (GB/s)"])
        for t, sw, cs, ccm, r_ccm in zip(threads_list, sw_results, cs_results, ccm_results, remote_ccm_results):
            writer.writerow([t, f"{sw:.2f}", f"{cs:.2f}", f"{ccm:.2f}", f"{r_ccm:.2f}"])

    # --- Plotting the Results ---
    print("Generating plot: bandwidth_architecture_plot.png")
    
    plt.figure(figsize=(10, 6))
    plt.plot(threads_list, cs_results, marker='o', linestyle='-', linewidth=2, color='blue', label='Mem Controller to IOD (CS)')
    plt.plot(threads_list, ccm_results, marker='s', linestyle='--', linewidth=2, color='red', label='Local IOD to Compute Die (Local CCM)')
    plt.plot(threads_list, remote_ccm_results, marker='D', linestyle='-.', linewidth=2, color='orange', label='Remote IOD to Compute Die (Remote CCM)')
    plt.plot(threads_list, sw_results, marker='^', linestyle=':', linewidth=2, color='green', label='Software Reported Bandwidth')
    
    # Mark the architectural boundary where threads spill to the second NUMA node
    plt.axvline(x=8.5, color='gray', linestyle='-.', alpha=0.6, label='Spillover to Node 1')

    plt.title('AMD EPYC Memory Bandwidth Architecture Scaling', fontsize=14, fontweight='bold')
    plt.xlabel('Number of Threads', fontsize=12)
    plt.ylabel('Bandwidth (GB/s)', fontsize=12)
    plt.xticks(threads_list)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend(loc='lower right', fontsize=10)
    plt.tight_layout()
    
    plt.savefig("bandwidth_architecture_plot.png", dpi=300)
    print("Done! Data visualization saved successfully.")

if __name__ == "__main__":
    main()
