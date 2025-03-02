import numpy as np
import argparse
from scipy.stats import poisson
import math

def simulate_overflow(N, B, K):
    assignments = np.random.randint(0, B, size=N)
    counts = np.bincount(assignments, minlength=B)
    overflow = sum((count - K) if count > K else 0 for count in counts)
    return overflow

def expected_overflow(lambda_val, k):
    """
    Compute the expected overflow E[(X-k)_+] for a Poisson random variable
    X ~ Poisson(lambda_val) and bucket capacity k.
    
    Parameters:
        lambda_val (float): Mean of the Poisson distribution.
        k (int): Capacity of the bucket.
    
    Returns:
        float: Expected overflow in the bucket.
    """
    # Choose a cutoff where remaining terms are negligible
    j_max = int(lambda_val + 5 * math.sqrt(lambda_val))
    total_overflow = 0.0
    for j in range(k + 1, j_max + 1):
        prob = (lambda_val**j * math.exp(-lambda_val)) / math.factorial(j)
        total_overflow += (j - k) * prob
    return total_overflow

def calculate_overflow_percentage(N, B, K):
    lambda_val = N / B
    e_overflow = expected_overflow(lambda_val, K)
    
    perc = e_overflow / lambda_val
    amount = e_overflow * B
    
    print(f"overflow percentage {perc:.4f}, amount {amount:.1f}")



def main():
    parser = argparse.ArgumentParser(
        description="Simulate N items assigned to B buckets with capacity K per bucket, and show the number of overflow items."
    )
    parser.add_argument("--N", type=int, required=True, help="Total number of items")
    parser.add_argument("--B", type=int, required=True, help="Number of buckets")
    parser.add_argument(
        "--K",
        type=int,
        required=True,
        help="Bucket capacity (maximum items allowed per bucket)",
    )
    parser.add_argument(
        "--trials",
        type=int,
        default=1,
        help="Number of simulation trials (default is 1)",
    )
    args = parser.parse_args()
    
    calculate_overflow_percentage(args.N, args.B, args.K)
    
    total_overflow = 0
    print(f"\nRunning {args.trials} trial(s) with N={args.N}, B={args.B}, K={args.K}")
    for trial in range(1, args.trials + 1):
        overflow = simulate_overflow(args.N, args.B, args.K)
        total_overflow += overflow
        print(f"Trial {trial}: Overflow items = {overflow}")

    if args.trials > 1:
        avg_overflow = total_overflow / args.trials
        print(f"\nAverage overflow over {args.trials} trials: {avg_overflow:.2f}")

if __name__ == "__main__":
    main()

