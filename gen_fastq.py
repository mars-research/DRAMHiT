#!/usr/bin/env python3
"""
Generates a synthetic FASTQ file and a ground truth file of encoded kmer counts.
The encoding matches DNAKMer in circular_buffer.hpp exactly:
  A=0 (00), C=1 (01), G=2 (10), T=3 (11)
  2 bits per base, MSB = first base, built by shift-left then OR.
  Any non-ACGT base resets the kmer window (K new valid bases required).
"""

import random
import argparse
from collections import defaultdict

# Matches ENCODE_MAP in DNAKMer — only ACGT (upper and lower) are valid
ENCODE = {'A': 0, 'C': 1, 'G': 2, 'T': 3,
          'a': 0, 'c': 1, 'g': 2, 't': 3}

def kmer_mask(k):
    """
    Matches DNAKMer::KMER_MASK:
      ~((uint64_t)0 - (1ull << (2*K)))  for K < 32
    Keeps only the lower 2*K bits.
    """
    return (1 << (2 * k)) - 1

def encode_sequence(sequence, k):
    """
    Slide a window of size K over the sequence, encoding each kmer.
    Resets the window on any non-ACGT character, matching DNAKMer::push()
    returning false for code < 0.
    Yields encoded uint64 values for each valid kmer.
    """
    mask = kmer_mask(k)
    buffer = 0
    valid_count = 0  # how many consecutive valid bases we've accumulated

    for base in sequence:
        if base in ENCODE:
            # shift left by 2, mask to K bits, OR in new base — matches shift_left() then buffer_ |= code
            buffer = ((buffer << 2) & mask) | ENCODE[base]
            valid_count += 1
            if valid_count >= k:
                yield buffer
        else:
            # non-ACGT resets the window (matches push() returning false)
            buffer = 0
            valid_count = 0

def decode_kmer(encoded, k):
    """
    Reverse of encode — matches DNAKMer::to_string().
    Useful for debugging mismatches.
    """
    DECODE = ['A', 'C', 'G', 'T']
    bases = []
    for _ in range(k):
        bases.append(DECODE[encoded & 0b11])
        encoded >>= 2
    return ''.join(reversed(bases))

def generate_sequence(length, alphabet="ACGT"):
    """Generate a random DNA sequence using only valid bases."""
    return ''.join(random.choices(alphabet, k=length))

def generate_fastq(out_fastq, out_truth, num_reads, read_length, k, seed=42):
    random.seed(seed)
    mask = kmer_mask(k)

    # encoded_int → count
    kmer_counts = defaultdict(int)

    with open(out_fastq, 'w') as f:
        for i in range(num_reads):
            seq  = generate_sequence(read_length)
            qual = 'I' * read_length  # fixed high-quality score, matches real FASTQ format

            f.write(f"@read_{i}\n")
            f.write(f"{seq}\n")
            f.write(f"+\n")
            f.write(f"{qual}\n")

            for encoded in encode_sequence(seq, k):
                kmer_counts[encoded] += 1

    total_unique = len(kmer_counts)
    total_obs    = sum(kmer_counts.values())

    # Write ground truth as encoded integers — matches what the hash table stores
    with open(out_truth, 'w') as f:
        for encoded, count in sorted(kmer_counts.items()):
            f.write(f"{encoded}\t{count}\n")

    print(f"Generated {num_reads} reads of length {read_length}, k={k}")
    print(f"Total unique {k}-mers : {total_unique}")
    print(f"Total kmer observations: {total_obs}")
    print(f"FASTQ   → {out_fastq}")
    print(f"Truth   → {out_truth}  (encoded uint64 key <tab> count)")
    print()
    print("Sanity check — first 5 kmers from truth file:")
    items = list(kmer_counts.items())[:5]
    for enc, cnt in items:
        print(f"  {enc:20d}  ({decode_kmer(enc, k)})  count={cnt}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate synthetic FASTQ + encoded kmer truth file"
    )
    parser.add_argument("--num-reads",   type=int,   default=1000,
                        help="Number of reads to generate (default: 1000)")
    parser.add_argument("--read-length", type=int,   default=150,
                        help="Length of each read (default: 150)")
    parser.add_argument("--k",           type=int,   default=31,
                        help="Kmer length (default: 31, max: 32)")
    parser.add_argument("--seed",        type=int,   default=42,
                        help="Random seed for reproducibility (default: 42)")
    parser.add_argument("--out-fastq",   default="synthetic.fastq",
                        help="Output FASTQ file path")
    parser.add_argument("--out-truth",   default="truth_kmers.tsv",
                        help="Output truth file path (encoded uint64 + count)")
    args = parser.parse_args()

    if args.k > 32 or args.k < 1:
        print(f"Error: k must be between 1 and 32 (got {args.k})")
        exit(1)

    generate_fastq(
        args.out_fastq,
        args.out_truth,
        args.num_reads,
        args.read_length,
        args.k,
        args.seed,
    )