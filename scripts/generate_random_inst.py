#!/bin/env python3

import sys
import os
import math
import subprocess

# ------------------------
# Helpers
# ------------------------



# ------------------------
# Parse and align ARRAY_LEN
# ------------------------

mem_len = 1024

if len(sys.argv) < 2:
    print("Usage: python generate_and_run.py <ARRAY_LEN>")
    sys.exit(1)

try:
    batch_sz = int(sys.argv[1])
    if batch_sz <= 0:
        raise ValueError
except ValueError:
    print("ARRAY_LEN must be a positive integer.")
    sys.exit(1)


# ------------------------
# Generate header file
# ------------------------

SEED = 42

def pseudo_random(x, len):
    return ((x + SEED) * 1103515245 + 12345) % len

file_path = "generated_prefetches.h"
if os.path.exists(file_path):
    os.remove(file_path)
    print(f"{file_path} removed successfully.")
else:
    print("File does not exist.")
    
with open(file_path, "w") as f:
    for i in range(batch_sz):
        idx = pseudo_random(i, mem_len)
        f.write(f"_mm_prefetch((const char*)(&mem[{idx}]), HINT_L1);\n")
        # f.write(
        #     f'asm volatile("movq (%0), %%rax\\n\\t" : : "r"(&mem[{idx}]) : "%rax", "memory");\n'
        # )

print("generated_prefetches.h written.")

# ------------------------
# Compile the C program
# ------------------------

compile_cmd = [
    "gcc", "-O1", "prefetch_test_static.c",
    f"-DMEM_LEN={mem_len}",
    f"-DBATCH_SZ={batch_sz}",
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
