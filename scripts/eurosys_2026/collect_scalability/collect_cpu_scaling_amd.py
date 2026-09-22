#!/usr/bin/env python3
'''
Core-count sweep against local DDR5 on the AMD box: this is intel_hbm/collect_cpu_scaling.py
carried over to hardware with no HBM tier and no second socket, so it answers the same
question -- does each added core buy a fixed slice of bandwidth, or does something shared
saturate first -- against the only memory tier this machine has.

Machine: 1x AMD EPYC 9354P (Zen4, Genoa), 32 cores / 64 threads, booted NPS4 -- the BIOS
splits the single socket into 4 NUMA nodes, each with its own slice of cores and its own
3 DDR5 channels:
    node 0: cpus 0-7,32-39    node 1: cpus 8-15,40-47
    node 2: cpus 16-23,48-55  node 3: cpus 24-31,56-63
(0-31 are physical cores, 32-63 are their SMT siblings -- cpu N and N+32 share a core.)
There is no cross-socket fabric to hold constant here the way the Intel sweep holds UPI
constant; the analogous "shared thing" on this chip is the single Infinity Fabric linking
all 4 memory controllers, which every node's traffic crosses regardless of core placement.

Two series, both bandwidth.c (random access, prefetcht1, lookahead 64), CPUs and memory
both bound to the same node(s) so nothing crosses to a remote controller:

  node_local   -- cpu node 0 -> mem node 0 only. Threads 1..16 sweep just that node's 8
                  physical cores then their 8 SMT siblings, isolating one node's ceiling.
  system_local -- all 4 nodes at once, thread i pinned to node i%4 (so node0/1/2/3 each
                  gain a thread in turn, physical cores before any node's SMT siblings),
                  memory local to whichever node the thread landed on. This is the
                  machine-wide analogue of Intel's single-HBM-node sweep: every controller
                  is loaded from its own local cores the whole way, so a bend in this curve
                  is either a per-controller ceiling (node_local bends at the same thread
                  count) or something above the controllers -- the fabric -- that all 4 of
                  them share.

Program-reported GB/s (bandwidth.c's own byte-count / wall-clock) is the headline number.
It is cross-checked at the DRAM controllers themselves, because a number the program
computes from its own timer can't tell a real ceiling from the timer being wrong -- and
that almost happened here: bandwidth.c's "-freq" is not measured, it's what you tell it to
divide elapsed cycles by, and the value the Intel sweep uses (2.7) is that machine's
number, not this one's. This chip's actual base clock is 3.25 GHz (matches
collect_bw/collect_threads.sh's `-DCPUFREQ_MHZ=3250` for this same box), confirmed here by
comparing the program's own elapsed-cycle count against wall-clock time recovered
independently from perf's -I timestamps on a calibration run -- the two agreed to within
0.4% at 3.25 GHz and were 17% apart at 2.7.

The DRAM-side PMU is amd_umc_<N> (12 instances, 3 per NUMA node -- confirmed empirically,
not from docs: pin 8 threads to node 0 only and watch which amd_umc_* boxes move. Boxes
0,1,2 moved; 3-11 stayed flat. Repeating per node gives node -> boxes {3n, 3n+1, 3n+2}.
That mapping cannot come from sysfs on this kernel: every amd_umc_*/cpumask reads "0" --
perf just needs one CPU to open the fd on, and picks CPU 0 for all of them regardless of
which node's controller the box actually is -- so both --per-socket (one socket, useless)
and --per-node (would bucket every uncore box under node 0) are dead ends here, unlike the
Intel sweep where uncore cpumask is meaningful. Node identity is instead threaded through
perf's `name=` field per box and summed back up in this script.

Each amd_umc_<N> is read as two named events, umc_cas_cmd.rd and .wr (raw CAS command
counts, no scale/unit exposed by this kernel's sysfs the way uncore_imc's is on the Intel
box) plus umc_mem_clk. CAS width: DDR5 on this UMC is 2x32B sub-channels bursting together,
64B/CAS -- checked the same way as the frequency, by summing (rd+wr)*64B over the interior
perf intervals of a calibration run and comparing to the program's own freq-corrected
GB/s: they agreed to within 8%, the rest attributable to non-demand DRAM traffic (partial
lines, refresh, the prefetcher) that a CPU-side byte count never sees -- the same order of
mismatch the Intel sweep documents between its own prog/PMU numbers.

Needs sudo (uncore PMUs) and 2 MB hugepages on every node under test:
scripts/enable_hugepages.sh reserves them; bandwidth.c's mbind() + MAP_HUGETLB fails
without them and the workers hang on their barrier instead of exiting.
'''
import argparse
import json
import os
import re
import statistics
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
BIN_PATH = os.path.normpath(os.path.join(HERE, "..", "machine_stats", "build", "bandwidth_rand"))

