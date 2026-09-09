#!/usr/bin/env python3
"""Mock end-to-end correctness run for DRAMHiT k-mer counting.

Generates a small synthetic FASTQ with a known ground truth, runs dramhit over
it in one of two configurations, and diffs the hashtable dump against the
truth. Nothing here is a benchmark -- it exists to answer "is the counting
algorithm still correct", so the defaults are deliberately tiny.

The two modes map onto the two code paths in src/Application.cpp:

  partition  --mode 4 --ht-type 1 (PARTITIONED_HT)
             Producer/consumer split over bqueues. Producers parse the FASTQ
             and enqueue encoded kmers; each consumer owns a private table and
             dumps shard indices nprod .. nprod+ncons-1. --numa-split is a
             *queue* policy here (1-4, see numa_policy_queues).

  global     --mode 4 --ht-type 3 (CASHTPP)
             Every thread inserts into one shared CAS table. Only shard 0
             writes the dump, so there is exactly one output file. --numa-split
             is a *thread* policy here (1-10, see numa_policy_threads).

Requires a build with -DAGGR=ON -DBQ_KMER_TEST=ON -DPART_ID=ON; see
build_dramhit.sh in this directory.

Examples:
  ./test_and_run_kmer.py --mode partition --out-file kmer_out/ht --k 8
  ./test_and_run_kmer.py --mode global    --out-file kmer_out/ht --k 12
  ./test_and_run_kmer.py --mode partition --out-file kmer_out/ht --k 4 --dry-run
"""

import argparse
import glob
import os
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
DRAMHIT_ROOT = HERE.parents[2]          # scripts/eurosys_2026/collect_kmer -> /opt/DRAMHiT

GEN_FASTQ = HERE / "gen_fastq.py"
VERIFY = HERE / "verify.py"

# src/types.hpp: run_mode_t / ht_type_t
MODE_FASTQ_WITH_INSERT = 4
PARTITIONED_HT = 1
CASHTPP = 3


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

def next_pow2(n):
    p = 1
    while p < n:
        p <<= 1
    return p


def auto_ht_size(num_reads, read_length, k):
    """Pick a table size with plenty of headroom for the synthetic workload.

    For partitioned runs this is the size of *each* consumer's private table,
    so sizing it for the whole key space is conservative, which is what we
    want -- a mock run should never fail because the table filled up.
    """
    kmers_per_read = max(0, read_length - k + 1)
    unique_est = min(4 ** k, num_reads * kmers_per_read)
    return max(1 << 20, next_pow2(unique_est * 4))


def run(cmd, dry_run, **kwargs):
    print(f"\n$ {' '.join(shlex.quote(c) for c in cmd)}\n", flush=True)
    if dry_run:
        return 0
    return subprocess.call(cmd, **kwargs)


def clean_shards(prefix, dry_run):
    """Remove stale dumps so verify can't read a previous run's output."""
    stale = sorted(glob.glob(f"{prefix}*"))
    if not stale:
        return
    if dry_run:
        print(f"[clean] would remove {len(stale)} stale shard file(s) "
              f"matching {prefix}*")
        return
    print(f"[clean] removing {len(stale)} stale shard file(s) matching {prefix}*")
    for path in stale:
        os.remove(path)


# ---------------------------------------------------------------------------
# dramhit argv construction
# ---------------------------------------------------------------------------

def dramhit_args(args, ht_size):
    common = [
        "--mode", str(MODE_FASTQ_WITH_INSERT),
        "--k", str(args.k),
        "--in-file", str(args.fastq),
        "--out-file", str(args.out_file),
        "--ht-size", str(ht_size),
        "--find_queue", str(args.find_queue),
        "--hw-pref", "1" if args.hw_pref else "0",
    ]

    if args.mode == "partition":
        return common + [
            "--ht-type", str(PARTITIONED_HT),
            "--numa-split", str(args.numa_split),
            "--nprod", str(args.nprod),
            "--ncons", str(args.ncons),
            "--insert-factor", "1",
        ]

    # global
    return common + [
        "--ht-type", str(CASHTPP),
        "--numa-split", str(args.numa_split),
        "--num-threads", str(args.num_threads),
        "--batch-len", str(args.batch_len),
        "--no-prefetch", "0",
    ]


