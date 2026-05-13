import re
import sys
import os
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

def parse_file(filepath):
    """Parses NUMA nodes and MOPS data from the experiment text file."""
    data = []
    numa_nodes = "Unknown"
    
    numa_pattern = re.compile(r"NUMA node\(s\):\s+(\d+)")
    mops_pattern = re.compile(r"set_mops\s*:\s*(\d+),\s*get_mops\s*:\s*(\d+)")

    # Mapping 9 iterations to 10-90% fill factor
    fill_factors = [10, 20, 30, 40, 50, 60, 70, 80, 90]

    if not os.path.exists(filepath):
        print(f"Error: {filepath} not found.")
        return pd.DataFrame()

    with open(filepath, 'r') as f:
        count = 0
        for line in f:
            n_match = numa_pattern.search(line)
            if n_match:
                numa_nodes = f"NPS{n_match.group(1)}"
            
            m_match = mops_pattern.search(line)
            if m_match and count < len(fill_factors):
                data.append({
                    "Config": numa_nodes,
                    "Fill Factor": fill_factors[count],
                    "set_mops": int(m_match.group(1)),
                    "get_mops": int(m_match.group(2))
                })
                count += 1
    return pd.DataFrame(data)

def main(file1, file2, output_file):
    df1 = parse_file(file1)
    df2 = parse_file(file2)
    
    if df1.empty or df2.empty:
        print("Error: One or both files could not be parsed.")
        return

    df = pd.concat([df1, df2], ignore_index=True)

    # Styling and Config
    sns.set_theme(style="whitegrid")
    MARKERS = ["o", "s", "^", "D"]
    configs = df["Config"].unique()
    palette = sns.color_palette("colorblind", n_colors=len(configs))
    color_map = dict(zip(configs, palette))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    plot_configs = [
        (axes[0], "set_mops", "Set Throughput", "Set Mops"),
        (axes[1], "get_mops", "Find Throughput", "Find Mops")
    ]

    for ax, y_col, title, y_label in plot_configs:
        sns.lineplot(
            data=df, x="Fill Factor", y=y_col, 
            hue="Config", style="Config", 
            markers=MARKERS[:len(configs)], 
            dashes=False, # Solid lines
            ax=ax, palette=color_map, legend=False
        )
        
        # Formatting markers: hollow and smaller
        for line in ax.get_lines():
            line.set_markerfacecolor("none")
            line.set_markeredgecolor(line.get_color())
            line.set_markeredgewidth(1.5)
            line.set_markersize(4) # Smaller markers on lines

        ax.set_title(title)
        ax.set_ylabel(y_label)
        ax.set_xlabel("Fill Factor (%)")
        ax.set_ylim(bottom=0)
        ax.grid(True, which="both", linestyle="--")

    # Custom Legend (Matches your reference style)
    custom_lines = [
        Line2D([0], [0], color=color_map[cfg], marker=MARKERS[i], 
               linestyle='-', markerfacecolor="none", 
               markeredgecolor=color_map[cfg], markeredgewidth=1.5, 
               markersize=6, label=cfg)
        for i, cfg in enumerate(configs)
    ]
    fig.legend(handles=custom_lines, loc="upper center", ncol=2, fontsize=10)

    plt.tight_layout(rect=[0, 0, 1, 0.92])
    plt.savefig(output_file, dpi=300)
    print(f"[OK] Comparison plot saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 plot_txt.py <file1> <file2> <output.pdf>")
    else:
        main(sys.argv[1], sys.argv[2], sys.argv[3])