#!/usr/bin/env python3
'''
Two bandwidth sweeps on the AMD EPYC 9354P (NPS4, 4 NUMA nodes x 3 DDR5 channels),
read and write each. Both reuse the PMU plumbing calibrated in
collect_cpu_scaling_amd.py (see its docstring for the node -> amd_umc box mapping, the
3.25 GHz clock, the 64 B/CAS width, and why perf's own aggregation flags cannot do the
per-node split here).

  local       -- all 4 nodes loaded at once with the SAME thread count each, 1..16 per
                 node (each node's 8 physical cores, then their 8 SMT siblings), every
                 thread's memory bound to its own node. Pattern: "n0a0tT n1a1tT n2a2tT
                 n3a3tT". Total threads 4T, 4..64. Nothing crosses a node boundary, so
                 this is 4 independent memory systems driven in lockstep -- the question
                 is how far it tracks a straight line through its own 1-thread point.

  interleave  -- T total threads round-robinned over the 4 cpu nodes (thread i -> node
                 i%4), but memory MPOL_INTERLEAVEd across all 4 nodes at once ("a0-3"),
                 so ~3/4 of every thread's traffic is remote by construction and all 12
                 channels serve all threads. Pattern: "n0a0-3tX n1a0-3tY ...". This is
                 the "one big evenly-spread region" case: same hardware, no locality.

Read is prefetcht1 with lookahead 64 (bandwidth.c's fastest read path on this box).
Write is a plain store (`-inst load -mode w` -> `buffer[idx*8] = 0xff`), no prefetch.

A store misses, so the line is fetched (RFO) and later written back: the controllers
move about 2x what the program stores. Verified on this machine -- a 4-thread local
write run counted 1.131e9 read CAS against 1.135e9 write CAS on the same 3 boxes. Both
halves are recorded per point (umc_rd_gbs / umc_wr_gbs) and the headline number
(umc_all_gbs) is their sum, i.e. the traffic the DRAM actually carries, which is what a
bandwidth ceiling is a ceiling on.

All 12 amd_umc boxes are counted for every point in both sweeps, not just the ones
belonging to active cpu nodes: under interleave the memory is spread over all 4 nodes
no matter how few cpu nodes are running.

Needs sudo (uncore PMUs) and 2 MB hugepages on all 4 nodes (scripts/enable_hugepages.sh).
'''
import argparse
import json
import os
import statistics
import sys
from collections import defaultdict

from collect_cpu_scaling_amd import (
    BIN_PATH,
    BYTES_PER_CAS,
    CPU_FREQ_GHZ,
    EVENT_ENCODINGS,
    LOOKAHEAD,
    MAX_PER_THREAD_BYTES,
    NODE_UMC_BOXES,
    NUM_NODES,
    TOTAL_FOOTPRINT_BYTES,
    parse_log,
    per_thread_bytes,
)
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
OUTPUT_JSON = os.path.join(HERE, "amd_local_interleave.json")
LOG_DIR = os.path.join(HERE, "logs", "local_interleave")

# layout: how a sweep point's x value turns into threads per cpu node.
#   per_node -- x threads on every node (total 4x)
#   total_rr -- x threads total, thread i on node i%4
# mem: local    -- each thread's memory bound to its own cpu node ("a<n>")
#      interleave -- every thread's memory interleaved across all 4 nodes ("a0-3")
SERIES = {
    "local_read":       {"layout": "per_node", "mem": "local",      "mode": "r", "inst": "t1"},
    "local_write":      {"layout": "per_node", "mem": "local",      "mode": "w", "inst": "load"},
    "interleave_read":  {"layout": "total_rr", "mem": "interleave", "mode": "r", "inst": "t1"},
    "interleave_write": {"layout": "total_rr", "mem": "interleave", "mode": "w", "inst": "load"},
}

PER_NODE_THREADS = list(range(1, 17))  # 1..16 per node -> 4..64 threads total
TOTAL_THREADS = [1, 2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64]

ALL_NODES = list(range(NUM_NODES))
INTERLEAVE_SPEC = "0-{}".format(NUM_NODES - 1)


def thread_counts(layout, x):
    """x -> {cpu node: thread count} for this layout."""
    if layout == "per_node":
        return {n: x for n in ALL_NODES}
    counts = defaultdict(int)
    for i in range(x):
        counts[i % NUM_NODES] += 1
    return dict(counts)


def build_pattern(spec, counts):
    """bandwidth.c -pattern: groups separated by SPACES (its parser is strtok(s, " ");
    commas only list memory nodes inside one group, which is exactly what interleave
    uses here)."""
    groups = []
    for node in sorted(counts):
        if counts[node] <= 0:
            continue
        mem = INTERLEAVE_SPEC if spec["mem"] == "interleave" else str(node)
        groups.append("n{n}a{m}t{c}".format(n=node, m=mem, c=counts[node]))
    return " ".join(groups)


def perf_event_string_all():
    """Every amd_umc box on the machine, tagged with the node it belongs to. All 12 are
    always counted: interleaved memory lands on all 4 nodes however few cpu nodes run."""
    terms = []
    for node in ALL_NODES:
        for box in NODE_UMC_BOXES[node]:
            for kind, enc in EVENT_ENCODINGS.items():
                terms.append("amd_umc_{b}/{enc},name=mem_{k}_n{n}_b{b}/".format(
                    b=box, enc=enc, k=kind, n=node))
    return ",".join(terms)