def verify_shard_range(args):
    """(n_prod, n_cons) as verify.py needs them to find the dump files.

    Partitioned consumers dump at shard indices nprod..nprod+ncons-1. In the
    global path only shard 0 writes (Application.cpp skips shard_idx > 0 for
    CASHTPP), so there is a single file at index 0.
    """
    if args.mode == "partition":
        return args.nprod, args.ncons
    return 0, 1


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Mock k-mer correctness run: generate -> count -> verify",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Examples:", 1)[1] if "Examples:" in __doc__ else None,
    )

    # the three the workflow is built around
    p.add_argument("--mode", required=True, choices=("partition", "global"),
                   help="partition: bqueue prod/cons, ht-type 1. "
                        "global: shared CAS table, ht-type 3.")
    p.add_argument("--out-file", required=True,
                   help="Hashtable dump prefix; dramhit appends the shard index "
                        "(e.g. kmer_out/ht -> kmer_out/ht16, kmer_out/ht17...). "
                        "Parent directories are created.")
    p.add_argument("--k", required=True, type=int,
                   help="k in k-mer (1..32)")

    # synthetic workload
    g = p.add_argument_group("synthetic input")
    g.add_argument("--num-reads", type=int, default=1000)
    g.add_argument("--read-length", type=int, default=150)
    g.add_argument("--seed", type=int, default=42)
    g.add_argument("--fastq", default=None,
                   help="Where to write the generated FASTQ "
                        "(default: <workdir>/synthetic.fastq)")
    g.add_argument("--truth", default=None,
                   help="Where to write the ground truth TSV "
                        "(default: <workdir>/truth_k<K>.tsv)")
    g.add_argument("--work-dir", default=None,
                   help="Directory for generated files "
                        "(default: alongside --out-file)")
    g.add_argument("--reuse-input", action="store_true",
                   help="Skip generation if the FASTQ and truth already exist")

    # run knobs
    g = p.add_argument_group("run configuration")
    g.add_argument("--bin", default=str(DRAMHIT_ROOT / "build" / "dramhit"),
                   help="Path to the dramhit binary")
    g.add_argument("--nprod", type=int, default=8,
                   help="Producers (partition mode only, default: 8)")
    g.add_argument("--ncons", type=int, default=8,
                   help="Consumers (partition mode only, default: 8)")
    g.add_argument("--num-threads", type=int, default=8,
                   help="Threads (global mode only, default: 8)")
    g.add_argument("--numa-split", type=int, default=4,
                   help="partition: queue policy 1-4 (default 4, "
                        "PROD_CONS_SAME_NODE). global: thread policy 1-10 "
                        "(default 4, THREADS_LOCAL_NUMA_NODE).")
    g.add_argument("--ht-size", type=int, default=None,
                   help="Slots per table (default: sized from the workload)")
    g.add_argument("--batch-len", type=int, default=16)
    g.add_argument("--find-queue", type=int, default=64, dest="find_queue")
    g.add_argument("--hw-pref", action="store_true",
                   help="Leave hardware prefetchers on (default: off, needs root)")
    g.add_argument("--sudo", dest="sudo", action="store_true", default=None,
                   help="Force sudo (default: sudo iff not already root)")
    g.add_argument("--no-sudo", dest="sudo", action="store_false",
                   help="Never use sudo")

    # behaviour
    g = p.add_argument_group("behaviour")
    g.add_argument("--dry-run", action="store_true",
                   help="Print every command without running anything")
    g.add_argument("--keep-output", action="store_true",
                   help="Keep the shard dumps after a passing run")
    g.add_argument("--count-key0", action="store_true",
                   help="Ask verify.py to also check encoded key 0 (the all-A "
                        "kmer). It is Aggr_KV's empty sentinel and is never "
                        "dumped, so this is expected to fail.")

    args = p.parse_args(argv)

    if not 1 <= args.k <= 32:
        p.error(f"--k must be between 1 and 32 (got {args.k})")
    if args.mode == "partition" and not 1 <= args.numa_split <= 4:
        p.error(f"--numa-split must be 1..4 in partition mode "
                f"(got {args.numa_split}); see numa_policy_queues in include/numa.hpp")
    if args.mode == "global" and not 1 <= args.numa_split <= 10:
        p.error(f"--numa-split must be 1..10 in global mode "
                f"(got {args.numa_split}); see numa_policy_threads in include/numa.hpp")

    args.out_file = Path(args.out_file).resolve()

    work_dir = Path(args.work_dir).resolve() if args.work_dir else args.out_file.parent
    args.work_dir = work_dir
    args.fastq = Path(args.fastq).resolve() if args.fastq else work_dir / "synthetic.fastq"
    args.truth = Path(args.truth).resolve() if args.truth else work_dir / f"truth_k{args.k}.tsv"

    if args.sudo is None:
        args.sudo = os.geteuid() != 0

    return args


