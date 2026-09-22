#!/usr/bin/env python3
"""dlht batch-length sweep on the AMD EPYC 9354P, fill 10 (mode 11, uniform).

amd_vs_intel_lookup.md says dlht does 0.57-0.66x the work per core-GHz on this
machine that a Max 9462 core does, and attributes it to memory-level
parallelism: dlht sustains 4.68 in-flight L1 misses against dramhit's 6.80.
That document also asserts dlht "needs 32; 16 is not an option for it".

This sweep tests both halves of that on the published configuration. dlht's
find_batch is a two-pass burst -- it issues one __builtin_prefetch per key for
the whole batch, then drains the whole batch with no further prefetches in
flight -- so batch length IS its prefetch depth, and the burst is 2x deeper per
core than it looks because the run is 64 threads on 32 SMT cores.

Every point records found vs find_ops, so a batch length that silently returns
the wrong number of results (as cas23 does at 32 and 64) shows up as a
correctness failure next to its throughput number rather than as a fast-looking
data point.

Everything except --batch-len matches collect_data_amd.py exactly, so the
batch-32 row here is directly comparable to amd-9354p_uniform.json's fill-10
dlht point.

    python3 sweep_dlht_batch_amd.py --dry-run
    python3 sweep_dlht_batch_amd.py
    python3 sweep_dlht_batch_amd.py --reps 1 --batches 16,32
"""

import argparse
import json
import re
import shlex
import statistics
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
DATA_DIR = SCRIPT_DIR / "amd"
LOG_DIR = DATA_DIR / "logs" / "dlht_batch_sweep"
OUT_JSON = DATA_DIR / "dlht_batch_sweep.json"

DRAMHIT = "/opt/DRAMHiT/build/dramhit"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_amd.sh"

# --- mirrored from collect_data_amd.py ---------------------------------------
MODE_UNIFORM = 11
HT_CAS23 = 8
HT_DLHT = 10

NUM_THREADS = 64
NUMA_SPLIT = 1
HT_SIZE = 1 << 29
INSERT_FACTOR = 100
READ_FACTOR = 100
SEED = 1775762440565610239
FILL = 10

# dlht's find_batch prefetches the whole batch at once, so these are prefetch
# depths per thread. 4..256 brackets the knee from both sides.
BATCHES = [4, 8, 12, 16, 20, 24, 32, 48, 64, 128, 256]
REPS = 3

# dramhit at its own published batch length, as the reference this machine's
# dlht number is judged against. Its find_batch keeps a persistent 64-entry
# queue and only drains down to FLUSH_THRESHOLD, so its prefetch depth is a
# property of the queue, not of --batch-len.
REFERENCE = {"name": "cas23", "display": "dramhit", "ht_type": HT_CAS23, "batch_len": 16}

SET_RE = re.compile(r"set_mops\s*:\s*([\d.]+)")
GET_RE = re.compile(r"get_mops\s*:\s*([\d.]+)")
CYC_RE = re.compile(r"set_cycles\s*:\s*(\d+),\s*get_cycles\s*:\s*(\d+)")
FOUND_RE = re.compile(r"find_ops\s*:\s*(\d+),\s*found\s*:\s*(\d+)")
FILL_RE = re.compile(r"fill\s*:\s*(\d+),\s*capacity\s*:\s*(\d+),\s*fill_factor\s*:\s*([\d.]+)")


def cmd_for(ht_type, batch_len):
    args = [
        DRAMHIT,
        "--mode", str(MODE_UNIFORM),
        "--ht-type", str(ht_type),
        "--ht-size", str(HT_SIZE),
        "--ht-fill", str(FILL),
        "--num-threads", str(NUM_THREADS),
        "--numa-split", str(NUMA_SPLIT),
        "--batch-len", str(batch_len),
        "--find_queue", "64",
        "--no-prefetch", "0",
        "--hw-pref", "0",
        "--insert-factor", str(INSERT_FACTOR),
        "--read-factor", str(READ_FACTOR),
        "--skew", "0.01",
        "--seed", str(SEED),
    ]
    return "sudo " + " ".join(shlex.quote(a) for a in args)


