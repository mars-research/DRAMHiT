#!/usr/bin/env python3
import sys
import re
import matplotlib.pyplot as plt
from collections import defaultdict

# Configurations to track
TARGET_CONFIGS = [
    "snoop_numa-split_1_read-factor_10",
    "snoop_numa-split_1_read-factor_500",
    "snoop_numa-split_4_read-factor_10",
    "snoop_numa-split_4_read-factor_500",
    "directory_numa-split_1_read-factor_10",
    "directory_numa-split_1_read-factor_500",
    "directory_numa-split_4_read-factor_10",
    "directory_numa-split_4_read-factor_500",
]

# Regex for parsing args from the command line
arg_pattern = re.compile(r"--([\w-]+)\s+([\w\.\-]+)")

# Regex for get_cycles in the stats line
get_cycles_pattern = re.compile(r"get_cycles\s*:\s*([\d\.]+)")

# Data: config -> list of (fill_factor, get_cycles)
data = defaultdict(list)

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} snoop_file.txt directory_file.txt")
    sys.exit(1)

files = sys.argv[1:3]

for filename in files:
    if "snoop" in filename.lower():
        category = "snoop"
    elif "directory" in filename.lower():
        category = "directory"
    else:
        print(f"ERROR: Cannot determine category from filename: {filename}")
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

            if config_name in TARGET_CONFIGS and 10 <= fill_factor <= 90:
                if i + 1 < len(lines):
                    stats_line = lines[i + 1]
                    match = get_cycles_pattern.search(stats_line)
                    if match:
                        get_cycles = float(match.group(1))
                        data[config_name].append((fill_factor, get_cycles))
        i += 1

# Sort data by fill_factor
for cfg in data:
    data[cfg].sort(key=lambda x: x[0])

# Define the four groups: (read_factor, numa_split)
groups = [
    (10, 1),
    (10, 4),
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
    ax.set_ylabel("Get Cycles")
    ax.grid(True)
    ax.legend(fontsize='small')

plt.tight_layout()
plt.savefig("get_cycles_2x2.png", dpi=300)
plt.close()

print("Saved: get_cycles_2x2.png")


