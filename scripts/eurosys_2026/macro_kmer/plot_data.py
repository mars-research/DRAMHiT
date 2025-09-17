import json
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


# Load JSON results
with open("results.json", "r") as f:
    all_results = json.load(f)

sns.set(style="whitegrid")
plt.figure(figsize=(10, 6))

# Plot each hash table
for ht_name, data in all_results.items():
    k = [entry["k"] for entry in data]  # convert to bytes
    mops = [entry["mops"] for entry in data]
    sns.lineplot(x=k, y=mops, marker="o", label=ht_name)

plt.xlabel("K")
plt.ylabel("MOPS")
plt.title("Kmer Test")

plt.legend(title="Hashtable")
plt.tight_layout()
# Save figure as PNG
plt.savefig("kmer_test.png", dpi=300)
plt.close()


