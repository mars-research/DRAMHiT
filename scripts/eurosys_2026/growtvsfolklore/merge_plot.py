#!/usr/bin/env python3
import re
import sys
import os
import statistics
import matplotlib.pyplot as plt
import matplotlib.lines as mlines
from pathlib import Path

# Insert the parent directory into sys.path to import paper_style.py
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import paper_style as ps

# NEW BASELINES (Bandwidth in GB/s)
BASELINES = [
    # ("r", 0),
    # ("rw", 0),
    # ("stream+rw", 0),
    # ("1.5r_1w", 0), 
]

def parse_bw_data(file_path):
    """Parses median memory bandwidth from umc_mem_bandwidth / unc_m_cas_count"""
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

    insert_medians_gbs = []
    find_medians_gbs = []
    trim = 2
    for data in insert_data:
        trimmed = data[trim:-trim] if len(data) > 2 * trim else data
        median_mb = statistics.median(trimmed) if trimmed else 0
        insert_medians_gbs.append(median_mb / 1000.0)

    for data in find_data:
        trimmed = data[trim:-trim] if len(data) > 2 * trim else data
        median_mb = statistics.median(trimmed) if trimmed else 0
        find_medians_gbs.append(median_mb / 1000.0)

    return insert_medians_gbs, find_medians_gbs

def parse_mops_data(file_path):
    """Parses set_mops and get_mops directly from the lines"""
    insert_mops = []
    find_mops = []

    with open(file_path, 'r') as f:
        for line in f:
            if "set_mops" in line:
                parts = line.split(',')
                set_val = float(parts[2].split(':')[1].strip())
                get_val = float(parts[3].split(':')[1].strip())
                
                insert_mops.append(set_val)
                find_mops.append(get_val)

    return insert_mops, find_mops


