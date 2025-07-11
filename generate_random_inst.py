import sys
import os
import math
import subprocess

# ------------------------
# Helpers
# ------------------------

def next_power_of_2(n):
    """Return the next power of 2 >= n"""
    return 1 << (n - 1).bit_length()

def pseudo_random(x, aligned_len):
    return (x * 1103515245 + 12345) & (aligned_len - 1)

# ------------------------
# Parse and align ARRAY_LEN
# ------------------------

if len(sys.argv) < 2:
    print("Usage: python generate_and_run.py <ARRAY_LEN>")
    sys.exit(1)

try:
    array_len = int(sys.argv[1])
    if array_len <= 0:
        raise ValueError
except ValueError:
    print("ARRAY_LEN must be a positive integer.")
    sys.exit(1)

aligned_len = next_power_of_2(array_len)
print(f"Using ARRAY_LEN={array_len}, aligned to {aligned_len}.")

# ------------------------
# Generate header file
# ------------------------

SEED = 42
with open("generated_prefetches.h", "w") as f:
    for i in range(array_len):
        idx = pseudo_random(i + SEED, aligned_len)
        #f.write(f"_mm_prefetch((const char*)(&mem[{idx}]), HINT_L1);\n")
        f.write(
            f'asm volatile("movq (%0), %%rax\\n\\t" : : "r"(&mem[{idx}]) : "%rax", "memory");\n'
        )

print("generated_prefetches.h written.")

# ------------------------
# Compile the C program
# ------------------------

compile_cmd = [
    "gcc", "-O1", "prefetch_test_static.c",
    f"-DARRAY_LEN={aligned_len}",
    "-o", "prefetch"
]

print("Compiling with:", " ".join(compile_cmd))
result = subprocess.run(compile_cmd)

if result.returncode != 0:
    print("Compilation failed.")
    sys.exit(1)

# ------------------------
# Run the binary
# ------------------------

print("Running ./prefetch")
subprocess.run(["./prefetch"])
