import os
import re
import sys

import numpy as np

# Tolerances for deviation warnings
HIT_RATE_DELTA = 0.02
SKEW_DELTA = 0.15


def estimate_zipf_skew(data):
    """Estimates the Zipfian skew parameter 's' using log-log regression."""
    _, counts = np.unique(data, return_counts=True)
    counts_sorted = np.sort(counts)[::-1]

    # Filter out zero counts to avoid log(0) errors
    valid = counts_sorted > 0
    if not np.any(valid):
        return 0.0

    log_ranks = np.log(np.arange(1, np.sum(valid) + 1))
    log_counts = np.log(counts_sorted[valid])

    # Fit line: log(count) = -s * log(rank) + c
    # The slope is the negative of the skew parameter
    # If there is no variance in counts (e.g., all 1s), slope is 0.
    if len(log_ranks) > 1 and np.var(log_counts) > 0:
        slope, _ = np.polyfit(log_ranks, log_counts, 1)
        return -slope
    return 0.0


def check_hashjoin(filepath, filename):
    pattern = r"hashjoin_r(\d+)_s(\d+)_skew([\d.]+)_hit([\d.]+)_seed(\d+)\.bin"
    match = re.match(pattern, filename)

    if not match:
        print(f"Error: Filename '{filename}' does not match hashjoin format.")
        sys.exit(1)

    r_size = int(match.group(1))
    s_size = int(match.group(2))
    expected_skew = float(match.group(3))
    expected_hit_rate = float(match.group(4))
    seed = int(match.group(5))

    print("Dataset Type: Hashjoin")
    print(f"Expected R Size:   {r_size}")
    print(f"Expected S Size:   {s_size}")
    print(f"Expected Skew:     {expected_skew}")
    print(f"Expected Hit Rate: {expected_hit_rate}")

    dtype = np.uint64
    data = np.fromfile(filepath, dtype=dtype)

    if len(data) != (r_size + s_size):
        print(
            f"WARNING: File length {len(data)} does not match expected {r_size + s_size}."
        )

    R = data[:r_size]
    S = data[r_size:]

    # Uniqueness check
    unique_r = np.unique(R)
    is_unique = len(unique_r) == len(R)
    if not is_unique:
        print("WARNING: R relation contains duplicate keys.")
    else:
        print("R Uniqueness:      Passed")

    # Hit rate check
    hits = np.isin(S, unique_r)
    actual_hit_rate = np.mean(hits)
    hit_diff = abs(actual_hit_rate - expected_hit_rate)

    print(f"Computed Hit Rate: {actual_hit_rate:.4f}")
    if hit_diff > HIT_RATE_DELTA:
        print(
            f"WARNING: Hit rate deviates by {hit_diff:.4f} (Threshold: {HIT_RATE_DELTA})"
        )

    # Skew check
    actual_skew = estimate_zipf_skew(S)
    skew_diff = abs(actual_skew - expected_skew)

    print(f"Computed Skew:     {actual_skew:.4f}")
    if expected_skew > 0 and skew_diff > SKEW_DELTA:
        print(f"WARNING: Skew deviates by {skew_diff:.4f} (Threshold: {SKEW_DELTA})")


def check_zipfian(filepath, filename):
    pattern = r"zipfian_skew([\d.]+)_seed(\d+)_size(\d+)_keyrange(\d+)\.bin"
    match = re.match(pattern, filename)

    if not match:
        print(f"Error: Filename '{filename}' does not match zipfian format.")
        sys.exit(1)

    expected_skew = float(match.group(1))
    seed = int(match.group(2))
    expected_size = int(match.group(3))

    print("Dataset Type: Pure Zipfian")
    print(f"Expected Size: {expected_size}")
    print(f"Expected Skew: {expected_skew}")

    dtype = np.uint64
    data = np.fromfile(filepath, dtype=dtype)

    if len(data) != expected_size:
        print(
            f"WARNING: File length {len(data)} does not match expected {expected_size}."
        )

    # Skew check
    actual_skew = estimate_zipf_skew(data)
    skew_diff = abs(actual_skew - expected_skew)

    print(f"Computed Skew: {actual_skew:.4f}")
    if expected_skew > 0 and skew_diff > SKEW_DELTA:
        print(f"WARNING: Skew deviates by {skew_diff:.4f} (Threshold: {SKEW_DELTA})")


def check_uniform(filepath, filename):
    pattern = r"uniform_seed(\d+)_size(\d+)\.bin"
    match = re.match(pattern, filename)

    if not match:
        print(f"Error: Filename '{filename}' does not match uniform format.")
        sys.exit(1)

    seed = int(match.group(1))
    expected_size = int(match.group(2))

    print("Dataset Type: Pure Uniform")
    print(f"Expected Size: {expected_size}")
    print(f"Seed:          {seed}")

    dtype = np.uint64
    data = np.fromfile(filepath, dtype=dtype)

    if len(data) != expected_size:
        print(
            f"WARNING: File length {len(data)} does not match expected {expected_size}."
        )

    # Skew check (should be approximately 0.0)
    actual_skew = estimate_zipf_skew(data)
    print(f"Computed Skew: {actual_skew:.4f}")

    if actual_skew > SKEW_DELTA:
        print(
            f"WARNING: Skew deviates significantly from 0.0 (Data shows skew of {actual_skew:.4f})"
        )

    # Collision check
    unique_elements = len(np.unique(data))
    collision_rate = 1.0 - (unique_elements / len(data))
    print(f"Collision Rate: {collision_rate:.6f}")
    if collision_rate > 0.01:  # Over 1% collisions in a 64-bit space is suspicious
        print(
            "WARNING: Unusually high collision rate for a 64-bit uniform distribution."
        )


def verify_dataset(filepath):
    filename = os.path.basename(filepath)
    print("-" * 45)
    print(f"Analyzing: {filename}")
    print("-" * 45)

    if filename.startswith("hashjoin_"):
        check_hashjoin(filepath, filename)
    elif filename.startswith("zipfian_"):
        check_zipfian(filepath, filename)
    elif filename.startswith("uniform_"):
        check_uniform(filepath, filename)
    else:
        print(f"Error: Unknown dataset type for file '{filename}'")
        sys.exit(1)
    print("-" * 45)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python verify_dataset.py <path_to_bin_file>")
        sys.exit(1)

    target_file = sys.argv[1]

    if not os.path.exists(target_file):
        print(f"Error: File '{target_file}' not found.")
        sys.exit(1)

    verify_dataset(target_file)
