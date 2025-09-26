import json
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# --- Load JSON ---
with open("hashjoin.json") as f:
    data = json.load(f)

# --- Flatten JSON into DataFrame ---
rows = []
for table, entries in data.items():
    for entry in entries:
        rows.append({
            "table": table,
            "fill": entry["fill"],
            "htsize": entry["htsize"],
            "mops": float(entry["mops"]),
        })

df = pd.DataFrame(rows)
# Pick fill factors you want subplots for
fills = [10, 70]

# --- Helper function to plot ---
def plot_metric(metric, ylabel, filename):
    fig, axes = plt.subplots(2, 2, figsize=(10, 8), constrained_layout=True)
    axes = axes.flatten()

    for i, fill in enumerate(fills):
        ax = axes[i]
        subset = df[df["fill"] == fill]
        sns.lineplot(
            data=subset,
            x="htsize", y=metric, hue="table", marker="o", ax=ax
        )
        ax.set_title(f"Fill = {fill}%")
        ax.set_ylabel(ylabel)
        ax.set_xlabel("Hashtable Size")
        ax.set_xscale("log", base=2)  # optional: log scale for htsize
        ax.grid(True, linestyle="--", alpha=0.6)

    # Hide unused subplot if fills < 4
    for j in range(i+1, len(axes)):
        fig.delaxes(axes[j])

    plt.suptitle(f"{ylabel} vs Hashtable Size", fontsize=14)
    plt.savefig(filename)
    plt.close()

# --- Generate both figures ---
plot_metric("mops", "MOPS", "get_mops.pdf")


