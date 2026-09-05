#!/usr/bin/env python3
"""cas vs cas23 on the uniform microbenchmark, single and dual socket.

A cross-check for the join numbers in SUMMARY.md: the joins put cas23 ahead
of cas on dual socket, which is the opposite of what ../macro_uniform/
intel.json shows for the same two tables. This runs that same test (mode 11,
UNIFORM, sweeping ht-fill) on both numa configs so the two workloads can be
compared on this machine rather than across machines.

Mirrors ../macro_uniform/collect_data_intel.py: same flags, same fill sweep,
same set_mops/get_mops parsing. ht-type 3 is "dramhit_2025" (cas) and 8 is
"dramhit_2023" (cas23) in that script's naming.

  python3 compare_uniform.py            # both configs -> uniform_cas_vs_cas23.json
"""

import json
import re
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"
RESERVE_HUGEPAGES_SCRIPT = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"

MODE_UNIFORM = 11

HT_TYPES = {"cas": 3, "cas23": 8}

# same as macro_uniform/collect_data_intel.py
one_gb = 1 << 26          # entries, not bytes: 2^26 * 16 B = 1 GB
HT_SIZE = one_gb * 8      # 8 GB table
REPEAT = 100
FILLS = list(range(10, 100, 10))

# numa configs, matching run_join.py
NUMA_CONFIGS = {
    "single": {"numa-split": 4, "num-threads": 64, "nodes": [0]},
    "dual": {"numa-split": 1, "num-threads": 128, "nodes": [0, 1]},
}

# the table is 8 GB of 1 GB pages; interleaved across both nodes in the dual
# config, bound to node 0 in single. Reserve with margin on every node used.
ONE_GB_PAGES_PER_NODE = 12

TWO_MB = 1 << 21


def two_mb_pages_per_node(numa_cfg):
    """ZipfianTest::run() copies each shard's slice of the key set into its own
    hugepage vector via huge_page_allocator, which uses 2 MB pages for anything
    at or under 500 of them. Size for the worst case, the highest fill.
    """
    keys = HT_SIZE * max(FILLS) // 100
    per_thread_bytes = (keys // numa_cfg["num-threads"] + 1) * 8
    pages_per_thread = (per_thread_bytes + TWO_MB - 1) // TWO_MB
    total = pages_per_thread * numa_cfg["num-threads"]
    per_node = -(-total // len(numa_cfg["nodes"]))
    return int(per_node * 1.25) + 64  # margin


def reserve(numa_cfg):
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, "reset"], check=True)
    two_mb = two_mb_pages_per_node(numa_cfg)
    args = [
        f"n{n}_{ONE_GB_PAGES_PER_NODE}gb_{two_mb * 2}mb" for n in numa_cfg["nodes"]
    ]
    print(f"[*] Reserving hugepages: {' '.join(args)}")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, *args], check=True)


def run_one(ht_type, numa_cfg, fill):
    cmd = [
        DRAMHIT_EXEC,
        "--find_queue", "64",
        "--ht-type", str(ht_type),
        "--num-threads", str(numa_cfg["num-threads"]),
        "--numa-split", str(numa_cfg["numa-split"]),
        "--no-prefetch", "0",
        "--insert-factor", str(REPEAT),
        "--read-factor", str(REPEAT),
        "--mode", str(MODE_UNIFORM),
        "--ht-size", str(HT_SIZE),
        "--ht-fill", str(fill),
        "--hw-pref", "0",
        "--batch-len", "16",
        "--skew", "0.01",
        "--seed", "1775762440565610239",
    ]
    proc = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    sets = re.findall(r"set_mops\s*:\s*([\d.]+)", proc.stdout)
    gets = re.findall(r"get_mops\s*:\s*([\d.]+)", proc.stdout)
    if not sets or not gets:
        print(proc.stdout[-2000:])
        raise SystemExit(f"[!] could not parse mops for ht-type {ht_type} fill {fill}")
    return float(sets[-1]), float(gets[-1])


def main():
    results = {}

    for config_name, numa_cfg in NUMA_CONFIGS.items():
        reserve(numa_cfg)
        # both tables are measured with the hardware prefetcher off, as in
        # macro_uniform's dramhit_2025 / dramhit_2023 runs
        subprocess.run([PREFETCH_SCRIPT, "off"], check=True)

        for ht_name, ht_type in HT_TYPES.items():
            key = f"{config_name}_{ht_name}"
            results[key] = []
            print(f"=== {key} ===")
            for fill in FILLS:
                set_mops, get_mops = run_one(ht_type, numa_cfg, fill)
                results[key].append(
                    {"fill": fill, "htsize": HT_SIZE,
                     "set_mops": set_mops, "get_mops": get_mops}
                )
                print(f"  fill {fill:>2}: set {set_mops:>7.0f}  get {get_mops:>7.0f}")

    out = SCRIPT_DIR / "uniform_cas_vs_cas23.json"
    with open(out, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\n[*] Data saved to {out}")

    for config_name in NUMA_CONFIGS:
        cas = results[f"{config_name}_cas"]
        cas23 = results[f"{config_name}_cas23"]
        wins = sum(1 for a, b in zip(cas, cas23) if a["get_mops"] > b["get_mops"])
        print(f"[*] {config_name}: cas get_mops beats cas23 at {wins}/{len(cas)} fills")


if __name__ == "__main__":
    main()
