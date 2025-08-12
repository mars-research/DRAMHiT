#!/usr/bin/env python3
import subprocess
import re
import csv
import matplotlib.pyplot as plt

# Command template
base_cmd = [
    "sudo", "/opt/DRAMHiT/build/dramhit",
    "--find_queue", "64",
    "--ht-fill", "70",
    "--ht-type", "3",
    "--insert-factor", "1",
    "--read-factor", None,  # Placeholder
    "--num-threads", "128",
    "--numa-split", "1",
    "--no-prefetch", "0",
    "--mode", "11",
    "--ht-size", "536870912",
    "--skew", "0.01",
    "--hw-pref", "0",
    "--batch-len", "16"
]

# Regex patterns
mc_pattern = re.compile(
    r"MC SOCKET (\d) Read\s+([0-9.]+)GB/s Write\s+([0-9.]+)GB/s"
)
cycles_pattern = re.compile(
    r"get_cycles\s*:\s*([0-9]+)"
)

# CSV file name
csv_filename = "dramhit_results.csv"

# Data storage for plotting
read_factors = []
mc0_read = []
mc0_write = []
mc1_read = []
mc1_write = []
get_cycles_list = []

# Open CSV for writing
with open(csv_filename, mode="w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    # Header
    writer.writerow([
        "read_factor",
        "mc0_read_GBps", "mc0_write_GBps",
        "mc1_read_GBps", "mc1_write_GBps",
        "get_cycles"
    ])

    for read_factor in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]:
        print(f"\n=== Running with read_factor={read_factor} ===")
        cmd = base_cmd.copy()
        cmd[cmd.index("--read-factor") + 1] = str(read_factor)

        try:
            result = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                check=True
            )
            output = result.stdout

            # Parse MC socket data
            mc_data = mc_pattern.findall(output)
            # Parse get_cycles
            cycles_match = cycles_pattern.search(output)

            if mc_data and cycles_match:
                mc0 = mc_data[0]
                mc1 = mc_data[1]
                get_cycles = int(cycles_match.group(1))

                # Save to lists for plotting
                read_factors.append(read_factor)
                mc0_read.append(float(mc0[1]))
                mc0_write.append(float(mc0[2]))
                mc1_read.append(float(mc1[1]))
                mc1_write.append(float(mc1[2]))
                get_cycles_list.append(get_cycles)

                # Print to console
                print(f"read_factor {read_factor}: "
                      f"{mc0[1]},{mc0[2]}, {mc1[1]},{mc1[2]}, {get_cycles}")

                # Write to CSV
                writer.writerow([
                    read_factor,
                    mc0[1], mc0[2],
                    mc1[1], mc1[2],
                    get_cycles
                ])
            else:
                print(f"Could not parse output for read_factor={read_factor}")

        except subprocess.CalledProcessError as e:
            print(f"Command failed for read_factor={read_factor}")
            print(e.stdout)

print(f"\nResults saved to {csv_filename}")

# === Plot results ===
plt.figure(figsize=(10, 6))
plt.plot(read_factors, mc0_read, 'o-', label="MC0 Read (GB/s)")
plt.plot(read_factors, mc0_write, 'o-', label="MC0 Write (GB/s)")
plt.plot(read_factors, mc1_read, 'o-', label="MC1 Read (GB/s)")
plt.plot(read_factors, mc1_write, 'o-', label="MC1 Write (GB/s)")
plt.xlabel("Read Factor")
plt.ylabel("Bandwidth (GB/s)")
plt.xscale("log", base=2)  # power of 2 scaling
plt.title("DRAMHiT Bandwidth vs Read Factor")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("dramhit_bandwidth.png")
print("Saved plot to dramhit_bandwidth.png")

# Plot get_cycles separately
plt.figure(figsize=(10, 6))
plt.plot(read_factors, get_cycles_list, 'o-', color="purple", label="get_cycles")
plt.xlabel("Read Factor")
plt.ylabel("get_cycles")
plt.xscale("log", base=2)
plt.title("DRAMHiT get_cycles vs Read Factor")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("dramhit_get_cycles.png")
print("Saved plot to dramhit_get_cycles.png")

