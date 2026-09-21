#!/usr/bin/env python3
'''
Core-count sweep against one HBM node: does each added core buy a fixed slice of
bandwidth, or does the socket hit a shared ceiling first?

Every run here is `machine_stats/bandwidth.c` (random access, prefetcht1,
lookahead 64) with CPUs pinned to node 0 and memory bound to node 2 -- socket
0's own HBM, so nothing crosses UPI and the only thing changing across the sweep
is how many cores are pulling. Pattern "n0a2tN": N threads on node 0, memory on
node 2.

bandwidth.c reports its own GB/s from the bytes it asked for. That number cannot
tell a core limit from a fabric limit, so every run is also measured at the HBM
controllers with the same uncore PMUs
`collect_dual_socket_upi/run_intel_hbm_bandwidth.py` established:

    - the HBM boxes carry no event list (perf enumerates them off the uncore
      discovery table), so CAS is raw event 0x05, umask 0xcf (rd) / 0xf0 (wr),
      and clockticks is event 0x01;
    - there are 32 uncore_hbm_* boxes per socket and perf does NOT merge them,
      so each event returns 32 rows per socket that have to be summed;
    - an HBM CAS moves 32 B, not 64.

The sweep also runs a DDR control (node 0 -> node 0) on the same cores, to see
whether a different memory system behind the same fabric bends in the same
place. DDR is counted at uncore_imc instead, which takes the very same raw
encodings -- uncore_imc_0/events/cas_count_read *is* event=0x05,umask=0xcf --
but at 64 B per CAS, per that PMU's own cas_count_read.scale.

Time base: each perf row carries its own run_ns (how long that box's counter was
actually running), so a rate is sum(count) * boxes / sum(run_ns), not
count / wall_clock. That matters at both ends of this sweep -- the interval the
counters are enabled in is stretched, and at 1 thread the run is short enough
for that interval to be a large fraction of it. Deriving the time from the HBM
clock instead (what the UPI script does) would need a frequency calibrated at
one load and reused at every other, and whether HBM DCLK moves with load is one
of the things this sweep is measuring, so it is reported per point rather than
assumed.

Thread N is pinned to the Nth cpu of node 0 in ascending cpu order. On this
machine node 0 is cpus 0,2,...,62 then 64,66,...,126, and 64 is the SMT sibling
of 0 -- so points 1..32 are one thread per physical core and 33..64 add the
second thread on an already-busy core. Where the curve flattens relative to that
boundary is the finding.

Needs sudo (uncore PMUs) and 2 MB hugepages on the nodes under test:
scripts/setup_hbm.sh reserves them, MAP_HUGETLB fails without them and the
workers then hang on their barrier instead of exiting.
'''
import argparse
import glob
import json
import os
import re
import statistics
import subprocess
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
BIN_PATH = os.path.join(HERE, "..", "machine_stats", "build", "bandwidth_rand")
BIN_PATH = os.path.normpath(BIN_PATH)

OUTPUT_JSON = os.path.join(HERE, "intel_hbm_cpu_scaling.json")
LOG_DIR = os.path.join(HERE, "logs", "cpu_scaling")

# Footprint. bandwidth.c takes a per-thread size, but a per-thread size held
# constant across a core sweep is not a constant experiment: at 1 thread the
# 128mb the other collectors use sits inside this socket's 75mb L3 + 2mb L2, so
# a third of the accesses never reach HBM. Measured: 1 thread reports 13.95
# GB/s over 128mb, 12.73 over 512mb, 12.15 over 2gb. So aim at a fixed 16gb of
# total footprint instead, split across the threads, and cap the per-thread
# chunk at 2gb so the 1- and 2-thread runs do not take minutes (bandwidth.c
# always makes 100 passes over whatever it is given). Every point then has at
# least 2gb live, i.e. the cache is under 4% of it, and most have 16gb.
TOTAL_FOOTPRINT_BYTES = 16 * 1024 ** 3
MAX_PER_THREAD_BYTES = 2 * 1024 ** 3
MIN_PER_THREAD_BYTES = 256 * 1024 ** 2

CPU_FREQ_GHZ = "2.7"
LOOKAHEAD = "64"
INST = "t1"

# 1..32 is one thread per physical core on node 0; 33..64 are SMT siblings.
DEFAULT_THREADS = [1, 2, 4, 6, 8, 12, 16, 20, 24, 28, 32, 40, 48, 56, 64]
DEFAULT_REPS = 3

