import re
import sys
import os
import matplotlib.pyplot as plt

STREAM = (289336.8/1000)  # GB/s, from STREAM, MLC, or custom BW test


def parse_perf_data(file_path):

    # Generates [10, 20, 30, 40, 50, 60, 70, 80, 90]
    fill_factors = list(range(10, 100, 10))

    insert_data = []
    find_data = []

    current_phase = None
    current_run_insert = []
    current_run_find = []

    # Regex to capture the float value before MB/s
    bw_pattern = re.compile(r"#\s+([0-9.]+)\s+MB/s\s+umc_mem_bandwidth")

    with open(file_path, 'r') as f:
        for line in f:

            # Check for phase markers
            if "zipfian test insert start" in line:
                current_phase = "insert"
                current_run_insert = []

            elif "zipfian test insert end" in line:
                current_phase = None
                insert_data.append(current_run_insert)

            elif "zipfian test find start" in line:
                current_phase = "find"
                current_run_find = []

            elif "zipfian test find end" in line:
                current_phase = None
                find_data.append(current_run_find)

            # If we are inside a phase, look for bandwidth lines
            elif current_phase and "umc_mem_bandwidth" in line:

                match = bw_pattern.search(line)

                if match:
                    bw_mb = float(match.group(1))

                    if current_phase == "insert":
                        current_run_insert.append(bw_mb)

                    elif current_phase == "find":
                        current_run_find.append(bw_mb)

    # Calculate averages and convert to GB/s
    insert_avgs_gbs = []
    find_avgs_gbs = []

    # maybe change 
    trim = 5
    for data in insert_data:

        # Exclude first and last 2 samples if possible
        trimmed = data[trim:-trim] if len(data) > 2 * trim else data

        avg_mb = sum(trimmed) / len(trimmed) if trimmed else 0
        insert_avgs_gbs.append(avg_mb / 1000.0)

    for data in find_data:

        trimmed = data[trim:-trim] if len(data) > 2 * trim else data

        avg_mb = sum(trimmed) / len(trimmed) if trimmed else 0
        find_avgs_gbs.append(avg_mb / 1000.0)

    return fill_factors, insert_avgs_gbs, find_avgs_gbs


def plot_bandwidth(all_results):

    # Create side-by-side graphs
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    #
    # INSERT GRAPH (LEFT)
    #
    for label, fill_factors, insert_avgs, _ in all_results:

        n_insert = min(len(fill_factors), len(insert_avgs))

        x_insert = fill_factors[:n_insert]
        y_insert = insert_avgs[:n_insert]

        axes[0].plot(
            x_insert,
            y_insert,
            marker='o',
            linestyle='-',
            label=label
        )

    axes[0].axhline(STREAM, linestyle='--', linewidth=2, label='STREAM')

    axes[0].set_title('Insert Memory Bandwidth')
    axes[0].set_xlabel('Fill Factor (%)')
    axes[0].set_ylabel('Bandwidth (GB/s)')
    axes[0].set_xticks(fill_factors)
    axes[0].set_ylim(bottom=0)   # Start y-axis at 0
    axes[0].grid(True, linestyle='--', alpha=0.7)
    axes[0].legend()

    #
    # FIND GRAPH (RIGHT)
    #
    for label, fill_factors, _, find_avgs in all_results:

        n_find = min(len(fill_factors), len(find_avgs))

        x_find = fill_factors[:n_find]
        y_find = find_avgs[:n_find]

        axes[1].plot(
            x_find,
            y_find,
            marker='s',
            linestyle='-',
            label=label
        )

    axes[1].axhline(STREAM, linestyle='--', linewidth=2, label='STREAM')

    axes[1].set_title('Find Memory Bandwidth')
    axes[1].set_xlabel('Fill Factor (%)')
    axes[1].set_ylabel('Bandwidth (GB/s)')
    axes[1].set_xticks(fill_factors)
    axes[1].set_ylim(bottom=0)   # Start y-axis at 0
    axes[1].grid(True, linestyle='--', alpha=0.7)
    axes[1].legend()

    plt.tight_layout()

    # Save both graphs into one PDF
    plt.savefig('bandwidth_plots.pdf')

    print("Plots successfully saved as 'bandwidth_plots.pdf'.")

    plt.show()


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <file1.txt> [file2.txt ...]")
        sys.exit(1)

    all_results = []

    for file_path in sys.argv[1:]:

        fill_factors, insert_avgs, find_avgs = parse_perf_data(file_path)

        label = os.path.splitext(os.path.basename(file_path))[0]

        print(f"\nResults for {file_path}")
        print(f"Inserts: {[round(val, 2) for val in insert_avgs]}")
        print(f"Finds:   {[round(val, 2) for val in find_avgs]}")

        all_results.append(
            (label, fill_factors, insert_avgs, find_avgs)
        )

    plot_bandwidth(all_results)