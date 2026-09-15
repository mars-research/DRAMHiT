import json
import re
import subprocess
import matplotlib.pyplot as plt

from plot_style import configure_palette, configure_style, get_subplots, tidy

filename = "intel_hbm_single_radix_sweep_8gb"
build_sz = 8 * int(1024 * 1024 * 1024 / 16)  # 8gb


def run_dramhit_experiments():
    # Radix values swept around the optimal-radix pick (14) for 8gb relation size.
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
        "64",
        "--num-threads",
        "64",
        "--numa-split",
        "10",
        "--np_cpu_node_msk",
        "1",
        "--np_mem_node_msk",
        "4",
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

            partition_match = re.search(
                r"partition_cycle_per_tuple:\s*([\d.]+)", result.stdout
            )
            join_match = re.search(r"join_cycle_per_tuple:\s*([\d.]+)", result.stdout)
            total_match = re.search(
                r"(?<!_)(?<![A-Za-z])cycle_per_tuple:\s*([\d.]+)", result.stdout
            )
            throughput_match = re.search(
                r"throughput_mops\s*:\s*([0-9.]+)", result.stdout
            )

            if partition_match and join_match and total_match:
                partition_cpt = float(partition_match.group(1))
                join_cpt = float(join_match.group(1))
                total_cpt = float(total_match.group(1))
                throughput = float(throughput_match.group(1)) if throughput_match else None

                print(
                    f"{radix:<10} | {partition_cpt:<18} | {join_cpt:<18} | {total_cpt:<18} | throughput_mops={throughput}"
                )

                successful_radices.append(radix)
                partition_cycles_data.append(partition_cpt)
                join_cycles_data.append(join_cpt)
                total_cycles_data.append(total_cpt)

                experiment_data.append({
                    "radix": radix,
                    "partition_cycles_per_tuple": partition_cpt,
                    "join_cycles_per_tuple": join_cpt,
                    "total_cycles_per_tuple": total_cpt,
                    "throughput_mops": throughput,
                })
            else:
                print(f"{radix:<10} | {'Missing metric(s) in output':<58}")

        except subprocess.CalledProcessError as e:
            print(f"{radix:<10} | Error: Command failed (Exit code {e.returncode})")
            print(e.stdout[-2000:] if e.stdout else "(no stdout)")
        except FileNotFoundError:
            print(f"Error: Executable not found at {base_cmd[0]}")
            return

    if successful_radices:
        json_filename = filename + ".json"
        with open(json_filename, "w") as json_file:
            json.dump(experiment_data, json_file, indent=4)
        print(f"\nData successfully saved to {json_filename}")

        configure_style()
        palette = configure_palette(3)

        fig, axes = get_subplots(1, 1)
        ax = axes if not hasattr(axes, "ravel") else axes.ravel()[0]

        ax.plot(successful_radices, partition_cycles_data, marker="o",
                linestyle="-", color=palette[0], linewidth=1.6,
                label="partition phase")
        ax.plot(successful_radices, join_cycles_data, marker="s",
                linestyle="-", color=palette[1], linewidth=1.6,
                label="join phase")
        ax.plot(successful_radices, total_cycles_data, marker="^",
                linestyle="--", color=palette[2], linewidth=1.6,
                label="total")

        ax.set_title("Partition/Join Cycle per Tuple vs Selected Radix")
        ax.set_xlabel("radix")
        ax.set_ylabel("cycle per tuple")
        ax.set_xticks(successful_radices)
        ax.set_ylim(bottom=0)
        tidy(ax)

        fig.legend(fontsize=8, loc="upper center", ncol=3)
        plt.tight_layout(rect=[0, 0, 1, 0.90])

        output_filename = filename + ".png"
        plt.savefig(output_filename, dpi=300)
        print(f"Plot successfully saved to {output_filename}")

    else:
        print("\nNo valid data was captured to generate a plot or JSON file.")


if __name__ == "__main__":
    run_dramhit_experiments()
