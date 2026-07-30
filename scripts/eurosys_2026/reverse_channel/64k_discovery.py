#!/usr/bin/env python3
import subprocess
import re
import sys

# 16KB = 16,384 Bytes = 256 Cachelines
CACHELINES_PER_16KB = 256
CHUNKS_PER_64KB = 4

# Test the 64KB boundaries across a 12MB span (One full hardware cycle)
# 12MB / 64KB = 192 groups
GROUPS_TO_TEST = 192

def parse_count(line):
    # Extracts numbers with commas
    match = re.search(r'([\d,]+)\s+amd_umc', line)
    if match:
        return int(match.group(1).replace(',', ''))
    return 0

def get_active_channel(base_line):
    # Generate the pattern for 4 contiguous cachelines (256 bytes)
    pattern = f"{base_line},{base_line+1},{base_line+2},{base_line+3}"

    # stdbuf -o0 ensures the C program's printf isn't buffered behind perf stat
    cmd = f"stdbuf -o0 perf stat -a -e amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/ -I 100 -- ./map -p '{pattern}' -n 1000000 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    in_access_loop = False
    counts = {0: 0, 1: 0, 2: 0}

    # Parse the interleaved output line-by-line
    for line in proc.stdout:
        if "Access loop starting now!" in line:
            in_access_loop = True
            continue
        if "Loop finished" in line:
            in_access_loop = False
            continue

        # Only accumulate stats while the main memory access loop is running
        if in_access_loop:
            if "amd_umc_0" in line:
                counts[0] += parse_count(line)
            elif "amd_umc_1" in line:
                counts[1] += parse_count(line)
            elif "amd_umc_2" in line:
                counts[2] += parse_count(line)

    proc.wait()

    # Return the channel that saw the most traffic
    dominant_ch = max(counts, key=counts.get)
    return dominant_ch

def main():
    print("[*] Starting Data Fabric 64KB Boundary Pattern Detection")
    print(f"[*] Probing the first chunk of each 64KB group for {GROUPS_TO_TEST} groups (12MB total).")
    print(f"[*] Note: {GROUPS_TO_TEST * 2} perf stat executions. This should take ~2-3 minutes.")
    print("-" * 105)
    print(f"| {'Offset':<12} | {'Chunk #':<8} | {'Cacheline':<10} | {'Even Block':<12} | {'Odd Block':<12} | {'Pair Map':<10} |")
    print("-" * 105)

    with open("fabric_64kb_boundaries.csv", "w") as f:
        f.write("Offset_KB,Chunk_ID,Cacheline_Start,Even_Ch,Odd_Ch,Pair\n")

        for group in range(GROUPS_TO_TEST):
            # Target the very first chunk of this 64KB region
            chunk = group * CHUNKS_PER_64KB
            base_line = chunk * CACHELINES_PER_16KB
            offset_kb = group * 64

            # Format offset for cleaner display (e.g., "1024 KB" -> "1 MB")
            if offset_kb % 1024 == 0:
                offset_str = f"{offset_kb//1024} MB"
            else:
                offset_str = f"{offset_kb} KB"

            # Test Even Block (Offset 0 in the chunk)
            ch_even = get_active_channel(base_line)

            # Test Odd Block (Offset 4 in the chunk)
            ch_odd = get_active_channel(base_line + 4)

            pair_str = f"ch{ch_even} ch{ch_odd}"

            # Visual marker every 1MB (16 groups of 64KB)
            if group > 0 and group % 16 == 0:
                print("-" * 105)

            # Print dynamically to console
            print(f"| {offset_str:<12} | {chunk:<8} | {base_line:<10} | UMC {ch_even:<8} | UMC {ch_odd:<8} | {pair_str:<10} |")
            sys.stdout.flush()

            # Write to disk safely
            f.write(f"{offset_kb},{chunk},{base_line},{ch_even},{ch_odd},{pair_str}\n")
            f.flush()

    print("-" * 105)
    print("[*] Pattern detection complete. Data saved to fabric_64kb_boundaries.csv")

if __name__ == '__main__':
    main()
