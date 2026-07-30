#!/usr/bin/env python3
import subprocess
import re
import sys

# 16KB = 16,384 Bytes = 256 Cachelines
CACHELINES_PER_16KB = 256
CHUNKS_PER_MB = 64

# Test the 1MB boundaries across a 24MB span (Two full 12MB hardware cycles)
MB_TO_TEST = 24

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
    print("[*] Starting Data Fabric 1MB Boundary Pattern Detection")
    print(f"[*] Probing the first 16KB chunk of each MB for {MB_TO_TEST} MB.")
    print(f"[*] Note: {MB_TO_TEST * 2} perf stat executions. This should take < 1 minute.")
    print("-" * 95)
    print(f"| {'MB Offset':<10} | {'Chunk #':<8} | {'Cacheline':<10} | {'Even Block':<12} | {'Odd Block':<12} | {'Pair Map':<10} |")
    print("-" * 95)

    with open("fabric_1mb_boundaries.csv", "w") as f:
        f.write("MB_Offset,Chunk_ID,Cacheline_Start,Even_Ch,Odd_Ch,Pair\n")

        for mb in range(MB_TO_TEST):
            # Target the very first chunk of this 1MB region
            chunk = mb * CHUNKS_PER_MB
            base_line = chunk * CACHELINES_PER_16KB

            # Test Even Block (Offset 0 in the chunk)
            ch_even = get_active_channel(base_line)

            # Test Odd Block (Offset 4 in the chunk)
            ch_odd = get_active_channel(base_line + 4)

            pair_str = f"ch{ch_even} ch{ch_odd}"

            # Visual marker every 12MB (One assumed hardware cycle)
            if mb > 0 and mb % 12 == 0:
                print("-" * 95)

            # Print dynamically to console
            print(f"| {mb:<7} MB | {chunk:<8} | {base_line:<10} | UMC {ch_even:<8} | UMC {ch_odd:<8} | {pair_str:<10} |")
            sys.stdout.flush()

            # Write to disk safely
            f.write(f"{mb},{chunk},{base_line},{ch_even},{ch_odd},{pair_str}\n")
            f.flush()

    print("-" * 95)
    print("[*] Pattern detection complete. Data saved to fabric_1mb_boundaries.csv")

if __name__ == '__main__':
    main()