def main(argv=None):
    args = parse_args(argv)

    binary = Path(args.bin)
    if not args.dry_run and not binary.is_file():
        print(f"[FAIL] dramhit binary not found: {binary}\n"
              f"       build it first: {HERE / 'build_dramhit.sh'}", file=sys.stderr)
        return 2

    ht_size = args.ht_size or auto_ht_size(args.num_reads, args.read_length, args.k)

    print("=" * 70)
    print(f"mock kmer run  mode={args.mode}  k={args.k}")
    print("=" * 70)
    print(f"  binary    : {binary}")
    print(f"  fastq     : {args.fastq}")
    print(f"  truth     : {args.truth}")
    print(f"  out prefix: {args.out_file}")
    print(f"  ht-size   : {ht_size}"
          f"{'' if args.ht_size else ' (auto)'}")
    if args.mode == "partition":
        print(f"  nprod/ncons: {args.nprod}/{args.ncons}   numa-split(queue): {args.numa_split}")
    else:
        print(f"  threads   : {args.num_threads}   numa-split(thread): {args.numa_split}")

    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.out_file.parent.mkdir(parents=True, exist_ok=True)

    # ---- 1. generate the synthetic input + ground truth --------------------
    have_input = args.fastq.is_file() and args.truth.is_file()
    if args.reuse_input and have_input:
        print(f"\n[1/3] reusing existing input ({args.fastq.name}, {args.truth.name})")
    else:
        print("\n[1/3] generating synthetic FASTQ + ground truth")
        rc = run([sys.executable, str(GEN_FASTQ),
                  "--num-reads", str(args.num_reads),
                  "--read-length", str(args.read_length),
                  "--k", str(args.k),
                  "--seed", str(args.seed),
                  "--out-fastq", str(args.fastq),
                  "--out-truth", str(args.truth)], args.dry_run)
        if rc != 0:
            print(f"[FAIL] gen_fastq.py exited {rc}", file=sys.stderr)
            return rc

    # ---- 2. count ----------------------------------------------------------
    print("\n[2/3] running dramhit")
    clean_shards(str(args.out_file), args.dry_run)

    cmd = ([ "sudo" ] if args.sudo else []) + [str(binary)] + dramhit_args(args, ht_size)
    rc = run(cmd, args.dry_run, cwd=str(DRAMHIT_ROOT))
    if rc != 0:
        print(f"[FAIL] dramhit exited {rc}", file=sys.stderr)
        return rc

    # Under sudo the dumps land root-owned. Both the verify read and the
    # cleanup below still work, since removal is governed by the (user-owned)
    # parent directory rather than the file.
    produced = sorted(glob.glob(f"{args.out_file}*"))
    if not args.dry_run and not produced:
        print(f"[FAIL] dramhit produced no shard files at {args.out_file}*\n"
              f"       is the binary built with -DAGGR=ON -DBQ_KMER_TEST=ON "
              f"-DPART_ID=ON?", file=sys.stderr)
        return 1
    print(f"[dump] {len(produced)} shard file(s) written")

    # ---- 3. verify ---------------------------------------------------------
    print("\n[3/3] verifying against ground truth")
    n_prod, n_cons = verify_shard_range(args)
    vcmd = [sys.executable, str(VERIFY),
            "--truth", str(args.truth),
            "--ht-output", str(args.out_file),
            "--n-prod", str(n_prod),
            "--n-cons", str(n_cons)]
    if args.count_key0:
        vcmd.append("--count-key0")
    rc = run(vcmd, args.dry_run)

    if args.dry_run:
        print("\n[dry-run] nothing was executed")
        return 0

    if rc == 0:
        print(f"\n=== PASS === {args.mode} mode, k={args.k}")
        if not args.keep_output:
            for path in produced:
                try:
                    os.remove(path)
                except OSError as e:
                    print(f"[warn] could not remove {path}: {e}")
            print(f"[clean] removed {len(produced)} shard file(s) "
                  f"(pass --keep-output to keep them)")
    else:
        print(f"\n=== FAIL === {args.mode} mode, k={args.k}; "
              f"shard dumps left at {args.out_file}*")
    return rc


if __name__ == "__main__":
    sys.exit(main())
