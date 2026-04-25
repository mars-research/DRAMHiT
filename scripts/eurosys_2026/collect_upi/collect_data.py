import json
import re
import subprocess

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def main():
    # Configuration
    max_threads = 64
    json_filename = "remote_bandwidth_results.json"
    plot_filename = "remote_bandwidth_plot.png"

    # Regex to extract the bandwidth value
    # Example target string: "mem: 16384 bytes, took 0.000 sec, bandwidth: 1.4 GB/s"
    bw_pattern = re.compile(r"bandwidth:\s*([0-9.]+)\s*GB/s")

    results = []

    print(f"Starting DRAMHiT benchmarks from 1 to {max_threads} threads...")

    for threads in range(1, max_threads + 1):
        # Construct the command
        cmd = [
            "/opt/DRAMHiT/build/dramhit",
            "--ht-size",
            "2097152",
            "--sequential",
            "1",
            "--mode",
            "15",
            "--numa-split",
            "7",
            "--num-threads",
            str(threads),
        ]

        try:
            # Run the command and capture standard output
            process = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True,
            )
            output = process.stdout

            # Parse the output for bandwidth
            match = bw_pattern.search(output)
            if match:
                bandwidth = float(match.group(1))
                results.append({"threads": threads, "bandwidth_GBps": bandwidth})
                print(f"Threads: {threads:2} | Bandwidth: {bandwidth} GB/s")
            else:
                print(
                    f"Threads: {threads:2} | Error: Could not parse bandwidth from output."
                )
                print(f"Raw output:\n{output}")

        except subprocess.CalledProcessError as e:
            print(
                f"Threads: {threads:2} | Command failed with exit code {e.returncode}"
            )
            print(f"Error output:\n{e.stderr}")
        except FileNotFoundError:
            print(
                "Error: The DRAMHiT executable was not found at /opt/DRAMHiT/build/dramhit"
            )
            return

    # 1. Output JSON data format
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"\nData successfully saved to {json_filename}")

    # 2. Plot the data using seaborn and save as PNG (Do not show)
    if results:
        # Convert list of dictionaries to a pandas DataFrame for seaborn
        df = pd.DataFrame(results)

        # Configure seaborn style
        sns.set_theme(style="whitegrid")
        plt.figure(figsize=(10, 6))

        # Create the line plot
        ax = sns.lineplot(
            data=df, x="threads", y="bandwidth_GBps", marker="o", color="b"
        )

        # Set titles and labels
        ax.set_title("DRAMHiT Bandwidth vs. Number of Threads", fontsize=14, pad=15)
        ax.set_xlabel("Number of Threads", fontsize=12)
        ax.set_ylabel("Bandwidth (GB/s)", fontsize=12)

        # Set x-axis limits to match thread bounds
        plt.xlim(1, max_threads)

        # Save the figure to a file
        plt.savefig(plot_filename, dpi=300, bbox_inches="tight")

        # Close the plot to prevent it from displaying
        plt.close()
        print(f"Plot successfully saved to {plot_filename}")
    else:
        print("No valid data collected to plot.")


if __name__ == "__main__":
    main()
