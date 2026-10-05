#!/usr/bin/env python3
"""Cap the core clock of socket 0 (node 0's cpus) through cpufreq, and always put it back.

    from cpufreq_cap import capped, set_cap
    with capped(2200):
        ...                        # run something

    python3 cpufreq_cap.py show | restore

The machine is pinned at min = max = 2.7 GHz by scripts/constant_freq.sh. Lowering both to
the same value pins the clock there (intel_pstate, HWP). Order matters: cpufreq rejects a max
below the current min, so lowering writes min first and raising writes max first. Only node
0's cpus are touched; socket 1 is left alone. Lowering a clock can only reduce power.
"""
import contextlib
import subprocess
import sys
from pathlib import Path

STOCK_KHZ = 2700000


def node0_cpus():
    text = Path("/sys/devices/system/node/node0/cpulist").read_text().strip()
    cpus = []
    for part in text.split(","):
        a, _, b = part.partition("-")
        cpus += list(range(int(a), int(b or a) + 1))
    return cpus


def _write(files_value):
    # one sudo shell for all files: [(path, value), ...]
    script = "; ".join(f"echo {v} > {p}" for p, v in files_value)
    subprocess.run(["sudo", "sh", "-c", script], check=True)


def current():
    c = node0_cpus()[0]
    base = f"/sys/devices/system/cpu/cpu{c}/cpufreq"
    return int(Path(f"{base}/scaling_min_freq").read_text()), int(Path(f"{base}/scaling_max_freq").read_text())


def set_cap(mhz):
    khz = int(mhz * 1000)
    cur_min, cur_max = current()
    cpus = node0_cpus()
    paths = lambda name: [f"/sys/devices/system/cpu/cpu{c}/cpufreq/{name}" for c in cpus]
    if khz < cur_min:                      # lowering: min first
        _write([(p, khz) for p in paths("scaling_min_freq")])
        _write([(p, khz) for p in paths("scaling_max_freq")])
    else:                                  # raising (or equal): max first
        _write([(p, khz) for p in paths("scaling_max_freq")])
        _write([(p, khz) for p in paths("scaling_min_freq")])
    mn, mx = current()
    if mn != khz or mx != khz:
        raise SystemExit(f"cap not applied: min {mn} max {mx}, wanted {khz}")


@contextlib.contextmanager
def capped(mhz):
    try:
        set_cap(mhz)
        yield
    finally:
        set_cap(STOCK_KHZ / 1000)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "show"
    if cmd == "restore":
        set_cap(STOCK_KHZ / 1000)
    print("node 0 cpufreq min/max (kHz):", current())
