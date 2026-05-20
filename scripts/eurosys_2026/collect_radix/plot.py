import argparse
import json
import sys

import matplotlib.pyplot as plt


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(
        description="Plot benchmark results from a JSON file."
    )
    parser.add_argument(
        "input_json", help="Path to the input JSON file (e.g., data.json)"
    )
    parser.add_argument(
        "output_png", help="Path to save the output PNG file (e.g., plot.png)"
    )

    args = parser.parse_args()

    # Load data from the provided JSON file
    try:
        with open(args.input_json, "r") as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: The file '{args.input_json}' was not found.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: The file '{args.input_json}' is not a valid JSON.")
        sys.exit(1)

    # Extract data
    try:
        x_values = data["param_values"]
        hash_throughput = data["hash_join_throughput"]
        radix_throughput = data["radix_join_throughput"]
        x_label = data["param_name"]
    except KeyError as e:
        print(f"Error: Missing expected key in JSON data: {e}")
        sys.exit(1)

    # Create the plot
    plt.figure(figsize=(10, 6))

    # Plot Hash Join
    plt.plot(
        x_values,
        hash_throughput,
        label="Hash Join (Prefetch OFF)",
        marker="o",
        color="#1f77b4",
        linewidth=2,
        markersize=8,
    )

    # Plot Radix Join
    plt.plot(
        x_values,
        radix_throughput,
        label="Radix Join (Prefetch ON)",
        marker="s",
        color="#ff7f0e",
        linewidth=2,
        markersize=8,
    )

    # Styling
    plt.title(
        f"Join Performance vs. {x_label.capitalize()}", fontsize=14, fontweight="bold"
    )
    plt.xlabel(x_label.capitalize(), fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend(fontsize=12, loc="best")

    # Adjust layout to prevent clipping of labels
    plt.tight_layout()

    # Save the plot to the provided output filename
    plt.savefig(args.output_png, dpi=300)
    print(f"[*] Plot successfully generated and saved to: {args.output_png}")


if __name__ == "__main__":
    main()
