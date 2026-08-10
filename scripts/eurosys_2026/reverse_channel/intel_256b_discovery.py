#!/usr/bin/env python3
import subprocess
import re
import sys

# 1 Block = 4 Cachelines = 256 Bytes
# 16 Blocks = 4 KB
# We will test the first 128 blocks (32 KB total) to find where the hash flips.

def get_active_channel(base_line):
    # Test 4 contiguous cachelines (256 bytes)
    pattern = f"{base_line},{base_line+1},{base_line+2},{base_line+3}"

    # Generate event string for Intel iMC channels 0-7
    events = ",".join([f"uncore_imc_{i}/cas_count_read/" for i in range(8)])

    # Updated interval to 1000ms (-I 1000) and iterations to 30000000 (-n 30000000)
    cmd = f"stdbuf -oL -eL perf stat -a -e {events} -I 1000 -- ./map -p '{pattern}' -n 30000000 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)

    in_access_loop = False
    counts = {i: 0.0 for i in range(8)}

    # Regex to capture value, optional unit (MiB/KiB/etc), and the Intel iMC channel number
    regex = re.compile(r'([\d\.,]+)\s*(MiB|KiB|B|Bytes|GiB|KB|GB)?\s+uncore_imc_(\d+)/cas_count_read/')

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

                # Normalize bandwidth to MiB if units are provided by perf
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
    TARGET_MB = 0  # We test Region 0 (Cachelines 0 to 16383)
    START_CACHELINE = TARGET_MB * 16384
    BLOCKS_TO_TEST = 128  # 128 blocks * 256B = 32 KB

    print(f"[*] Sweeping Intra-MB Hash for MB Region {TARGET_MB}")
    print(f"[*] Testing first {BLOCKS_TO_TEST} blocks sequentially...")
    print("-" * 75)
    print(f"| {'Block Index':<12} | {'Cacheline':<10} | {'Byte Offset':<12} | {'Active iMC':<10} | {'Boundary':<12} |")
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

        print(f"| {block:<12} | {base_line:<10} | {byte_offset:<12} | iMC {ch:<8} | {boundary:<12} |")
        sys.stdout.flush()

    print("-" * 75)
    print(f"[*] Sweep complete. Unique channels mapped in this 32KB window: {list(seen_channels)}")

    if len(seen_channels) > 2:
        print("[!] WARNING: Found more than 2 channels! The 1MB assumption is broken.")
    else:
        print("[*] CONFIRMED: Only 2 channels are active in this region.")

if __name__ == '__main__':
    main()
