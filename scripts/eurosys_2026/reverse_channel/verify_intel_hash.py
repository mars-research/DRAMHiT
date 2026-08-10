#!/usr/bin/env python3
import subprocess
import re
import sys
import argparse

def get_active_channel(cacheline, iterations, interval, map_bin):
    # Pass just the specific cacheline to the map tool
    pattern = str(cacheline)

    # Generate event string for Intel iMC channels 0-7
    events = ",".join([f"uncore_imc_{i}/cas_count_read/" for i in range(8)])

    cmd = f"stdbuf -oL -eL perf stat -a -e {events} -I {interval} -- {map_bin} -p '{pattern}' -n {iterations} 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    in_access_loop = False
    counts = {i: 0.0 for i in range(8)}

    # Regex to capture value, optional unit (MiB/KiB/etc), and the Intel iMC channel number
    regex = re.compile(r'^\s*[\d\.]+\s+([\d\.,]+)\s*(MiB|KiB|B|Bytes|GiB|KB|GB)?\s+uncore_imc_(\d+)/cas_count_read/')

    for line in proc.stdout:
        if "Access loop starting now!" in line:
            in_access_loop = True
            continue
        if "Loop finished" in line:
            in_access_loop = False
            continue

        if in_access_loop:
            match = regex.search(line)
            if match:
                val_str = match.group(1).replace(',', '')
                unit = match.group(2)
                channel = int(match.group(3))

                val = float(val_str)

                # Normalize bandwidth to MiB
                if unit:
                    if unit in ("B", "Bytes"):
                        val /= (1024 ** 2)
                    elif unit in ("KiB", "KB"):
                        val /= 1024
                    elif unit in ("GiB", "GB"):
                        val *= 1024

                if channel in counts:
                    counts[channel] += val

    proc.wait()

    # Return the channel with the highest traffic
    return max(counts, key=counts.get) if any(counts.values()) else -1

def main():
    parser = argparse.ArgumentParser(description="Verify if specific cachelines route to iMC 0.")
    parser.add_argument("-c", "--cachelines", required=True, type=str,
                        help="Comma-separated list of cacheline indices (e.g., '16290652, 8508157')")
    parser.add_argument("-n", "--iterations", type=int, default=30000000,
                        help="Map tool iterations (default: 30000000)")
    parser.add_argument("-i", "--interval", type=int, default=1000,
                        help="Perf interval ms (default: 1000)")
    parser.add_argument("--map-bin", default="./map",
                        help="Path to map executable (default: ./map)")
    args = parser.parse_args()

    # Parse the input list securely
    try:
        cachelines_to_test = [int(x.strip()) for x in args.cachelines.split(",") if x.strip()]
    except ValueError:
        print("[-] Error: --cachelines must be a comma-separated list of integers.")
        sys.exit(1)

    print(f"[*] Beginning verification of {len(cachelines_to_test)} cachelines...")
    print("-" * 68)
    print(f"| {'Cacheline':<12} | {'Physical Addr':<15} | {'Detected iMC':<12} | {'Status':<15} |")
    print("-" * 68)

    passed_count = 0

    for line in cachelines_to_test:
        phys_addr = line * 64  # Cachelines are 64 bytes

        ch = get_active_channel(line, args.iterations, args.interval, args.map_bin)

        if ch == 0:
            status = "\033[92m[PASS]\033[0m"  # Green PASS
            passed_count += 1
        elif ch == -1:
            status = "\033[93m[NO DATA]\033[0m" # Yellow NO DATA
        else:
            status = f"\033[91m[FAIL] -> {ch}\033[0m" # Red FAIL

        print(f"| {line:<12} | 0x{phys_addr:<13x} | iMC {ch:<8} | {status:<24} |")
        sys.stdout.flush()

    print("-" * 68)
    print(f"[*] Verification Complete: {passed_count}/{len(cachelines_to_test)} cachelines verified on iMC 0.")

if __name__ == '__main__':
    main()
