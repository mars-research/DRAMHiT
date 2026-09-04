"""Collect join throughput on the 2-socket Xeon Gold 6548Y+ box.

Adapted from ../intel_hbm/run_single_join.py. Differences that matter here:

  * this machine has no HBM node -- it is 2 sockets of plain DDR (2 numa
    nodes, 64 cpus / 128 GB each), so the numa_split=10 (THREADS_CUSTOM)
    cpu/mem node masks the hbm script used are gone.
  * cpu runs at 2.5 GHz, so CPUFREQ_MHZ=2500.
  * two numa configurations are selectable with --numa-config:
      single -> numa-split 4 (THREADS_LOCAL_NUMA_NODE): all 64 threads on
                node 0, global hashtable mbind()ed to node 0 (local memory).
      dual   -> numa-split 1 (THREADS_SPLIT_SEPARATE_NODES): 128 threads
                split evenly over both nodes, global hashtable
                MPOL_INTERLEAVE'd so it is spread evenly over both nodes.
    numa-split only steers the *global* hashtable and the thread pinning.
    Radix join builds its own per-thread HugepageArena and never binds it
    (see radixjoin2016(): the mem_bind() there is gated on numa_split==10),
    so radix memory just follows first touch -- i.e. node 0 for single, and
    evenly over both nodes for dual, purely because of where threads run.
  * hugepage reservation is computed from the actual allocations dramhit
    makes rather than from a single hand-tuned number, and is split over
    the nodes the chosen numa config actually runs on. The reservation is
    verified against the kernel afterwards, and the whole footprint is
    checked against per-node MemTotal before anything runs.
"""

import argparse
import json
import math
import re
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
# One directory per experiment set, i.e. per (numa config, swept param)
# pair: "single_relation_size", "dual_skew", ... Each holds the per-join
# json plus a logs/ tree of the raw dramhit output.

L2_BYTES = 1 * 1024 * 1024  # 2mb per core, 2 hyperthreads per core

MACHINE = "intel"

# numa-split values, from numa_policy_threads in include/numa.hpp.
#   THREADS_SPLIT_SEPARATE_NODES = 1 -> threads split evenly over all nodes,
#                                       global ht interleaved over all nodes.
#   THREADS_LOCAL_NUMA_NODE      = 4 -> threads all on node 0, global ht
#                                       bound to node 0.
NUMA_CONFIGS = {
    "single": {"numa-split": 4, "num-threads": 64, "nodes": [0]},
    "dual": {"numa-split": 1, "num-threads": 128, "nodes": [0, 1]},
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
        256 * one_mb,
        512 * one_mb,
        1 * one_gb,
        2 * one_gb,
        4 * one_gb,
        8 * one_gb,
        # 16 * one_gb,  # ~80gb on one node in the single config -- check --dry-run first
    ],
}

# Paths to the executables
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"
RESERVE_HUGEPAGES_SCRIPT = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"
DATASET_CACHE_DIR = Path("/opt/DRAMHiT/cache")

CPUFREQ_MHZ = 2500

# Element / KVType are both {uint64 key, uint64 value}.
TUPLE_BYTES = 16
KV_BYTES = 16

ONE_GB_PAGE = 1 << 30
TWO_MB_PAGE = 1 << 21

# sizeof(CacheLineBuffer): Element tuples[4] (64B) + uint64 counter, alignas(64).
CACHELINE_BUFFER_BYTES = 128

# Slack on top of the computed reservation, per node. Covers the bucket
# alignment/round-to-4 padding preallocate_phase() burns that
# radixjoin2016()'s own estimate does not account for, plus odd
# huge_page_allocator users.
HUGEPAGE_SLACK_FRAC = 0.05
HUGEPAGE_SLACK_2MB_PAGES = 64

# Leave this fraction of a node's MemTotal alone: hugetlb reservations come
# straight out of it, and the g_zipf_values vector (8 bytes per tuple of
# r+s) plus the OS still need ordinary pages.
NODE_MEM_HEADROOM_FRAC = 0.15

