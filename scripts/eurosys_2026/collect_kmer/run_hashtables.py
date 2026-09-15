#!/usr/bin/env python3
"""Run the same k-mer workload across several hashtable implementations.

The point of this script is that you cannot sweep --ht-type with a fixed
hugepage pool. Each implementation takes a DIFFERENT SHAPE of pool, and a pool
of the wrong shape does not degrade gracefully -- the run aborts minutes in with
"mmap failed" or std::bad_alloc, or refuses to start at all:

  * the partitioned tables (ht-type 1, 12) allocate one private table per
    consumer, each --ht-size/ncons slots. At the usual 2^31 total over 64
    consumers that is 0.5GiB per table, which calloc_ht maps with 2MB pages.
  * the global tables (3, 8, ...) allocate one table of the full --ht-size.
    At 2^31 slots that is 32GiB in a single mapping, which calloc_ht maps with
    1GB pages.

So the same --ht-size needs 16384 x 2MB pages for one and 32 x 1GB pages for the
other, and the two are not interchangeable: 1GB pages cannot back a 2MB request.
The staging arena differs too, because the file is split across --nprod on the
partitioned path and across --num-threads on the global one.

This script therefore re-plans and re-reserves the pool for every ht-type it
runs, by shelling out to plan_hugepages.sh, which derives the numbers from
src/tests/kmer_tests.cpp and src/tests/queue_tests.cpp. The plan for each run is
written into the head of that run's log, so any number in a log can be traced
back to both the command and the pool it ran on.

Usage:
  ./run_hashtables.py                                   # 3, 8, 1, 12 at k=30
  ./run_hashtables.py --ht-types 3 12 --k 10 30
  ./run_hashtables.py --ht-types 1 --repeats 3
  ./run_hashtables.py --dry-run                         # print everything, run nothing
  ./run_hashtables.py --no-reserve                      # trust the current pool
"""

import argparse
import csv
import re
import shlex
import subprocess
import sys
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent
DRAMHIT_ROOT = HERE.parents[2]
PLAN_HUGEPAGES = HERE / "plan_hugepages.sh"

# --- pinned for every run ---------------------------------------------------
MODE = 4                    # FASTQ_WITH_INSERT, include/types.hpp
FIND_QUEUE = 64
BATCH_LEN = 16
DEFAULT_HT_SIZE = 2147483648    # slots, TOTAL on both paths


class HT:
    """One --ht-type: how it is spelled in logs, and which path it takes."""

    def __init__(self, label, partitioned, desc):
        self.label = label
        self.partitioned = partitioned
        self.desc = desc


# ht_type_t in include/types.hpp. The short labels are the ones already used by
# the log files in logs/, so a sweep run today sorts alongside the older ones.
#
# `partitioned` is the only field that changes what this script does, and it is
# not a naming choice: Application.cpp sends exactly ht-type 1 and 12 down
# qt.run_test() (the producer/consumer path in queue_tests.cpp) and everything
# else through spawn_shard_threads() (the global path in kmer_tests.cpp).
HASHTABLES = {
    1:  HT("dramhit-p",   True,  "PARTITIONED_HT -- private table per consumer"),
    3:  HT("dramblast",   False, "CASHTPP -- one shared CAS table"),
    4:  HT("array",       False, "ARRAY_HT"),
    5:  HT("multi",       False, "MULTI_HT"),
    6:  HT("growt",       False, "GROWHT -- needs -DGROWT"),
    7:  HT("clht",        False, "CLHT_HT -- needs -DCLHT"),
    8:  HT("dramhit",     False, "CAS23HTPP -- one shared 2023 CAS table"),
    9:  HT("tbb",         False, "TBB_HT -- needs -DGROWT"),
    10: HT("dlht",        False, "DLHT_HT"),
    11: HT("folklore",    False, "FOLKLORE_HT"),
    12: HT("dramblast-p", True,  "CASSTHTPP -- private single-thread table per consumer"),
}

PARTITIONED = {t for t, ht in HASHTABLES.items() if ht.partitioned}

DEFAULT_HT_TYPES = [3, 8, 1, 12]

