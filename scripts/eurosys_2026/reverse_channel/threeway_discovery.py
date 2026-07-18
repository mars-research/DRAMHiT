#!/usr/bin/env python3
import subprocess
import re
import sys

# 16KB = 16,384 Bytes = 256 Cachelines
CACHELINES_PER_16KB = 256

# A full hardware cycle is 12MB.
# 12MB = 768 chunks of 16KB.
# (Testing the full 1GB would take ~36 hours, so we cap it to one full 12MB hardware cycle).
CHUNKS_TO_TEST = 12 * 64

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
    cmd = f"stdbuf -o0 perf stat -a -e amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/ -I 100 -- ./mapping_test -p '{pattern}' -n 1000000 2>&1"

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
    print("[*] Starting Data Fabric 16KB Boundary Sweep")
    print(f"[*] Sweeping 12MB (One full hardware macro-cycle) = {CHUNKS_TO_TEST} boundaries.")
    print("[*] Note: 1,536 perf stat executions. This may take ~25 minutes.")
    print("-" * 105)
    print(f"| {'Chunk #':<8} | {'MB Offset':<10} | {'KB Offset':<10} | {'Cacheline':<10} | {'Even Block':<12} | {'Odd Block':<12} | {'Pair Map':<10} |")
    print("-" * 105)

    with open("fabric_16kb_map.csv", "w") as f:
        f.write("Chunk_ID,MB_Offset,KB_Offset,Cacheline_Start,Even_Ch,Odd_Ch,Pair\n")

        for chunk in range(CHUNKS_TO_TEST):
            base_line = chunk * CACHELINES_PER_16KB

            mb_offset = chunk // 64
            kb_offset = (chunk % 64) * 16

            # Test Even Block (Offset 0)
            ch_even = get_active_channel(base_line)

            # Test Odd Block (Offset 4)
            ch_odd = get_active_channel(base_line + 4)

            pair_str = f"ch{ch_even} ch{ch_odd}"

            # Visual boundary marker when crossing a 1MB line
            if chunk > 0 and chunk % 64 == 0:
                print("-" * 105)

            # Print dynamically to console
            print(f"| {chunk:<8} | {mb_offset:<7} MB | {kb_offset:<7} KB | {base_line:<10} | UMC {ch_even:<8} | UMC {ch_odd:<8} | {pair_str:<10} |")
            sys.stdout.flush()

            # Write to disk safely
            f.write(f"{chunk},{mb_offset},{kb_offset},{base_line},{ch_even},{ch_odd},{pair_str}\n")
            f.flush()

    print("-" * 105)
    print("[*] Sweep complete. Data saved to fabric_16kb_map.csv")

if __name__ == '__main__':
    main()