# The memory PMU that serves each node. Both take the same raw encodings -- the
# HBM boxes only accept raw ones (no events/ directory), and uncore_imc, which
# does publish names, spells cas_count_read as exactly the same
# event=0x05,umask=0xcf. What differs is the CAS width: uncore_imc's own
# cas_count_read.scale is 6.103515625e-5 MiB, i.e. 64 B per count, against 32 B
# on HBM.
MEM_PMUS = {
    "hbm": {"prefix": "uncore_hbm", "bytes_per_cas": 32},
    "imc": {"prefix": "uncore_imc", "bytes_per_cas": 64},
}

EVENT_ENCODINGS = {
    "rd": "event=0x05,umask=0xcf",
    "wr": "event=0x05,umask=0xf0",
    "clk": "event=0x01,umask=0x00",
}

# cpu node -> memory node, and the read/write mode. hbm_* is the experiment;
# ddr_read is the control: same cores, same mesh, a different memory system
# behind it. If both flatten at the same place the ceiling is not in the memory.
SERIES = {
    "hbm_read":  {"cpu_node": 0, "mem_node": 2, "mode": "r", "pmu": "hbm"},
    "hbm_write": {"cpu_node": 0, "mem_node": 2, "mode": "w", "pmu": "hbm"},
    "ddr_read":  {"cpu_node": 0, "mem_node": 0, "mode": "r", "pmu": "imc"},
}


def pmu_boxes(pmu):
    """Instances of one uncore PMU, by index.

    The name has to match to the end: uncore_imc_free_running_0 is a different
    PMU that shares the uncore_imc prefix *and* ends in a digit, so matching a
    trailing number alone returns 0-7 plus a second 0-3, and every event on
    boxes 0-3 is then requested twice. That is not visible as an error -- perf
    counts them twice, and the box count used to convert rows into a rate is
    12 instead of 8, which reports DDR at exactly 2x its real bandwidth.
    """
    prefix = MEM_PMUS[pmu]["prefix"]
    pattern = re.compile(re.escape(prefix) + r"_(\d+)$")
    return sorted(
        int(m.group(1))
        for m in (pattern.match(os.path.basename(p))
                  for p in glob.glob("/sys/devices/{}_*".format(prefix)))
        if m
    )