# misc_lib.cpp prints these at the end of a successful run.
RE_MOPS = re.compile(r"set_mops\s*:\s*(\d+)")
RE_FILL = re.compile(r"fill\s*:\s*(\d+),\s*capacity\s*:\s*(\d+),\s*fill_factor\s*:\s*([\d.]+)")
# The partitioned path never prints that aggregate: each consumer owns a private
# table and reports its own fill (queue_tests.cpp consumer_thread), so the
# run-wide figure is the sum over consumers against the sum of their capacities.
RE_SHARD_FILL = re.compile(r"ht-fill:\s*(\d+),\s*ht-sz:\s*(\d+)")


# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------

def plan_argv(ht_type, args, extra=()):
    """Arguments for plan_hugepages.sh describing this ht-type's pool.

    --ht-size goes through unchanged: it is the TOTAL on both paths, and
    plan_hugepages.sh applies queue_tests.cpp's /ncons split itself.
    """
    argv = [
        str(PLAN_HUGEPAGES),
        "--ht-type", str(ht_type),
        "--ht-size", str(args.ht_size),
        "--in-file", args.in_file,
        "--batch-len", str(BATCH_LEN),
    ]
    if ht_type in PARTITIONED:
        argv += ["--nprod", str(args.nprod), "--ncons", str(args.ncons)]
    else:
        argv += ["--num-threads", str(args.num_threads)]
    return argv + list(extra)


def numa_split_for(ht_type, args):
    """--numa-split is a different enum on each path.

    Partitioned runs index numa_policy_queues (1-4), which places producers and
    consumers; global runs index numa_policy_threads (1-10). Passing one path's
    value to the other silently picks an unrelated policy.
    """
    return (args.numa_split_partitioned if ht_type in PARTITIONED
            else args.numa_split_global)


def dramhit_argv(ht_type, k, args):
    argv = [args.bin,
            "--mode", str(MODE),
            "--k", str(k),
            "--in-file", args.in_file,
            "--ht-type", str(ht_type),
            "--ht-size", str(args.ht_size),
            "--find_queue", str(FIND_QUEUE),
            "--hw-pref", "1" if args.hw_pref else "0",
            "--numa-split", str(numa_split_for(ht_type, args))]

    if ht_type in PARTITIONED:
        argv += ["--nprod", str(args.nprod),
                 "--ncons", str(args.ncons),
                 "--insert-factor", "1"]
    else:
        argv += ["--num-threads", str(args.num_threads),
                 "--batch-len", str(BATCH_LEN),
                 "--no-prefetch", "0"]

    if args.np_mem_node_msk:
        argv += ["--np_mem_node_msk", str(args.np_mem_node_msk)]
    if args.sudo:
        argv = ["sudo"] + argv
    return argv


def cmd_str(argv):
    return " ".join(shlex.quote(a) for a in argv)


# Every command this script triggers is appended here BEFORE it runs, so a run
# that hangs and gets killed still leaves a record of what was started. Same
# convention as collect_data.py.
COMMANDS_LOG = None


def record(argv, note):
    """Append one triggered command to logs/commands.log.

    A dry run records nothing: the file is a record of what was actually
    started, and a command that was only printed would read the same as one
    that ran for an hour and got killed.
    """
    if COMMANDS_LOG is None:
        return
    with open(COMMANDS_LOG, "a") as f:
        f.write(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\t{note}\t"
                f"{cmd_str(argv)}\n")


def run(argv, dry_run, capture=True):
    """Run a command; return (rc, output). Dry runs report success and no output."""
    if dry_run:
        print(f"    $ {cmd_str(argv)}")
        return 0, ""
    if capture:
        proc = subprocess.run(argv, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True)
        return proc.returncode, proc.stdout
    return subprocess.call(argv), ""


# ---------------------------------------------------------------------------
# the pool
# ---------------------------------------------------------------------------

def pool_shape(ht_type, args):
    """What the pool depends on.

    k is absent on purpose: it changes how many DISTINCT kmers land in the
    table, never how much memory is mapped. So is --numa-split: it moves the
    pages between nodes, and the pool is reserved evenly on every node anyway.
    """
    if ht_type in PARTITIONED:
        return ("partitioned", args.nprod, args.ncons, args.ht_size)
    return ("global", args.num_threads, 1, args.ht_size)