# Default arguments for Hash Join. num-threads/numa-split are filled in from
# the selected --numa-config.
HASH_JOIN_DEFAULTS = {
    "ht-type": 3,
    "ht-fill": 7,
    "relation_r_size": default_build_sz,
    "relation_s_size": 15 * default_build_sz,
    "find_queue": 64,
    "no-prefetch": 0,
    "mode": 13,
    "batch-len": 16,  # per-variant override in HASH_JOIN_VARIANTS
    "skew": 0.01,
    "associativity": 1.0,
    "seed": 1774551337382868027,
}

# ht-type values, mirrored from include/types.hpp (ht_type_t).
# Only types actually wired up by the current build flags (GROWT=ON, no
# PART_ID, no CLHT) are usable here -- see init_ht() in src/misc_lib.cpp.
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
    """Turns the hardware prefetcher 'on' or 'off'."""
    print(f"[*] Setting prefetcher to: {state.upper()}")
    subprocess.run([PREFETCH_SCRIPT, state], check=True)


def next_pow2(x):
    """utils::next_pow2()."""
    return 1 if x <= 1 else 1 << (x - 1).bit_length()


def gb(nbytes):
    return nbytes / (1024 ** 3)


# =============================================================================
# HUGEPAGE ACCOUNTING
#
# Every function below mirrors an allocation dramhit actually performs, so
# the reservation matches the mmap()s the run will issue instead of being a
# guess. Page counts are (num 1gb pages, num 2mb pages).
# =============================================================================


