import re
import subprocess

import matplotlib.pyplot as plt


def run_dramhit_experiments():
    # Radix values from 8 to 16 inclusive (script originally had 6 to 16)
    radix_values = list(range(10, 16))

    # Data arrays for the 3 lines
    partition_cycles_data = []
    join_cycles_data = []
    total_cycles_data = []
    successful_radices = []

    base_cmd = [
        "/opt/DRAMHiT/build/dramhit",
        "--ht-type",
        "3",
        "--ht-fill",
        "50",
        "--relation_r_size",
        "1073741824",
        "--relation_s_size",
        "1073741824",
        "--find_queue",
        "32",
        "--num-threads",
        "128",
        "--numa-split",
        "1",
        "--mode",
        "16",
        "--associativity",
        "1.00",
        "--skew",
        "0.01",
        "--seed",
        "1774551337382868027",
    ]

    print(
        f"{'Radix':<10} | {'Partition (cp/t)':<18} | {'Join (cp/t)':<18} | {'Total (cp/t)':<18}"
    )
    print("-" * 73)

    for radix in radix_values:
        cmd = base_cmd + ["--radix", str(radix)]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)

            # Using specific regexes to capture the 3 metrics
            partition_match = re.search(
                r"partition_cycle_per_tuple:\s*([\d.]+)", result.stdout
            )
            join_match = re.search(r"join_cycle_per_tuple:\s*([\d.]+)", result.stdout)
            # Use negative lookbehinds so we don't accidentally match 'partition_cycle_per_tuple'
            total_match = re.search(
                r"(?<!_)(?<![A-Za-z])cycle_per_tuple:\s*([\d.]+)", result.stdout
            )

            if partition_match and join_match and total_match:
                partition_cpt = float(partition_match.group(1))
                join_cpt = float(join_match.group(1))
                total_cpt = float(total_match.group(1))

                print(
                    f"{radix:<10} | {partition_cpt:<18} | {join_cpt:<18} | {total_cpt:<18}"
                )

                # Store the data for plotting
                successful_radices.append(radix)
                partition_cycles_data.append(partition_cpt)
                join_cycles_data.append(join_cpt)
                total_cycles_data.append(total_cpt)
            else:
                print(f"{radix:<10} | {'Missing metric(s) in output':<58}")

        except subprocess.CalledProcessError as e:
            print(f"{radix:<10} | Error: Command failed (Exit code {e.returncode})")
        except FileNotFoundError:
            print(f"Error: Executable not found at {base_cmd[0]}")
            return

    # --- Plotting the Results ---
    if successful_radices:
        plt.figure(figsize=(10, 6))

        # Plot all 3 lines with distinct markers and colors
        plt.plot(
            successful_radices,
            partition_cycles_data,
            marker="o",
            linestyle="-",
            color="r",
            label="Partition Phase",
        )
        plt.plot(
            successful_radices,
            join_cycles_data,
            marker="s",
            linestyle="-",
            color="g",
            label="Join Phase",
        )
        plt.plot(
            successful_radices,
            total_cycles_data,
            marker="^",
            linestyle="-",
            color="b",
            label="Total Cycles",
        )

        # Formatting the graph
        plt.title("DRAMHiT: Cycle per Tuple vs Radix")
        plt.xlabel("Radix")
        plt.ylabel("Cycle per Tuple")

        # Ensure x-axis only shows integer radix values
        plt.xticks(successful_radices)

        # Add Legend & Grid
        plt.legend(loc="upper left")
        plt.grid(True, linestyle="--", alpha=0.7)
        plt.tight_layout()

        # Save the plot
        output_filename = "intel_dual_equal_relation_radix.png"
        plt.savefig(output_filename)
        print(f"\nPlot successfully saved to {output_filename}")

    else:
        print("\nNo valid data was captured to generate a plot.")


if __name__ == "__main__":
    run_dramhit_experiments()
