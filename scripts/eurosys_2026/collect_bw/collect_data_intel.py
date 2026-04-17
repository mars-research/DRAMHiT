import re
import statistics
import subprocess
import sys


def main():
    # The command to run
    command = [
        "perf",
        "stat",
        "-e",
        "imc/cas_count_read/,imc/cas_count_write/",
        "-I",
        "1000",
        "-a",
        "--",
        "/opt/DRAMHiT/build/dramhit",
        "--ht-type",
        "3",  # 3 for dramblast, 8 for dramhit
        "--hw-pref",
        "0",
        "--ht-fill",
        "70",
        "--find_queue",
        "64",
        "--num-threads",
        "128",
        "--numa-split",
        "1",
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

    # Regex to capture the bandwidth number and the specific event type
    # Matches strings like:
    #      44.054565880         263,788.37 MiB  imc/cas_count_read/
    #      44.054565880          28,301.89 MiB  imc/cas_count_write/
    bw_pattern = re.compile(
        r"([0-9.,]+)\s+(?:MiB\s+|MB\s+|MB/s\s+)?(imc/cas_count_read/|imc/cas_count_write/)"
    )

    # State flags
    in_insert_phase = False
    in_find_phase = False

    # Data collection
    insert_reads = []
    insert_writes = []
    find_reads = []
    find_writes = []

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
            # Print the live output to the console so you can see it running
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
                # Group 1 is the value, Group 2 is the event name
                val_str = match.group(1).replace(",", "")
                raw_val = float(val_str)
                event_name = match.group(2)

                # Auto-detect if perf is outputting MiB or raw CAS counts
                if "MiB" in line or "MB" in line:
                    bw_gb = raw_val / 1024.0
                else:
                    # Raw CAS events represent 64-byte chunks. Convert to GB/s.
                    bw_gb = (raw_val * 64) / (1024.0**3)

                # Route the value to the correct list
                if in_insert_phase:
                    if "read" in event_name:
                        insert_reads.append(bw_gb)
                    elif "write" in event_name:
                        insert_writes.append(bw_gb)

                elif in_find_phase:
                    if "read" in event_name:
                        find_reads.append(bw_gb)
                    elif "write" in event_name:
                        find_writes.append(bw_gb)

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
    print("\n" + "=" * 50)
    print(" BANDWIDTH SUMMARY (GB/s)")
    print("=" * 50)

    def print_stats(phase_name, reads, writes):
        if not reads and not writes:
            print(
                f"{phase_name.upper()}: No bandwidth data captured during this phase.\n"
            )
            return

        # Calculate averages safely
        avg_read = statistics.mean(reads) if reads else 0.0
        avg_write = statistics.mean(writes) if writes else 0.0
        avg_total = avg_read + avg_write

        # Calculate Max Total cleanly by pairing up read/write samples from the same tick interval
        if len(reads) == len(writes) and len(reads) > 0:
            max_total = max(r + w for r, w in zip(reads, writes))
        else:
            # Fallback approximation if parsing missed a sample
            max_total = (max(reads) if reads else 0.0) + (
                max(writes) if writes else 0.0
            )

        print(f"--- {phase_name.upper()} PHASE ---")
        print(f"  Samples Collected: Read({len(reads)}), Write({len(writes)})")
        print(f"  Average Read:  {avg_read:8.2f} GB/s")
        print(f"  Average Write: {avg_write:8.2f} GB/s")
        print(f"  Average TOTAL: {avg_total:8.2f} GB/s")
        print(f"  Max TOTAL:     {max_total:8.2f} GB/s\n")

    print_stats("Insert", insert_reads, insert_writes)
    print_stats("Find", find_reads, find_writes)


if __name__ == "__main__":
    main()