OUTPUT_JSON = os.path.join(HERE, "amd_cpu_scaling.json")
LOG_DIR = os.path.join(HERE, "logs", "cpu_scaling")

# See per_thread_bytes(): why a fixed per-thread size is wrong for a core sweep, and why
# 16gb/2gb/256mb are the right total/cap/floor -- copied verbatim from the Intel sweep,
# the reasoning is footprint-vs-cache and has nothing to do with which vendor's cache it is.
TOTAL_FOOTPRINT_BYTES = 16 * 1024 ** 3
MAX_PER_THREAD_BYTES = 2 * 1024 ** 3
MIN_PER_THREAD_BYTES = 256 * 1024 ** 2

# node_local is confined to one node's ~8GB of reserved 2MB hugepages (enable_hugepages.sh
# reserves per-node, not machine-wide), so it gets its own, smaller target.
NODE_TOTAL_FOOTPRINT_BYTES = 6 * 1024 ** 3

CPU_FREQ_GHZ = "3.25"  # this machine's actual base clock -- see module docstring
LOOKAHEAD = "64"
INST = "t1"

NUM_NODES = 4
CPUS_PER_NODE = 16  # 8 physical + 8 SMT siblings, this machine's NPS4 layout

# node -> its 3 amd_umc_<N> boxes, confirmed empirically (see module docstring); this is
# NOT derivable from /sys/devices/amd_umc_*/cpumask, which reads 0 for every box.
NODE_UMC_BOXES = {n: [3 * n, 3 * n + 1, 3 * n + 2] for n in range(NUM_NODES)}
BYTES_PER_CAS = 64  # DDR5, 2x32B sub-channels bursting together -- see module docstring

EVENT_ENCODINGS = {
    "rd": "umc_cas_cmd.rd",
    "wr": "umc_cas_cmd.wr",
    "clk": "umc_mem_clk",
}

# node_local: just node 0, 1..16 threads (8 physical then their SMT siblings).
# system_local: all 4 nodes at once, up to 16 threads/node -- the extra points below
# 16*4=64 are round-robinned across nodes (see thread_layout()), same as the Intel default.
NODE_LOCAL_THREADS = [1, 2, 4, 6, 8, 12, 16]
SYSTEM_LOCAL_THREADS = [1, 2, 4, 6, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64]

PROG_BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s")
PROG_CPA_RE = re.compile(r"node\s+(\d+)\s*:\s*([\d.]+)\s*cycles/access")
PROG_CYCLES_RE = re.compile(r"Elapsed Cycles\s*:\s*(\d+)")


