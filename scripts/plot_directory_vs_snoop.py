#!/usr/bin/env python3
import sys
import re
import matplotlib.pyplot as plt
import os
from collections import defaultdict

# Configurations to track
TARGET_CONFIGS = [
    "snoop_numa-split_1_read-factor_0",
    "snoop_numa-split_1_read-factor_500",
    "snoop_numa-split_4_read-factor_0",
    "snoop_numa-split_4_read-factor_500",
    "directory_numa-split_1_read-factor_0",
    "directory_numa-split_1_read-factor_500",
    "directory_numa-split_4_read-factor_0",
    "directory_numa-split_4_read-factor_500",
]

# Regex for parsing args from the command line
arg_pattern = re.compile(r"--([\w-]+)\s+([\w\.\-]+)")

# Regex for get_cycles in the stats line
get_cycles_pattern = re.compile(r"get_cycles\s*:\s*([\d\.]+)")

get_mops_pattern = re.compile(r"get_mops\s*:\s*([\d\.]+)")

# Data: config -> list of (fill_factor, get_cycles)
data = defaultdict(list)

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} snoop_file.txt directory_file.txt")
    sys.exit(1)

files = sys.argv[1:3]
for filename in files:
    fname = os.path.basename(filename).lower()
    if "snoop" in fname.lower():
        category = "snoop"
    elif "directory" in fname.lower():
        category = "directory"
    else:
        print(f"ERROR: Cannot determine category from filename: {fname}")
        sys.exit(1)

    with open(filename, "r") as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("/opt/DRAMHiT/build/dramhit"):
            args = dict(arg_pattern.findall(line))
            numa_split = args.get("numa-split")
            read_factor = args.get("read-factor")
            fill_factor = int(args.get("ht-fill"))

            config_name = f"{category}_numa-split_{numa_split}_read-factor_{read_factor}"

            if i + 2 < len(lines):                
                numbers = re.findall(r'\d+', lines[i+1])
                numbers = [int(n) for n in numbers]
                mops = numbers[4]
                read_factor = numbers[0]
                config_name = f"{category}_numa-split_{numa_split}_read-factor_{read_factor}"
                data[config_name].append((fill_factor, mops))
                
                numbers = re.findall(r'\d+', lines[i+2])
                numbers = [int(n) for n in numbers]
                mops = numbers[4]
                read_factor = numbers[0]
                config_name = f"{category}_numa-split_{numa_split}_read-factor_{read_factor}"
                data[config_name].append((fill_factor, mops))

        i += 1

# Sort data by fill_factor
for cfg in data:
    data[cfg].sort(key=lambda x: x[0])

# Define the four groups: (read_factor, numa_split)
groups = [
    (0, 1),
    (0, 4),
    (500, 1),
    (500, 4),
]

# Create figure with 2x2 subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 10), sharey=True)

for ax, (rf, ns) in zip(axes.flatten(), groups):
    for cfg in TARGET_CONFIGS:
        if cfg.endswith(f"read-factor_{rf}") and f"numa-split_{ns}" in cfg and cfg in data:
            xs = [ff for ff, _ in data[cfg]]
            ys = [gc for _, gc in data[cfg]]
            ax.plot(xs, ys, marker='o', label=cfg)
    ax.set_title(f"Read {rf}, NUMA {ns}")
    ax.set_xlabel("Fill Factor")
    ax.set_ylabel("Get Mops")
    ax.grid(True)
    ax.legend(fontsize='small')

plt.tight_layout()
plt.savefig("get_mops_2x2.png", dpi=300)
plt.close()

print("Saved: get_cycles_2x2.png")


