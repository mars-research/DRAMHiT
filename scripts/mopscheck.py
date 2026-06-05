#!/usr/bin/env python3
import re
import subprocess
import sys

BIN = "./build/dramhit"
INFILE = "/opt/datasets/ERR4846928.fastq"

COMMON = [
    "--find_queue", "64",
    "--num-threads", "64",
    "--mode", "4",
    "--ht-size", "2147483648",
    "--hw-pref", "0",
    "--in-file", INFILE,
]

# (label, extra args)
RUNS = [
    ("ht10 k=8",  ["--ht-type", "10", "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "8",  "--insert-factor", "1"]),
    ("ht1  k=8",  ["--ht-type", "1",  "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "8",  "--insert-factor", "1"]),
    ("ht3  k=8",  ["--batch-len", "16", "--ht-type", "3", "--numa-split", "1", "--no-prefetch", "0", "--k", "8"]),
    ("ht10 k=16", ["--ht-type", "10", "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "16", "--insert-factor", "1"]),
    ("ht1  k=16", ["--ht-type", "1",  "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "16", "--insert-factor", "1"]),
    ("ht3  k=16", ["--batch-len", "16", "--ht-type", "3", "--numa-split", "1", "--no-prefetch", "0", "--k", "16"]),
    ("ht10 k=31", ["--ht-type", "10", "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "31", "--insert-factor", "1"]),
    ("ht1  k=31", ["--ht-type", "1",  "--numa-split", "3", "--nprod", "32", "--ncons", "32", "--k", "31", "--insert-factor", "1"]),
    ("ht3  k=31", ["--batch-len", "16", "--ht-type", "3", "--numa-split", "1", "--no-prefetch", "0", "--k", "31"]),
]

MOPS_RE = re.compile(r"set_mops[:\s]+(\d+(?:\.\d+)?)")


def parse_mops(text):
    matches = MOPS_RE.findall(text)
    return matches[-1] if matches else None


def main():
    print(f"{'RUN':<12} set_mops")
    print(f"{'---':<12} --------")
    results = []
    for label, extra in RUNS:
        cmd = [BIN] + COMMON + extra
        try:
            proc = subprocess.run(cmd, capture_output=True, text=True)
            output = proc.stdout + proc.stderr
            mops = parse_mops(output)
        except FileNotFoundError:
            print(f"error: binary not found: {BIN}", file=sys.stderr)
            sys.exit(1)
        results.append((label, mops))
        print(f"{label:<12} {mops if mops is not None else 'NOT_FOUND'}")

    # Optional: CSV output to file
    with open("set_mops_results.csv", "w") as f:
        f.write("run,set_mops\n")
        for label, mops in results:
            f.write(f'"{label}",{mops if mops is not None else ""}\n')


if __name__ == "__main__":
    main()