def per_thread_bytes(threads, total_footprint_bytes):
    """Per-thread chunk for this point, as a power of two (bandwidth.c rounds down to one
    anyway, so choose it here and report the real footprint)."""
    target = min(MAX_PER_THREAD_BYTES, total_footprint_bytes // threads)
    size = MIN_PER_THREAD_BYTES
    while size * 2 <= target:
        size *= 2
    return size


def thread_layout(total_threads, nodes):
    """Thread i -> nodes[i % len(nodes)] -- round-robin so every active node gains a
    thread in turn (physical cores before any node's SMT siblings, since bandwidth.c
    assigns each node's cpus in ascending id order and this machine lists physical cores
    before their SMT siblings). Returns {node: thread_count} for nodes that got >=1."""
    counts = defaultdict(int)
    for i in range(total_threads):
        counts[nodes[i % len(nodes)]] += 1
    return dict(counts)


def perf_event_string(nodes):
    """One amd_umc_<N>/.../,name=mem_<kind>_n<node>_b<box>/ term per (node, box, kind),
    restricted to the boxes of the given nodes -- so a node_local run doesn't pay for (or
    get confused by) counters on nodes it never touches."""
    terms = []
    for node in nodes:
        for box in NODE_UMC_BOXES[node]:
            for kind, enc in EVENT_ENCODINGS.items():
                terms.append("amd_umc_{b}/{enc},name=mem_{k}_n{n}_b{b}/".format(
                    b=box, enc=enc, k=kind, n=node))
    return ",".join(terms)


def run_one(series_name, node_threads, rep, interval_ms, inst=INST):
    """node_threads: {node: thread_count}. Builds bandwidth.c's -pattern from it directly:
    'n{node}a{node}t{count}' per active node, SPACE-joined -- bandwidth.c's parser splits
    pattern groups on strtok(str, " "), not commas (commas are only used inside a group,
    e.g. 'a0,1' to interleave one group's memory across two nodes)."""
    pattern = " ".join(
        "n{n}a{n}t{c}".format(n=n, c=c) for n, c in sorted(node_threads.items()) if c > 0
    )
    total_threads = sum(node_threads.values())
    chunk_mb = per_thread_bytes(total_threads, footprint_for(node_threads)) // (1024 ** 2)

    cmd = [
        "sudo", "perf", "stat", "-a",
        "-e", perf_event_string(sorted(n for n, c in node_threads.items() if c > 0)),
        "-I", str(interval_ms), "-x", ",",
        "--",
        BIN_PATH,
        "-m", "{}mb".format(chunk_mb),
        "-pattern", pattern,
        "-freq", CPU_FREQ_GHZ,
        "-inst", inst,
        "-lookahead", LOOKAHEAD,
        "-mode", "r",
    ]

    log_path = os.path.join(LOG_DIR, "{}_t{}_r{}.log".format(series_name, total_threads, rep))
    with open(log_path, "w") as log:
        subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, text=True).check_returncode()
    return log_path


def footprint_for(node_threads):
    return NODE_TOTAL_FOOTPRINT_BYTES if len(node_threads) == 1 else TOTAL_FOOTPRINT_BYTES


