#!/usr/bin/env python3
"""Run the k-mer counting sweep (k = 8..32) and write one log per run.

This script does not parse, aggregate, or plot anything -- it runs dramhit and
keeps the output. Every log opens with the exact command that produced it, and
every command is also appended to logs/commands.log, so any number in a log can
be traced back to the invocation that made it.

Only the three things that actually change between experiments are flags; the
rest is pinned below.

Usage:
  ./collect_data.py --ht-type 3                        # global CAS table
  ./collect_data.py --ht-type 3 --ht-size 4294967296   # bigger table
  ./collect_data.py --ht-type 3 --dry-run              # print, run nothing
"""

import argparse
import shlex
import subprocess
import sys
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent

# --- pinned for every run ---------------------------------------------------
BIN = "/opt/DRAMHiT/build/dramhit"
IN_FILE = "/opt/datasets/ERR4846928.fastq"
MODE = 4        # FASTQ_WITH_INSERT, see include/types.hpp
FIND_QUEUE = 64
NUM_THREADS = 64
K_MIN, K_MAX = 8, 32

DEFAULT_HT_SIZE = 2147483648

# ht-types that take the producer/consumer path (Application.cpp:961): they are
# driven by --nprod/--ncons, and --numa-split is a queue policy (1-4) for them
# rather than a thread policy.
PROD_CONS_HT_TYPES = {1, 12}

LOG_DIR = HERE / "logs"
COMMANDS_LOG = LOG_DIR / "commands.log"


def build_cmd(k, args):
    argv = [
        BIN,
        "--mode", str(MODE),
        "--k", str(k),
        "--in-file", IN_FILE,
        "--ht-type", str(args.ht_type),
        "--ht-size", str(args.ht_size),
        "--numa-split", str(args.numa_split),
        "--find_queue", str(FIND_QUEUE),
    ]
    if args.ht_type in PROD_CONS_HT_TYPES:
        half = NUM_THREADS // 2
        argv += ["--nprod", str(half), "--ncons", str(half)]
    else:
        argv += ["--num-threads", str(NUM_THREADS)]
    # 0 means "no override" for both masks, so only pass them when set.
    if args.np_mem_node_msk:
        argv += ["--np_mem_node_msk", str(args.np_mem_node_msk)]
    if args.np_cpu_node_msk:
        argv += ["--np_cpu_node_msk", str(args.np_cpu_node_msk)]
    return argv


def cmd_str(argv):
    return " ".join(shlex.quote(a) for a in argv)


def main():
    p = argparse.ArgumentParser(
        description="Run the kmer sweep and log it.",
        formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--ht-type", type=int, required=True,
                   help="hashtable type, see ht_type_t in include/types.hpp "
                        "(1 partitioned, 3 casht++, 8 cas2023, 10 dlht, ...)")
    p.add_argument("--ht-size", type=int, default=DEFAULT_HT_SIZE,
                   help=f"slots per table (default: {DEFAULT_HT_SIZE})")
    p.add_argument("--numa-split", type=int, default=1,
                   help="queue policy 1-4 for prod/cons ht-types, otherwise "
                        "thread policy 1-10 (default: 1)")
    p.add_argument("--k", type=int, nargs="+", dest="k_list",
                   help=f"k values to run (default: {K_MIN}..{K_MAX})")
    p.add_argument("--np-mem-node-msk", type=int, default=0,
                   help="bitmask of numa nodes to bind hashtable memory to; "
                        "bit i = node i (e.g. 4 = node 2). 0 = no override")
    p.add_argument("--np-cpu-node-msk", type=int, default=0,
                   help="bitmask of numa nodes allowed to host threads; "
                        "bit i = node i (e.g. 1 = node 0). 0 = no restriction")
    p.add_argument("--dry-run", action="store_true",
                   help="print the commands without running them")
    args = p.parse_args()

    k_values = args.k_list if args.k_list else list(range(K_MIN, K_MAX + 1))

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    failed = []
    for k in k_values:
        argv = build_cmd(k, args)
        line = cmd_str(argv)

        if args.dry_run:
            print(line)
            continue

        log_path = LOG_DIR / (
            f"ht{args.ht_type}_numa{args.numa_split}_k{k}_{stamp}.log")

        # Append first, so the command is on record even if the run hangs and
        # gets killed before it can write its own log.
        with open(COMMANDS_LOG, "a") as f:
            f.write(f"{stamp}\t{log_path.name}\t{line}\n")

        print(f"[k={k}] {line}", flush=True)
        proc = subprocess.run(argv, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True)

        # The exit code alone is not enough: dramhit exits 0 on an unknown
        # --ht-type (Application.cpp:893), so a typo would otherwise look like
        # a clean sweep. A real run always prints set_mops.
        ok = proc.returncode == 0 and "set_mops" in proc.stdout

        with open(log_path, "w") as f:
            f.write(f"# {line}\n")
            f.write(f"# exit: {proc.returncode}\n")
            f.write(proc.stdout)

        if ok:
            status = "ok"
        elif proc.returncode != 0:
            status = f"FAILED (exit {proc.returncode})"
        else:
            status = "FAILED (exit 0 but no set_mops)"
        print(f"[k={k}] {status} -> {log_path.name}", flush=True)
        if not ok:
            failed.append(k)

    if args.dry_run:
        return 0

    print(f"\nlogs in {LOG_DIR}")
    print(f"commands appended to {COMMANDS_LOG}")
    if failed:
        print(f"failed at k = {failed}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
