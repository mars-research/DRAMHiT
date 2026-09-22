import argparse
import json
import os
import math
import re
import statistics
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
LOG_ROOT = SCRIPT_DIR / "logs"

L2_BYTES = 1 * 1024 * 1024  # 1mb per hyperthread

numa = 10

# How much of the machine a run gets. "single" is one socket: 64 threads on
# the cpus of numa node 0, with the join working set in node 0's hbm (node 2).
# "all" is the whole machine: 128 threads over both sockets, with every thread
# binding its own arena to the hbm node attached to its socket (node 0 cpus ->
# node 2, node 1 cpus -> node 3) via --np_mem_local, so no thread reaches
# across the interconnect for its partitions or its hashtable.
CPU_SCOPES = {
    "single": {
        "name": "intel_hbm_single",
        "num_threads": 64,
        "cpu_nodes": [0],
        "mem_nodes": [2],
        "np_cpu_node_msk": 1,
        "np_mem_node_msk": 4,
        "np_mem_local": 0,
    },
    "all": {
        "name": "intel_hbm_allcpu",
        "num_threads": 128,
        "cpu_nodes": [0, 1],
        "mem_nodes": [2, 3],
        "np_cpu_node_msk": 3,
        "np_mem_node_msk": 4,  # ignored, np_mem_local picks the local hbm node
        "np_mem_local": 1,
    },
}

# the goal here is reduce keep radix high enough to make each paritition size fit into l2
# while keep radix low enough parition runtime doesn't blow up because partition must maintin
# 2^radix amount of cachelines.
def get_optimal_radix(build_sz, ht_fill):
    # fit into l2.
    optimal_join_size = L2_BYTES * ht_fill / 100
    radix = max(6, math.ceil(math.log(build_sz * 16 / optimal_join_size, 2)))

    # if build size is too large, then give a warning for partition.
    if pow(2, radix) * 64 >= L2_BYTES:
        print(
            f"input size is too big, partition runtime will go up, build_sz {build_sz / (1024 * 1024)} MB radix {radix}"
        )

    return radix


one_mb = int(1024 * 1024 / 16)
one_gb = int(1024 * 1024 * 1024 / 16)
# =============================================================================
# CONFIGURATION
# =============================================================================

default_build_sz = one_gb

# Parameters (X-axis) that can be swept, selected via --param-name on the
# command line instead of commenting/uncommenting blocks.
PARAM_CONFIGS = {
    "skew": [round(0.1 + i * 0.1, 1) for i in range(12)],
    "relation_size": [
        # 512 * one_mb,
        1 * one_gb,
        2 * one_gb,
        4 * one_gb,
        8 * one_gb,
        16 * one_gb,
    ],
}

# Paths to the executables
# prefetch_control_hbm.sh, not prefetch_control.sh: on this part the latter's
# 0xf leaves a prefetcher enabled (bit 5 of MSR 0x1a4). It costs a sequential
# access pattern ~2 extra cache lines per operation while still reporting "all
# prefetchers off" -- and radix join's partition pass is exactly that pattern.
# See that script's header for the measurement.
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_hbm.sh"
RESERVE_HUGEPAGES_SCRIPT = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"

# Each cpu node needs a fixed pool of 2mb hugepages regardless of join type /
# relation size, to hold the r/s relation data its own threads generate (those
# allocations are unbound, so they land on the faulting thread's node).
CPU_NODE_2MB_RESERVE_MB = 35000

# 2mb pages on the mem (hbm) node, for dlht's secondary store when it is small
# enough that calloc_ht maps it with 2mb pages. Nothing else on the mem node
# wants them: the hash table itself is 1gb pages and radix asks for 2mb ones
# through its own branch below.
MEM_NODE_2MB_RESERVE_MB = 2048

# The mem (hbm) nodes hold the join working set: partition buckets and the
# per-thread hashtable. Element counts in relation_r_size/relation_s_size are
# in units of 16-byte tuples.
TUPLE_BYTES = 16

# Default arguments for Hash Join
HASH_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 7,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "find_queue": 64,
    "numa-split": numa,
    "no-prefetch": 0,
    "mode": 13,
    "batch-len": 16,  # per-variant override in HASH_JOIN_VARIANTS
    "skew": 0.01,
    "associativity": 1.0,
    "seed": 1774551337382868027,
}

# ht-type values, mirrored from include/types.hpp (ht_type_t).
# Only types actually wired up by the current build flags (see
# collect_join.py's cmake invocation: GROWT=ON, no PART_ID, no CLHT)
# are usable here -- see init_ht() in src/misc_lib.cpp.
HT_TYPES = {
    "cas": 3,  # CASHTPP
    "cas23": 8,  # CAS23HTPP
    "dlht": 10,  # DLHT_HT, needs 32 batch, needs low fill for build or increase link.....
    "folklore": 11,  # FOLKLORE_HT
}

