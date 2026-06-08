import re
import sys
import os
import matplotlib.pyplot as plt

# Separate baseline constants (GB/s) for independent adjustment
STREAM_INSERT = 255.6 
STREAM_FIND = 346.3

STREAM_INSERT_LABEL = "synthetic_1read_1write"
STREAM_FIND_LABEL = "synthetic_read"

# NEW BASELINES
BASELINES = [
    ("r", 342.3),
    ("rw", 271.4),
    ("stream+rw", 297.0),
    ("1.5R_1W", 280.0),
]

# USE TAB10 COLORS
TAB10 = plt.get_cmap("tab10").colors

BASELINE_COLORS = {
    "r": TAB10[0],          # blue
    "rw": TAB10[1],         # orange
    "stream+rw": TAB10[2],  # green
    "1.5R_1W": TAB10[3],    # red
}


def parse_perf_data(file_path):
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

    with open(file_path, 'r') as f:
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

            elif current_phase and ("umc_mem_bandwidth" in line or "unc_m_cas_count.all" in line):
                match = bw_pattern.search(line)
                if match:
                    if match.group(1):  # AMD path
                        bw_mb = float(match.group(1))
                    else:
                        bw_mb = (float(match.group(2).replace(',', '')) * 64) / 1e6

                    if current_phase == "insert":
                        current_run_insert.append(bw_mb)
                    elif current_phase == "find":
                        current_run_find.append(bw_mb)

    insert_avgs_gbs = []
    find_avgs_gbs = []

    trim = 2
    for data in insert_data:
        trimmed = data[trim:-trim] if len(data) > 2 * trim else data
        avg_mb = sum(trimmed) / len(trimmed) if trimmed else 0
        insert_avgs_gbs.append(avg_mb / 1000.0)

    for data in find_data:
        trimmed = data[trim:-trim] if len(data) > 2 * trim else data
        avg_mb = sum(trimmed) / len(trimmed) if trimmed else 0
        find_avgs_gbs.append(avg_mb / 1000.0)

    return fill_factors, insert_avgs_gbs, find_avgs_gbs


def plot_bandwidth(all_results):
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Track max value to dynamically sync the Y-axis limits
    max_y_val = max([val for _, val in BASELINES])  # Start with the highest baseline

    #
    # INSERT GRAPH
    #
    for idx, (label, fill_factors, insert_avgs, _) in enumerate(all_results):
        n_insert = min(len(fill_factors), len(insert_avgs))
        x_insert = fill_factors[:n_insert]
        y_insert = insert_avgs[:n_insert]
        
        if y_insert:
            max_y_val = max(max_y_val, max(y_insert))

        data_color = TAB10[(4 + idx) % 10]

        # zorder=3 keeps dynamic lines safely above the baselines
        axes[0].plot(
            x_insert,
            y_insert,
            marker='o',
            linestyle='-',
            color=data_color,
            label=label,
            zorder=3
        )

    # Baselines (INSERT)
    for name, val in BASELINES:
        # zorder=1 forces synthetic benchmarks below the parsed metrics
        axes[0].axhline(
            val,
            linestyle='--',
            linewidth=2,
            color=BASELINE_COLORS.get(name, None),
            label=name,
            zorder=1
        )

    axes[0].set_title('Insert Memory Bandwidth')
    axes[0].set_xlabel('Fill Factor (%)')
    axes[0].set_ylabel('Bandwidth (GB/s)')
    axes[0].set_xticks(list(range(10, 100, 10)))
    axes[0].grid(True, linestyle='--', alpha=0.7, zorder=0)

    #
    # FIND GRAPH
    #
    for idx, (label, fill_factors, _, find_avgs) in enumerate(all_results):
        n_find = min(len(fill_factors), len(find_avgs))
        x_find = fill_factors[:n_find]
        y_find = find_avgs[:n_find]
        
        if y_find:
            max_y_val = max(max_y_val, max(y_find))

        data_color = TAB10[(4 + idx) % 10]

        axes[1].plot(
            x_find,
            y_find,
            marker='s',
            linestyle='-',
            color=data_color,
            label=label,
            zorder=3
        )

    # Baselines (FIND)
    for name, val in BASELINES:
        axes[1].axhline(
            val,
            linestyle='--',
            linewidth=2,
            color=BASELINE_COLORS.get(name, None),
            label=name,
            zorder=1
        )

    axes[1].set_title('Find Memory Bandwidth')
    axes[1].set_xlabel('Fill Factor (%)')
    axes[1].set_ylabel('Bandwidth (GB/s)')
    axes[1].set_xticks(list(range(10, 100, 10)))
    axes[1].grid(True, linestyle='--', alpha=0.7, zorder=0)

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
    
    baseline_names = [b[0] for b in BASELINES]

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

    fig.legend(
        sorted_handles,
        sorted_labels,
        loc='upper center',
        ncol=len(sorted_labels),  # Force columns equal to length so it's always single-row
        frameon=True
    )

    plt.tight_layout(rect=[0, 0, 1, 0.90])

    plt.savefig('test.pdf')
    print("Plots successfully saved as 'test.pdf'.")
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