def reserve_pool(ht_type, args):
    """Reset, then reserve the pool this ht-type needs. Returns (ok, plan_text).

    The reset is not optional when the shape changes. Lowering nr_hugepages
    frees the old pages, but they come back fragmented, and the kernel then
    cannot assemble the 1GB pages the next shape wants. reserve_hugepages.sh
    drops caches and compacts on the way in, which only helps from a clean pool.
    """
    print(f"  [pool] planning and reserving for ht-type {ht_type}")
    reset_argv = [str(PLAN_HUGEPAGES), "--reset"]
    record(reset_argv, f"ht{ht_type} pool reset")
    rc, _ = run(reset_argv, args.dry_run)
    if rc != 0:
        return False, f"plan_hugepages.sh --reset exited {rc}"

    argv = plan_argv(ht_type, args)
    record(argv, f"ht{ht_type} pool reserve")
    rc, out = run(argv, args.dry_run)
    if args.dry_run:
        return True, ""
    if rc != 0:
        print(out, file=sys.stderr)
        return False, out
    for line in out.splitlines():
        if ("TOTAL RESERVED" in line or "reserve command" in line
                or line.startswith("     NOTE:")):
            print(f"  [pool]{line.rstrip()}")
    return True, out


# ---------------------------------------------------------------------------
# one run
# ---------------------------------------------------------------------------

def parse_result(text):
    mops = RE_MOPS.search(text)
    out = {"set_mops": int(mops.group(1)) if mops else None,
           "fill": None, "capacity": None, "fill_factor": None}

    agg = RE_FILL.search(text)
    if agg:
        out.update(fill=int(agg.group(1)), capacity=int(agg.group(2)),
                   fill_factor=float(agg.group(3)))
        return out

    shards = RE_SHARD_FILL.findall(text)
    if shards:
        fill = sum(int(f) for f, _ in shards)
        cap = sum(int(c) for _, c in shards)
        out.update(fill=fill, capacity=cap,
                   fill_factor=(fill / cap) if cap else None)
    return out


