#!/usr/bin/env python3
import subprocess
import re
import sys

# 1 Block = 4 Cachelines = 256 Bytes
# 16 Blocks = 4 KB
# We will test the first 128 blocks (32 KB total) to find where the hash flips.

def parse_count(line):
    match = re.search(r'([\d,]+)\s+amd_umc', line)
    if match:
        return int(match.group(1).replace(',', ''))
    return 0

def get_active_channel(base_line):
    pattern = f"{base_line},{base_line+1},{base_line+2},{base_line+3}"
    cmd = f"stdbuf -o0 perf stat -a -e amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/ -I 100 -- ./mapping_test -p '{pattern}' -n 1000000 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    in_access_loop = False
    counts = {0: 0, 1: 0, 2: 0}

    for line in proc.stdout:
        if "Access loop starting now!" in line:
            in_access_loop = True
            continue
        if "Loop finished" in line:
            in_access_loop = False
            continue

        if in_access_loop:
            if "amd_umc_0" in line:
                counts[0] += parse_count(line)
            elif "amd_umc_1" in line:
                counts[1] += parse_count(line)
            elif "amd_umc_2" in line:
                counts[2] += parse_count(line)

    proc.wait()
    return max(counts, key=counts.get) if any(counts.values()) else -1

def main():
    TARGET_MB = 0  # We test Region 0 (Cachelines 0 to 16383)
    START_CACHELINE = TARGET_MB * 16384
    BLOCKS_TO_TEST = 128  # 128 blocks * 256B = 32 KB

    print(f"[*] Sweeping Intra-MB Hash for MB Region {TARGET_MB}")
    print(f"[*] Testing first {BLOCKS_TO_TEST} blocks sequentially...")
    print("-" * 75)
    print(f"| {'Block Index':<12} | {'Cacheline':<10} | {'Byte Offset':<12} | {'Active UMC':<10} | {'Boundary':<12} |")
    print("-" * 75)

    seen_channels = set()

    for block in range(BLOCKS_TO_TEST):
        base_line = START_CACHELINE + (block * 4)
        ch = get_active_channel(base_line)
        seen_channels.add(ch)

        byte_offset = block * 256

        # Mark standard memory boundaries to easily spot the XOR flips
        boundary = ""
        if byte_offset > 0 and byte_offset % 4096 == 0:
            boundary = f"<-- {byte_offset // 1024} KB"
            print("-" * 75) # Visual break at page boundaries

        print(f"| {block:<12} | {base_line:<10} | {byte_offset:<12} | UMC {ch:<8} | {boundary:<12} |")
        sys.stdout.flush()

    print("-" * 75)
    print(f"[*] Sweep complete. Unique channels mapped in this 32KB window: {list(seen_channels)}")

    if len(seen_channels) > 2:
        print("[!] WARNING: Found more than 2 channels! The 1MB assumption is broken.")
    else:
        print("[*] CONFIRMED: Only 2 channels are active in this region.")

if __name__ == '__main__':
    main()
