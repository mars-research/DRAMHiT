#!/usr/bin/env python3
"""
Plots the kmer frequency distribution from jellyfish histo output on a
log-log scale, and overlays a fitted power-law (Zipfian) line.


using jellyfish to generate the mer_counts files for a given dataset can be done like the following:

m is the "mer" number (k), -s is number of slots for the internal hash table (4 billion for 4G,
sizing this to larger than the number of distinct kmers helps)

jellyfish count -m 31 -s 4G -t 32 /opt/datasets/ERR4846928.fastq -o mer_counts.jf

Input: histo.txt from `jellyfish histo -t 32 mer_counts.jf > histo.txt`
       Two columns: <count_value> <number_of_kmers_with_that_count>

Usage:
    python3 plot_skew.py --histo histo.txt --out skew_plot.png
"""

import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")   # no display needed, save to file
import matplotlib.pyplot as plt


def load_histo(path):
    """Load (count_value, num_kmers) pairs from jellyfish histo output."""
    count_vals = []
    num_kmers  = []
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) != 2:
                continue
            c, n = int(parts[0]), int(parts[1])
            count_vals.append(c)
            num_kmers.append(n)
    return np.array(count_vals), np.array(num_kmers)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--histo", required=True, help="jellyfish histo output")
    parser.add_argument("--out", default="skew_plot.png", help="output image")
    parser.add_argument("--k", type=int, default=31, help="kmer length (for title)")
    args = parser.parse_args()

    count_vals, num_kmers = load_histo(args.histo)

    # ---- Summary statistics ----
    total_distinct = num_kmers.sum()
    total_obs      = (count_vals * num_kmers).sum()
    singletons     = num_kmers[count_vals == 1].sum() if 1 in count_vals else 0
    max_count      = count_vals.max()
    mean_count     = total_obs / total_distinct

    print(f"Distinct kmers     : {total_distinct:,}")
    print(f"Total observations : {total_obs:,}")
    print(f"Singletons         : {singletons:,} ({100*singletons/total_distinct:.1f}%)")
    print(f"Max count          : {max_count:,}")
    print(f"Mean count         : {mean_count:.2f}")

    # ---- Build rank-frequency from the histogram ----
    # Each count value c corresponds to num_kmers[i] kmers, all with frequency c.
    # Sort by frequency descending to get the rank-frequency curve.
    order = np.argsort(-count_vals)
    sorted_counts = count_vals[order]
    sorted_nums   = num_kmers[order]

    # Cumulative rank: kmers ranked by frequency
    ranks = np.cumsum(sorted_nums)
    freqs = sorted_counts

    # ---- Fit power law: log(freq) = -s * log(rank) + b ----
    mask = (ranks > 0) & (freqs > 0)
    log_rank = np.log10(ranks[mask])
    log_freq = np.log10(freqs[mask])
    slope, intercept = np.polyfit(log_rank, log_freq, 1)
    skew_s = -slope
    print(f"\nFitted Zipfian skew (s): {skew_s:.3f}")

    # ---- Plot 1: Frequency histogram (count vs number of kmers) ----
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax1 = axes[0]
    valid = (count_vals > 0) & (num_kmers > 0)
    ax1.loglog(count_vals[valid], num_kmers[valid], 'o', markersize=3,
               color='steelblue', alpha=0.6)
    ax1.set_xlabel("kmer frequency (count)")
    ax1.set_ylabel("number of distinct kmers")
    ax1.set_title(f"Frequency Histogram (k={args.k})")
    ax1.grid(True, which="both", ls="--", alpha=0.3)

    # ---- Plot 2: Rank-frequency with Zipfian fit ----
    ax2 = axes[1]
    ax2.loglog(ranks[mask], freqs[mask], '-', color='steelblue',
               linewidth=1.5, label="observed")

    # Overlay the fitted line
    fit_freq = 10 ** (intercept + slope * log_rank)
    ax2.loglog(ranks[mask], fit_freq, '--', color='crimson',
               linewidth=1.5, label=f"Zipfian fit (s={skew_s:.2f})")

    ax2.set_xlabel("rank (kmers ordered by frequency)")
    ax2.set_ylabel("frequency (count)")
    ax2.set_title("Rank-Frequency Distribution")
    ax2.legend()
    ax2.grid(True, which="both", ls="--", alpha=0.3)

    plt.tight_layout()
    plt.savefig(args.out, dpi=150, bbox_inches="tight")
    print(f"\nPlot saved to {args.out}")


if __name__ == "__main__":
    main()
