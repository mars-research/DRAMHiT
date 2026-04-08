import re
import statistics
import subprocess
import sys


def main():
    # The command to run
    command = [
        "perf",
        "stat",
        "-a",
        "-M",
        "umc_mem_bandwidth",
        "-I",
        "1000",
        "--",
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
        "100",
        "--mode",
        "11",
        "--batch-len",
        "16",
        "--skew",
        "0.01",
        "--seed",
        "1774551337382868027",
        "--ht-size",
        "536870912",
    ]

    # Regex to capture the bandwidth number
    # Matches strings like: # 357864.7 MB/s  umc_mem_bandwidth
    bw_pattern = re.compile(r"#\s+([0-9.]+)\s+MB/s\s+umc_mem_bandwidth")

    # State flags
    in_insert_phase = False
    in_find_phase = False

    # Data collection
    insert_bws = []
    find_bws = []

    print("Running command and parsing output...\n")

    try:
        # Start the process, combining stderr into stdout for chronological parsing
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,  # Line-buffered
        )

        for line in process.stdout:
            # Optional: Print the live output to the console so you can see it running
            print(line, end="")

            # Update state based on log markers
            if "zipfian test insert start" in line:
                in_insert_phase = True
            elif "zipfian test insert end" in line:
                in_insert_phase = False
            elif "zipfian test find start" in line:
                in_find_phase = True
            elif "zipfian test find end" in line:
                in_find_phase = False

            # Check if the line contains our target bandwidth metric
            match = bw_pattern.search(line)
            if match:
                # Extract the number and convert MB/s to GB/s
                # Note: Dividing by 1024 for GiB/s. Use 1000 if you prefer strictly decimal GB/s.
                bw_mb = float(match.group(1))
                bw_gb = bw_mb / 1024.0

                if in_insert_phase:
                    insert_bws.append(bw_gb)
                if in_find_phase:
                    find_bws.append(bw_gb)

        process.wait()

    except FileNotFoundError:
        print(
            "Error: 'perf' command not found. Make sure you are running this on a Linux machine with linux-tools installed."
        )
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nProcess interrupted by user.")
        process.kill()

    # --- Print the Summary ---
    print("\n" + "=" * 40)
    print(" BANDWIDTH SUMMARY (GB/s)")
    print("=" * 40)

    def print_stats(phase_name, data):
        if not data:
            print(
                f"{phase_name.upper()}: No bandwidth data captured during this phase."
            )
            return

        avg_bw = statistics.mean(data)
        max_bw = max(data)

        print(f"--- {phase_name.upper()} PHASE ---")
        print(f"  Samples collected: {len(data)}")
        print(f"  Average Bandwidth: {avg_bw:.2f} GB/s")
        print(f"  Max Bandwidth:     {max_bw:.2f} GB/s\n")

    print_stats("Insert", insert_bws)
    print_stats("Find", find_bws)


if __name__ == "__main__":
    main()
