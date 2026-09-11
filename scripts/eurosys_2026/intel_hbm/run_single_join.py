import argparse
import json
import math
import re
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
    ],
}

# Paths to the executables
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control.sh"
RESERVE_HUGEPAGES_SCRIPT = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
DRAMHIT_EXEC = "/opt/DRAMHiT/build/dramhit"

# Each cpu node needs a fixed pool of 2mb hugepages regardless of join type /
# relation size, to hold the r/s relation data its own threads generate (those
# allocations are unbound, so they land on the faulting thread's node).
CPU_NODE_2MB_RESERVE_MB = 35000

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
    """Turns the hardware prefetcher 'on' or 'off'."""
    print(f"[*] Setting prefetcher to: {state.upper()}")
    subprocess.run([PREFETCH_SCRIPT, state], check=True)


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

    print("[*] Resetting hugepages before reservation...")
    subprocess.run([RESERVE_HUGEPAGES_SCRIPT, "reset"], check=True)

    args = [f"n{n}_0gb_{CPU_NODE_2MB_RESERVE_MB}mb" for n in scope["cpu_nodes"]]
    for n in mem_nodes:
        if join_type == "hash":
            required_gb = math.ceil(per_mem_node_bytes / (1024 ** 3))
            if hashtable == "dlht":
                extra_gb = math.ceil(required_gb / 8)
                print(f"[*] dlht secondary storage: +{extra_gb}gb on top of the {required_gb}gb table")
                required_gb += extra_gb
            args.append(f"n{n}_{required_gb}gb_0mb")
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
        "cas_prefetch_insertion": args.cas_prefetch_insertion,
        "log_dir": str(log_dir),
        "throughput_mops": [],
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
            set_prefetcher("on")
            cmd = build_command(RADIX_JOIN_DEFAULTS, param_name, val, scope)

        log_path = log_dir / f"{param_name}_{val}.log"
        perf = run_and_parse(cmd, log_path)
        results["throughput_mops"].append(perf)
        check_memory_locality(log_path)

        print("\n")

    # =========================================================================
    # SAVE DATA TO JSON
    # =========================================================================
    json_filename = f"{numa_name}_{run_label}_{param_name}.json"
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
    args = parser.parse_args()

    if args.join_type == "hash" and not args.hashtable:
        parser.error("--hashtable is required when --join-type hash")
    if args.join_type == "radix" and (args.hashtable or args.prefetcher or args.batch_len is not None):
        parser.error("--hashtable/--prefetcher/--batch-len only apply to --join-type hash")
    if args.join_type == "hash" and args.cpu_scope != "single":
        # Hash join shares one table across all threads, so "every thread in
        # its own hbm node" has no meaning for it; it would need its own
        # placement story (and hugepage budget) before it could be swept here.
        parser.error("--cpu-scope all is only wired up for --join-type radix")

    return args


if __name__ == "__main__":
    main(parse_args())