def parse_log(log_path):
    '''Per-interval memory rates from one run's merged perf+program output, summed per
    NUMA node (from the name= tag, not a socket column -- see module docstring for why).

    Only the rows between the program's own markers count: outside them the threads are
    still allocating and first-touching their chunks, which is real memory traffic that
    has nothing to do with the measured loop.
    '''
    in_window = False
    # ts -> node -> event kind -> [summed count, summed run_ns, box count]
    acc = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0])))
    prog = {"cpa_by_node": {}}

    node_re = re.compile(r"^mem_(rd|wr|clk)_n(\d+)_b\d+$")

    with open(log_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            if "Start perf collection" in line:
                in_window = True
                continue
            if "End perf collection" in line:
                in_window = False
                continue

            m = PROG_BW_RE.search(line)
            if m:
                prog["prog_bw_gbs"] = float(m.group(1))
            m = PROG_CYCLES_RE.search(line)
            if m:
                prog["elapsed_cycles"] = int(m.group(1))
            for mm in PROG_CPA_RE.finditer(line):
                prog["cpa_by_node"][mm.group(1)] = float(mm.group(2))

            if not in_window:
                continue

            parts = line.split(",")
            if len(parts) < 5 or not parts[0][:1].isdigit():
                continue
            if "<not counted>" in parts[1] or "<not supported>" in parts[1]:
                continue
            m = node_re.match(parts[3].strip())
            if not m:
                continue
            try:
                ts = float(parts[0])
                count = float(parts[1])
                run_ns = float(parts[4])
            except ValueError:
                continue

            kind, node = m.group(1), int(m.group(2))
            slot = acc[ts][node][kind]
            slot[0] += count
            slot[1] += run_ns
            slot[2] += 1

    if "elapsed_cycles" in prog:
        prog["prog_time_freq_corrected_s"] = prog["elapsed_cycles"] / (float(CPU_FREQ_GHZ) * 1e9)

    per_node = defaultdict(lambda: defaultdict(list))
    timestamps = sorted(acc.keys())
    # The first and last interval inside the markers are partial -- the loop starts and
    # ends somewhere inside them -- so they understate the rate.
    window = timestamps[1:-1] if len(timestamps) > 2 else timestamps
    for ts in window:
        for node, events in acc[ts].items():
            if not {"rd", "wr", "clk"} <= set(events):
                continue
            rd_count, rd_ns, rd_boxes = events["rd"]
            wr_count, wr_ns, wr_boxes = events["wr"]
            clk_count, clk_ns, clk_boxes = events["clk"]
            if rd_ns <= 0 or wr_ns <= 0:
                continue
            # run_ns here is SUMMED across this node's boxes (one term per box added
            # above), so dividing by it alone gives a per-box rate; multiplying by the
            # box count restores the node total -- same correction the Intel sweep's
            # uncore_hbm accounting applies for the same reason (rates[key] = bytes *
            # boxes * count / run_ns).
            rd_gbs = BYTES_PER_CAS * rd_boxes * rd_count / rd_ns
            wr_gbs = BYTES_PER_CAS * wr_boxes * wr_count / wr_ns
            per_node[node]["rd"].append(rd_gbs)
            per_node[node]["wr"].append(wr_gbs)
            per_node[node]["all"].append(rd_gbs + wr_gbs)
            if clk_ns > 0:
                per_node[node]["dclk_ghz"].append(clk_boxes * clk_count / clk_ns)

    summary = {"prog": prog, "nodes": {}, "intervals": len(window)}
    for node, series in per_node.items():
        summary["nodes"][node] = {
            k: {"median": statistics.median(v), "max": max(v), "min": min(v), "n": len(v)}
            for k, v in series.items() if v
        }
    return summary


def collect(series_name, threads_list, nodes, reps, interval_ms, inst=INST):
    os.makedirs(LOG_DIR, exist_ok=True)
    results = {}
    if os.path.exists(OUTPUT_JSON):
        with open(OUTPUT_JSON) as f:
            results = json.load(f)

    results.setdefault("config", {})
    results["config"].update({
        "binary": BIN_PATH,
        "total_footprint_target_gb": TOTAL_FOOTPRINT_BYTES / 1024 ** 3,
        "node_total_footprint_target_gb": NODE_TOTAL_FOOTPRINT_BYTES / 1024 ** 3,
        "max_per_thread_gb": MAX_PER_THREAD_BYTES / 1024 ** 3,
        "inst": inst,
        "lookahead": LOOKAHEAD,
        "cpu_freq_ghz": CPU_FREQ_GHZ,
        "bytes_per_cas": BYTES_PER_CAS,
        "node_umc_boxes": NODE_UMC_BOXES,
        "reps": reps,
        "interval_ms": interval_ms,
        "note": "node_local: node 0 only, 1-16 threads (8 physical + 8 SMT). "
                "system_local: thread i pinned to node i%4, memory local to that node.",
    })

    key = series_name if inst == INST else "{}_{}".format(series_name, inst)
    row = results.setdefault(key, {"nodes": nodes, "threads": [], "points": {}})
    row["nodes"] = nodes
    row["config"] = {"inst": inst, "reps": reps}
    print("\n=== {} (nodes {}, inst {}) ===".format(key, nodes, inst))

    for total_threads in threads_list:
        node_threads = thread_layout(total_threads, nodes)
        runs = []
        for rep in range(reps):
            log_path = run_one(key, node_threads, rep, interval_ms, inst)
            runs.append(parse_log(log_path))

        active_nodes = sorted(node_threads.keys())

        def med(samples, field, subfield="median"):
            vals = [s["nodes"][n][field][subfield] for s in samples
                     for n in active_nodes if n in s["nodes"] and field in s["nodes"][n]]
            return statistics.median(vals) if vals else None

        def node_total(samples, field, subfield="median"):
            # sum across active nodes per run, then median across reps
            totals = []
            for s in samples:
                vals = [s["nodes"][n][field][subfield] for n in active_nodes
                         if n in s["nodes"] and field in s["nodes"][n]]
                if len(vals) == len(active_nodes):
                    totals.append(sum(vals))
            return statistics.median(totals) if totals else None

        prog_bw = [r["prog"].get("prog_bw_gbs") for r in runs]
        prog_bw = [v for v in prog_bw if v is not None]
        prog_time = [r["prog"].get("prog_time_freq_corrected_s") for r in runs]
        prog_time = [v for v in prog_time if v is not None]

        footprint_bytes = footprint_for(node_threads)
        per_thread_b = per_thread_bytes(total_threads, footprint_bytes)

        point = {
            "threads": total_threads,
            "node_threads": node_threads,
            "per_thread_mb": per_thread_b // (1024 ** 2),
            "total_footprint_gb": total_threads * per_thread_b / 1024 ** 3,
            "umc_all_gbs": node_total(runs, "all"),
            "umc_rd_gbs": node_total(runs, "rd"),
            "umc_wr_gbs": node_total(runs, "wr"),
            "umc_dclk_ghz_median_per_node": med(runs, "dclk_ghz"),
            "per_node_all_gbs": {
                n: statistics.median([r["nodes"][n]["all"]["median"] for r in runs
                                       if n in r["nodes"] and "all" in r["nodes"][n]])
                for n in active_nodes
                if any(n in r["nodes"] and "all" in r["nodes"][n] for r in runs)
            },
            "prog_bw_gbs": statistics.median(prog_bw) if prog_bw else None,
            "prog_bw_samples": prog_bw,
            "prog_time_freq_corrected_s": statistics.median(prog_time) if prog_time else None,
        }
        row["points"][str(total_threads)] = point
        if total_threads not in row["threads"]:
            row["threads"].append(total_threads)
        row["threads"].sort()

        per_core = (point["umc_all_gbs"] / total_threads) if point["umc_all_gbs"] else 0.0
        print("  t={:<3} (nodes {}, {:>4} mb/thr) umc {:>7.1f} GB/s ({:>5.2f} GB/s/thread) | "
              "prog {:>7.1f} GB/s".format(
                  total_threads, node_threads, point["per_thread_mb"],
                  point["umc_all_gbs"] or 0.0, per_core, point["prog_bw_gbs"] or 0.0))

        with open(OUTPUT_JSON, "w") as f:
            json.dump(results, f, indent=2)

    print("\nSaved {}".format(OUTPUT_JSON))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--series", nargs="+", default=["node_local", "system_local"],
                    choices=["node_local", "system_local"])
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--interval-ms", type=int, default=20)
    ap.add_argument("--inst", default=INST,
                    choices=["load", "avx512", "t0", "t1", "t2", "nta", "prefetchw"])
    args = ap.parse_args()

    if not os.path.exists(BIN_PATH):
        sys.exit("ERROR: {} missing -- run `make build/bandwidth_rand` in machine_stats/".format(BIN_PATH))

    for name in args.series:
        if name == "node_local":
            collect("node_local", NODE_LOCAL_THREADS, [0], args.reps, args.interval_ms, args.inst)
        else:
            collect("system_local", SYSTEM_LOCAL_THREADS, [0, 1, 2, 3], args.reps,
                    args.interval_ms, args.inst)


if __name__ == "__main__":
    main()
