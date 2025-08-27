#!/bin/env python3
import subprocess
import re
import matplotlib.pyplot as plt

compile_cmd = "gcc -O1 lfb_test.c -o lfb"
print("Compiling lfb_test.c...")
comp_proc = subprocess.run(compile_cmd, shell=True, capture_output=True, text=True)
if comp_proc.returncode != 0:   
    print("Compilation failed!")
    print(comp_proc.stdout)
    print(comp_proc.stderr)
    exit(1)
print("Compilation succeeded.\n")


proc = subprocess.run("./lfb", shell=True, capture_output=True, text=True)

batch_sizes = []
cycles = []

for line in proc.stdout.strip().splitlines():
    parts = line.split(",")
    bs = int(parts[0].split(":")[1].strip())
    cyc = int(parts[1].split()[-1])
    batch_sizes.append(bs)
    cycles.append(cyc)

# Print parsed data
for b, c in zip(batch_sizes, cycles):
    print(f"batch_sz={b}, cycles/op={c}")

# Plot
plt.plot(batch_sizes, cycles, marker='o')
plt.xlabel("Batch Size")
plt.ylabel("Cycles per Operation")
plt.title("Batch Size vs Cycles per Operation")
plt.grid(True)

# Save as PNG
plt.savefig("lfb.png", dpi=300, bbox_inches="tight")
print("Plot saved as batch_cycles.png")
