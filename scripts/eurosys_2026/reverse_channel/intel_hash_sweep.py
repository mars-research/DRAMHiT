#!/usr/bin/env python3
import subprocess
import re
import sys
import argparse

def get_active_channel(base_line, iterations, interval, map_bin):
    # Test 4 contiguous cachelines (256 bytes)
    pattern = f"{base_line},{base_line+1},{base_line+2},{base_line+3}"

    # Monitor all 8 iMC channels
    events = ",".join([f"uncore_imc_{i}/cas_count_read/" for i in range(8)])

    cmd = f"stdbuf -oL -eL perf stat -a -e {events} -I {interval} -- {map_bin} -p '{pattern}' -n {iterations} 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    in_access_loop = False
    counts = {i: 0.0 for i in range(8)}

    # Regex to capture value, optional unit, and the iMC channel number
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

                # Normalize to MiB
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

    # Return the channel with the highest traffic, or -1 if no data
    return max(counts, key=counts.get) if any(counts.values()) else -1

def main():
    parser = argparse.ArgumentParser(description="Sweep memory strides to discover Intel iMC XOR hashing.")
    parser.add_argument("-s", "--stride-kb", type=int, default=16, help="Stride size in KB (default: 16)")
    parser.add_argument("-c", "--count", type=int, default=32, help="Number of strides to test (default: 32)")
    parser.add_argument("-b", "--base-mb", type=int, default=0, help="Base MB offset to start from (default: 0)")
    parser.add_argument("-n", "--iterations", type=int, default=30000000, help="Map tool iterations (default: 30000000)")
    parser.add_argument("-i", "--interval", type=int, default=1000, help="Perf interval ms (default: 1000)")
    parser.add_argument("--map-bin", default="./map", help="Path to map executable (default: ./map)")
    args = parser.parse_args()

    stride_bytes = args.stride_kb * 1024
    start_bytes = args.base_mb * 1024 * 1024

    print(f"[*] Sweeping Memory Boundaries")
    print(f"[*] Start Offset: {args.base_mb} MB")
    print(f"[*] Stride size : {args.stride_kb} KB")
    print(f"[*] Total steps : {args.count}")
    print("-" * 80)
    print(f"| {'Step':<5} | {'Byte Offset':<15} | {'Base Cacheline':<15} | {'Target iMC':<10} | {'Expected (No XOR)':<18} |")
    print("-" * 80)

    for step in range(args.count):
        current_offset = start_bytes + (step * stride_bytes)
        base_line = current_offset // 64

        # Calculate what the channel WOULD be if there were no XOR hashing
        # 1 block = 256 bytes.
        block_index = current_offset // 256
        expected_pattern_idx = block_index % 4
        expected_map = {0: 0, 1: 6, 2: 1, 3: 7}
        expected_imc = expected_map.get(expected_pattern_idx, -1)

        # Measure actual hardware routing
        ch = get_active_channel(base_line, args.iterations, args.interval, args.map_bin)

        # Flag if the hardware routing deviates from the naive 256B interleave
        divergence = "<-- XOR FLIP!" if ch != expected_imc and ch != -1 else ""

        print(f"| {step:<5} | {current_offset:<15} | {base_line:<15} | iMC {ch:<8} | iMC {expected_imc:<14} {divergence}")
        sys.stdout.flush()

    print("-" * 80)
    print("[*] Sweep complete.")

if __name__ == '__main__':
    main()