def do_run(ht_type, k, rep, args, plan_text, stamp, log_dir):
    ht = HASHTABLES[ht_type]
    argv = dramhit_argv(ht_type, k, args)
    line = cmd_str(argv)

    suffix = f"_r{rep}" if args.repeats > 1 else ""
    log_path = log_dir / f"{ht.label}_ht{ht_type}_k{k}{suffix}_{stamp}.log"

    record(argv, f"ht{ht_type} {ht.label} k={k} rep={rep} -> {log_path.name}")
    print(f"  [run ] ht{ht_type} {ht.label} k={k}"
          f"{f' rep {rep}/{args.repeats}' if args.repeats > 1 else ''}")
    if args.dry_run:
        print(f"    $ {line}")
        return {"ht_type": ht_type, "label": ht.label, "k": k, "rep": rep,
                "status": "dry-run", "log": "", "exit": 0,
                "set_mops": None, "fill": None, "capacity": None,
                "fill_factor": None}

    proc = subprocess.run(argv, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True,
                          cwd=str(DRAMHIT_ROOT))
    res = parse_result(proc.stdout)

    with open(log_path, "w") as f:
        f.write(f"# {line}\n")
        f.write(f"# exit: {proc.returncode}\n")
        # The pool is part of the result: the same command on a short pool
        # aborts, so record what was reserved next to what was run.
        for pl in plan_text.splitlines():
            f.write(f"# plan| {pl}\n")
        f.write(proc.stdout)

    # The exit code alone is not enough: Application.cpp exits 0 on an unknown
    # --ht-type, so a type missing from the build would look like a clean run.
    if proc.returncode != 0:
        status = f"FAILED (exit {proc.returncode})"
    elif res["set_mops"] is None:
        status = "FAILED (exit 0, no set_mops -- is this ht-type in the build?)"
    else:
        status = "ok"

    print(f"  [run ] {status}"
          + (f"   set_mops={res['set_mops']}" if res["set_mops"] is not None else "")
          + f"   -> {log_path.name}")

    return {"ht_type": ht_type, "label": ht.label, "k": k, "rep": rep,
            "status": status, "log": log_path.name,
            "exit": proc.returncode, **res}


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Sweep --ht-type, re-reserving the hugepage pool for each.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Usage:", 1)[1])

    p.add_argument("--ht-types", type=int, nargs="+", default=DEFAULT_HT_TYPES,
                   metavar="T",
                   help="ht_type_t values to run (default: %(default)s). "
                        + "; ".join(f"{t}={h.label}" for t, h in sorted(HASHTABLES.items())))
    p.add_argument("--k", type=int, nargs="+", default=[30], dest="k_list",
                   metavar="K", help="k values (default: 30)")
    p.add_argument("--ht-size", type=int, default=DEFAULT_HT_SIZE,
                   help="slots, TOTAL on both paths; the partitioned path "
                        "splits it across ncons (default: %(default)s)")
    p.add_argument("--in-file", default="/opt/datasets/ERR4846928.fastq")
    p.add_argument("--bin", default=str(DRAMHIT_ROOT / "build" / "dramhit"))
    p.add_argument("--repeats", type=int, default=1)

    g = p.add_argument_group("thread layout")
    g.add_argument("--num-threads", type=int, default=64,
                   help="global ht-types (default: %(default)s)")
    g.add_argument("--nprod", type=int, default=64,
                   help="partitioned ht-types (default: %(default)s)")
    g.add_argument("--ncons", type=int, default=64,
                   help="partitioned ht-types (default: %(default)s)")
    g.add_argument("--numa-split-global", type=int, default=1, metavar="P",
                   help="numa_policy_threads 1-10 for the global ht-types "
                        "(default: %(default)s)")
    g.add_argument("--numa-split-partitioned", type=int, default=4, metavar="P",
                   help="numa_policy_queues 1-4 for ht-type 1 and 12 "
                        "(default: %(default)s)")
    g.add_argument("--np-mem-node-msk", type=int, default=0,
                   dest="np_mem_node_msk",
                   help="bitmask of nodes to bind table memory to; 0 = no override")

    g = p.add_argument_group("behaviour")
    g.add_argument("--no-reserve", dest="reserve", action="store_false",
                   help="do not touch the hugepage pool; use what is there")
    g.add_argument("--hw-pref", action="store_true",
                   help="leave hardware prefetchers on (default: off)")
    g.add_argument("--no-sudo", dest="sudo", action="store_false",
                   help="run dramhit without sudo")
    g.add_argument("--log-dir", default=None)
    g.add_argument("--csv", default=None,
                   help="where to write the summary (default: <log-dir>/summary_<stamp>.csv)")
    g.add_argument("--dry-run", action="store_true",
                   help="print every command without running anything")
    p.set_defaults(sudo=True, reserve=True)

    args = p.parse_args(argv)

    unknown = [t for t in args.ht_types if t not in HASHTABLES]
    if unknown:
        p.error(f"unknown ht-type(s) {unknown}; known: {sorted(HASHTABLES)}")
    for t in args.ht_types:
        ns = numa_split_for(t, args)
        if t in PARTITIONED and not 1 <= ns <= 4:
            p.error(f"--numa-split-partitioned must be 1..4 (numa_policy_queues), got {ns}")
        if t not in PARTITIONED and not 1 <= ns <= 10:
            p.error(f"--numa-split-global must be 1..10 (numa_policy_threads), got {ns}")
    for k in args.k_list:
        if not 1 <= k <= 32:
            p.error(f"--k must be 1..32, got {k}")

    args.log_dir = Path(args.log_dir).resolve() if args.log_dir else HERE / "logs"
    return args


