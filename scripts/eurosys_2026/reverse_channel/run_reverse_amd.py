#!/usr/bin/env python3

import argparse
import subprocess
import csv
import sys
import os
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser(description="Collect and plot UMC and CCM memory bandwidth data from perf stat.")
    parser.add_argument("-o", "--output-csv", default="bandwidth_results.csv",
                        help="Output CSV file name (default: bandwidth_results.csv)")
    parser.add_argument("-i", "--output-img", default="bandwidth_plot.png",
                        help="Output PNG image file name (default: bandwidth_plot.png)")
    parser.add_argument("-t", "--max-threads", type=int, default=8,
                        help="Maximum number of threads to test (default: 8)")
    parser.add_argument("-p", "--program", default="./amd_re",
                        help="Target executable to run (default: ./amd_re)")
    parser.add_argument("-e", "--events",
                        default="amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/,amd_df/local_socket_inf0_inbound_data_beats_ccm0/,amd_df/local_socket_inf0_inbound_data_beats_ccm4/",
                        help="Events string to pass to perf stat")

    args = parser.parse_args()
    results = []

    # Hardcoded UMC and CCM counters based on the default events string
    umc0_ctr = "amd_umc_0/umc_cas_cmd.rd/"
    umc1_ctr = "amd_umc_1/umc_cas_cmd.rd/"
    umc2_ctr = "amd_umc_2/umc_cas_cmd.rd/"
    ccm0_ctr = "amd_df/local_socket_inf0_inbound_data_beats_ccm0/"
    ccm4_ctr = "amd_df/local_socket_inf0_inbound_data_beats_ccm4/"

    print(f"[*] Starting memory bandwidth collection.")
    print(f"[*] Counters monitored:")
    print(f"    - {umc0_ctr} (64 Bytes/Unit)")
    print(f"    - {umc1_ctr} (64 Bytes/Unit)")
    print(f"    - {umc2_ctr} (64 Bytes/Unit)")
    print(f"    - {ccm0_ctr} (32 Bytes/Unit)")
    print(f"    - {ccm4_ctr} (32 Bytes/Unit)")
    print(f"[*] CSV will be saved to: {args.output_csv}")
    print(f"[*] Plot will be saved to: {args.output_img}")
    print(f"[*] Debug logs will be saved as: test_<threadnum>\n")

    for threads in range(1, args.max_threads + 1):
        log_file = f"test_{threads}"
        print(f"[*] Running {args.program} with {threads} threads (logging to {log_file})...")

        # Explicitly passing "-x," to enforce comma separation
        command = f"stdbuf -o0 perf stat -x, -e {args.events} -I1 -- {args.program} {threads} > {log_file} 2>&1"
        subprocess.run(command, shell=True)

        if not os.path.exists(log_file):
            print(f"[!] Error: {log_file} was not generated. Did the command fail?", file=sys.stderr)
            continue

        # No longer tracking prev_time, just the multiplier and label
        trackers = {
            umc0_ctr: {'mult': 64, 'label': 'UMC0'},
            umc1_ctr: {'mult': 64, 'label': 'UMC1'},
            umc2_ctr: {'mult': 64, 'label': 'UMC2'},
            ccm0_ctr: {'mult': 32, 'label': 'CCM0'},
            ccm4_ctr: {'mult': 32, 'label': 'CCM4'}
        }

        # Store calculated bandwidths grouped by timestamp string
        time_points = {}
        is_collecting = False

        with open(log_file, "r") as f:
            for line in f:
                if "[*] Spawning" in line:
                    is_collecting = True
                    time_points.clear()
                    continue
                elif "[*] All threads finished execution." in line:
                    is_collecting = False
                    continue

                if is_collecting and not line.startswith('#'):
                    # CSV format parsing
                    parts = [p.strip() for p in line.strip().split(',')]

                    # Ensure the line has enough columns for timestamp, value, unit, event, time_enabled
                    if len(parts) >= 5:
                        ts_str = parts[0]
                        raw_value = parts[1]
                        event_name = parts[3]
                        raw_time_enabled_ns = parts[4]

                        for c_key, c_data in trackers.items():
                            if c_key in event_name:
                                try:
                                    # perf might output "<not counted>" or similar strings if idle
                                    if raw_value.isdigit():
                                        counter_value = int(raw_value)
                                        time_enabled_ns = float(raw_time_enabled_ns)

                                        if time_enabled_ns > 0:
                                            # Bytes / ns is equivalent to GB/s
                                            bw_gbps = (counter_value * c_data['mult']) / time_enabled_ns

                                            # Initialize timestamp entry if it doesn't exist
                                            if ts_str not in time_points:
                                                time_points[ts_str] = {}

                                            time_points[ts_str][c_data['label']] = bw_gbps
                                except ValueError:
                                    continue

        # Extract only complete time points (where all 5 counters successfully reported)
        valid_ts_keys = [ts for ts, data in time_points.items()
                         if 'UMC0' in data and 'UMC1' in data and 'UMC2' in data
                         and 'CCM0' in data and 'CCM4' in data]

        # Sort chronologically by the actual float time values
        valid_ts_keys.sort(key=float)

        sample_count = len(valid_ts_keys)

        if sample_count > 0:
            mid_idx = sample_count // 2

            # If odd number of samples, pick the exact middle time point
            if sample_count % 2 == 1:
                mid_ts = valid_ts_keys[mid_idx]
                umc0_bw = time_points[mid_ts]['UMC0']
                umc1_bw = time_points[mid_ts]['UMC1']
                umc2_bw = time_points[mid_ts]['UMC2']
                ccm0_bw = time_points[mid_ts]['CCM0']
                ccm4_bw = time_points[mid_ts]['CCM4']

            # If even number of samples, average the two middle time points
            else:
                ts1 = valid_ts_keys[mid_idx - 1]
                ts2 = valid_ts_keys[mid_idx]
                umc0_bw = (time_points[ts1]['UMC0'] + time_points[ts2]['UMC0']) / 2.0
                umc1_bw = (time_points[ts1]['UMC1'] + time_points[ts2]['UMC1']) / 2.0
                umc2_bw = (time_points[ts1]['UMC2'] + time_points[ts2]['UMC2']) / 2.0
                ccm0_bw = (time_points[ts1]['CCM0'] + time_points[ts2]['CCM0']) / 2.0
                ccm4_bw = (time_points[ts1]['CCM4'] + time_points[ts2]['CCM4']) / 2.0
        else:
            umc0_bw = umc1_bw = umc2_bw = ccm0_bw = ccm4_bw = 0.0
            print(f"[!] Warning: No fully complete samples collected at {threads} threads.", file=sys.stderr)

        results.append({
            'thread': threads,
            'umc0_bw': umc0_bw,
            'umc1_bw': umc1_bw,
            'umc2_bw': umc2_bw,
            'ccm0_bw': ccm0_bw,
            'ccm4_bw': ccm4_bw,
            'samples_collected': sample_count
        })

        print(f"    -> Threads: {threads} | UMC0: {umc0_bw:6.2f} | UMC1: {umc1_bw:6.2f} | UMC2: {umc2_bw:6.2f} | CCM0: {ccm0_bw:6.2f} | CCM4: {ccm4_bw:6.2f} (GB/s) | Valid: {sample_count}")

    # Write the results to a CSV file
    with open(args.output_csv, mode='w', newline='') as csv_file:
        fieldnames = ['thread', 'UMC0 bandwidth (GB/s)', 'UMC1 bandwidth (GB/s)', 'UMC2 bandwidth (GB/s)',
                      'CCM0 bandwidth (GB/s)', 'CCM4 bandwidth (GB/s)', 'amount of samples collected']
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

        writer.writeheader()
        for row in results:
            writer.writerow({
                'thread': row['thread'],
                'UMC0 bandwidth (GB/s)': f"{row['umc0_bw']:.6f}",
                'UMC1 bandwidth (GB/s)': f"{row['umc1_bw']:.6f}",
                'UMC2 bandwidth (GB/s)': f"{row['umc2_bw']:.6f}",
                'CCM0 bandwidth (GB/s)': f"{row['ccm0_bw']:.6f}",
                'CCM4 bandwidth (GB/s)': f"{row['ccm4_bw']:.6f}",
                'amount of samples collected': row['samples_collected']
            })
    print(f"\n[*] Data successfully saved to '{args.output_csv}'.")

    # Generate and save the plot
    if results:
        threads_list = [r['thread'] for r in results]
        umc0_list = [r['umc0_bw'] for r in results]
        umc1_list = [r['umc1_bw'] for r in results]
        umc2_list = [r['umc2_bw'] for r in results]
        ccm0_list = [r['ccm0_bw'] for r in results]
        ccm4_list = [r['ccm4_bw'] for r in results]

        plt.figure(figsize=(12, 7))

        # Plot individual UMC lines (3) and CCM lines (2)
        plt.plot(threads_list, umc0_list, marker='o', linestyle='--', color='b', alpha=0.7, linewidth=2, label='UMC0')
        plt.plot(threads_list, umc1_list, marker='s', linestyle='--', color='g', alpha=0.7, linewidth=2, label='UMC1')
        plt.plot(threads_list, umc2_list, marker='^', linestyle='--', color='m', alpha=0.7, linewidth=2, label='UMC2')

        plt.plot(threads_list, ccm0_list, marker='d', linestyle='-.', color='c', alpha=0.9, linewidth=2, label='CCM0')
        plt.plot(threads_list, ccm4_list, marker='v', linestyle='-.', color='orange', alpha=0.9, linewidth=2, label='CCM4')

        plt.title('UMC & CCM Memory Bandwidth vs. Thread Count', fontsize=14)
        plt.xlabel('Number of Threads', fontsize=12)
        plt.ylabel('Bandwidth at Median Time Point (GB/s)', fontsize=12)

        plt.xticks(threads_list)
        plt.grid(True, linestyle='--', alpha=0.7)
        plt.legend(loc='upper left')
        plt.tight_layout()

        plt.savefig(args.output_img, dpi=300)
        print(f"[*] Plot successfully saved to '{args.output_img}'.")
    else:
        print("[!] No data collected, skipping plot generation.")

if __name__ == "__main__":
    main()
