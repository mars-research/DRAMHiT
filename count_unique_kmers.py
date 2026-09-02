#!/usr/bin/env python3
"""
Counts unique kmers in a FASTQ file using the same 2-bit encoding
as DNAKMer in circular_buffer.hpp:
  A=0 (00), C=1 (01), G=2 (10), T=3 (11)
  Any non-ACGT base resets the kmer window.

Usage:
    python3 count_unique_kmers.py --in-file reads.fastq --k 31
"""

import argparse
import sys

ENCODE = {'A': 0, 'C': 1, 'G': 2, 'T': 3,
          'a': 0, 'c': 1, 'g': 2, 't': 3}

def kmer_mask(k):
    return (1 << (2 * k)) - 1

def iter_sequences(fastq_path):
    """Yield DNA sequences from a FASTQ file."""
    with open(fastq_path, 'r') as f:
        while True:
            header = f.readline()
            if not header:
                break
            if not header.startswith('@'):
                continue
            seq  = f.readline().strip()
            plus = f.readline()   # '+'
            qual = f.readline()   # quality scores
            if seq:
                yield seq

def count_unique_kmers(fastq_path, k):
    mask   = kmer_mask(k)
    unique = set()

    total_reads  = 0
    total_kmers  = 0

    for seq in iter_sequences(fastq_path):
        total_reads += 1
        buffer      = 0
        valid_count = 0

        for base in seq:
            if base in ENCODE:
                buffer = ((buffer << 2) & mask) | ENCODE[base]
                valid_count += 1
                if valid_count >= k:
                    unique.add(buffer)
                    total_kmers += 1
            else:
                buffer      = 0
                valid_count = 0

        if total_reads % 100000 == 0:
            print(f"  processed {total_reads:,} reads, "
                  f"{total_kmers:,} kmers, "
                  f"{len(unique):,} unique so far...",
                  file=sys.stderr)

    return total_reads, total_kmers, len(unique)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Count unique kmers in a FASTQ file"
    )
    parser.add_argument("--in-file", required=True,
                        help="Input FASTQ file")
    parser.add_argument("--k", type=int, required=True,
                        help="Kmer length (1-32)")
    args = parser.parse_args()

    if args.k < 1 or args.k > 32:
        print(f"Error: k must be between 1 and 32 (got {args.k})")
        sys.exit(1)

    print(f"Counting unique {args.k}-mers in {args.in_file}...",
          file=sys.stderr)

    reads, total, unique = count_unique_kmers(args.in_file, args.k)

    print(f"\nResults:")
    print(f"  Total reads             : {reads:,}")
    print(f"  Total kmer observations : {total:,}")
    print(f"  Unique kmers            : {unique:,}")
    print(f"  Avg observations/kmer   : {total/unique:.1f}" if unique else "")
    print()

    # Suggest ht_size for dramhit
    # ht_size = unique_kmers * n_cons * num_threads / target_load
    for load in [0.5, 0.7]:
        for n_cons, num_threads in [(16, 32), (32, 64)]:
            ht_size = int(unique / load) * n_cons * num_threads
            print(f"  Suggested --ht-size for {int(load*100)}% load, "
                  f"ncons={n_cons}, num-threads={num_threads}: "
                  f"{ht_size:,}")