def plot_combined(all_results):
    ps.configure_style()
    palette = ps.configure_palette()

    # Creates 1x2 panels with standard 4x4-inch sizing (8x4 total)
    fig, axes = ps.get_subplots(1, 2)

    ax_ins_mops = axes[0]
    ax_ins_bw = ax_ins_mops.twinx()

    ax_fnd_mops = axes[1]
    ax_fnd_bw = ax_fnd_mops.twinx()

    fill_factors = list(range(10, 100, 10))

    # Sort dictionary to adhere to Canonical ordering and color assignments
    all_results_dict = {res[0]: res for res in all_results}
    ordered_labels = ps.order_series(list(all_results_dict.keys()))
    ordered_results = [all_results_dict[lbl] for lbl in ordered_labels]

    # Track styles so plot and legend are perfectly synced
    final_styles = {}
    fallback_colors = ['gray', 'brown', 'teal', 'navy']
    unknown_idx = 0

    for label, ffs, ins_bw, fnd_bw, ins_mops, fnd_mops in ordered_results:
        # Retrieve strict canonical style mapping for the hashtable
        style = ps.series_style(label, palette)
        
        # Handle custom series cleanly if they aren't matched in PALETTE_ORDER
        plot_kwargs = {k: v for k, v in style.items() if v is not None}
        if 'color' not in plot_kwargs:
            plot_kwargs['color'] = fallback_colors[unknown_idx % len(fallback_colors)]
            unknown_idx += 1
            
        final_styles[label] = plot_kwargs

        # Build style overrides for the secondary Bandwidth axis
        bw_kwargs = plot_kwargs.copy()
        bw_kwargs['linestyle'] = '--'
        bw_kwargs['marker'] = '^'
        bw_kwargs['alpha'] = 0.8

        # ----------------- INSERT SUBPLOT -----------------
        n_ins = min(len(ffs), len(ins_mops), len(ins_bw))
        x_ins = ffs[:n_ins]

        ax_ins_mops.plot(x_ins, ins_mops[:n_ins], linewidth=2, zorder=3, **plot_kwargs)
        ax_ins_bw.plot(x_ins, ins_bw[:n_ins], linewidth=2, zorder=3, **bw_kwargs)

        # ----------------- FIND SUBPLOT -----------------
        n_fnd = min(len(ffs), len(fnd_mops), len(fnd_bw))
        x_fnd = ffs[:n_fnd]

        ax_fnd_mops.plot(x_fnd, fnd_mops[:n_fnd], linewidth=2, zorder=3, **plot_kwargs)
        ax_fnd_bw.plot(x_fnd, fnd_bw[:n_fnd], linewidth=2, zorder=3, **bw_kwargs)

    # Add Baselines (on Bandwidth axes)
    for i, (name, val) in enumerate(BASELINES):
        b_color = palette[i % len(palette)]
        ax_ins_bw.axhline(val, linestyle=':', linewidth=2, color=b_color, zorder=1)
        ax_fnd_bw.axhline(val, linestyle=':', linewidth=2, color=b_color, zorder=1)

    # ----------------- FORMATTING -----------------
    xlabel, ylabel_mops = ps.axis_labels("fill")

    ax_ins_mops.set_title("Insert Performance")
    ax_ins_mops.set_xlabel(xlabel)
    ax_ins_mops.set_ylabel(ylabel_mops)
    ax_ins_bw.set_ylabel("Bandwidth (GB/s)")
    ax_ins_mops.set_xticks(fill_factors)

    ax_fnd_mops.set_title("Find Performance")
    ax_fnd_mops.set_xlabel(xlabel)
    ax_fnd_mops.set_ylabel(ylabel_mops)
    ax_fnd_bw.set_ylabel("Bandwidth (GB/s)")
    ax_fnd_mops.set_xticks(fill_factors)

    # Apply 0-bottom rule before tidying
    ax_ins_mops.set_ylim(bottom=0)
    ax_fnd_mops.set_ylim(bottom=0)
    ax_ins_bw.set_ylim(bottom=0)
    ax_fnd_bw.set_ylim(bottom=0)

    ps.tidy(ax_ins_mops)
    ps.tidy(ax_fnd_mops)

    # ----------------- LEGEND SORTING -----------------
    # Generate canonical legend entries pulling from our synced dictionary
    custom_lines = [
        mlines.Line2D([0], [0], label=ps.display_name(name), **final_styles[name])
        for name in ordered_labels
    ]

    # Append baseline handles
    for i, (name, val) in enumerate(BASELINES):
        custom_lines.append(mlines.Line2D([], [], color=palette[i % len(palette)], linestyle=':', label=name))

    # Append dummy handles to explain twin axis lines
    custom_lines.extend([
        mlines.Line2D([], [], color='black', linestyle='-', marker='o', label='Throughput (MOPS)'),
        mlines.Line2D([], [], color='black', linestyle='--', marker='^', label='Bandwidth (GB/s)')
    ])

    fig.legend(
        handles=custom_lines,
        loc="upper center",
        ncol=len(custom_lines),
        fontsize=8,
        frameon=False
    )

    # Save via helper
    ps.save(fig, "combined_perf.pdf", legend_top=0.90)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <file1.txt> [file2.txt ...]")
        sys.exit(1)

    all_results = []

    for file_path in sys.argv[1:]:
        ins_bw, fnd_bw = parse_bw_data(file_path)
        ins_mops, fnd_mops = parse_mops_data(file_path)
        label = os.path.splitext(os.path.basename(file_path))[0]

        print(f"\nResults for {label}")
        print(f"Inserts BW (GB/s):   {[round(v, 2) for v in ins_bw]}")
        print(f"Finds BW (GB/s):     {[round(v, 2) for v in fnd_bw]}")
        print(f"Inserts MOPS:        {[round(v, 2) for v in ins_mops]}")
        print(f"Finds MOPS:          {[round(v, 2) for v in fnd_mops]}")

        # Adding placeholder range since parsing extracts lists of data directly without tracking the X-axis key 
        fill_factors = list(range(10, 100, 10))
        all_results.append((label, fill_factors, ins_bw, fnd_bw, ins_mops, fnd_mops))

    plot_combined(all_results)