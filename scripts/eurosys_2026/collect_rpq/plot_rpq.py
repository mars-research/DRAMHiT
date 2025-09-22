#!/usr/bin/env python3

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <csv_file>")
    sys.exit(1)

csv_file = sys.argv[1]

# Load CSV into DataFrame
df = pd.read_csv(csv_file)

# Compute derived metrics
df["occupancy_rate"] = df["unc_m_rpq_occupancy_pch0"] / df["duration"]
df["insert_rate"] = df["unc_m_rpq_inserts.pch0"] / df["duration"]

sns.set_theme(style="whitegrid")

# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(9, 3))
# Bandwidth
sns.lineplot(data=df, x="num_threads", y="bw", marker="o", color="red", ax=axes[0])
axes[0].set_ylabel("Bandwidth (GB/s)")
axes[0].set_xlabel("Number of Threads")

# RPQ Occupancy
sns.lineplot(data=df, x="num_threads", y="occupancy_rate", marker="o", color="orange", ax=axes[1])
axes[1].set_ylabel("RPQ Occupancy pch0")
axes[1].set_xlabel("Number of Threads")

# RPQ Inserts
sns.lineplot(data=df, x="num_threads", y="insert_rate", marker="o", color="blue", ax=axes[2])
axes[2].set_ylabel("RPQ Inserts pch0")
axes[2].set_xlabel("Number of Threads")

plt.tight_layout()  # leave space for suptitle
plt.savefig("rpq.png")
plt.show()