def run_one(series_name, spec, counts, x, rep, interval_ms):
    total_threads = sum(counts.values())
    chunk_mb = per_thread_bytes(total_threads, TOTAL_FOOTPRINT_BYTES) // (1024 ** 2)
    cmd = [
        "sudo", "perf", "stat", "-a",
        "-e", perf_event_string_all(),
        "-I", str(interval_ms), "-x", ",",
        "--",
        BIN_PATH,
        "-m", "{}mb".format(chunk_mb),
        "-pattern", build_pattern(spec, counts),
        "-freq", CPU_FREQ_GHZ,
        "-inst", spec["inst"],
        "-lookahead", LOOKAHEAD,
        "-mode", spec["mode"],
    ]
    log_path = os.path.join(LOG_DIR, "{}_x{}_r{}.log".format(series_name, x, rep))
    with open(log_path, "w") as log:
        subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, text=True).check_returncode()
    return log_path


def collect(series_names, reps, interval_ms):
    os.makedirs(LOG_DIR, exist_ok=True)
    results = {}
    if os.path.exists(OUTPUT_JSON):
        with open(OUTPUT_JSON) as f:
            results = json.load(f)

    results.setdefault("config", {})
    results["config"].update({
        "binary": BIN_PATH,
        "total_footprint_target_gb": TOTAL_FOOTPRINT_BYTES / 1024 ** 3,
        "max_per_thread_gb": MAX_PER_THREAD_BYTES / 1024 ** 3,
        "lookahead": LOOKAHEAD,
        "cpu_freq_ghz": CPU_FREQ_GHZ,
        "bytes_per_cas": BYTES_PER_CAS,
        "node_umc_boxes": NODE_UMC_BOXES,
        "reps": reps,
        "interval_ms": interval_ms,
        "note": "local: x threads on EVERY node (total 4x), memory node-local. "
                "interleave: x threads total, thread i on node i%4, memory "
                "MPOL_INTERLEAVE across all 4 nodes. write = plain store, and its "
                "umc_all_gbs is rd+wr, i.e. RFO fetch + writeback (~2x program stores).",
    })

    for name in series_names:
        spec = SERIES[name]
        xs = PER_NODE_THREADS if spec["layout"] == "per_node" else TOTAL_THREADS
        row = results.setdefault(name, {"config": spec, "x": [], "points": {}})
        row["config"] = dict(spec, reps=reps)
        row["x_meaning"] = ("threads per node (all 4 nodes loaded)"
                            if spec["layout"] == "per_node" else "total threads")
        print("\n=== {} ({}, mem {}, mode {}, inst {}) ===".format(
            name, row["x_meaning"], spec["mem"], spec["mode"], spec["inst"]))

        for x in xs:
            counts = thread_counts(spec["layout"], x)
            runs = []
            for rep in range(reps):
                runs.append(parse_log(run_one(name, spec, counts, x, rep, interval_ms)))

            total_threads = sum(counts.values())

            def total_over_nodes(field):
                """Sum a field across all 4 nodes within each rep, then median the reps."""
                totals = []
                for s in runs:
                    vals = [s["nodes"][n][field]["median"] for n in ALL_NODES
                            if n in s["nodes"] and field in s["nodes"][n]]
                    if len(vals) == NUM_NODES:
                        totals.append(sum(vals))
                return statistics.median(totals) if totals else None

            prog_bw = [r["prog"].get("prog_bw_gbs") for r in runs]
            prog_bw = [v for v in prog_bw if v is not None]

            per_thread_b = per_thread_bytes(total_threads, TOTAL_FOOTPRINT_BYTES)
            all_gbs = total_over_nodes("all")
            point = {
                "x": x,
                "threads": total_threads,
                "node_threads": counts,
                "per_thread_mb": per_thread_b // (1024 ** 2),
                "total_footprint_gb": total_threads * per_thread_b / 1024 ** 3,
                "umc_all_gbs": all_gbs,
                "umc_rd_gbs": total_over_nodes("rd"),
                "umc_wr_gbs": total_over_nodes("wr"),
                "per_node_all_gbs": {
                    n: statistics.median([r["nodes"][n]["all"]["median"] for r in runs
                                          if n in r["nodes"] and "all" in r["nodes"][n]])
                    for n in ALL_NODES
                    if any(n in r["nodes"] and "all" in r["nodes"][n] for r in runs)
                },
                "prog_bw_gbs": statistics.median(prog_bw) if prog_bw else None,
                "prog_bw_samples": prog_bw,
            }
            row["points"][str(x)] = point
            if x not in row["x"]:
                row["x"].append(x)
            row["x"].sort()

            print("  x={:<3} ({:>2} thr, {:>4} mb/thr) umc {:>7.1f} GB/s "
                  "(rd {:>6.1f} + wr {:>6.1f}) | {:>5.2f} GB/s/thread | prog {:>7.1f}".format(
                      x, total_threads, point["per_thread_mb"], all_gbs or 0.0,
                      point["umc_rd_gbs"] or 0.0, point["umc_wr_gbs"] or 0.0,
                      (all_gbs / total_threads) if all_gbs else 0.0,
                      point["prog_bw_gbs"] or 0.0))

            with open(OUTPUT_JSON, "w") as f:
                json.dump(results, f, indent=2)

    print("\nSaved {}".format(OUTPUT_JSON))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--series", nargs="+", default=list(SERIES), choices=list(SERIES))
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--interval-ms", type=int, default=20)
    args = ap.parse_args()

    if not os.path.exists(BIN_PATH):
        sys.exit("ERROR: {} missing -- run `make build/bandwidth_rand` in machine_stats/"
                 .format(BIN_PATH))

    collect(args.series, args.reps, args.interval_ms)


if __name__ == "__main__":
    main()
