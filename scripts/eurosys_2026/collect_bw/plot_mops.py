#!/usr/bin/env python3
import os
import sys
import matplotlib.pyplot as plt

def parse_mops_data(file_path):
    """
    Directly extracts set and get MOPS from the standard 9-block file structure.
    """
    insert_mops = []
    find_mops = []

    with open(file_path, 'r') as f:
        for line in f:
            if "set_mops" in line:
                # Line format: set_cycles : 107, get_cycles : 47, set_mops : 1488, get_mops : 3363
                parts = line.split(',')
                set_val = float(parts[2].split(':')[1].strip())
                get_val = float(parts[3].split(':')[1].strip())
                
                insert_mops.append(set_val)
                find_mops.append(get_val)

    # 10% to 90% fill factors matching the parsed rows
    fill_factors = list(range(10, 100, 10))
    return fill_factors[:len(insert_mops)], insert_mops, find_mops


def plot_throughput(all_results):
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    fill_factors = list(range(10, 100, 10))

    # INSERT GRAPH (LEFT)
    for label, ffs, inserts, _ in all_results:
        axes[0].plot(ffs, inserts, marker='o', linestyle='-', linewidth=2, label=label)

    axes[0].set_title('Insert Throughput', fontsize=14, fontweight='normal')
    axes[0].set_xlabel('Fill Factor (%)', fontsize=12)
    axes[0].set_ylabel('Throughput (MOPS)', fontsize=12)
    axes[0].set_xticks(fill_factors)
    axes[0].set_ylim(bottom=0)
    axes[0].grid(True, linestyle='--', alpha=0.5)
    axes[0].legend()

    # FIND GRAPH (RIGHT)
    for label, ffs, _, finds in all_results:
        axes[1].plot(ffs, finds, marker='s', linestyle='-', linewidth=2, label=label)

    axes[1].set_title('Find Throughput', fontsize=14, fontweight='normal')
    axes[1].set_xlabel('Fill Factor (%)', fontsize=12)
    axes[1].set_ylabel('Throughput (MOPS)', fontsize=12)
    axes[1].set_xticks(fill_factors)
    axes[1].set_ylim(bottom=0)
    axes[1].grid(True, linestyle='--', alpha=0.5)
    axes[1].legend()

    plt.tight_layout()
    plt.savefig('throughput_mops_plots.pdf', dpi=300)
    print("\nPlots successfully saved as 'throughput_mops_plots.pdf'.")
    plt.show()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <file1.txt> [file2.txt ...]")
        sys.exit(1)

    all_results = []

    for file_path in sys.argv[1:]:
        ffs, insert_mops, find_mops = parse_mops_data(file_path)
        label = os.path.splitext(os.path.basename(file_path))[0]

        print(f"\n{label}:")
        print(f"  Inserts: {insert_mops}")
        print(f"  Finds:   {find_mops}")

        all_results.append((label, ffs, insert_mops, find_mops))

    plot_throughput(all_results)