import json
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd  # for CSV

# Load JSON results
with open("results.json", "r") as f:
    all_results = json.load(f)

# chtkc
csv_df = pd.read_csv("summary_dmela.csv")
csv_df.columns = csv_df.columns.str.strip()

sns.set(style="whitegrid")
plt.figure(figsize=(10, 6))

# Plot each hash table from JSON
for ht_name, data in all_results.items():
    k = [entry["k"] for entry in data]
    mops = [entry["mops"] for entry in data]
    sns.lineplot(x=k, y=mops, marker="o", label=ht_name)

# Plot CSV hashtable
sns.lineplot(
    data=csv_df,
    x="k", y="mops",
    marker="o",
    label="chtkc"  # change label if needed
)

plt.xlabel("K")
plt.ylabel("MOPS")
plt.title("Kmer Test")

plt.legend(title="Hashtable")
plt.tight_layout()

# Save figure as PNG
plt.savefig("kmer_test.png", dpi=300)
plt.close()


