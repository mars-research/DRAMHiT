import json
import re
import subprocess
import matplotlib.pyplot as plt

filename = "intel_d760_dir_equal_radix_1gb"
build_sz = int(1024 * 1024 * 1024 / 16) # 1gb
def run_dramhit_experiments():
    # Radix values from 10 to 15 inclusive
    radix_values = list(range(10, 16))

    # Data arrays for the 3 lines
    partition_cycles_data = []
    join_cycles_data = []
    total_cycles_data = []
    successful_radices = []

    # List to store the data for JSON export
    experiment_data = []

    base_cmd = [
        "/opt/DRAMHiT/build/dramhit",
        "--ht-type",
        "3",
        "--ht-fill",
        "50",
        "--relation_r_size",
        str(build_sz),
        "--relation_s_size",
        str(build_sz),
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
            #print("cmd: " + " ".join(cmd))
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

                # Store the data for JSON export
                experiment_data.append({
                    "radix": radix,
                    "partition_cycles_per_tuple": partition_cpt,
                    "join_cycles_per_tuple": join_cpt,
                    "total_cycles_per_tuple": total_cpt
                })
            else:
                print(f"{radix:<10} | {'Missing metric(s) in output':<58}")

        except subprocess.CalledProcessError as e:
            print(f"{radix:<10} | Error: Command failed (Exit code {e.returncode})")
        except FileNotFoundError:
            print(f"Error: Executable not found at {base_cmd[0]}")
            return

    # --- Saving and Plotting the Results ---
    if successful_radices:
        # 1. Save to JSON
        json_filename = filename + ".json"
        with open(json_filename, "w") as json_file:
            json.dump(experiment_data, json_file, indent=4)
        print(f"\nData successfully saved to {json_filename}")

        # 2. Save the Plot
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
        output_filename = filename + ".png"
        plt.savefig(output_filename)
        print(f"Plot successfully saved to {output_filename}")

    else:
        print("\nNo valid data was captured to generate a plot or JSON file.")


if __name__ == "__main__":
    run_dramhit_experiments()
