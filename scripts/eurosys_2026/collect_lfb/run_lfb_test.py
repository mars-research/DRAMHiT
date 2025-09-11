#!/bin/env python3
import subprocess
import re
import matplotlib.pyplot as plt
import csv
import seaborn as sns
import pandas as pd

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

pattern = re.compile(
    r"batch_sz:\s*(?P<bs>\d+),\s*duration:\s*(?P<dur>\d+),\s*overhead:\s*(?P<ovh>\d+),\s*cycle_per_op:\s*(?P<cyc>\d+)"
)

batch_sizes = []
cycles = []

for line in proc.stdout.strip().splitlines():
    m = pattern.search(line)
    if m:
        bs = int(m.group("bs"))
        cyc = int(m.group("cyc"))
        batch_sizes.append(bs)
        cycles.append(cyc)


# Print parsed data
for b, c in zip(batch_sizes, cycles):
    print(f"batch_sz={b}, cycles/op={c}")

with open("results.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["batch_sz", "cycles_per_op"])
    for b, c in zip(batch_sizes, cycles):
        writer.writerow([b, c])


df = pd.DataFrame({
    "Batch Size": batch_sizes,
    "Cycles per Prefetch": cycles
})

# Set Seaborn theme
sns.set_theme(style="whitegrid")  # or "darkgrid", "ticks", etc.

# Plot
sns.lineplot(data=df, x="Batch Size", y="Cycles per Prefetch", marker="o")

# Labels & title
plt.xlabel("Batch Size")
plt.ylabel("Cycles per Prefetch")
plt.title("Batch Size vs Cycles per Prefetch")

# Save as PNG
plt.savefig("batch_cycles.png", dpi=300, bbox_inches="tight")
print("Plot saved as batch_cycles.png")