def main(argv=None):
    args = parse_args(argv)

    if not args.dry_run:
        if not Path(args.bin).is_file():
            print(f"[FAIL] no dramhit binary at {args.bin}\n"
                  f"       build it: {HERE / 'build_dramhit.sh'}", file=sys.stderr)
            return 2
        if not Path(args.in_file).is_file():
            print(f"[FAIL] no input file at {args.in_file}", file=sys.stderr)
            return 2
    if args.reserve and not PLAN_HUGEPAGES.is_file():
        print(f"[FAIL] {PLAN_HUGEPAGES} is missing", file=sys.stderr)
        return 2

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    args.log_dir.mkdir(parents=True, exist_ok=True)

    global COMMANDS_LOG
    if not args.dry_run:
        COMMANDS_LOG = args.log_dir / "commands.log"
        with open(COMMANDS_LOG, "a") as f:
            f.write(f"\n# ==== sweep {stamp}: ht-types {args.ht_types}, "
                    f"k {args.k_list}, ht-size {args.ht_size} ====\n")

    print("=" * 78)
    print("  k-mer sweep across hashtable implementations")
    print("=" * 78)
    print(f"  input      {args.in_file}")
    print(f"  ht-size    {args.ht_size} slots total")
    print(f"  k          {args.k_list}   repeats {args.repeats}")
    for t in args.ht_types:
        ht = HASHTABLES[t]
        shape = (f"nprod {args.nprod} + ncons {args.ncons}, "
                 f"queue policy {args.numa_split_partitioned}"
                 if ht.partitioned else
                 f"num-threads {args.num_threads}, "
                 f"thread policy {args.numa_split_global}")
        print(f"  ht-type {t:<3}{ht.label:<13}{ht.desc}")
        print(f"              {shape}")

    # The two paths are only comparable if they are given the same cpus; say so
    # rather than letting a thread-count mismatch hide in the defaults.
    part = [t for t in args.ht_types if t in PARTITIONED]
    glob = [t for t in args.ht_types if t not in PARTITIONED]
    if part and glob and args.nprod + args.ncons != args.num_threads:
        print(f"\n  NOTE: partitioned runs use {args.nprod + args.ncons} threads "
              f"({args.nprod} prod + {args.ncons} cons) and global runs use "
              f"{args.num_threads}.\n"
              f"        Pass --num-threads {args.nprod + args.ncons} for a "
              f"thread-matched comparison.")
    print()

    results = []
    last_shape = None
    plan_text = ""

    for ht_type in args.ht_types:
        ht = HASHTABLES[ht_type]
        print("-" * 78)
        print(f"  ht-type {ht_type} ({ht.label})")
        print("-" * 78)

        shape = pool_shape(ht_type, args)
        if not args.reserve:
            print("  [pool] --no-reserve: using whatever is currently reserved")
        elif shape == last_shape:
            # Reset + compact + reserve costs real time, and the pool it would
            # produce is the one already there.
            print(f"  [pool] unchanged from the previous ht-type, keeping it")
        else:
            ok, plan_text = reserve_pool(ht_type, args)
            if not ok:
                print(f"  [pool] FAILED to reserve; skipping ht-type {ht_type}",
                      file=sys.stderr)
                for k in args.k_list:
                    for rep in range(1, args.repeats + 1):
                        results.append({"ht_type": ht_type, "label": ht.label,
                                        "k": k, "rep": rep,
                                        "status": "SKIPPED (pool reservation failed)",
                                        "log": "", "exit": None, "set_mops": None,
                                        "fill": None, "capacity": None,
                                        "fill_factor": None})
                last_shape = None
                continue
            last_shape = shape

        for k in args.k_list:
            for rep in range(1, args.repeats + 1):
                results.append(do_run(ht_type, k, rep, args, plan_text,
                                      stamp, args.log_dir))
        print()

    # ---- summary -----------------------------------------------------------
    print("=" * 78)
    print("  summary")
    print("=" * 78)
    print(f"  {'ht':>3} {'label':<13}{'k':>3}{'rep':>4}{'set_mops':>10}"
          f"{'fill':>14}{'fill%':>8}  status")
    for r in results:
        mops = r["set_mops"] if r["set_mops"] is not None else "-"
        fill = r["fill"] if r["fill"] is not None else "-"
        ff = f"{r['fill_factor'] * 100:.1f}" if r["fill_factor"] is not None else "-"
        print(f"  {r['ht_type']:>3} {r['label']:<13}{r['k']:>3}{r['rep']:>4}"
              f"{str(mops):>10}{str(fill):>14}{ff:>8}  {r['status']}")

    if args.dry_run:
        print("\n  (dry run, nothing was executed)")
        return 0

    csv_path = Path(args.csv) if args.csv else args.log_dir / f"summary_{stamp}.csv"
    with open(csv_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["ht_type", "label", "k", "rep",
                                          "set_mops", "fill", "capacity",
                                          "fill_factor", "exit", "status", "log"])
        w.writeheader()
        w.writerows(results)

    print(f"\n  logs     {args.log_dir}")
    print(f"  commands {COMMANDS_LOG}")
    print(f"  summary  {csv_path}")

    failed = [r for r in results if r["status"] != "ok"]
    if failed:
        print(f"\n  {len(failed)} of {len(results)} run(s) did not complete:",
              file=sys.stderr)
        for r in failed:
            print(f"    ht{r['ht_type']} {r['label']} k={r['k']} rep={r['rep']}: "
                  f"{r['status']}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