PROG_BW_RE = re.compile(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s")
PROG_CPA_RE = re.compile(r"node\s+\d+\s*:\s*([\d.]+)\s*cycles/access")
PROG_TIME_RE = re.compile(r"Time Taken\s*:\s*([\d.]+)\s*seconds")


def per_thread_bytes(threads):
    """Per-thread chunk for this point, as a power of two (bandwidth.c rounds
    down to one anyway, so choose it here and report the real footprint)."""
    target = min(MAX_PER_THREAD_BYTES, TOTAL_FOOTPRINT_BYTES // threads)
    size = MIN_PER_THREAD_BYTES
    while size * 2 <= target:
        size *= 2
    return size


def perf_event_string(pmu):
    prefix = MEM_PMUS[pmu]["prefix"]
    return ",".join(
        "{p}_{i}/{enc},name=mem_{n}/".format(p=prefix, i=i, enc=EVENT_ENCODINGS[n], n=n)
        for i in pmu_boxes(pmu)
        for n in EVENT_ENCODINGS
    )


def run_one(series_name, cfg, threads, rep, interval_ms, inst=INST):
    cfg_pattern = "n{c}a{m}t{t}".format(c=cfg["cpu_node"], m=cfg["mem_node"], t=threads)
    chunk_mb = per_thread_bytes(threads) // (1024 ** 2)
    cmd = [
        "sudo", "perf", "stat", "--per-socket",
        "-e", perf_event_string(cfg["pmu"]),
        "-I", str(interval_ms), "-x", ",",
        "--",
        BIN_PATH,
        "-m", "{}mb".format(chunk_mb),
        "-pattern", cfg_pattern,
        "-freq", CPU_FREQ_GHZ,
        "-inst", inst,
        "-lookahead", LOOKAHEAD,
        "-mode", cfg["mode"],
    ]

    log_path = os.path.join(LOG_DIR, "{}_t{}_r{}.log".format(series_name, threads, rep))
    with open(log_path, "w") as log:
        subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT, text=True).check_returncode()
    return log_path


def parse_log(log_path, bytes_per_cas):
    '''Per-interval memory rates from one run's merged perf+program output.

    Only the rows between the program's own markers count: outside them the
    threads are still allocating and first-touching their chunks, which is real
    memory traffic that has nothing to do with the measured loop.
    '''
    in_window = False
    # ts -> socket -> event -> [summed count, summed run_ns, rows]
    acc = defaultdict(lambda: defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0])))
    prog = {}

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
            m = PROG_CPA_RE.search(line)
            if m:
                prog["cycles_per_access"] = float(m.group(1))
            m = PROG_TIME_RE.search(line)
            if m:
                prog["elapsed_s"] = float(m.group(1))

            if not in_window:
                continue

            parts = line.split(",")
            if len(parts) < 7 or not parts[0][:1].isdigit():
                continue
            if "<not counted>" in parts[3] or "<not supported>" in parts[3]:
                continue
            socket = parts[1].strip()
            if not socket.startswith("S"):
                continue
            try:
                ts = float(parts[0])
                count = float(parts[3])
                event = parts[5].strip()
                run_ns = float(parts[6])
            except ValueError:
                continue

            slot = acc[ts][socket][event]
            slot[0] += count
            slot[1] += run_ns
            slot[2] += 1

    # count * B_per_cas / (run_ns * 1e-9 s) / 1e9 == count * B_per_cas / run_ns,
    # in GB/s, once run_ns is the per-box mean (sum_run_ns / boxes).
    per_socket = defaultdict(lambda: defaultdict(list))
    timestamps = sorted(acc.keys())
    # The first and last interval inside the markers are partial -- the loop
    # starts and ends somewhere inside them -- so they understate the rate.
    for ts in timestamps[1:-1] if len(timestamps) > 2 else timestamps:
        for socket, events in acc[ts].items():
            if not {"mem_rd", "mem_wr", "mem_clk"} <= set(events):
                continue
            rates = {}
            for key in ("rd", "wr"):
                count, run_ns, boxes = events["mem_" + key]
                if run_ns <= 0:
                    break
                rates[key] = bytes_per_cas * boxes * count / run_ns
            else:
                clk_count, clk_run_ns, _ = events["mem_clk"]
                per_socket[socket]["rd"].append(rates["rd"])
                per_socket[socket]["wr"].append(rates["wr"])
                per_socket[socket]["all"].append(rates["rd"] + rates["wr"])
                if clk_run_ns > 0:
                    per_socket[socket]["dclk_ghz"].append(clk_count / clk_run_ns)

    summary = {"prog": prog, "sockets": {}, "intervals": 0}
    for socket, series in per_socket.items():
        summary["sockets"][socket] = {
            k: {
                "median": statistics.median(v),
                "max": max(v),
                "min": min(v),
                "n": len(v),
            }
            for k, v in series.items() if v
        }
        summary["intervals"] = max(summary["intervals"], len(series.get("rd", [])))
    return summary


