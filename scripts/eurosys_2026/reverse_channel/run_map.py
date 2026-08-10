#!/usr/bin/env python3
import subprocess
import re
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(description="Reverse engineer physical cacheline to iMC mapping.")
    parser.add_argument("-p", "--pattern", required=True, help="Cacheline access pattern (e.g., '0,1,2,3,4')")
    parser.add_argument("-n", "--iterations", default="10000000", help="Number of iterations for the access loop")
    parser.add_argument("--map-bin", default="./map", help="Path to your map executable (default: ./map)")
    parser.add_argument("-i", "--interval", default="100", help="perf stat sampling interval in ms (default: 100)")
    args = parser.parse_args()

    # 1. Build the perf command for all 8 memory channels (0 to 7)
    events = []
    for i in range(8):
        events.extend(["-e", f"uncore_imc_{i}/cas_count_read/"])

    # Use stdbuf to unbuffer both stdout and stderr of the command
    cmd = [
        "stdbuf", "-oL", "-eL", 
        "perf", "stat", "-I", args.interval
    ] + events + ["--", args.map_bin, "-p", args.pattern, "-n", str(args.iterations)]

    print(f"[*] Executing: {' '.join(cmd)}\n")

    # Merge stdout and stderr so we get chronological interleaving of perf and ./map
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    in_loop = False
    channel_data = {i: [] for i in range(8)}

    # Regex breakdown:
    # 1. Matches timestamp (ignored in capture)
    # 2. Captures value (e.g., 28.02)
    # 3. Captures unit (e.g., MiB)
    # 4. Captures channel ID (e.g., 0)
    regex = re.compile(r'^\s*[\d\.]+\s+([\d\.,]+)\s+([A-Za-z]+)\s+uncore_imc_(\d+)/cas_count_read/')

    try:
        for line in process.stdout:
            # Echo the live output to the console
            sys.stdout.write(line)
            sys.stdout.flush()

            # State machine: only parse data when inside the loop
            if "[*] Access loop starting now!" in line:
                in_loop = True
                continue
            elif "[*] Loop finished" in line:
                in_loop = False
                break

            if in_loop:
                match = regex.search(line)
                if match:
                    val_str, unit, channel_str = match.groups()
                    val = float(val_str.replace(',', ''))
                    channel = int(channel_str)

                    # Normalize bandwidth to MiB
                    if unit in ("B", "Bytes"):
                        val /= (1024 ** 2)
                    elif unit in ("KiB", "KB"):
                        val /= 1024
                    elif unit in ("GiB", "GB"):
                        val *= 1024

                    if channel in channel_data:
                        channel_data[channel].append(val)

    except KeyboardInterrupt:
        print("\n[*] Interrupted by user.")
    finally:
        process.terminate()
        process.wait()

    # 2. Analyze the extracted metrics
    print("\n" + "="*55)
    print(f"   iMC Channel Mapping Analysis for Pattern: [{args.pattern}]")
    print("="*55)

    averages = {}
    for ch in range(8):
        data = channel_data[ch]
        # Calculate average. If no data (e.g., loop was too fast), default to 0
        avg = sum(data) / len(data) if data else 0.0
        averages[ch] = avg
        print(f"  uncore_imc_{ch}: {avg:>8.2f} MiB/interval (Avg over {len(data):>2} samples)")

    # 3. Determine the targeted channel
    print("-" * 55)
    if any(averages.values()):
        max_ch = max(averages, key=averages.get)
        max_val = averages[max_ch]
        
        # Calculate percentage of traffic hitting the dominant channel
        total_traffic = sum(averages.values())
        percentage = (max_val / total_traffic) * 100 if total_traffic > 0 else 0

        print(f"  [+] Active Channel Detected: uncore_imc_{max_ch}")
        print(f"  [+] Dominant Throughput:     {max_val:.2f} MiB")
        print(f"  [+] Traffic Concentration:   {percentage:.1f}% of total CAS reads")
    else:
        print("  [-] No valid perf data collected during the loop window.")
    print("="*55)

if __name__ == "__main__":
    main()