# Per-hashtable overrides applied on top of HASH_JOIN_DEFAULTS. "prefetcher"
# is special-cased to select the *hardware* prefetcher state ("on"/"off") via
# set_prefetcher(), it is not passed to the dramhit binary. These are the
# defaults used unless overridden via --prefetcher/--batch-len on the CLI.
# Largest relation_size a hashtable can be swept to on this machine, in tuples.
# dlht keeps a secondary overflow store on top of its table, so at 16gb it wants
# more hbm than node 2 has; the sweep stops at 8gb for it instead of dying in
# the middle of a run.
MAX_RELATION_SIZE = {
    "dlht": 8 * one_gb,
}

HASH_JOIN_VARIANTS = {
    "cas": {"ht-type": HT_TYPES["cas"], "prefetcher": "off", "batch-len": 16},
    "cas23": {"ht-type": HT_TYPES["cas23"], "prefetcher": "off", "batch-len": 16},
    "dlht": {"ht-type": HT_TYPES["dlht"], "prefetcher": "on", "batch-len": 32},
    "folklore": {"ht-type": HT_TYPES["folklore"], "prefetcher": "on", "batch-len": 16},
}

# Default arguments for Radix Join
RADIX_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 50,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "numa-split": numa,
    "mode": 16,
    "skew": 0.01,
    "seed": 1774551337382868027,
    "radix": 10,
    "associativity": 1.0,
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


def set_prefetcher(state):
    """Turns the hardware prefetcher 'on' or 'off'.

    The msr write needs root and prefetch_control.sh deliberately does not
    sudo itself, so re-invoke it under sudo when we are not root -- carrying
    PATH across, since sudo's secure_path drops msr-tools.
    """
    print(f"[*] Setting prefetcher to: {state.upper()}")
    cmd = [PREFETCH_SCRIPT, state]
    if os.geteuid() != 0:
        cmd = ["sudo", "env", f"PATH={os.environ['PATH']}"] + cmd
    subprocess.run(cmd, check=True)


# HBM bandwidth per phase, counted at the controllers. Same recipe as
# macro_uniform/collect_data_intel_hbm.py: the 32 uncore_hbm boxes take raw CAS
# encodings (they publish no event list), a HBM CAS moves 32 B, and each perf
# row carries its own run_ns, so a rate is bytes * boxes * count / run_ns.
# Radix join's two phases are bracketed in the log by "Partition phase
# start/end" and "Join phase start/end".
# Both memories are counted, because a join run uses both: the partition
# buckets and the join hashtable are bound to the hbm node, but the r/s
# relations the partition pass READS are unbound and land in the cpu node's
# ddr. Counting only hbm would show the partition phase as almost pure writes
# and hide half its traffic. uncore_imc takes the same raw encodings as the hbm
# boxes; what differs is the CAS width, 64 B against 32 B.
BW_PMUS = {"hbm": {"prefix": "uncore_hbm", "bytes_per_cas": 32},
           "ddr": {"prefix": "uncore_imc", "bytes_per_cas": 64}}
BW_EVENT_ENCODINGS = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
BW_INTERVAL_MS = 10
# radix join's two phases and hash join's two. One list covers both: a run
# only ever prints one pair of pairs, so the phases that do not appear simply
# collect no intervals.
BW_PHASE_MARKS = [
    ("Partition phase start", "partition"),
    ("Partition phase end", None),
    ("Join phase start", "join"),
    ("Join phase end", None),
    ("Build phase start", "build"),
    ("Build phase end", None),
    ("Probe phase start", "probe"),
    ("Probe phase end", None),
]
BW_PHASES = ["partition", "join", "build", "probe"]


def bw_pmu_boxes(prefix):
    """Box indices of one uncore pmu, matched to the END of the name.

    A prefix match alone also catches uncore_imc_free_running_*, which shares
    the prefix and ends in a digit; every event on the overlapping boxes would
    then be requested twice and the reported bandwidth would be inflated
    without anything looking wrong.
    """
    pattern = re.compile(re.escape(prefix) + r"_(\d+)$")
    return sorted(int(m.group(1))
                  for m in (pattern.match(q.name)
                            for q in Path("/sys/devices").glob(f"{prefix}_*"))
                  if m)


def bw_perf_prefix():
    events = ",".join(
        f"{cfg['prefix']}_{i}/{enc},name={mem}_{n}/"
        for mem, cfg in BW_PMUS.items()
        for i in bw_pmu_boxes(cfg["prefix"])
        for n, enc in BW_EVENT_ENCODINGS.items())
    return ["sudo", "perf", "stat", "--per-socket", "-e", events,
            "-I", str(BW_INTERVAL_MS), "-x", ",", "--"]