def per_thread_split(total, num_threads):
    """join_relations_generated(): even split, remainder onto the last shard."""
    sizes = [total // num_threads] * num_threads
    sizes[-1] += total % num_threads
    return sizes


def arena_pages(estimate_bytes, relation_arena):
    """HugepageArena page counts, as computed by the callers in hashjoin_test.cpp."""
    one_gb_needed = estimate_bytes // ONE_GB_PAGE
    if estimate_bytes < ONE_GB_PAGE:
        two_mb_needed = estimate_bytes // TWO_MB_PAGE + 1
    else:
        two_mb_needed = (estimate_bytes - one_gb_needed * ONE_GB_PAGE) // TWO_MB_PAGE

    # only join_relations_generated() rounds a nearly-full 1gb arena up
    if (
        relation_arena
        and estimate_bytes < ONE_GB_PAGE
        and estimate_bytes > 409 * TWO_MB_PAGE
    ):
        one_gb_needed, two_mb_needed = 1, 0

    return one_gb_needed, two_mb_needed


def calloc_ht_pages(nbytes):
    """calloc_ht(): round_hugepage() then pick the page size off the result."""
    if nbytes < ONE_GB_PAGE:
        alloc_sz = ((nbytes - 1) // TWO_MB_PAGE + 1) * TWO_MB_PAGE
    else:
        alloc_sz = ((nbytes - 1) // ONE_GB_PAGE + 1) * ONE_GB_PAGE

    if alloc_sz <= ONE_GB_PAGE:
        return 0, alloc_sz // TWO_MB_PAGE
    return alloc_sz // ONE_GB_PAGE, 0


def run_hugepages(args, join_type, hashtable):
    """Total hugepages one dramhit invocation will fault in.

    args is the fully resolved argument dict (post build_command overrides),
    so ht-fill / radix / num-threads are already the values the binary sees.
    """
    num_threads = args["num-threads"]
    r_size = args["relation_r_size"]
    s_size = args["relation_s_size"]

    r_parts = per_thread_split(r_size, num_threads)
    s_parts = per_thread_split(s_size, num_threads)

    one_gb = two_mb = 0

    # 1. per-thread relation arena, holding this shard's slice of r and s.
    for tid in range(num_threads):
        a, b = arena_pages(
            TUPLE_BYTES * (r_parts[tid] + s_parts[tid]), relation_arena=True
        )
        one_gb += a
        two_mb += b

    if join_type == "hash":
        # 2. the one global hashtable, hashjoin() -> init_ht() -> calloc_ht().
        capacity = next_pow2(r_size * 100 // args["ht-fill"])
        a, b = calloc_ht_pages(capacity * KV_BYTES)
        one_gb += a
        two_mb += b

        # dlht additionally allocates a link table of capacity>>3 entries.
        if hashtable == "dlht":
            a, b = calloc_ht_pages((capacity >> 3) * KV_BYTES)
            one_gb += a
            two_mb += b
    else:
        # 2. per-thread radix arena, live at the same time as the relation
        #    arena above. Mirrors estimate_bytes_needed in radixjoin2016().
        partition_num = 1 << args["radix"]
        est_join_ht = (r_size * 2 * 100 * TUPLE_BYTES) // (
            partition_num * args["ht-fill"]
        )
        fixed = (
            CACHELINE_BUFFER_BYTES * partition_num  # swbs
            + 8 * partition_num * 2  # histograms
            + 8 * partition_num * 2  # bucket pointers
            + TWO_MB_PAGE  # the explicit extra 2mb
            + est_join_ht  # per-partition join hashtable
        )
        for tid in range(num_threads):
            est = fixed + TUPLE_BYTES * (r_parts[tid] + s_parts[tid])
            a, b = arena_pages(est, relation_arena=False)
            one_gb += a
            two_mb += b

    return one_gb, two_mb


def ordinary_memory_bytes(args):
    """g_zipf_values: one std::vector<uint64_t> of r+s keys, ordinary pages."""
    return 8 * (args["relation_r_size"] + args["relation_s_size"])


def node_mem_total_bytes(node):
    text = Path(f"/sys/devices/system/node/node{node}/meminfo").read_text()
    match = re.search(r"MemTotal:\s+(\d+)\s+kB", text)
    if not match:
        raise RuntimeError(f"could not read MemTotal for node {node}")
    return int(match.group(1)) * 1024


def node_hugepages(node):
    base = Path(f"/sys/devices/system/node/node{node}/hugepages")
    one_gb = int((base / "hugepages-1048576kB" / "nr_hugepages").read_text())
    two_mb = int((base / "hugepages-2048kB" / "nr_hugepages").read_text())
    return one_gb, two_mb


def plan_hugepages(commands, numa_cfg, join_type, hashtable):
    """Per-node (1gb, 2mb) page counts covering every command in the sweep.

    The reservation has to satisfy the largest point of the sweep, so take
    the max over all of them, then spread it over the nodes this numa config
    actually touches:

      single -- every thread and the global ht sit on node 0, so node 0 has
                to hold the whole footprint.
      dual   -- threads are split evenly over both nodes and the global ht
                is interleaved, so each node holds about half. Round up so
                neither node comes up short.
    """
    worst_one_gb = worst_two_mb = 0
    worst_ordinary = 0
    for args in commands:
        one_gb, two_mb = run_hugepages(args, join_type, hashtable)
        if one_gb * ONE_GB_PAGE + two_mb * TWO_MB_PAGE > (
            worst_one_gb * ONE_GB_PAGE + worst_two_mb * TWO_MB_PAGE
        ):
            worst_one_gb, worst_two_mb = one_gb, two_mb
        worst_ordinary = max(worst_ordinary, ordinary_memory_bytes(args))

    nodes = numa_cfg["nodes"]
    per_node_one_gb = math.ceil(worst_one_gb / len(nodes))
    per_node_two_mb = math.ceil(worst_two_mb / len(nodes))

    # slack, plus one spare 1gb page so a lone rounded-up allocation cannot
    # tip a node over.
    per_node_two_mb = (
        math.ceil(per_node_two_mb * (1 + HUGEPAGE_SLACK_FRAC))
        + HUGEPAGE_SLACK_2MB_PAGES
    )
    if per_node_one_gb:
        per_node_one_gb += 1

    return {n: (per_node_one_gb, per_node_two_mb) for n in nodes}, worst_ordinary


def check_memory_fits(plan, ordinary_bytes, numa_cfg):
    """Abort before touching the machine if the plan cannot physically fit.

    g_zipf_values is allocated by the main thread before any pinning
    happens, so charge it to every node in the plan rather than guessing
    which one it lands on.
    """
    ok = True
    print("[*] memory budget:")
    for node, (one_gb, two_mb) in sorted(plan.items()):
        huge = one_gb * ONE_GB_PAGE + two_mb * TWO_MB_PAGE
        total = node_mem_total_bytes(node)
        budget = total * (1 - NODE_MEM_HEADROOM_FRAC)
        need = huge + ordinary_bytes
        status = "ok" if need <= budget else "OVER"
        print(
            f"      node{node}: {one_gb} x 1gb + {two_mb} x 2mb = {gb(huge):.1f} gb hugepages"
            f" + {gb(ordinary_bytes):.1f} gb ordinary = {gb(need):.1f} gb"
            f" / {gb(budget):.1f} gb usable of {gb(total):.1f} gb  [{status}]"
        )
        if need > budget:
            ok = False

    if not ok:
        raise SystemExit(
            "[!] this sweep does not fit in memory on the "
            f"'{'/'.join(str(n) for n in numa_cfg['nodes'])}' node(s). "
            "Shrink PARAM_CONFIGS, or use --numa-config dual to spread over both sockets."
        )


def reserve_hugepages(plan):
    """Reset the pools, reserve the plan, and verify the kernel honoured it."""
    print("[*] Resetting hugepages before reservation...")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, "reset"], check=True)

    reserve_args = []
    for node, (one_gb, two_mb) in sorted(plan.items()):
        # reserve_hugepages.sh takes 2mb pages as a total megabyte count
        reserve_args.append(f"n{node}_{one_gb}gb_{two_mb * 2}mb")

    print(f"[*] Reserving hugepages: {' '.join(reserve_args)}")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, *reserve_args], check=True)

    short = []
    for node, (want_one_gb, want_two_mb) in sorted(plan.items()):
        got_one_gb, got_two_mb = node_hugepages(node)
        print(
            f"      node{node}: got {got_one_gb}/{want_one_gb} 1gb pages, "
            f"{got_two_mb}/{want_two_mb} 2mb pages"
        )
        if got_one_gb < want_one_gb or got_two_mb < want_two_mb:
            short.append(node)

    if short:
        raise SystemExit(
            f"[!] kernel could not reserve the requested hugepages on node(s) {short} "
            "(likely fragmentation). Free memory / reboot and retry."
        )


