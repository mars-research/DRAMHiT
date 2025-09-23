#!/usr/bin/env python3
"""
mlc_run_and_parse.py

Run MLC workloads, parse NUMA matrices, compute average local/remote latency and bandwidth,
and generate two LaTeX tables:
  - Bandwidth (all workloads)
  - Latency (only Random Read and Sequential Read)
"""

import subprocess
import argparse
import re
import shlex
import statistics
import sys
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
                        return matrix, [int(x) for x in header_nodes]
    return None, None

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
        return completed.returncode, out, err
    except FileNotFoundError:
        return 127, "", f"executable not found: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return 124, "", "timeout"
    except Exception as e:
        return 1, "", str(e)

def detect_bandwidth_unit(text):
    txt = text.lower()
    if "mb/s" in txt or "mbps" in txt or "mb/sec" in txt:
        return "MB"
    if "gb/s" in txt or "gbps" in txt or "gb/sec" in txt:
        return "GB"
    return None

def scale_matrix(mat, factor):
    return [[v / factor for v in row] for row in mat]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mlc", default=MLC, help="path to mlc")
    parser.add_argument("--out", default="mlc_results.tex", help="output LaTeX filename")
    parser.add_argument("--no-run", action="store_true", help="skip running commands")
    parser.add_argument("--timeout", type=int, default=300, help="timeout seconds per command")
    parser.add_argument("--use-1024", action="store_true", help="convert MB->GB using 1024 instead of 1000")
    args = parser.parse_args()

    mlc_bin = args.mlc
    conv_factor = 1024.0 if args.use_1024 else 1000.0

    # Workload definitions
    cmds = OrderedDict([
        ("Random Read", {
            "latency":   {"cmd": [mlc_bin, "--latency_matrix", "-r"], "use_sudo": False},
            "bandwidth": {"cmd": [mlc_bin, "--bandwidth_matrix"], "use_sudo": False},
        }),
        ("Random RW(1:1)", {
            "bandwidth": {"cmd": [mlc_bin, "--bandwidth_matrix", "-W5"], "use_sudo": False},
        }),
        ("Sequential Read", {
            "latency":   {"cmd": [mlc_bin, "--latency_matrix"], "use_sudo": True},
            "bandwidth": {"cmd": [mlc_bin, "--bandwidth_matrix"], "use_sudo": True},
        }),
        ("Sequential RW(1:1)", {
            "bandwidth": {"cmd": [mlc_bin, "--bandwidth_matrix", "-W5"], "use_sudo": True},
        }),
    ])

    results = {}

    for label, subcmds in cmds.items():
        results[label] = {}
        for typ in ("latency", "bandwidth"):
            info = subcmds[typ]
            cmdstr = " ".join(shlex.quote(x) for x in info["cmd"])
            print(f"Running: {label} ({typ}) -> {cmdstr}")
            if args.no_run:
                results[label][typ] = {"local": None, "remote": None}
                continue

            rc, out, err = run_command(info["cmd"], use_sudo=info["use_sudo"], timeout=args.timeout)
            combined = (out or "") + "\n" + (err or "")
            mat, _ = parse_numa_matrix(combined)

            unit = None
            if typ == "bandwidth":
                unit = detect_bandwidth_unit(combined)
                if mat is not None and unit == "MB":
                    mat = scale_matrix(mat, conv_factor)

            if mat:
                local, remote = local_remote_from_matrix(mat)
            else:
                local, remote = None, None

            results[label][typ] = {"local": local, "remote": remote, "unit": unit}

    def fmt(x):
        return f"{x:.1f}" if (x is not None) else "--"

    # -------------------------------
    # Bandwidth table
    # -------------------------------
    bw_labels = [
        "Random Read",
        "Random RW(1:1)",
        "Sequential Read",
        "Sequential RW(1:1)",
    ]

    bw_tex = []
    bw_tex.append(r"\begin{table}[t]")
    bw_tex.append(r"\begin{center}")
    bw_tex.append(r"\caption{Measured bandwidth (Local vs Remote). Bandwidth reported in GB/s.}")
    bw_tex.append(r"\label{table:bandwidth}")
    bw_tex.append(r"\small")
    bw_tex.append(r"\begin{tabular}{| l | c | c |}")
    bw_tex.append(r"\hline")
    bw_tex.append(r"Configuration & Local BW (GB/s) & Remote BW (GB/s) \\")
    bw_tex.append(r"\hline\hline")
    for lbl in bw_labels:
        bw_local = results[lbl]["bandwidth"]["local"]
        bw_remote = results[lbl]["bandwidth"]["remote"]
        bw_tex.append(rf"{lbl} & {fmt(bw_local)} & {fmt(bw_remote)} \\ \hline")
    bw_tex.append(r"\end{tabular}")
    bw_tex.append(r"\end{center}")
    bw_tex.append(r"\end{table}")

    # -------------------------------
    # Latency table
    # -------------------------------
    lat_labels = [
        "Random Read",
        "Sequential Read",
    ]

    lat_tex = []
    lat_tex.append(r"\begin{table}[t]")
    lat_tex.append(r"\begin{center}")
    lat_tex.append(r"\caption{Measured memory access latency (Local vs Remote).}")
    lat_tex.append(r"\label{table:latency}")
    lat_tex.append(r"\small")
    lat_tex.append(r"\begin{tabular}{| l | c | c |}")
    lat_tex.append(r"\hline")
    lat_tex.append(r"Configuration & Local Lat (ns) & Remote Lat (ns) \\")
    lat_tex.append(r"\hline\hline")
    for lbl in lat_labels:
        lat_local = results[lbl]["latency"]["local"]
        lat_remote = results[lbl]["latency"]["remote"]
        lat_tex.append(rf"{lbl} & {fmt(lat_local)} & {fmt(lat_remote)} \\ \hline")
    lat_tex.append(r"\end{tabular}")
    lat_tex.append(r"\end{center}")
    lat_tex.append(r"\end{table}")

    # Write both tables into one file
    tex_content = "% Generated by mlc_run_and_parse.py\n" + "\n".join(bw_tex + [""] + lat_tex)
    with open(args.out, "w") as f:
        f.write(tex_content)
    print(f"\nLaTeX tables written to {args.out}")

if __name__ == "__main__":
    main()
