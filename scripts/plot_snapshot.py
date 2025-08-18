#!/usr/bin/env python3
import re
import sys
from collections import defaultdict
import matplotlib.pyplot as plt

# Usage: python script.py input.log
if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <logfile>")
    sys.exit(1)

logfile = sys.argv[1]

# Regex pattern for the example line
pattern = re.compile(
    r"Zipfian find iter:\s+(\d+)\s+duration:\s+(\d+)"
)

patternOp = re.compile(
    r"read op per iter\s+(\d+)"
)

# get find op occur per iteration, this should be consistent accross runs.
fop = 0
# Data structure: { iter: {"duration": total_duration, "op": total_op} }
data = defaultdict(lambda: {"duration": 0})

# Read and parse log file
with open(logfile, "r") as f:
    for line in f:
        match = pattern.search(line)
        if match:
            iteration, duration = match.groups()
            iteration = int(iteration)
            duration = int(duration)
            data[iteration]["duration"] += duration
            
        match = patternOp.search(line)
        if match:
            op = match.groups()
            fop = int(op[0])
            print(f"op number {fop}")

# Compute cycle_per_op
iter_list = sorted(data.keys())
cycle_per_op = [
    data[it]["duration"] / fop if fop != 0 else 0
    for it in iter_list
]

# Plot
plt.figure(figsize=(8, 5))
plt.plot(iter_list, cycle_per_op, marker="o")
plt.xlabel("Iteration")
plt.ylabel("Cycles per Op")
plt.title("Cycles per Operation vs Iteration")
plt.grid(True)
plt.tight_layout()

# Save to file
outfile = "cycles_per_op.png"
plt.savefig(outfile, dpi=300)
print(f"Plot saved as {outfile}")

