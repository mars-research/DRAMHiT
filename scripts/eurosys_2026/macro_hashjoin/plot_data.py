import json
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import sys

if len(sys.argv) < 3:
    print("Usage: python script.py <data to plot> <output path>")
    sys.exit(1)

input_json = sys.argv[1]
out_file = sys.argv[2]

# Load JSON results
with open(input_json, "r") as f:
    all_results = json.load(f)

sns.set(style="whitegrid")
plt.figure(figsize=(10, 6))

rsize_set = set()
# Plot each hash table
for ht_name, data in all_results.items():
    rsizes_bytes = [entry["htsize"] * 16 for entry in data]  # convert to bytes
    rsizes_mb = [int(b / 1024**2) for b in rsizes_bytes]         # convert to GB
    mops = [entry["mops"] for entry in data]
    sns.lineplot(x=rsizes_mb, y=mops, marker="o", label=ht_name)

plt.xlabel("Hash Table Size (MB)")
plt.ylabel("MOPS")
plt.title("Hashjoin Test")
#plt.xscale("log")  # log base 2 scale for x-axis

plt.legend(title="Hash Table")
plt.tight_layout()
# min_size = min(rsizes_mb)
# max_size = max(rsizes_mb)
# ticks = 2 ** np.arange(np.floor(np.log2(min_size)), np.ceil(np.log2(max_size)) + 0.25, 1)
# plt.xticks(ticks)  # log2 fractional ticks
# plt.xlim(min_size, max_size)

# Save figure as PNG
plt.savefig(out_file, dpi=300)
plt.close()


