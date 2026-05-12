import re
import subprocess

import matplotlib.pyplot as plt

# Define the range of skew factors you want to test
skew_factors = [0.01, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0, 1.2, 1.4]

# Base command template (everything except --skew)
base_cmd = [
    "/opt/DRAMHiT/build/dramhit",
    "--ht-type",
    "3",
    "--hw-pref",
    "0",
    "--ht-fill",
    "70",
    "--find_queue",
    "64",
    "--num-threads",
    "64",
    "--numa-split",
    "4",
    "--no-prefetch",
    "0",
    "--insert-factor",
    "1",
    "--read-factor",
    "1",
    "--mode",
    "11",
    "--batch-len",
    "16",
    "--seed",
    "1774551337382868027",
    "--ht-size",
    "536870912",
]

# Regular expressions to parse the required metrics from stdout/stderr
reprobe_pattern = re.compile(r"\{reprobe_factor\s*:\s*([0-9.]+)\}")
found_pattern = re.compile(r"found\s*:\s*(\d+),\s*expected_found\s*:\s*(\d+)")
mops_pattern = re.compile(r"get_mops\s*:\s*([0-9.]+)")

valid_skews = []
get_mops_data = []
reprobe_data = []

print("Starting DRAMHiT skew factor evaluation...\n")

for skew in skew_factors:
    # Build the full command for this iteration
    cmd = base_cmd + ["--skew", str(skew)]
    print(f"Running for skew = {skew}...")

    try:
        # Execute the command, combining stdout and stderr to catch all log messages
        result = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        )
        output = result.stdout

        # Parse the output
        reprobe_match = reprobe_pattern.search(output)
        found_match = found_pattern.search(output)
        mops_match = mops_pattern.search(output)

        if not (reprobe_match and found_match and mops_match):
            print(
                f"  [!] Warning: Missing required metrics in output for skew {skew}. Skipping."
            )
            continue

        reprobe_factor = float(reprobe_match.group(1))
        found = int(found_match.group(1))
        expected_found = int(found_match.group(2))
        get_mops = float(mops_match.group(1))

        # Validate found == expected_found
        if found != expected_found:
            print(
                f"  [!] Warning: Data mismatch for skew {skew} (found: {found}, expected: {expected_found}). Skipping."
            )
            continue

        print(
            f"  [✓] Success: get_mops = {get_mops}, reprobe_factor = {reprobe_factor}"
        )
        valid_skews.append(skew)
        get_mops_data.append(get_mops)
        reprobe_data.append(reprobe_factor)

    except Exception as e:
        print(f"  [!] Error executing command for skew {skew}: {e}")

# Generate Plots
if valid_skews:
    print("\nGenerating plots...")
    plt.figure(figsize=(14, 6))

    # Plot 1: Skew Factor vs get_mops
    plt.subplot(1, 2, 1)
    plt.plot(
        valid_skews,
        get_mops_data,
        marker="o",
        linestyle="-",
        color="tab:blue",
        linewidth=2,
    )
    plt.title("Zipfian Skew Factor vs. get_mops", fontsize=14)
    plt.xlabel("Zipfian Skew Factor", fontsize=12)
    plt.ylabel("get_mops", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)

    # Plot 2: Skew Factor vs reprobe_factor
    plt.subplot(1, 2, 2)
    plt.plot(
        valid_skews,
        reprobe_data,
        marker="s",
        linestyle="-",
        color="tab:red",
        linewidth=2,
    )
    plt.title("Zipfian Skew Factor vs. reprobe_factor", fontsize=14)
    plt.xlabel("Zipfian Skew Factor", fontsize=12)
    plt.ylabel("reprobe_factor", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)

    plt.tight_layout()

    # Save the plot to a file and display it
    output_filename = "dramhit_skew_analysis2.png"
    plt.savefig(output_filename, dpi=300)
    print(f"Plots successfully saved to {output_filename}")
    plt.show()
else:
    print(
        "\nNo valid data points were collected. Please check the executable path or output format."
    )