# =============================================================================
# COMMAND CONSTRUCTION
# =============================================================================


def build_args(defaults_dict, numa_cfg, param_name, param_value, overrides=None):
    """Resolves the full argument dict for one run.

    `overrides` (e.g. a HASH_JOIN_VARIANTS entry, minus the "prefetcher" key)
    are applied on top of defaults_dict, before the swept param_name/param_value.
    """
    args = defaults_dict.copy()
    args["num-threads"] = numa_cfg["num-threads"]
    args["numa-split"] = numa_cfg["numa-split"]
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

    return args


def to_command(args):
    cmd = [DRAMHIT_EXEC]
    for key, val in args.items():
        cmd.extend([f"--{key}", str(val)])
    return cmd


def run_and_parse(cmd, log_path):
    """Runs the benchmark command, saves its full stdout/stderr to log_path,
    and extracts throughput_mops."""
    print(f"    Running: {' '.join(cmd)}")
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


# =============================================================================
# MAIN EXECUTION
# =============================================================================


def main(args):
    param_name = args.param_name
    param_values = PARAM_CONFIGS[param_name]
    numa_cfg = NUMA_CONFIGS[args.numa_config]

    if args.join_type == "hash":
        variant_cfg = dict(HASH_JOIN_VARIANTS[args.hashtable])
        if args.prefetcher is not None:
            variant_cfg["prefetcher"] = args.prefetcher
        if args.batch_len is not None:
            variant_cfg["batch-len"] = args.batch_len
        overrides = {k: v for k, v in variant_cfg.items() if k != "prefetcher"}
        defaults = HASH_JOIN_DEFAULTS
        run_label = f"hash_{args.hashtable}"
    else:
        variant_cfg = {"prefetcher": "on"}
        overrides = None
        defaults = RADIX_JOIN_DEFAULTS
        run_label = "radix"

    resolved = [
        build_args(defaults, numa_cfg, param_name, val, overrides)
        for val in param_values
    ]

    print(
        f"Starting Benchmark. Join type: {run_label}. "
        f"numa config: {args.numa_config} "
        f"(numa-split {numa_cfg['numa-split']}, {numa_cfg['num-threads']} threads, "
        f"nodes {numa_cfg['nodes']}). "
        f"Varying '--{param_name}' across: {param_values}\n"
    )

    result_dir = SCRIPT_DIR / f"{args.numa_config}_{param_name}"
    log_dir = result_dir / "logs" / run_label
    print(f"[*] dramhit run logs will be saved under {log_dir}")

    plan, ordinary_bytes = plan_hugepages(
        resolved,
        numa_cfg,
        args.join_type,
        args.hashtable if args.join_type == "hash" else None,
    )
    check_memory_fits(plan, ordinary_bytes, numa_cfg)

    if args.dry_run:
        for cfg_args in resolved:
            print(f"    {' '.join(to_command(cfg_args))}")
        print("[*] --dry-run: stopping before reserving hugepages / building.")
        return

    reserve_hugepages(plan)

    # init_hashjoin_dist() caches generated datasets here and silently warns
    # if the directory is missing.
    DATASET_CACHE_DIR.mkdir(parents=True, exist_ok=True)

    subprocess.run(
        "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
        "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON "
        f"-DGROWT=ON -DCPUFREQ_MHZ={CPUFREQ_MHZ}",
        shell=True,
        check=True,
    )
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)

    results = {
        "param_name": param_name,
        "param_values": param_values,
        "join_type": run_label,
        "numa_config": args.numa_config,
        "numa_split": numa_cfg["numa-split"],
        "num_threads": numa_cfg["num-threads"],
        "cpufreq_mhz": CPUFREQ_MHZ,
        "log_dir": str(log_dir),
        "throughput_mops": [],
    }

    for val, cfg_args in zip(param_values, resolved):
        print(f"=== Testing {param_name} = {val} ===")

        if args.join_type == "hash":
            print(f"  -- hash join variant: {args.hashtable} --")
        else:
            print("  -- radix join --")
        set_prefetcher(variant_cfg.get("prefetcher", "off"))

        log_path = log_dir / f"{param_name}_{val}.log"
        perf = run_and_parse(to_command(cfg_args), log_path)
        results["throughput_mops"].append(perf)

        print("\n")

    # =========================================================================
    # SAVE DATA TO JSON
    # =========================================================================
    result_dir.mkdir(parents=True, exist_ok=True)
    json_filename = result_dir / f"{MACHINE}_{args.numa_config}_{run_label}_{param_name}.json"
    with open(json_filename, "w") as f:
        json.dump(results, f, indent=4)
    print(f"[*] Data saved to {json_filename}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Collect throughput for a single hash-join hashtable or radix join, "
                    "sweeping a parameter, on one of the two numa configurations."
    )
    parser.add_argument(
        "--join-type",
        choices=["hash", "radix"],
        required=True,
        help="Which join to run: a single hash-join hashtable, or radix join.",
    )
    parser.add_argument(
        "--numa-config",
        choices=sorted(NUMA_CONFIGS.keys()),
        required=True,
        help="single: 64 threads on node 0, numa-split 4 (local memory). "
             "dual: 128 threads over both nodes, numa-split 1 (global hashtable "
             "spread evenly over both nodes).",
    )
    parser.add_argument(
        "--hashtable",
        choices=sorted(HASH_JOIN_VARIANTS.keys()),
        help="Which hashtable to use for --join-type hash (required in that case).",
    )
    parser.add_argument(
        "--param-name",
        choices=sorted(PARAM_CONFIGS.keys()),
        default="skew",
        help="Which parameter to sweep on the x-axis (default: skew).",
    )
    parser.add_argument(
        "--prefetcher",
        choices=["on", "off"],
        default=None,
        help="Override the hardware prefetcher state for --join-type hash "
             "(default: the hashtable's configured value in HASH_JOIN_VARIANTS).",
    )
    parser.add_argument(
        "--batch-len",
        type=int,
        default=None,
        help="Override --batch-len for --join-type hash "
             "(default: the hashtable's configured value in HASH_JOIN_VARIANTS).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the memory budget and the dramhit command lines, then exit "
             "without reserving hugepages, rebuilding or running anything.",
    )
    args = parser.parse_args()

    if args.join_type == "hash" and not args.hashtable:
        parser.error("--hashtable is required when --join-type hash")
    if args.join_type == "radix" and (args.hashtable or args.prefetcher or args.batch_len is not None):
        parser.error("--hashtable/--prefetcher/--batch-len only apply to --join-type hash")

    return args


if __name__ == "__main__":
    main(parse_args())
