#!/usr/bin/env python3
"""growt vs folklore vs dramblast: throughput and DRAM bandwidth over fill.

Style comes from ../paper_style.py; see ../PLOTTING.md.

    python3 merge_plot.py folklore.txt growt.txt dramblast.txt

Each input is a collect.sh log (perf stat interval output + dramhit stdout).
Throughput is on the left axis (solid), memory bandwidth on a twin right axis
(dashed, hollow diamond) in the same colour as its table.

Each point is a single run, so there are no repeats and no min/max band.
"""
import re
import sys
import os
import statistics
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

# growt is not one of the five tables in ps.PALETTE_ORDER, and appending it
# there would change the palette size and recolour every other figure. It gets
# one fixed neutral colour here instead, so it never borrows a hashtable's.
OUTSIDE_PALETTE = {"growt": "0.45"}

# Baselines are reference levels, not tables: dotted, in neutral greys.
BASELINE_COLORS = ["0.2", "0.4", "0.6", "0.8"]

# The bandwidth curve of a table: same colour, told apart from its throughput
# curve by dash + hollow diamond. "D" is not used by any ps.VARIANT_STYLE entry,
# so it cannot be read as a variant (dashed-square is *_nopref / *_hwpf_off).
BW_STYLE = {"linestyle": "--", "marker": "D", "markerfacecolor": "none"}


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


def parse_fills(file_path):
    """Fill factor of each run, from the command line collect.sh echoes after it."""
    fill_pattern = re.compile(r"--ht-fill\s+(\d+)")
    fills = []
    with open(file_path, 'r') as f:
        for line in f:
            m = fill_pattern.search(line)
            if m:
                fills.append(int(m.group(1)))
    return fills


def styles_for(names, palette):
    styles = ps.styles_for(names, palette)
    for name in names:
        if styles[name]["color"] is None:
            styles[name]["color"] = OUTSIDE_PALETTE.get(name, "0.45")
    return styles


def draw_phase(ax, results, names, styles, phase, title, fills):
    ax_bw = ax.twinx()
    for name in names:
        r = results[name]
        mops, bw = r[f"{phase}_mops"], r[f"{phase}_bw"]
        n = min(len(r["fills"]), len(mops), len(bw))
        x = r["fills"][:n]
        ax.plot(x, mops[:n], zorder=3, **styles[name])
        ax_bw.plot(x, bw[:n], zorder=3, **{**styles[name], **BW_STYLE})

    for (_, val), colour in zip(BASELINES, BASELINE_COLORS):
        ax_bw.axhline(val, linestyle=':', color=colour, zorder=1)

    xlabel, ylabel = ps.axis_labels("fill")
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax_bw.set_ylabel("bandwidth (GB/s)")
    ax.set_xticks(fills)
    ax.set_xlim(min(fills) - 5, max(fills) + 5)

    ax.set_ylim(bottom=0)
    ax_bw.set_ylim(bottom=0)
    ps.tidy(ax)
    # One grid per panel: the twin axis' ticks don't land on the left axis'
    # gridlines, so a second whitegrid would just be noise.
    ax_bw.grid(False)


def plot_combined(results, out_path="combined_perf.pdf"):
    ps.configure_style()
    palette = ps.configure_palette()

    names = ps.order_series(list(results))
    styles = styles_for(names, palette)
    fills = sorted({f for r in results.values() for f in r["fills"]})

    fig, axes = ps.get_subplots(1, 2)
    draw_phase(axes[0], results, names, styles, "ins", "insertion", fills)
    draw_phase(axes[1], results, names, styles, "fnd", "lookup", fills)

    # ps.add_legend() with two extra keys explaining the twin axes, so the
    # legend matches the other figures' (same kwargs, same name translation).
    handles = [
        mlines.Line2D([0], [0], label=ps.display_name(name), **styles[name])
        for name in names
    ]
    handles += [
        mlines.Line2D([], [], color=c, linestyle=':', label=name)
        for (name, _), c in zip(BASELINES, BASELINE_COLORS)
    ]
    handles += [
        mlines.Line2D([], [], color='black', linestyle='-', marker='o',
                      label='throughput (Mops)'),
        mlines.Line2D([], [], color='black', **BW_STYLE, label='bandwidth (GB/s)'),
    ]
    fig.legend(fontsize=8, handles=handles, loc="upper center", ncol=len(handles))

    ps.save(fig, out_path, legend_top=0.9)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <file1.txt> [file2.txt ...]")
        sys.exit(1)

    results = {}

    for file_path in sys.argv[1:]:
        ins_bw, fnd_bw = parse_bw_data(file_path)
        ins_mops, fnd_mops = parse_mops_data(file_path)
        fills = parse_fills(file_path)
        label = os.path.splitext(os.path.basename(file_path))[0]

        print(f"\nResults for {label}")
        print(f"Fill factors (%):    {fills}")
        print(f"Inserts BW (GB/s):   {[round(v, 2) for v in ins_bw]}")
        print(f"Finds BW (GB/s):     {[round(v, 2) for v in fnd_bw]}")
        print(f"Inserts MOPS:        {[round(v, 2) for v in ins_mops]}")
        print(f"Finds MOPS:          {[round(v, 2) for v in fnd_mops]}")

        results[label] = {
            "fills": fills,
            "ins_bw": ins_bw, "fnd_bw": fnd_bw,
            "ins_mops": ins_mops, "fnd_mops": fnd_mops,
        }

    plot_combined(results)