def parse_bandwidth(text):
    """Per-phase memory bandwidth from one run's interleaved perf/dramhit output.

    Returns {"partition": {"hbm": {...}, "ddr": {...}}, "join": {...}} in GB/s,
    or {} when the run was not sampled. The first and last interval of a phase
    straddle a marker and mix it with whatever ran next to it, so both go.
    """
    phase = None
    acc = {}
    ts_phase = {}
    wanted = {f"{mem}_{n}" for mem in BW_PMUS for n in BW_EVENT_ENCODINGS}
    for line in text.splitlines():
        for mark, target in BW_PHASE_MARKS:
            if mark in line:
                phase = target
                break
        parts = line.strip().split(",")
        if len(parts) < 7 or not parts[0][:1].isdigit():
            continue
        if not parts[1].strip().startswith("S") or phase is None:
            continue
        try:
            ts, count, event, run_ns = (float(parts[0]), float(parts[3]),
                                        parts[5].strip(), float(parts[6]))
        except (ValueError, IndexError):
            continue
        if event not in wanted:
            continue
        ts_phase.setdefault(ts, phase)
        slot = acc.setdefault(ts, {}).setdefault(event, [0.0, 0.0, 0])
        slot[0] += count
        slot[1] += run_ns
        slot[2] += 1

    rows = {name: [] for name in BW_PHASES}
    for ts in sorted(acc):
        events = acc[ts]
        if not wanted <= set(events):
            continue
        rates = {}
        for mem, cfg in BW_PMUS.items():
            for n in BW_EVENT_ENCODINGS:
                count, run_ns, boxes = events[f"{mem}_{n}"]
                if run_ns <= 0:
                    rates = None
                    break
                # count * boxes * B / run_ns is bytes per ns, i.e. GB/s, once
                # run_ns is turned back into the per-box mean.
                rates[f"{mem}_{n}"] = cfg["bytes_per_cas"] * boxes * count / run_ns
            if rates is None:
                break
        if rates:
            rows[ts_phase[ts]].append(rates)

    out = {}
    for name, samples in rows.items():
        if len(samples) > 2:
            samples = samples[1:-1]
        if not samples:
            continue
        per_mem = {}
        for mem in BW_PMUS:
            rd = [s[f"{mem}_rd"] for s in samples]
            wr = [s[f"{mem}_wr"] for s in samples]
            per_mem[mem] = {
                "gbps": round(statistics.median(r + w for r, w in zip(rd, wr)), 1),
                "rd_gbps": round(statistics.median(rd), 1),
                "wr_gbps": round(statistics.median(wr), 1),
            }
        per_mem["intervals"] = len(samples)
        per_mem["total_gbps"] = round(
            sum(per_mem[m]["gbps"] for m in BW_PMUS), 1)
        out[name] = per_mem
    return out


def next_pow2(n):
    """Same rounding the hashtables apply to their capacity."""
    p = 1
    while p < n:
        p <<= 1
    return p


def node_total_bytes(node):
    """Physical memory on a numa node, from its meminfo."""
    with open(f"/sys/devices/system/node/node{node}/meminfo") as f:
        for line in f:
            if "MemTotal" in line:
                return int(line.split()[-2]) * 1024
    raise RuntimeError(f"no MemTotal for node {node}")


