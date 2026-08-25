import subprocess
import sys

# Update these if your specific CPU model has a different architecture
NUM_MEM_CHANNELS = 8
NUM_UPI_LINKS = 3

def measure_uncore_freq():
    cmd = [
        "perf", "stat", "-a", "--per-socket",
        "-e", "unc_m_clockticks,unc_upi_clockticks",
        "-x", ",",
        "sleep", "1"
    ]

    print("Running 1-second perf measurement...")

    # perf stat writes to stderr by default
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error running perf. Make sure you run with sudo or have sufficient privileges.")
        print(result.stderr)
        sys.exit(1)

    lines = result.stderr.strip().split('\n')

    m_ticks = {}
    upi_ticks = {}
    elapsed_time = 1.0 # fallback in case perf doesn't print it

    for line in lines:
        parts = line.split(',')
        if not parts or len(parts) < 3:
            continue

        # Extract precise wall-clock time from perf's summary
        if "time elapsed" in line:
            try:
                elapsed_time = float(parts[0].strip())
            except ValueError:
                pass
            continue

        socket = parts[0].strip()

        # Format: Socket, CPUs, Count, Unit, EventName
        if "unc_m_clockticks" in line:
            try:
                count = float(parts[2].strip())
                m_ticks[socket] = count
            except ValueError:
                pass # Handles "<not counted>"
        elif "unc_upi_clockticks" in line:
            try:
                count = float(parts[2].strip())
                upi_ticks[socket] = count
            except ValueError:
                pass

    print(f"\nMeasurement Time: {elapsed_time:.4f} seconds")
    print("-" * 55)

    # Sort to ensure S0 prints before S1
    for socket in sorted(set(list(m_ticks.keys()) + list(upi_ticks.keys()))):
        print(f"Socket: {socket}")

        if socket in m_ticks:
            total_m = m_ticks[socket]
            per_channel = total_m / NUM_MEM_CHANNELS
            m_freq_ghz = (per_channel / elapsed_time) / 1_000_000_000
            print(f"  Memory Controller Freq : {m_freq_ghz:.3f} GHz")

        if socket in upi_ticks:
            total_upi = upi_ticks[socket]
            per_link = total_upi / NUM_UPI_LINKS
            upi_freq_ghz = (per_link / elapsed_time) / 1_000_000_000
            print(f"  UPI Link Freq          : {upi_freq_ghz:.3f} GHz")

    print("-" * 55)

if __name__ == "__main__":
    measure_uncore_freq()