def one_run(tag, ht_type, batch_len):
    """Run once, return the parsed point. Runs are serial on purpose: two
    concurrent 64-thread runs cost each other ~35% and the contaminated numbers
    look like real data."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log = LOG_DIR / f"{tag}.log"
    cmd = cmd_for(ht_type, batch_len)
    print(f"[run] {tag}", flush=True)
    proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    out = proc.stdout + proc.stderr
    log.write_text(out)

    point = {"ok": proc.returncode == 0, "returncode": proc.returncode, "log": log.name}
    m = SET_RE.search(out)
    point["set_mops"] = float(m.group(1)) if m else None
    m = GET_RE.search(out)
    point["get_mops"] = float(m.group(1)) if m else None
    m = CYC_RE.search(out)
    if m:
        point["set_cycles"] = int(m.group(1))
        point["get_cycles"] = int(m.group(2))
    m = FOUND_RE.search(out)
    if m:
        point["find_ops"] = int(m.group(1))
        point["found"] = int(m.group(2))
        point["all_found"] = point["find_ops"] == point["found"]
    else:
        point["find_ops"] = point["found"] = None
        point["all_found"] = False
    m = FILL_RE.search(out)
    if m:
        point["fill_entries"] = int(m.group(1))
        point["fill_factor"] = float(m.group(3))
    return point


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--reps", type=int, default=REPS)
    ap.add_argument("--batches", default=",".join(str(b) for b in BATCHES))
    ap.add_argument("--no-reference", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    batches = [int(b) for b in args.batches.split(",") if b.strip()]

    if args.dry_run:
        for b in batches:
            print(cmd_for(HT_DLHT, b))
        if not args.no_reference:
            print(cmd_for(REFERENCE["ht_type"], REFERENCE["batch_len"]))
        return 0

    subprocess.run(f"bash {PREFETCH_SCRIPT} off", shell=True, check=False)

    result = {
        "machine": "amd-9354p",
        "mode": MODE_UNIFORM,
        "collected_utc": datetime.now(timezone.utc).isoformat(),
        "fill": FILL,
        "ht_size": HT_SIZE,
        "num_threads": NUM_THREADS,
        "numa_split": NUMA_SPLIT,
        "insert_factor": INSERT_FACTOR,
        "read_factor": READ_FACTOR,
        "seed": SEED,
        "prefetcher": "off",
        "reps": args.reps,
        "dlht": {},
        "reference": None,
    }

    def record():
        OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
        OUT_JSON.write_text(json.dumps(result, indent=2) + "\n")

    def summarize(samples):
        gets = [s["get_mops"] for s in samples if s["get_mops"] is not None]
        sets = [s["set_mops"] for s in samples if s["set_mops"] is not None]
        return {
            "samples": samples,
            "get_mops_median": statistics.median(gets) if gets else None,
            "get_mops_min": min(gets) if gets else None,
            "get_mops_max": max(gets) if gets else None,
            "set_mops_median": statistics.median(sets) if sets else None,
            "all_found": all(s["all_found"] for s in samples),
            "ok": all(s["ok"] for s in samples),
        }

    for b in batches:
        samples = [one_run(f"dlht_b{b}_r{r}", HT_DLHT, b) for r in range(args.reps)]
        result["dlht"][str(b)] = summarize(samples)
        record()

    if not args.no_reference:
        ref = REFERENCE
        samples = [one_run(f"{ref['name']}_b{ref['batch_len']}_r{r}", ref["ht_type"],
                           ref["batch_len"]) for r in range(args.reps)]
        result["reference"] = dict(ref, **summarize(samples))
        record()

    print()
    print(f"dlht, fill {FILL}, {NUM_THREADS} threads, prefetcher off, "
          f"{args.reps} reps -- median of get_mops")
    print("{:>7} {:>10} {:>14} {:>10} {:>10}".format(
        "batch", "get_mops", "min-max", "set_mops", "correct"))
    for b in batches:
        e = result["dlht"][str(b)]
        band = "{:.0f}-{:.0f}".format(e["get_mops_min"], e["get_mops_max"]) \
            if e["get_mops_min"] is not None else "-"
        print("{:>7} {:>10.0f} {:>14} {:>10.0f} {:>10}".format(
            b, e["get_mops_median"], band, e["set_mops_median"],
            "yes" if e["all_found"] else "NO"))
    if result["reference"]:
        e = result["reference"]
        print("{:>7} {:>10.0f} {:>14} {:>10.0f} {:>10}   <- {} batch {}".format(
            "ref", e["get_mops_median"], "-", e["set_mops_median"],
            "yes" if e["all_found"] else "NO", e["display"], e["batch_len"]))
    print(f"\nwritten to {OUT_JSON}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
