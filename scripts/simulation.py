import numpy as np
import argparse


def simulate_overflow(N, B, K):
    assignments = np.random.randint(0, B, size=N)
    counts = np.bincount(assignments, minlength=B)
    overflow = sum((count - K) if count > K else 0 for count in counts)
    return overflow


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

    total_overflow = 0
    print(f"Running {args.trials} trial(s) with N={args.N}, B={args.B}, K={args.K}")
    for trial in range(1, args.trials + 1):
        overflow = simulate_overflow(args.N, args.B, args.K)
        perc = overflow / args.N
        total_overflow += overflow
        print(f"Trial {trial}: Overflow items = {overflow}, percentage = {perc}")

    if args.trials > 1:
        avg_overflow = total_overflow / args.trials
        perc = avg_overflow / args.N
        print(f"\nAverage overflow over {args.trials} trials: {avg_overflow} percentage = {perc}")


if __name__ == "__main__":
    main()