def hash_table_bytes(r_size, ht_fill):
    """What the hash join's table itself occupies on the mem node.

    Mirrors hashjoin() in src/tests/hashjoin_test.cpp: the table is sized
    relation_r_size * 100 / ht_fill slots, rounded up to a power of two by the
    hashtable constructor, at 16 bytes per slot.
    """
    return next_pow2(r_size * 100 // ht_fill) * TUPLE_BYTES


def radix_arena_bytes(r_size, s_size, ht_fill, num_threads):
    """What radix join's per-thread arenas occupy on the mem node, summed.

    Mirrors estimate_bytes_needed in radixjoin2016(), including the per-thread
    rounding up to whole 2mb pages, which at high radix is not negligible.
    """
    partition_num = 1 << get_optimal_radix(r_size, ht_fill)
    per_thread = (
        64 * partition_num          # software write buffers
        + 8 * partition_num * 2     # histograms
        + 8 * partition_num * 2     # bucket pointers
        + 2 * 1024 * 1024           # the extra 2mb page it reserves
        + (r_size * 2 * 100 * TUPLE_BYTES) // (partition_num * ht_fill)  # its table
        + ((r_size + s_size) // num_threads) * TUPLE_BYTES  # the partitioned copy
    )
    two_mb = 2 * 1024 * 1024
    return ((per_thread + two_mb - 1) // two_mb + 1) * two_mb * num_threads


def relation_arena_bytes(r_size, s_size, num_threads, threads_per_cpu_node):
    """What the r/s relations occupy on one cpu node.

    Mirrors join_relations_generated(): each thread maps its own arena for its
    slice of R and S, rounded up to whole hugepages, and those allocations carry
    no numa binding, so they land on the node of the thread that faults them.
    """
    per_thread = ((r_size + s_size) // num_threads) * TUPLE_BYTES
    one_gb = 1024 ** 3
    two_mb = 2 * 1024 * 1024
    if per_thread < one_gb and per_thread > 409 * two_mb:
        per_thread_pages = one_gb          # the code rounds >80% of 1gb up to 1gb
    elif per_thread < one_gb:
        per_thread_pages = (per_thread // two_mb + 1) * two_mb
    else:
        gb = per_thread // one_gb
        per_thread_pages = gb * one_gb + ((per_thread - gb * one_gb) // two_mb + 1) * two_mb
    return per_thread_pages * threads_per_cpu_node


def max_build_probe_bytes(defaults_dict, param_name, param_values):
    """Max (r_size + s_size), in bytes, across every value in the sweep."""
    max_bytes = 0
    for val in param_values:
        r_size = defaults_dict["relation_r_size"]
        s_size = defaults_dict["relation_s_size"]
        if param_name == "relation_size":
            r_size = val
            s_size = val
        max_bytes = max(max_bytes, (r_size + s_size) * TUPLE_BYTES)
    return max_bytes


def ht_fill_for(defaults_dict, param_name, param_value):
    """The ht_fill build_command() will end up passing, for sizing purposes."""
    if defaults_dict["mode"] != 13:
        return defaults_dict["ht-fill"]
    r = param_value if param_name == "relation_size" else defaults_dict["relation_r_size"]
    s = param_value if param_name == "relation_size" else defaults_dict["relation_s_size"]
    return math.ceil((r * 100) / (r + s))


def reserve_hugepages(join_type, defaults_dict, param_name, param_values, scope,
                      hashtable=None):
    """Resets hugepages and reserves enough for the whole sweep up-front.

    Every cpu node gets a fixed 2mb-page budget for everything besides the join
    working set -- chiefly the r/s relations its own threads generate. The hbm
    nodes hold that working set: radix join needs it in 2mb pages, sized to at
    least 2x build+probe (double buffering during partitioning). Hash join is
    given the same total budget, for a fair comparison, but as 1gb pages --
    hence the reset, since an hbm node's hugepages have to be re-reserved at a
    different page size between runs.

    With more than one cpu node in the scope the threads (and so the working
    set) are split evenly over the hbm nodes, so each hbm node only has to
    cover its share.

    dlht additionally needs secondary-storage overflow space on top of its
    regular table: about 1/8 of the table's 1gb-page footprint, as extra 1gb
    pages (e.g. a 16gb table needs 2 extra 1gb pages).
    """
    mem_nodes = scope["mem_nodes"]
    required_bytes = 2 * max_build_probe_bytes(defaults_dict, param_name, param_values)
    per_mem_node_bytes = math.ceil(required_bytes / len(mem_nodes))

    # That 2x is deliberate slack, and it is affordable while the working set is
    # a fraction of the node. At the top of the sweep it is not: 16gb relations
    # ask for 64gb per hbm node, which is the whole node. So cap the request at
    # what the node can plausibly hand out, and separately compute what the run
    # actually allocates so the cap can never drop below it.
    needed_bytes = max(
        hash_table_bytes(v if param_name == "relation_size"
                         else defaults_dict["relation_r_size"], ht_fill_for(defaults_dict, param_name, v))
        if join_type == "hash" else
        radix_arena_bytes(v if param_name == "relation_size" else defaults_dict["relation_r_size"],
                          v if param_name == "relation_size" else defaults_dict["relation_s_size"],
                          defaults_dict["ht-fill"], scope["num_threads"])
        for v in param_values
    )
    if hashtable == "dlht":
        needed_bytes += needed_bytes // 8  # secondary overflow store

    cap_bytes = int(0.85 * min(node_total_bytes(n) for n in mem_nodes))
    if needed_bytes > cap_bytes:
        raise RuntimeError(
            f"{join_type} needs {needed_bytes / (1024 ** 3):.1f} gb per mem node "
            f"but node capacity caps usable hugepages at {cap_bytes / (1024 ** 3):.1f} gb"
        )
    per_mem_node_bytes = max(min(per_mem_node_bytes, cap_bytes),
                             math.ceil(needed_bytes * 1.1))
    print(f"[*] mem node budget: {per_mem_node_bytes / (1024 ** 3):.1f} gb "
          f"(run allocates ~{needed_bytes / (1024 ** 3):.1f} gb)")

    print("[*] Resetting hugepages before reservation...")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, "reset"], check=True)

    # Same story on the cpu nodes: the fixed budget is ample for small
    # relations and too tight at 16gb, so take whichever is larger.
    threads_per_cpu_node = math.ceil(scope["num_threads"] / len(scope["cpu_nodes"]))
    relations_bytes = max(
        relation_arena_bytes(
            v if param_name == "relation_size" else defaults_dict["relation_r_size"],
            v if param_name == "relation_size" else defaults_dict["relation_s_size"],
            scope["num_threads"], threads_per_cpu_node)
        for v in param_values
    )
    cpu_node_mb = max(CPU_NODE_2MB_RESERVE_MB,
                      math.ceil(relations_bytes * 1.15 / (1024 ** 2)))
    print(f"[*] cpu node budget: {cpu_node_mb / 1024:.1f} gb "
          f"(relations need ~{relations_bytes / (1024 ** 3):.1f} gb)")

    args = [f"n{n}_0gb_{cpu_node_mb}mb" for n in scope["cpu_nodes"]]
    for n in mem_nodes:
        if join_type == "hash":
            required_gb = math.ceil(per_mem_node_bytes / (1024 ** 3))
            mem_node_2mb = 0
            if hashtable == "dlht":
                extra_gb = math.ceil(required_gb / 8)
                print(f"[*] dlht secondary storage: +{extra_gb}gb on top of the {required_gb}gb table")
                required_gb += extra_gb
                # The secondary store is a separate allocation, and calloc_ht
                # picks its page size by size alone: over 1gb it takes 1gb
                # pages, at or under it takes 2mb ones. At the small end of
                # this sweep the store IS under 1gb (512mb at r=1gb), so the
                # mem node needs a 2mb pool as well or the mmap succeeds, the
                # mbind succeeds, and the run then dies faulting it in -- with
                # no error beyond a truncated log.
                mem_node_2mb = MEM_NODE_2MB_RESERVE_MB
            args.append(f"n{n}_{required_gb}gb_{mem_node_2mb}mb")
        else:
            required_mb = math.ceil(per_mem_node_bytes / (1024 ** 2))
            args.append(f"n{n}_0gb_{required_mb}mb")

    print(f"[*] Reserving hugepages: {' '.join(args)}")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, *args], check=True)


def build_command(defaults_dict, param_name, param_value, scope, overrides=None):
    """Builds the command list dynamically based on defaults + varied parameter.

    `overrides` (e.g. a HASH_JOIN_VARIANTS entry, minus the "prefetcher" key)
    are applied on top of defaults_dict, before the swept param_name/param_value.
    `scope` supplies the thread count and the cpu/memory placement.
    """
    args = defaults_dict.copy()
    args.update({
        "num-threads": scope["num_threads"],
        "np_cpu_node_msk": scope["np_cpu_node_msk"],
        "np_mem_node_msk": scope["np_mem_node_msk"],
        "np_mem_local": scope["np_mem_local"],
    })
    if overrides:
        args.update(overrides)

    if param_name == "relation_size":
        args["relation_r_size"] = param_value
        args["relation_s_size"] = param_value
    else:
        args[param_name] = param_value  # Override the specific parameter being tested

    if args["mode"] == 13:
        # hash join can use same space as used by radix join
        build_sz = args["relation_r_size"]
        probe_sz = args["relation_s_size"]
        ht_fill = math.ceil((build_sz * 100) / (build_sz + probe_sz)) # on skew, this is 7% to get a 16gb table.

        if args["ht-type"] == 10 and param_name == "relation_size": # dlht can only holds up to 30%
            ht_fill = 30

        args["ht-fill"] = ht_fill
    else:
        args["radix"] = get_optimal_radix(args["relation_r_size"], args["ht-fill"])

    cmd = [DRAMHIT_EXEC]

    for key, val in args.items():
        cmd.extend([f"--{key}", str(val)])
    return cmd


def run_and_parse(cmd, log_path, with_bw=False):
    """Runs the benchmark command, saves its full stdout/stderr to log_path,
    and extracts throughput_mops."""
    if with_bw:
        cmd = bw_perf_prefix() + cmd
    print(f"    Running: {' '.join(cmd[:3])} ... {' '.join(cmd[-6:])}"
          if with_bw else f"    Running: {' '.join(cmd)}")
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )

    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(result.stdout)
    print(f"    -> log saved to {log_path}")

    # Regex to find "throughput_mops : <number>" (handles optional spaces)
    match = re.search(r"throughput_mops\s*:\s*([0-9.]+)", result.stdout)
    if match:
        throughput = float(match.group(1))
        print(f"    -> throughput_mops: {throughput}")
        return throughput
    else:
        print("    -> ERROR: Could not find throughput_mops in output! See log for details.")
        return 0.0


def phase_metrics(log_path):
    """Per-phase cycles/op from one run's log, when the mode reports them.

    Hash join prints build/probe, radix join prints partition/join; either way
    the two numbers say which half of the join moved, which a single throughput
    figure cannot.
    """
    if not log_path.exists():
        return {}

    text = log_path.read_text()
    build = re.search(r"build_phrase_mops\s*:\s*\d+,\s*cycle_per_op\s*:\s*(\d+)", text)
    probe = re.search(r"probe_phrase_mops\s*:\s*\d+,\s*cycle_per_op\s*:\s*(\d+)", text)
    if build and probe:
        return {"build_cyc_per_op": int(build.group(1)),
                "probe_cyc_per_op": int(probe.group(1))}

    part = re.search(r"partition_cycle_per_tuple:\s*(\d+)", text)
    join = re.search(r"join_cycle_per_tuple:\s*(\d+)", text)
    if part and join:
        return {"partition_cyc_per_tuple": int(part.group(1)),
                "join_cyc_per_tuple": int(join.group(1))}
    return {}


def check_memory_locality(log_path):
    """Summarises where the radix join's per-thread arenas actually landed.

    dramhit checks each thread's hashtable after the arena is faulted in and
    logs the node it ended up on, so a run that quietly fell back to remote
    memory shows up here instead of only as a slow number.
    """
    if not log_path.exists():
        return

    text = log_path.read_text()
    local = re.findall(r"hashtable local: .* on numa node (\d+)", text)
    remote = re.findall(r"hashtable NOT local: .*", text)

    if not local and not remote:
        return

    per_node = {}
    for node in local:
        per_node[node] = per_node.get(node, 0) + 1
    placement = ", ".join(f"{cnt} threads on node {n}" for n, cnt in sorted(per_node.items()))
    print(f"    -> hashtable placement: {placement}")
    if remote:
        print(f"    -> WARNING: {len(remote)} thread(s) got a NON-LOCAL hashtable!")
        for line in remote[:4]:
            print(f"       {line.strip()}")


# =============================================================================
# MAIN EXECUTION
# =============================================================================


def main(args):
    param_name = args.param_name
    param_values = PARAM_CONFIGS[param_name]
    scope = CPU_SCOPES[args.cpu_scope]
    numa_name = scope["name"]

    if param_name == "skew" and args.skews:
        missing = [k for k in args.skews if k not in param_values]
        if missing:
            raise SystemExit(f"skews not in the sweep: {missing}")
        param_values = list(args.skews)
        print(f"[*] skews to run: {param_values}")

    if param_name == "relation_size":
        if args.relation_sizes_gib:
            wanted = [g * one_gb for g in args.relation_sizes_gib]
            missing = [g for g, v in zip(args.relation_sizes_gib, wanted)
                       if v not in param_values]
            if missing:
                raise SystemExit(f"relation sizes not in the sweep: {missing} gb")
            param_values = wanted
        cap = MAX_RELATION_SIZE.get(args.hashtable)
        if cap is not None and any(v > cap for v in param_values):
            dropped = [v * TUPLE_BYTES // (1024 ** 3) for v in param_values if v > cap]
            print(f"[*] {args.hashtable} capped at {cap * TUPLE_BYTES // (1024 ** 3)}gb, "
                  f"skipping {dropped} gb")
            param_values = [v for v in param_values if v <= cap]
        print(f"[*] relation sizes to run: "
              f"{[v * TUPLE_BYTES // (1024 ** 3) for v in param_values]} gb")

    if args.join_type == "hash":
        variant_cfg = dict(HASH_JOIN_VARIANTS[args.hashtable])
        if args.prefetcher is not None:
            variant_cfg["prefetcher"] = args.prefetcher
        if args.batch_len is not None:
            variant_cfg["batch-len"] = args.batch_len
        run_label = f"hash_{args.hashtable}"
        hugepage_defaults = HASH_JOIN_DEFAULTS
    else:
        run_label = "radix"
        hugepage_defaults = RADIX_JOIN_DEFAULTS

    print(f"Starting Benchmark. Join type: {run_label}. Varying '--{param_name}' across: {param_values}\n")

    log_dir = LOG_ROOT / f"{numa_name}_{run_label}_{param_name}"
    print(f"[*] dramhit run logs will be saved under {log_dir}")

    reserve_hugepages(
        args.join_type,
        hugepage_defaults,
        param_name,
        param_values,
        scope,
        hashtable=args.hashtable if args.join_type == "hash" else None,
    )

    # Build from scratch: a stale CMakeCache in build/ silently keeps whatever
    # options a previous run configured (and can even break the build), which
    # is not something a benchmark number should depend on.
    print("[*] Removing /opt/DRAMHiT/build for a clean configure")
    subprocess.run("rm -rf /opt/DRAMHiT/build", shell=True, check=True)

    # PREFETCH picks how the table paths prefetch. DOUBLE issues a second
    # prefetch when an entry is dequeued on top of the one issued when it was
    # queued; the single-prefetch settings (L1/L2/...) keep only the first,
    # NONE drops software prefetching from the read path entirely.
    cmake_cmd = (
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON "
        "-DGROWT=ON -DCPUFREQ_MHZ=2700 "
        f"-DPREFETCH={args.prefetch} "
        f"-DCAS_PREFETCH_INSERTION={args.cas_prefetch_insertion}"
    )
    print(f"[*] {cmake_cmd}")
    subprocess.run(cmake_cmd, shell=True, check=True)
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    results = {
        "param_name": param_name,
        "param_values": param_values,
        "join_type": run_label,
        "cpu_scope": args.cpu_scope,
        "num_threads": scope["num_threads"],
        "cpu_nodes": scope["cpu_nodes"],
        "mem_nodes": scope["mem_nodes"],
        "np_mem_local": scope["np_mem_local"],
        "prefetch": args.prefetch,
        "prefetch_script": PREFETCH_SCRIPT,
        "hw_prefetcher": (variant_cfg.get("prefetcher", "off")
                          if args.join_type == "hash" else (args.prefetcher or "on")),
        "cas_prefetch_insertion": args.cas_prefetch_insertion,
        "repeats": args.repeats,
        "log_dir": str(log_dir),
        # throughput_mops is the per-point median so a single-repeat run reads
        # the same as it always did; the raw samples sit alongside it, in the
        # same shape collect_join/run_join.py writes them.
        "throughput_mops": [],
        "throughput_samples": [],
        "phase_samples": [],
    }

    for val in param_values:
        print(f"=== Testing {param_name} = {val} ===")

        if args.join_type == "hash":
            print(f"  -- hash join variant: {args.hashtable} --")
            overrides = {k: v for k, v in variant_cfg.items() if k != "prefetcher"}
            set_prefetcher(variant_cfg.get("prefetcher", "off"))
            cmd = build_command(HASH_JOIN_DEFAULTS, param_name, val, scope, overrides)
        else:
            print("  -- radix join --")
            set_prefetcher(args.prefetcher or "on")
            cmd = build_command(RADIX_JOIN_DEFAULTS, param_name, val, scope)

        # Repeats matter here: at some points this workload varies by far more
        # than the difference a curve is meant to show, so a single sample can
        # be misread as a real effect. The median is what gets plotted, and the
        # samples are kept so the spread stays visible.
        samples = []
        phases = []
        for rep in range(1, args.repeats + 1):
            suffix = "" if args.repeats == 1 else f"_rep{rep}"
            log_path = log_dir / f"{param_name}_{val}{suffix}.log"
            perf = run_and_parse(cmd, log_path, args.bandwidth)
            check_memory_locality(log_path)
            if perf > 0:
                samples.append(perf)
                metrics = phase_metrics(log_path)
                if args.bandwidth:
                    bw = parse_bandwidth(log_path.read_text())
                    if bw:
                        metrics["bw"] = bw
                        print("    -> bw: " + " | ".join(
                            f"{k} hbm {v['hbm']['gbps']:.0f}"
                            f" (r{v['hbm']['rd_gbps']:.0f}/w{v['hbm']['wr_gbps']:.0f})"
                            f" ddr {v['ddr']['gbps']:.0f}"
                            f" (r{v['ddr']['rd_gbps']:.0f}/w{v['ddr']['wr_gbps']:.0f})"
                            for k, v in bw.items()))
                    else:
                        print("    -> [!] no bandwidth intervals parsed")
                phases.append(metrics)

        if not samples:
            print("    => all repeats failed, recording 0")
            results["throughput_mops"].append(0.0)
        else:
            median = statistics.median(samples)
            results["throughput_mops"].append(median)
            if len(samples) > 1:
                spread = (max(samples) - min(samples)) / median
                print(f"    => median {median:.0f} mops over {len(samples)} runs "
                      f"{[f'{x:.0f}' for x in samples]}, spread {spread:.1%}")
        results["throughput_samples"].append(samples)
        results["phase_samples"].append(phases)

        print("\n")

    # =========================================================================
    # SAVE DATA TO JSON
    # =========================================================================
    json_filename = f"{numa_name}_{run_label}_{param_name}{args.out_suffix}.json"
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"[*] Data saved to {json_filename}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Collect throughput for a single hash-join hashtable or radix join, sweeping a parameter."
    )
    parser.add_argument(
        "--join-type",
        choices=["hash", "radix"],
        required=True,
        help="Which join to run: a single hash-join hashtable, or radix join.",
    )
    parser.add_argument(
        "--hashtable",
        choices=sorted(HASH_JOIN_VARIANTS.keys()),
        help="Which hashtable to use for --join-type hash (required in that case).",
    )
    parser.add_argument(
        "--prefetch",
        choices=["DOUBLE", "L1", "L2", "L3", "NTA", "NONE"],
        default="DOUBLE",
        help="Build with -DPREFETCH=<choice> (default: DOUBLE). Drives the cas "
             "find path, and the insert path too unless --cas-prefetch-insertion "
             "overrides it.",
    )
    parser.add_argument(
        "--skews",
        type=float,
        nargs="+",
        default=None,
        help="Run only these skews out of the skew sweep, e.g. --skews 0.1 1.0 "
             "to spot-check a stored curve. Pair with --out-suffix.",
    )
    parser.add_argument(
        "--relation-sizes-gib",
        type=int,
        nargs="+",
        default=None,
        help="Run only these relation sizes (in gib) out of the relation_size "
             "sweep, e.g. --relation-sizes-gib 8 16 to add a point without "
             "re-collecting the whole curve. Pair with --out-suffix so the "
             "partial result does not overwrite the full one.",
    )
    parser.add_argument(
        "--repeats",
        type=int,
        default=1,
        help="Run each point this many times and plot the median (default: 1). "
             "The raw samples are stored in throughput_samples, which the "
             "plotters draw as a min/max band.",
    )
    parser.add_argument(
        "--out-suffix",
        default="",
        help="Suffix for the output json name, e.g. '_new' to keep a partial "
             "sweep separate from the collected curve.",
    )
    parser.add_argument(
        "--cas-prefetch-insertion",
        choices=["AUTO", "DOUBLE", "PREFETCHW", "NONE"],
        default="AUTO",
        help="Build with -DCAS_PREFETCH_INSERTION=<choice>: tunes the cas "
             "insert path on its own. DOUBLE = prefetcht1 at queue time plus "
             "prefetchw at dequeue, PREFETCHW = one prefetchw, NONE = no "
             "prefetch. AUTO (default) follows --prefetch.",
    )
    parser.add_argument(
        "--cpu-scope",
        choices=sorted(CPU_SCOPES.keys()),
        default="single",
        help="How much of the machine to use: 'single' = 64 threads on node 0 "
             "with the working set in node 2's hbm (default), 'all' = 128 "
             "threads over both sockets, each binding its arena to its own "
             "socket's hbm node.",
    )
    parser.add_argument(
        "--param-name",
        choices=sorted(PARAM_CONFIGS.keys()),
        default="skew",
        help="Which parameter to sweep on the x-axis (default: skew).",
    )
    parser.add_argument(
        "--bandwidth",
        action="store_true",
        help="Sample hbm bandwidth at the controllers while each run is in "
             "flight (perf stat -I over the 32 uncore_hbm boxes) and record "
             "it per phase, the way macro_uniform's collector does. Needs the "
             "phase markers dramhit logs around partition and join.",
    )
    parser.add_argument(
        "--prefetcher",
        choices=["on", "off"],
        default=None,
        help="Override the hardware prefetcher state (default: the "
             "hashtable's configured value in HASH_JOIN_VARIANTS for "
             "--join-type hash, 'on' for --join-type radix).",
    )
    parser.add_argument(
        "--batch-len",
        type=int,
        default=None,
        help="Override --batch-len for --join-type hash "
             "(default: the hashtable's configured value in HASH_JOIN_VARIANTS).",
    )
    args = parser.parse_args()

    if args.join_type == "hash" and not args.hashtable:
        parser.error("--hashtable is required when --join-type hash")
    if args.join_type == "radix" and (args.hashtable or args.batch_len is not None):
        parser.error("--hashtable/--batch-len only apply to --join-type hash")
    if args.join_type == "hash" and args.cpu_scope != "single":
        # Hash join shares one table across all threads, so "every thread in
        # its own hbm node" has no meaning for it; it would need its own
        # placement story (and hugepage budget) before it could be swept here.
        parser.error("--cpu-scope all is only wired up for --join-type radix")

    return args


if __name__ == "__main__":
    main(parse_args())