def collect(series_names, threads_list, reps, interval_ms, inst=INST):
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
        "inst": INST,
        "lookahead": LOOKAHEAD,
        "cpu_freq_ghz": CPU_FREQ_GHZ,
        "pmus": {
            pmu: {"boxes_per_socket": len(pmu_boxes(pmu)),
                  "bytes_per_cas": MEM_PMUS[pmu]["bytes_per_cas"]}
            for pmu in MEM_PMUS
        },
        "reps": reps,
        "interval_ms": interval_ms,
        "note": "threads 1-32 are one per physical core on node 0; 33-64 are SMT siblings",
    })

    for name in series_names:
        cfg = SERIES[name]
        # A non-default access instruction gets its own series key, so an
        # instruction comparison lands beside the main sweep rather than
        # silently overwriting points collected with a different one.
        key = name if inst == INST else "{}_{}".format(name, inst)
        row = results.setdefault(key, {"config": cfg, "threads": [], "points": {}})
        # Per-series, because a later --inst or --threads run with a different
        # --reps would otherwise silently redefine what the top-level config
        # says about points collected earlier.
        row["config"] = dict(cfg, inst=inst, reps=reps)
        bytes_per_cas = MEM_PMUS[cfg["pmu"]]["bytes_per_cas"]
        print("\n=== {} (cpu node {} -> mem node {}, mode {}, {} PMU, inst {}) ===".format(
            key, cfg["cpu_node"], cfg["mem_node"], cfg["mode"], cfg["pmu"], inst))

        for threads in threads_list:
            runs = []
            for rep in range(reps):
                log_path = run_one(key, cfg, threads, rep, interval_ms, inst)
                runs.append(parse_log(log_path, bytes_per_cas))

            s0 = [r["sockets"].get("S0", {}) for r in runs]
            s1 = [r["sockets"].get("S1", {}) for r in runs]

            def med(samples, key, field="median"):
                vals = [s[key][field] for s in samples if key in s]
                return statistics.median(vals) if vals else None

            def spread(samples, key):
                vals = [s[key]["median"] for s in samples if key in s]
                return (min(vals), max(vals)) if vals else (None, None)

            prog_bw = [r["prog"].get("prog_bw_gbs") for r in runs]
            prog_bw = [v for v in prog_bw if v is not None]
            cpa = [r["prog"].get("cycles_per_access") for r in runs]
            cpa = [v for v in cpa if v is not None]

            lo, hi = spread(s0, "all")
            point = {
                "threads": threads,
                "per_thread_mb": per_thread_bytes(threads) // (1024 ** 2),
                "total_footprint_gb": threads * per_thread_bytes(threads) / 1024 ** 3,
                "mem_all_gbs": med(s0, "all"),
                "mem_all_lo": lo,
                "mem_all_hi": hi,
                "mem_all_peak_gbs": med(s0, "all", field="max"),
                "mem_rd_gbs": med(s0, "rd"),
                "mem_wr_gbs": med(s0, "wr"),
                "mem_dclk_ghz": med(s0, "dclk_ghz"),
                "far_socket_all_gbs": med(s1, "all"),
                "prog_bw_gbs": statistics.median(prog_bw) if prog_bw else None,
                "prog_bw_samples": prog_bw,
                "cycles_per_access": statistics.median(cpa) if cpa else None,
                "mem_all_samples": [s["all"]["median"] for s in s0 if "all" in s],
                "intervals_per_run": [r["intervals"] for r in runs],
            }
            row["points"][str(threads)] = point
            if threads not in row["threads"]:
                row["threads"].append(threads)
            row["threads"].sort()

            per_core = (point["mem_all_gbs"] / threads) if point["mem_all_gbs"] else 0.0
            print("  t={:<3} ({:>4} mb/thr) mem {:>7.1f} GB/s ({:>5.2f} GB/s/thread) | "
                  "peak {:>7.1f} | prog {:>7.1f} | cpa {:>6.1f} cyc | clk {:.3f} GHz".format(
                      threads,
                      point["per_thread_mb"],
                      point["mem_all_gbs"] or 0.0,
                      per_core,
                      point["mem_all_peak_gbs"] or 0.0,
                      point["prog_bw_gbs"] or 0.0,
                      point["cycles_per_access"] or 0.0,
                      point["mem_dclk_ghz"] or 0.0))

            with open(OUTPUT_JSON, "w") as f:
                json.dump(results, f, indent=2)

    print("\nSaved {}".format(OUTPUT_JSON))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--series", nargs="+", default=list(SERIES),
                    choices=list(SERIES))
    ap.add_argument("--threads", nargs="+", type=int, default=DEFAULT_THREADS)
    ap.add_argument("--reps", type=int, default=DEFAULT_REPS)
    ap.add_argument("--interval-ms", type=int, default=20)
    # Access instruction. t1 is the default because it is the fastest on this
    # machine (machine_spec_analysis.md section 3: at 64 threads t1/t2 342,
    # t0 298, plain load 267 GB/s). A non-default one is stored under its own
    # series key so it sits beside the main sweep instead of overwriting it.
    ap.add_argument("--inst", default=INST,
                    choices=["load", "avx512", "t0", "t1", "t2", "nta", "prefetchw"])
    args = ap.parse_args()

    if not pmu_boxes("hbm"):
        sys.exit("ERROR: no uncore_hbm_* PMUs; this needs a Xeon Max in flat mode")
    if not os.path.exists(BIN_PATH):
        sys.exit("ERROR: {} missing -- run `make` in machine_stats/".format(BIN_PATH))

    collect(args.series, args.threads, args.reps, args.interval_ms, args.inst)


if __name__ == "__main__":
    main()
