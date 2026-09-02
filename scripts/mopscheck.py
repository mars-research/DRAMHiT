#!/usr/bin/env python3
import re
import subprocess
import sys
import time

BIN = "./build/dramhit"
INFILE = "/opt/datasets/ERR4846928.fastq"

COMMON = [
    "--find_queue", "64",
    "--num-threads", "128",
    "--mode", "4",
    "--ht-size", "2147483648",
    "--hw-pref", "0",
    "--in-file", INFILE,
]

# k values: 8, 10, 12, ... 32
K_VALUES = list(range(4, 33, 2))

# Number of times to run each config; best (max) is reported.
RUNS_PER_CONFIG = 2

# Total 1GB hugepages in the pool (at-rest free count). Adjust if your
# pool size differs - check with:
#   cat /sys/kernel/mm/hugepages/hugepages-1048576kB/free_hugepages
HUGEPAGE_EXPECTED_FREE = 128

# Per-hashtable argument templates.

# Dramblast-p
def ht10_args(k):
    return ["--ht-type", "10", "--numa-split", "3", "--nprod", "64",
            "--ncons", "64", "--k", str(k), "--insert-factor", "1"]
            
#Dramblast
def ht3_args(k):
    return ["--batch-len", "16", "--ht-type", "3", "--numa-split", "1",
            "--no-prefetch", "0", "--k", str(k)]

#dramhit-p
def ht1_args(k):
    return ["--ht-type", "1", "--numa-split", "3", "--nprod", "64",
            "--ncons", "64", "--k", str(k), "--insert-factor", "3"]

#dramhit
def ht8_args(k):
    return ["--batch-len", "16", "--ht-type", "8", "--numa-split", "1",
            "--no-prefetch", "0", "--k", str(k)]
# Build the run list: for each k, do ht10 then ht3
RUNS = []
for k in K_VALUES:
    RUNS.append((f"dramhit-p k={k}", ht1_args(k)))
    RUNS.append((f"dramhit k={k}", ht8_args(k)))
    #RUNS.append((f"ht10 k={k}", ht10_args(k)))
    #RUNS.append((f"ht3 k={k}", ht3_args(k)))

MOPS_RE = re.compile(r"set_mops[:\s]+(\d+(?:\.\d+)?)")

def parse_mops(text):
    matches = MOPS_RE.findall(text)
    return matches[-1] if matches else None

def wait_for_hugepages(expected_free, timeout=10):
    """Wait until the 1GB hugepage pool has recovered to expected_free.
    Returns True if recovered within timeout, False otherwise."""
    path = "/sys/kernel/mm/hugepages/hugepages-1048576kB/free_hugepages"
    start = time.time()
    while time.time() - start < timeout:
        try:
            with open(path) as f:
                if int(f.read().strip()) >= expected_free:
                    return True
        except (FileNotFoundError, ValueError):
            # Path may not exist on non-hugepage setups; don't block.
            return True
        time.sleep(0.2)
    return False

def run_once(cmd):
    """Run one invocation, return set_mops as float or None."""
    proc = subprocess.run(cmd, capture_output=True, text=True)
    m = parse_mops(proc.stdout + proc.stderr)
    return float(m) if m else None

def main():
    print(f"{'RUN':<12} {'best_mops':<10} all_runs")
    print(f"{'---':<12} {'---------':<10} --------")
    results = []

    for label, extra in RUNS:
        cmd = [BIN] + COMMON + extra
        vals = []
        for _ in range(RUNS_PER_CONFIG):
            # Wait for the previous run's hugepages to be released
            if not wait_for_hugepages(HUGEPAGE_EXPECTED_FREE):
                print(f"  warning: hugepages didn't fully recover before {label}",
                      file=sys.stderr)
            try:
                v = run_once(cmd)
            except FileNotFoundError:
                print(f"error: binary not found: {BIN}", file=sys.stderr)
                sys.exit(1)
            if v is not None:
                vals.append(v)

        best = max(vals) if vals else None
        results.append((label, best, vals))
        all_str = ", ".join(f"{v:.0f}" for v in vals) if vals else "none"
        best_str = f"{best:.0f}" if best is not None else "NOT_FOUND"
        print(f"{label:<12} {best_str:<10} [{all_str}]")

    # CSV output: best value plus all individual runs for spread/error bars
    with open("set_mops_resultsdramhit.csv", "w") as f:
        f.write("run,best_mops,all_runs\n")
        for label, best, vals in results:
            all_str = ";".join(f"{v:.0f}" for v in vals)
            best_str = f"{best:.0f}" if best is not None else ""
            f.write(f'"{label}",{best_str},"{all_str}"\n')

    print("\nResults written to set_mops_resultsdramhit.csv")

if __name__ == "__main__":
    main()