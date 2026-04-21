import json
import os
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def plot_dram_data(file_path):
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return

    # Load the JSON data
    with open(file_path, "r") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            print(f"Error: Failed to decode JSON from {file_path}")
            return

    # Flatten the nested JSON structure
    rows = []
    for name, measurements in data.items():
        for entry in measurements:
            # Add the 'name' key to the dictionary for seaborn hue
            entry["name"] = name
            # Cast to numeric in case values are strings
            entry["get_mops"] = float(entry["get_mops"])
            entry["set_mops"] = float(entry["set_mops"])
            rows.append(entry)

    df = pd.DataFrame(rows)

    # Styling
    sns.set_theme()
    fig, axes = plt.subplots(1, 2, figsize=(15, 6))

    # Graph 1: Get MOPS
    sns.lineplot(data=df, x="fill", y="get_mops", hue="name", marker="o", ax=axes[0])
    axes[0].set_title("Read Performance (Get MOPS)", fontsize=14, pad=10)
    axes[0].set_ylabel("Million Ops / Sec")
    axes[0].set_xlabel("Fill Factor (%)")

    # Graph 2: Set MOPS
    sns.lineplot(data=df, x="fill", y="set_mops", hue="name", marker="s", ax=axes[1])
    axes[1].set_title("Write Performance (Set MOPS)", fontsize=14, pad=10)
    axes[1].set_ylabel("Million Ops / Sec")
    axes[1].set_xlabel("Fill Factor (%)")

    plt.tight_layout()
    plt.savefig(sys.argv[2])
    plt.close()


if __name__ == "__main__":
    # Ensure a file path was provided
    if len(sys.argv) < 3:
        print("Usage: python script_name.py <path_to_data.json> <out.png>")
    else:
        plot_dram_data(sys.argv[1])
