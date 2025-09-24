#!/usr/bin/env python3
"""
mlc_run_and_parse_simple.py

Run MLC workloads in order, parse NUMA matrices, and write local/remote values to a text file.
"""

import subprocess
import argparse
import re
import shlex
import statistics
from collections import OrderedDict

MLC = "mlc"  # default mlc path

float_re = re.compile(r"[-+]?\d*\.\d+|\d+")

def parse_numa_matrix(text):
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        if "Numa node" in ln:
            if i + 1 < len(lines):
                header_line = lines[i + 1].strip()
                header_nodes = re.findall(r"\d+", header_line)
                if header_nodes:
                    matrix = []
                    j = i + 2
                    while j < len(lines):
                        row = lines[j].strip()
                        if not row:
                            break
                        tokens = float_re.findall(row)
                        if len(tokens) >= 2:
                            vals = [float(x) for x in tokens[1:]]
                            matrix.append(vals)
                            j += 1
                            continue
                        else:
                            break
                    ncol = len(header_nodes)
                    if matrix and all(len(r) == ncol for r in matrix):
                        return matrix
    return None

def local_remote_from_matrix(mat):
    if not mat:
        return None, None
    n = len(mat)
    diag = []
    off = []
    for i in range(n):
        for j in range(n):
            v = mat[i][j]
            if i == j:
                diag.append(v)
            else:
                off.append(v)
    avg_local = statistics.mean(diag) if diag else None
    avg_remote = statistics.mean(off) if off else None
    return avg_local, avg_remote

def run_command(cmd_list, use_sudo=False, timeout=300):
    cmd = (["sudo"] + cmd_list) if use_sudo else cmd_list
    try:
        completed = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout,
            check=False,
        )
        out = completed.stdout.decode(errors="replace")
        err = completed.stderr.decode(errors="replace")
        return completed.returncode, out + "\n" + err
    except Exception as e:
        return 1, str(e)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mlc", default=MLC, help="path to mlc")
    parser.add_argument("--out", default="mlc_local_remote.txt", help="output text filename")
    parser.add_argument("--timeout", type=int, default=300, help="timeout seconds per command")
    args = parser.parse_args()

    mlc_bin = args.mlc

    # Workload commands in order
    cmds = OrderedDict([
        ("Random Read Latency", {"cmd": [mlc_bin, "--latency_matrix", "-X", "-x1"], "use_sudo": False}),
        ("Random Read Bandwidth", {"cmd": [mlc_bin, "--bandwidth_matrix"], "use_sudo": False}),
        ("Random RW(1:1) Bandwidth", {"cmd": [mlc_bin, "--bandwidth_matrix", "-W5"], "use_sudo": False}),
        ("Sequential Read Latency", {"cmd": [mlc_bin, "--latency_matrix", "-X", "-x1"], "use_sudo": True}),
        ("Sequential Read Bandwidth", {"cmd": [mlc_bin, "--bandwidth_matrix"], "use_sudo": True}),
        ("Sequential RW(1:1) Bandwidth", {"cmd": [mlc_bin, "--bandwidth_matrix", "-W5"], "use_sudo": True}),
    ])

    with open(args.out, "w") as f:
        for label, info in cmds.items():
            cmdstr = " ".join(shlex.quote(x) for x in info["cmd"])
            f.write(f"=== {label} ===\n")
            f.write(f"Command: {cmdstr}\n")
            print(f"Running: {label} -> {cmdstr}")
            rc, out = run_command(info["cmd"], use_sudo=info["use_sudo"], timeout=args.timeout)
            mat = parse_numa_matrix(out)
            local, remote = local_remote_from_matrix(mat)
            f.write(f"Local: {local}\nRemote: {remote}\n\n")

    print(f"Local/Remote results written to {args.out}")

if __name__ == "__main__":
    main()
