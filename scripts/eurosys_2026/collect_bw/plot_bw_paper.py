import os
import re
import statistics
import sys

import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

# ==========================================
# EXTRACTED STYLE DECISIONS APPLIED HERE
# ==========================================
rc_fonts = {
    "text.usetex": True,
    "font.family": "serif",
    "font.serif": ["Linux Libertine O"],
    "font.weight": "bold",
}
mpl.rcParams.update(rc_fonts)
sns.set_context("paper")

# Separate baseline constants (GB/s) for independent adjustment
STREAM_INSERT = 255.6
STREAM_FIND = 346.3

STREAM_INSERT_LABEL = "synthetic_1read_1write"
STREAM_FIND_LABEL = "synthetic_read"

# ==========================================
# SEPARATED BASELINES FOR AMD AND INTEL
# ==========================================
BASELINES_AMD = [
    ("r", 342.3),
    ("rw", 271.4),
    ("stream+rw", 297.0),
    ("1.5r_1w", 280.0),
]

BASELINES_INTEL = [
    ("r", 243.0),
    ("rw", 198.0),
    ("stream+rw", 236.0),
    ("1.5r_1w", 201.0),
]

# USE SEABORN 'ROCKET' PALETTE INSTEAD OF TAB10
# Generate enough colors for baselines + dynamic plots
PALETTE = sns.color_palette("rocket", n_colors=10)

BASELINE_COLORS = {
    "r": PALETTE[0],
    "rw": PALETTE[1],
    "stream+rw": PALETTE[2],
    "1.5r_1w": PALETTE[3],
}


def parse_perf_data(file_path, mode="AVG"):
    # Ensure the mode is valid and case-insensitive
    valid_modes = {"MIN", "MAX", "AVG", "MEDIAN"}
    mode = mode.upper()
    if mode not in valid_modes:
        raise ValueError(f"Invalid mode '{mode}'. Must be one of {valid_modes}.")

    fill_factors = list(range(10, 100, 10))

    insert_data = []
    find_data = []

    current_phase = None
    current_run_insert = []
    current_run_find = []

    bw_pattern = re.compile(
        r"(?:#\s+([0-9.]+)\s+MB/s\s+umc_mem_bandwidth)"
        r"|(?:([\d,]+)\s+unc_m_cas_count\.all)"
    )

    with open(file_path, "r") as f:
        for line in f:
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

            elif current_phase and (
                "umc_mem_bandwidth" in line or "unc_m_cas_count.all" in line
            ):
                match = bw_pattern.search(line)
                if match:
                    if match.group(1):  # AMD path
                        bw_mb = float(match.group(1))
                    else:
                        bw_mb = (float(match.group(2).replace(",", "")) * 64) / 1e6

                    if current_phase == "insert":
                        current_run_insert.append(bw_mb)
                    elif current_phase == "find":
                        current_run_find.append(bw_mb)

    # Helper function to process the data blocks based on the selected mode
    def calculate_stat(data_runs, calc_mode):
        results_gbs = []
        trim = 2
        for data in data_runs:
            trimmed = data[trim:-trim] if len(data) > 2 * trim else data

            if not trimmed:
                results_gbs.append(0.0)
                continue

            if calc_mode == "MIN":
                val_mb = min(trimmed)
            elif calc_mode == "MAX":
                val_mb = max(trimmed)
            elif calc_mode == "MEDIAN":
                val_mb = statistics.median(trimmed)
            else:  # AVG
                val_mb = statistics.mean(trimmed)

            results_gbs.append(val_mb / 1000.0)

        return results_gbs

    insert_results_gbs = calculate_stat(insert_data, mode)
    find_results_gbs = calculate_stat(find_data, mode)

    return fill_factors, insert_results_gbs, find_results_gbs


