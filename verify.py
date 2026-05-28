#!/usr/bin/env python3
"""
Verifies kmer counting output against a ground truth file.

Truth file format (from gen_fastq.py):
    <encoded_uint64>\t<count>

Hash table output format (from Aggr_KV::operator<<):
    <encoded_uint64> : <count>

Usage:
    python3 verify.py --truth truth_kmers.tsv --ht-output ht_output --n-cons 16
"""

import argparse
import glob
import sys
from collections import defaultdict


def load_truth(path):
    counts = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split('\t')
            if len(parts) != 2:
                print(f"[WARN] Skipping malformed truth line: {line!r}")
                continue
            key, count = int(parts[0]), int(parts[1])
            counts[key] = count
    return counts


def load_ht_outputs(prefix, n_cons, n_prod):
    """
    Load all consumer shard files.
    Consumer shards are indexed from n_prod to n_prod+n_cons-1.
    e.g. with nprod=2, ncons=2: ht_output2, ht_output3
    """
    counts = defaultdict(int)
    files_read = []

    # Try explicit shard range first
    for shard_idx in range(n_prod, n_prod + n_cons):
        path = f"{prefix}{shard_idx}"
        try:
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    # Format: "<key> : <count>"
                    parts = line.split(' : ')
                    if len(parts) != 2:
                        print(f"[WARN] Skipping malformed output line: {line!r}")
                        continue
                    key, count = int(parts[0]), int(parts[1])
                    counts[key] += count
            files_read.append(path)
        except FileNotFoundError:
            print(f"[WARN] Shard file not found: {path}")

    # Fallback: glob for any matching files if none found in range
    if not files_read:
        print(f"[INFO] No files found in range, falling back to glob: {prefix}*")
        for path in sorted(glob.glob(f"{prefix}*")):
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    parts = line.split(' : ')
                    if len(parts) != 2:
                        continue
                    key, count = int(parts[0]), int(parts[1])
                    counts[key] += count
            files_read.append(path)

    return dict(counts), files_read


def verify(truth, result):
    all_keys = set(truth.keys()) | set(result.keys())

    mismatches = []
    missing    = []   # in truth but not in result
    extra      = []   # in result but not in truth

    for key in sorted(all_keys):
        expected = truth.get(key, 0)
        got      = result.get(key, 0)

        if expected == 0 and got > 0:
            extra.append((key, got))
        elif expected > 0 and got == 0:
            missing.append((key, expected))
        elif expected != got:
            mismatches.append((key, expected, got))

    return mismatches, missing, extra


def main():
    parser = argparse.ArgumentParser(
        description="Verify kmer counting output against ground truth"
    )
    parser.add_argument("--truth",     required=True,
                        help="Ground truth TSV file from gen_fastq.py")
    parser.add_argument("--ht-output", required=True,
                        help="Hash table output file prefix (e.g. 'ht_output')")
    parser.add_argument("--n-cons",    type=int, default=16,
                        help="Number of consumer threads (default: 16)")
    parser.add_argument("--n-prod",    type=int, default=16,
                        help="Number of producer threads (default: 16)")
    args = parser.parse_args()

    print(f"Loading truth file:      {args.truth}")
    truth = load_truth(args.truth)
    print(f"  {len(truth)} unique kmers, "
          f"{sum(truth.values())} total observations")

    print(f"\nLoading hash table output: {args.ht_output}*")
    result, files = load_ht_outputs(args.ht_output, args.n_cons, args.n_prod)
    print(f"  Read {len(files)} shard file(s): {files}")
    print(f"  {len(result)} unique kmers, "
          f"{sum(result.values())} total observations")

    print("\nVerifying...")
    mismatches, missing, extra = verify(truth, result)

    # Summary
    total_keys = len(set(truth.keys()) | set(result.keys()))
    correct    = total_keys - len(mismatches) - len(missing) - len(extra)

    print(f"\n{'='*50}")
    print(f"Total unique kmers checked : {total_keys}")
    print(f"Correct                    : {correct}")
    print(f"Count mismatches           : {len(mismatches)}")
    print(f"Missing from output        : {len(missing)}")
    print(f"Extra in output            : {len(extra)}")
    print(f"{'='*50}")

    if mismatches:
        print(f"\nCount mismatches (first 10):")
        for key, expected, got in mismatches[:10]:
            print(f"  key={key:20d}  expected={expected}  got={got}  diff={got-expected:+d}")

    if missing:
        print(f"\nMissing from output (first 10):")
        for key, expected in missing[:10]:
            print(f"  key={key:20d}  expected={expected}")

    if extra:
        print(f"\nExtra in output (first 10):")
        for key, got in extra[:10]:
            print(f"  key={key:20d}  got={got}")

    if not mismatches and not missing and not extra:
        print("\n✓ All kmer counts match perfectly!")
        sys.exit(0)
    else:
        print("\n✗ Verification failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()