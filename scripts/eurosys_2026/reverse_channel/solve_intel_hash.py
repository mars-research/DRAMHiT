#!/usr/bin/env python3
import subprocess
import re
import sys
import random

# Number of physical address bits within 1GB (Bit 6 to Bit 29)
BIT_START = 6
BIT_END = 29
NUM_BITS = BIT_END - BIT_START + 1  # 24 bits

def get_active_channel(line_idx, map_bin="./map"):
    """Measures the dominant iMC for a specific cacheline."""
    events = ",".join([f"uncore_imc_{i}/cas_count_read/" for i in range(8)])
    pattern = f"{line_idx},{line_idx+1},{line_idx+2},{line_idx+3}"
    cmd = f"stdbuf -oL -eL perf stat -a -e {events} -I 1000 -- {map_bin} -p '{pattern}' -n 30000000 2>&1"

    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, text=True)
    counts = {i: 0.0 for i in range(8)}
    in_loop = False
    regex = re.compile(r'^\s*[\d\.]+\s+([\d\.,]+)\s*(MiB|KiB|B|Bytes|GiB|KB|GB)?\s+uncore_imc_(\d+)/cas_count_read/')

    for line in proc.stdout:
        if "Access loop starting now!" in line:
            in_loop = True
            continue
        if "Loop finished" in line:
            in_loop = False
            continue

        if in_loop:
            match = regex.search(line)
            if match:
                val_str = match.group(1).replace(',', '')
                unit = match.group(2)
                ch = int(match.group(3))
                val = float(val_str)
                if unit:
                    if unit in ("B", "Bytes"): val /= (1024 ** 2)
                    elif unit in ("KiB", "KB"): val /= 1024
                    elif unit in ("GiB", "GB"): val *= 1024
                counts[ch] += val

    proc.wait()
    return max(counts, key=counts.get) if any(counts.values()) else -1

def solve_gf2(A, Y):
    """Solves A * x = Y over GF(2) using Gaussian Elimination."""
    rows = len(A)
    cols = len(A[0])
    M = [A[i][:] + [Y[i]] for i in range(rows)]

    pivot_row = 0
    pivot_cols = []
    for c in range(cols):
        r_pivot = -1
        for r in range(pivot_row, rows):
            if M[r][c] == 1:
                r_pivot = r
                break
        if r_pivot == -1:
            continue

        M[pivot_row], M[r_pivot] = M[r_pivot], M[pivot_row]
        for r in range(rows):
            if r != pivot_row and M[r][c] == 1:
                M[r] = [M[r][i] ^ M[pivot_row][i] for i in range(cols + 1)]

        pivot_cols.append((pivot_row, c))
        pivot_row += 1

    x = [0] * cols
    for r, c in pivot_cols:
        x[c] = M[r][cols]
    return x

def main():
    print("[*] Generating test sample cachelines across 1GB range...")
    sample_lines = []

    # 1. Single-bit test lines (Bit 6 through Bit 29)
    for b in range(BIT_START, BIT_END + 1):
        sample_lines.append((1 << b) // 64)

    # 2. Random sample lines across 1GB space to overdetermine the system
    random.seed(42)
    for _ in range(30):
        sample_lines.append(random.randint(0, (1024*1024*1024 // 64) - 4))

    # Add user's explicit cacheline as a validation point
    sample_lines.append(16230321)

    print(f"[*] Total samples to measure: {len(sample_lines)}")
    print("-" * 65)

    A_matrix = []
    Y_c0, Y_c1, Y_c2 = [], [], []

    for idx, line in enumerate(sample_lines):
        addr = line * 64
        ch = get_active_channel(line)
        if ch == -1:
            print(f"[-] Sample {idx}: Cacheline {line} failed to collect data. Skipping.")
            continue

        # Extract bits 6 through 29 into feature vector
        bit_vector = [(addr >> b) & 1 for b in range(BIT_START, BIT_END + 1)]
        A_matrix.append(bit_vector)

        # Decompose channel (0-7) into bit components c2, c1, c0
        c0 = ch & 1
        c1 = (ch >> 1) & 1
        c2 = (ch >> 2) & 1

        Y_c0.append(c0)
        Y_c1.append(c1)
        Y_c2.append(c2)

        print(f"[{idx+1}/{len(sample_lines)}] Cacheline {line:>10} (0x{addr:08x}) -> iMC {ch} ({c2}{c1}{c0}_2)")

    print("-" * 65)
    print("[*] Solving linear system over GF(2)...")

    sol_c0 = solve_gf2(A_matrix, Y_c0)
    sol_c1 = solve_gf2(A_matrix, Y_c1)
    sol_c2 = solve_gf2(A_matrix, Y_c2)

    # Print the C code
    print("\n" + "=" * 65)
    print("      EXACT GENERATED C FUNCTION FOR YOUR SYSTEM")
    print("=" * 65)

    def build_xor_str(sol):
        active_bits = [f"a{b}" for idx, b in enumerate(range(BIT_START, BIT_END + 1)) if sol[idx] == 1]
        return " ^ ".join(active_bits) if active_bits else "0"

    print("static inline int is_block0_owner_cacheline(uint64_t line_idx, uint64_t cycle_offset) {")
    print("    uint64_t addr = line_idx * 64;\n")

    # Collect used bits
    all_used_bits = set()
    for sol in (sol_c0, sol_c1, sol_c2):
        for idx, b in enumerate(range(BIT_START, BIT_END + 1)):
            if sol[idx] == 1:
                all_used_bits.add(b)

    for b in sorted(all_used_bits):
        print(f"    uint8_t a{b:<2} = (addr >> {b}) & 1;")

    print(f"\n    uint8_t c0 = {build_xor_str(sol_c0)};")
    print(f"    uint8_t c1 = {build_xor_str(sol_c1)};")
    print(f"    uint8_t c2 = {build_xor_str(sol_c2)};\n")
    print("    uint8_t target_imc = (c2 << 2) | (c1 << 1) | c0;\n")
    print("    return (target_imc == 0); // Returns true for iMC 0")
    print("}")
    print("=" * 65)

if __name__ == '__main__':
    main()