def plot_bandwidth(all_results, active_baselines):
    # STYLE: Dynamic sizing based on plot_sz
    plot_sz = 5
    fig, axes = plt.subplots(1, 2, figsize=(2 * plot_sz, 1 * plot_sz))

    # Track max value to dynamically sync the Y-axis limits
    max_y_val = max(
        [val for _, val in active_baselines]
    )  # Start with the highest baseline

    #
    # INSERT GRAPH
    #
    for idx, (label, fill_factors, insert_avgs, _) in enumerate(all_results):
        n_insert = min(len(fill_factors), len(insert_avgs))
        x_insert = fill_factors[:n_insert]
        y_insert = insert_avgs[:n_insert]

        if y_insert:
            max_y_val = max(max_y_val, max(y_insert))

        data_color = PALETTE[(4 + idx) % 10]

        # zorder=3 keeps dynamic lines safely above the baselines
        axes[0].plot(
            x_insert,
            y_insert,
            marker="o",
            linestyle="-",
            color=data_color,
            label=label,
            zorder=3,
        )

    # Baselines (INSERT)
    for name, val in active_baselines:
        # zorder=1 forces synthetic benchmarks below the parsed metrics
        axes[0].axhline(
            val,
            linestyle="--",
            linewidth=2,
            color=BASELINE_COLORS.get(name, None),
            label=name,
            zorder=1,
        )

    # STYLE: Updated titles and explicit grid definitions
    axes[0].set_title("Insert Memory Bandwidth", fontsize=12, fontweight="bold")
    axes[0].set_xlabel(r"Fill Factor (\%)")
    axes[0].set_ylabel("Bandwidth (GB/s)")
    axes[0].set_xticks(list(range(10, 100, 10)))
    axes[0].grid(True, which="major", axis="both", linestyle="--", alpha=0.7, zorder=0)

    #
    # FIND GRAPH
    #
    for idx, (label, fill_factors, _, find_avgs) in enumerate(all_results):
        n_find = min(len(fill_factors), len(find_avgs))
        x_find = fill_factors[:n_find]
        y_find = find_avgs[:n_find]

        if y_find:
            max_y_val = max(max_y_val, max(y_find))

        data_color = PALETTE[(4 + idx) % 10]

        axes[1].plot(
            x_find,
            y_find,
            marker="o",  # Standardized to 'o' based on style script
            linestyle="-",
            color=data_color,
            label=label,
            zorder=3,
        )

    # Baselines (FIND)
    for name, val in active_baselines:
        axes[1].axhline(
            val,
            linestyle="--",
            linewidth=2,
            color=BASELINE_COLORS.get(name, None),
            label=name,
            zorder=1,
        )

    # STYLE: Updated titles and explicit grid definitions
    axes[1].set_title("Find Memory Bandwidth", fontsize=12, fontweight="bold")
    axes[1].set_xlabel(r"Fill Factor (\%)")
    axes[1].set_ylabel("Bandwidth (GB/s)")
    axes[1].set_xticks(list(range(10, 100, 10)))
    axes[1].grid(True, which="major", axis="both", linestyle="--", alpha=0.7, zorder=0)

    #
    # SYNCHRONIZE Y-AXIS LIMITS
    #
    y_limit_top = max_y_val * 1.05
    axes[0].set_ylim(bottom=0, top=y_limit_top)
    axes[1].set_ylim(bottom=0, top=y_limit_top)

    #
    # GLOBAL LEGEND (TOP) WITH CUSTOM ORDER
    #
    handles, labels = axes[0].get_legend_handles_labels()

    # Define primary sorting intent
    priority_order = ["dramblast", "dramhit", "growt"]

    # Map out chunks: Priority matches -> other parsed text logs -> static baselines
    priority_items = []
    other_items = []
    baseline_items = []

    baseline_names = [b[0] for b in active_baselines]

    for h, l in zip(handles, labels):
        if l in priority_order:
            priority_items.append((h, l))
        elif l in baseline_names:
            baseline_items.append((h, l))
        else:
            other_items.append((h, l))

    # Sub-sort priority items strictly to match the list declaration order
    priority_items.sort(key=lambda x: priority_order.index(x[1]))

    # Combine everything back together in a clear structural chain
    sorted_pairs = priority_items + other_items + baseline_items
    sorted_handles = [p[0] for p in sorted_pairs]
    sorted_labels = [p[1] for p in sorted_pairs]

    # STYLE: Adjusted bounding box to closely match layout requirements
    fig.legend(
        sorted_handles,
        sorted_labels,
        loc="upper center",
        ncol=len(sorted_labels),
        bbox_to_anchor=(0.5, 0.98),
        frameon=True,
    )

    plt.tight_layout(rect=[0, 0, 1, 0.88])

    # STYLE: Added dpi requirement
    plt.savefig("test.pdf", dpi=300)
    print("[OK] Plots successfully saved as 'test.pdf'.")
    # plt.show()


if __name__ == "__main__":
    # Updated length check to 3 to account for the arch argument + at least one file
    if len(sys.argv) < 3:
        print(f"Usage: python {sys.argv[0]} <amd|intel> <file1.txt> [file2.txt ...]")
        sys.exit(1)

    arch_arg = sys.argv[1].lower()
    if arch_arg == "amd":
        selected_baselines = BASELINES_AMD
        print("[INFO] Utilizing AMD memory baselines.")
    elif arch_arg == "intel":
        selected_baselines = BASELINES_INTEL
        print("[INFO] Utilizing Intel memory baselines.")
    else:
        print("Error: First argument must be either 'amd' or 'intel'.")
        sys.exit(1)

    all_results = []

    # Shifted to read files starting from sys.argv[2:]
    for file_path in sys.argv[2:]:
        fill_factors, insert_avgs, find_avgs = parse_perf_data(file_path, "MEDIAN")
        label = os.path.splitext(os.path.basename(file_path))[0]

        print(f"\nResults for {file_path}")
        print(f"Inserts: {[round(val, 2) for val in insert_avgs]}")
        print(f"Finds:   {[round(val, 2) for val in find_avgs]}")

        all_results.append((label, fill_factors, insert_avgs, find_avgs))

    # Pass the actively selected baselines to the plot function
    plot_bandwidth(all_results, selected_baselines)
