#!/usr/bin/env python3

import json
import sys
from pathlib import Path

import pandas as pd
import seaborn as sns

# Inject parent directory to import the shared style guide
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import paper_style as ps

def load_and_prep(json_file):
    """Loads JSON, auto-detects architecture, dynamically finds NUMA policy, and prepares performance data."""
    with open(json_file, "r") as f:
        data = json.load(f)

    df = pd.json_normalize(data, sep=".")

    # Drop NONE identifiers first so we only look at actual workload runs
    if "identifier" in df.columns:
        df = df[df["identifier"] != "NONE"]
        df["prefetch_id"] = df["identifier"].str.split("-").str[0]
    else:
        df["prefetch_id"] = "Unknown"

    # Dynamically pick the NUMA policy that actually has data
    if "run_cfg.numa_policy" in df.columns and not df.empty:
        best_policy = df["run_cfg.numa_policy"].mode()[0]
        df = df[df["run_cfg.numa_policy"] == best_policy]

    if "run_cfg.fill_factor" in df.columns:
        df["run_cfg.fill_factor"] = pd.to_numeric(df["run_cfg.fill_factor"])

    # Auto-detect Architecture for naming purposes
    has_intel = any(col in df.columns for col in ["cycle_activity.stalls_total", "l1d_pend_miss.fb_full"])
    has_amd = any(col in df.columns for col in ["ls_alloc_mab_count", "ls_mab_alloc.all_allocations"])

    if has_intel:
        arch = "intel"
    elif has_amd:
        arch = "amd"
    else:
        arch = "unknown"

    return df, arch


def plot_combined(json_files, output_file):
    # 1. Setup paper style
    ps.configure_style()
    
    datasets = []

    # Load all files and assign names automatically based on filename/arch
    for f in json_files:
        df, arch = load_and_prep(f)
        if arch == "intel":
            if "hbm" in f.lower():
                label = "Intel HBM"
            else:
                label = "Intel"
        elif arch == "amd":
            label = "AMD"
        else:
            label = "Unknown Architecture"
        
        datasets.append((label, df, arch))

    # Consolidate unique IDs across ALL files for a unified legend
    unique_ids = []
    for _, df_set, _ in datasets:
        if "prefetch_id" in df_set.columns:
            for uid in df_set["prefetch_id"].unique():
                if uid not in unique_ids:
                    unique_ids.append(uid)

    # 2. Fix Palette Assignment for Unmapped Sweeps
    # Check if ANY of our dataset series are known hashtables in the paper
    known_series = [uid for uid in unique_ids if ps.canonical(uid) in ps.PALETTE_ORDER]
    
    if not known_series:
        # Per PLOTTING.md: If these are not hashtables (e.g. prefetch distances), 
        # build the palette dynamically based on the length of unique_ids.
        palette = ps.configure_palette(n=max(1, len(unique_ids)))
        styles = {uid: {"color": palette[i % len(palette)], "linestyle": "-", "marker": "o"} 
                  for i, uid in enumerate(unique_ids)}
    else:
        # Stick to the strict paper rules for known hashtables
        palette = ps.configure_palette()
        styles = ps.styles_for(unique_ids, palette)
        
        # Failsafe: if a rogue unknown series slipped in, manually lock its color 
        # so Seaborn doesn't cycle and ruin the other colors.
        fallback_color_idx = 0
        for uid in unique_ids:
            if styles[uid].get("color") is None:
                styles[uid]["color"] = palette[fallback_color_idx % len(palette)]
                fallback_color_idx += 1

    # 3. Get panels (1 row, N columns)
    col = len(datasets)
    fig, axes = ps.get_subplots(1, col)
    # Ensure axes is iterable even if col=1
    axes_flat = [axes] if col == 1 else axes.ravel()

    # Get standard labels defined by the paper
    x_label, y_label = ps.axis_labels("fill")
    
    # Calculate global max throughput to emulate sharey=True across all machines
    global_max_mops = max([df_set["get_mops"].max() for _, df_set, _ in datasets if not df_set.empty])

    # 4. Plotting loop
    for c, (machine_name, df_set, arch) in enumerate(datasets):
        if df_set.empty:
            print(f"[Warning] No valid data found to plot for {machine_name}")
            continue

        ax = axes_flat[c]
        
        # Iterate safely (using paper_style's order)
        for name in ps.order_series(df_set["prefetch_id"].unique()):
            sub = df_set[df_set["prefetch_id"] == name].sort_values("run_cfg.fill_factor")
            style = styles[name]
            
            # Draw line with explicit color lock applied above
            sns.lineplot(
                data=sub, 
                x="run_cfg.fill_factor", 
                y="get_mops",
                ax=ax, 
                legend=False, 
                **style
            )
        
        # Apply strict Y-axis baseline and emulate sharey=True
        ax.set_ylim(0, global_max_mops)
        
        # Apply dashed grid and tick snapping
        ps.tidy(ax)
        
        ax.set_title(machine_name, fontweight='bold')
        ax.set_xlabel(x_label)
        
        # Only label the Y-axis on the leftmost plot
        if c == 0:
            ax.set_ylabel(y_label)
        else:
            ax.set_ylabel("")

    # 5. Legend and Output
    ps.add_legend(fig, palette, ps.order_series(unique_ids), styles=styles)
    ps.save(fig, output_file, legend_top=0.88)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python plot_merge.py <file1.json> [file2.json ...] <output.pdf>")
        sys.exit(1)

    # Everything up to the last argument is considered an input JSON
    input_files = sys.argv[1:-1]
    
    # The final argument is always the output image/pdf
    output_file = sys.argv[-1]

    plot_combined(input_files, output_file)