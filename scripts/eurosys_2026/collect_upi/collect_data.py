import json
import os
import re
import subprocess
import sys

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def main():
    # Configuration
    max_threads = 64
    INTERVAL_MS = 10  # perf stat interval in milliseconds

    mode = "remote"
    numa = 7
    json_filename = "bandwidth_results_upi.json"
    plot_filename = "bandwidth_plot_upi.png"

    # Check if an argument is passed and if it is "local"
    if len(sys.argv) > 1 and sys.argv[1] == "local":
        mode = "local"
        numa = 1

        # Split the filename and extension, then append "_local"
        json_base, json_ext = os.path.splitext(json_filename)
        json_filename = f"{json_base}_local{json_ext}"

        plot_base, plot_ext = os.path.splitext(plot_filename)
        plot_filename = f"{plot_base}_local{plot_ext}"

    else:
        # Fallback for anything else (remote)
        mode = "remote"
        numa = 7

        # Split the filename and extension, then append "_remote"
        json_base, json_ext = os.path.splitext(json_filename)
        json_filename = f"{json_base}_remote{json_ext}"

        plot_base, plot_ext = os.path.splitext(plot_filename)
        plot_filename = f"{plot_base}_remote{plot_ext}"

    interval_sec = INTERVAL_MS / 1000.0

    # Regex to extract the bandwidth value from DRAMHiT
    bw_pattern = re.compile(r"bandwidth:\s*([0-9.]+)\s*GB/s")

    results = []

    print(f"Interval set to {INTERVAL_MS}ms. Taking the MAX sample for UPI bandwidth.")

    for threads in range(2, max_threads + 1, 2):
        # We wrap the target command inside perf stat.
        # Removed the "-x," flag to use standard whitespace-separated output.
        cmd = [
            "perf",
            "stat",
            "-I",
            str(INTERVAL_MS),
            "-a",
            "-e",
            "unc_upi_txl_flits.all_data",
            "-e",
            "unc_upi_txl_flits.non_data",
            "-e",
            "unc_upi_clockticks",
            "--",
            "/opt/DRAMHiT/build/dramhit",
            "--ht-size",
            "16777216",
            "--sequential",
            "0",
            "--mode",
            "15",
            "--numa-split",
            str(numa),
            "--num-threads",
            str(threads),
        ]

        try:
            # Popen with STDOUT to merge stdout/stderr, reading line by line asynchronously
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            app_bandwidth = 0.0
            interval_data = {}
            capture_perf = False

            # Read the process output stream in real-time
            for line in iter(process.stdout.readline, ""):
                # print(line, end="")  # Echo output so you can see progress

                # Check for our start and end markers to toggle collection
                if "Bandwidth test start" in line:
                    capture_perf = True
                    interval_data.clear()  # Reset data for a clean test window
                    continue
                elif "Bandwidth test end" in line:
                    capture_perf = False
                    continue

                match = bw_pattern.search(line)
                if match:
                    app_bandwidth = float(match.group(1))

                # ONLY execute parse logic if we are actively in the test window
                if capture_perf:
                    # Split by whitespace instead of commas
                    parts = line.split()
                    if len(parts) >= 3:
                        try:
                            ts = float(parts[0])

                            # Remove the comma thousands separator (e.g., "21,519" -> "21519")
                            val_str = parts[1].replace(",", "")

                            # Event name is usually the 3rd column
                            event = parts[2]

                            # Skip lines that don't contain numeric counter data
                            if not val_str.isdigit():
                                continue

                            val = int(val_str)

                            # Accumulate data per timestamp
                            if ts not in interval_data:
                                interval_data[ts] = {"tx_d": 0, "tx_nd": 0}

                            if "unc_upi_txl_flits.all_data" in event:
                                interval_data[ts]["tx_d"] = val
                            elif "unc_upi_txl_flits.non_data" in event:
                                interval_data[ts]["tx_nd"] = val
                            elif "unc_upi_clockticks" in event:
                                interval_data[ts]["clockticks"] = val

                        except ValueError:
                            # Ignore lines that fail to parse (like standard text output)
                            pass

            process.wait()

            if process.returncode != 0:
                print(
                    f"Threads: {threads:2} | Command failed with exit code {process.returncode}"
                )
                continue

            max_upi_tx_gbps = 0.0
            max_upi_rx_gbps = 0.0

            # Calculate GB/s for EACH captured interval and find the max
            # clockticks are aggregated over 6 links and 2.5ghz
            for ts, data in interval_data.items():
                current_tx_gbps = (data["tx_d"] * 100) / (
                    data["clockticks"]
                )  # packet size 64/9 according to doc
                current_rx_gbps = (data["tx_nd"] * 110) / (
                    data["clockticks"]
                )  # (gb * 8 /(1<<30)) / (tick / (6*2.5*10^9))

                if current_tx_gbps > max_upi_tx_gbps:
                    max_upi_tx_gbps = current_tx_gbps
                if current_rx_gbps > max_upi_rx_gbps:
                    max_upi_rx_gbps = current_rx_gbps

            results.append(
                {
                    "threads": threads,
                    "app_bandwidth_GBps": app_bandwidth,
                    "upi_tx_data_GBps": max_upi_tx_gbps,
                    "upi_tx_nondata_GBps": max_upi_rx_gbps,
                }
            )

            print(
                f"-> App BW: {app_bandwidth} GB/s | Max UPI TX data: {max_upi_tx_gbps:.3f} GB/s | Max UPI TX non_data: {max_upi_rx_gbps:.3f} GB/s"
            )
            print(
                f"-> Checked {len(interval_data)} valid interval(s) to find the maximum.\n"
            )

        except FileNotFoundError:
            print(
                "Error: Ensure 'perf' is installed and DRAMHiT exists at the specified path."
            )
            return

    # 1. Output JSON data format
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"Data successfully saved to {json_filename}")

    # 2. Plot the data using seaborn and save as PNG
    if results:
        df = pd.DataFrame(results)

        # Melt DataFrame to stack our three metrics into a single column for easy plotting
        df_melted = df.melt(
            id_vars=["threads"],
            value_vars=[
                "app_bandwidth_GBps",
                "upi_tx_data_GBps",
                "upi_tx_nondata_GBps",
            ],
            var_name="Metric",
            value_name="Bandwidth (GB/s)",
        )

        # Configure seaborn style
        sns.set_theme(style="whitegrid")
        plt.figure(figsize=(10, 6))

        # Create the multiline plot
        ax = sns.lineplot(
            data=df_melted, x="threads", y="Bandwidth (GB/s)", hue="Metric", marker="o"
        )

        # Set titles and labels
        ax.set_title("Application & Max UPI Bandwidth vs. Threads", fontsize=14, pad=15)
        ax.set_xlabel("Number of Threads", fontsize=12)
        ax.set_ylabel("Bandwidth (GB/s)", fontsize=12)

        # Rename legend labels for cleanliness
        new_labels = ["Application BW", "Max UPI TX Data BW", "Max UPI TX NData BW"]
        for t, l in zip(ax.legend_.texts, new_labels):
            t.set_text(l)

        plt.xlim(1, max_threads)
        plt.savefig(plot_filename, dpi=300, bbox_inches="tight")
        plt.close()
        print(f"Plot successfully saved to {plot_filename}")
    else:
        print("No valid data collected to plot.")


if __name__ == "__main__":
    main()
