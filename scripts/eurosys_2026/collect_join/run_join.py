"""Collect join throughput on any machine, driven by a machine spec json.

    python3 run_join.py amd-9354p.json --dry-run
    python3 run_join.py amd-9354p.json --run n4_cas
    python3 run_join.py amd-9354p.json                # every run x every sweep

The spec lists runs whose dramhit argument strings are *self-describing*:
each carries its own --mode / --ht-type / --numa-split (and, for numa-split
10, --np_cpu_node_msk / --np_mem_node_msk). Nothing about placement is
configured twice -- this script reads those args back and derives from them
which numa nodes each allocation lands on and therefore how many hugepages
to reserve where. That is what makes one script cover the 2-socket Xeon, the
NPS4 EPYC and the HBM box, whose numa stories have nothing in common.

Placement, mirrored from the source:

  per-thread relation arena  join_relations_generated() builds a
  (every mode)               HugepageArena and never binds it, so its pages
                             land wherever the owning thread first touches
                             them -> the *cpu* nodes.

  global hashtable           calloc_ht() -> distribute_mem_to_nodes(numa_split)
  (mode 13)                  in ht_helper.hpp: split 3 -> node 1, split 4/5 ->
                             node 0, split 6 -> chunked over all nodes, split
                             10 -> np_mem_node_msk (MPOL_BIND for one bit,
                             MPOL_INTERLEAVE for several), anything else ->
                             interleaved over all nodes.

  per-thread radix arena     radixjoin2016() calls arena.mem_bind(
  (mode 16/17)               np_mem_node_msk) *only* when numa_split == 10;
                             otherwise it too follows first touch. So a split
                             10 radix run with a multi-bit mask interleaves
                             its partitions instead of keeping them
                             thread-local -- a different experiment from the
                             same sweep under split 1 or 4.

Page sizes come from the same source: calloc_ht() round_hugepage()s and then
takes 1gb pages iff the result exceeds 1gb, else 2mb, while the arenas
compute their own 1gb + 2mb mix. The two pools are not interchangeable,
hence the full reset before every reservation.
"""

import argparse
import json
import math
import re
import shlex
import statistics
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

# --- mirrored from include/types.hpp -----------------------------------------
MODE_HASHJOIN = 13
MODE_PARTITIONJOIN_V1 = 16
MODE_PARTITIONJOIN_V2 = 17
RADIX_MODES = (MODE_PARTITIONJOIN_V1, MODE_PARTITIONJOIN_V2)
HT_DLHT = 10

# --- numa_policy_threads, mirrored from include/numa.hpp ----------------------
THREADS_SPLIT_SEPARATE_NODES = 1
THREADS_ASSIGN_SEQUENTIAL = 2
THREADS_REMOTE_NUMA_NODE = 3
THREADS_LOCAL_NUMA_NODE = 4
THREADS_NO_MEM_DISTRIBUTION = 5
THREADS_SPLIT_EVEN_NODES = 6
THREADS_ALL_NODES_REMOTE_ACCESS = 7
THREADS_ALL_NODES_LOCAL_ACCESS = 8
THREADS_MIXED_NUMA_NODE = 9
THREADS_CUSTOM = 10

# generate_cpu_list()'s three families
NODE0_ONLY_SPLITS = (
    THREADS_REMOTE_NUMA_NODE,
    THREADS_LOCAL_NUMA_NODE,
    THREADS_MIXED_NUMA_NODE,
)
EVEN_SPLIT_SPLITS = (
    THREADS_SPLIT_SEPARATE_NODES,
    THREADS_NO_MEM_DISTRIBUTION,
    THREADS_SPLIT_EVEN_NODES,
    THREADS_ALL_NODES_LOCAL_ACCESS,
    THREADS_ALL_NODES_REMOTE_ACCESS,
)

# Element / KVType are both {uint64 key, uint64 value}.
TUPLE_BYTES = 16
KV_BYTES = 16

ONE_GB_PAGE = 1 << 30
TWO_MB_PAGE = 1 << 21

# sizeof(CacheLineBuffer): Element tuples[4] (64B) + uint64 counter, alignas(64).
CACHELINE_BUFFER_BYTES = 128

# Slack on top of the computed reservation, per node. Covers the bucket
# alignment / round-to-4 padding preallocate_phase() burns that
# radixjoin2016()'s own estimate does not account for, plus odd
# huge_page_allocator users.
HUGEPAGE_SLACK_FRAC = 0.05
HUGEPAGE_SLACK_2MB_PAGES = 64


# =============================================================================
# SPEC
# =============================================================================


def strip_comments(obj):
    """Drop '_'-prefixed keys -- json has no comments, the specs use those."""
    if isinstance(obj, dict):
        return {k: strip_comments(v) for k, v in obj.items() if not k.startswith("_")}
    if isinstance(obj, list):
        return [strip_comments(v) for v in obj]
    return obj


def load_spec(path):
    spec = strip_comments(json.loads(Path(path).read_text()))
    for key in ("machine", "data_dir", "cpufreq_mhz", "runs", "params"):
        if key not in spec:
            raise SystemExit(f"[!] {path}: spec is missing required key '{key}'")
    return spec


def scalar(text):
    """Argument values arrive as strings; keep numbers numeric for the math."""
    try:
        return int(text)
    except ValueError:
        pass
    try:
        return float(text)
    except ValueError:
        return text


def parse_arg_string(text):
    """'--mode 13 --ht-type 3' -> {'mode': 13, 'ht-type': 3}."""
    tokens = shlex.split(text or "")
    args = {}
    i = 0
    while i < len(tokens):
        token = tokens[i]
        if not token.startswith("--"):
            raise SystemExit(f"[!] expected an option, got '{token}' in: {text}")
        if i + 1 >= len(tokens) or tokens[i + 1].startswith("--"):
            raise SystemExit(f"[!] option '{token}' has no value in: {text}")
        args[token[2:]] = scalar(tokens[i + 1])
        i += 2
    return args


def run_params(spec, run):
    """Global sweeps, overridden per run. An empty list means 'skip'."""
    params = dict(spec["params"])
    params.update(run.get("params", {}))
    return {name: values for name, values in params.items() if values}


# =============================================================================
# TOPOLOGY  (read from the live machine, never from the spec)
# =============================================================================


def parse_cpulist(text):
    cpus = []
    for piece in text.strip().split(","):
        if not piece:
            continue
        if "-" in piece:
            lo, hi = piece.split("-")
            cpus.extend(range(int(lo), int(hi) + 1))
        else:
            cpus.append(int(piece))
    return cpus


def read_topology():
    nodes = {}
    for node_dir in sorted(Path("/sys/devices/system/node").glob("node[0-9]*")):
        node = int(node_dir.name[4:])
        meminfo = (node_dir / "meminfo").read_text()
        match = re.search(r"MemTotal:\s+(\d+)\s+kB", meminfo)
        if not match:
            raise RuntimeError(f"could not read MemTotal for node {node}")
        nodes[node] = {
            "cpus": parse_cpulist((node_dir / "cpulist").read_text()),
            "mem_total": int(match.group(1)) * 1024,
        }
    if not nodes:
        raise RuntimeError("no numa nodes found under /sys/devices/system/node")
    return nodes


def mask_nodes(mask, topo):
    return [n for n in sorted(topo) if mask >> n & 1]


# =============================================================================
# PLACEMENT
# =============================================================================


def assign_threads(args, topo):
    """Which node each thread lands on, mirroring generate_cpu_list().

    Returns {node: number of threads pinned there}. Raises with a readable
    message where the binary itself would just exit(-1).
    """
    split = args.get("numa-split")
    num_threads = args.get("num-threads")
    if split is None or num_threads is None:
        raise SystemExit("[!] a run's args must set --numa-split and --num-threads")

    node_ids = sorted(topo)
    per_node = {}

    def take(node, count):
        per_node[node] = per_node.get(node, 0) + count

    if split == THREADS_CUSTOM:
        mask = args.get("np_cpu_node_msk", 0)
        selected = mask_nodes(mask, topo)
        if not selected:
            raise SystemExit(
                f"[!] --np_cpu_node_msk 0x{mask:x} selects no node on this machine "
                f"(nodes present: {node_ids})"
            )
        available = sum(len(topo[n]["cpus"]) for n in selected)
        if num_threads > available:
            raise SystemExit(
                f"[!] --num-threads {num_threads} exceeds the {available} cpus on "
                f"nodes {selected} (--np_cpu_node_msk 0x{mask:x})"
            )
        # fills each selected node completely before moving to the next
        left = num_threads
        for node in selected:
            here = min(left, len(topo[node]["cpus"]))
            if here:
                take(node, here)
            left -= here

    elif split in NODE0_ONLY_SPLITS:
        node = node_ids[0]
        if num_threads > len(topo[node]["cpus"]):
            raise SystemExit(
                f"[!] --numa-split {split} pins every thread to node {node}, which "
                f"has {len(topo[node]['cpus'])} cpus -- --num-threads {num_threads} "
                "would make dramhit exit(-1). Use --numa-split 10 with "
                "--np_cpu_node_msk to spread over a node subset."
            )
        take(node, num_threads)

    elif split in EVEN_SPLIT_SPLITS:
        threads_per_node, spill = divmod(num_threads, len(node_ids))
        narrowest = min(len(topo[n]["cpus"]) for n in node_ids)
        if threads_per_node + (1 if spill else 0) > narrowest:
            raise SystemExit(
                f"[!] --numa-split {split} splits {num_threads} threads over "
                f"{len(node_ids)} nodes, i.e. {threads_per_node} per node, but the "
                f"smallest node has only {narrowest} cpus."
            )
        for node in node_ids:
            take(node, threads_per_node)
        for node in node_ids[:spill]:
            take(node, 1)

    elif split == THREADS_ASSIGN_SEQUENTIAL:
        left = num_threads
        for node in node_ids:
            here = min(left, len(topo[node]["cpus"]))
            if here:
                take(node, here)
            left -= here
        if left > 0:
            raise SystemExit(
                f"[!] --num-threads {num_threads} exceeds the cpus on this machine"
            )

    else:
        raise SystemExit(f"[!] unsupported --numa-split {split}")

    return {n: c for n, c in per_node.items() if c}


def hashtable_nodes(args, topo):
    """distribute_mem_to_nodes(): where calloc_ht()'s table is mbind()ed."""
    node_ids = sorted(topo)
    if len(node_ids) == 1:  # the function returns early on a 1-node box
        return node_ids

    split = args["numa-split"]
    if split == THREADS_REMOTE_NUMA_NODE:
        return [node_ids[1]]
    if split in (THREADS_LOCAL_NUMA_NODE, THREADS_NO_MEM_DISTRIBUTION):
        return [node_ids[0]]
    if split == THREADS_CUSTOM:
        mask = args.get("np_mem_node_msk", 0)
        nodes = mask_nodes(mask, topo)
        if not nodes:
            raise SystemExit(
                f"[!] --np_mem_node_msk 0x{mask:x} selects no node on this machine"
            )
        return nodes
    # THREADS_SPLIT_EVEN_NODES chunks it, everything else interleaves it;
    # either way every node holds a share.
    return node_ids


def radix_arena_nodes(args, threads_by_node, topo):
    """radixjoin2016() binds its arena only under numa-split 10."""
    if args["numa-split"] == THREADS_CUSTOM:
        mask = args.get("np_mem_node_msk", 0)
        nodes = mask_nodes(mask, topo)
        if not nodes:
            raise SystemExit(
                f"[!] --np_mem_node_msk 0x{mask:x} selects no node on this machine"
            )
        return nodes  # bound / interleaved, not thread-local
    return None  # first touch -- follows threads_by_node


# =============================================================================
# DERIVED ARGUMENTS
# =============================================================================


def next_pow2(x):
    """utils::next_pow2()."""
    return 1 if x <= 1 else 1 << (x - 1).bit_length()


def gb(nbytes):
    return nbytes / (1024 ** 3)


def get_optimal_radix(build_sz, ht_fill, l2_bytes):
    """Keep each partition inside L2 without letting 2^radix write buffers
    blow the same budget."""
    optimal_join_size = l2_bytes * ht_fill / 100
    radix = max(6, math.ceil(math.log(build_sz * TUPLE_BYTES / optimal_join_size, 2)))
    if pow(2, radix) * 64 >= l2_bytes:
        print(
            f"    [!] input size is too big, partition runtime will go up: "
            f"build_sz {build_sz * TUPLE_BYTES / (1024 * 1024):.0f} MB, radix {radix}"
        )
    return radix


def resolve_args(spec, run, param_name, param_value):
    """defaults <- run args <- the swept parameter <- derived ht-fill / radix."""
    args = parse_arg_string(spec.get("defaults", ""))
    args.update(parse_arg_string(run["args"]))

    if param_name == "relation_size":
        args["relation_r_size"] = param_value
        args["relation_s_size"] = param_value
    else:
        args[param_name] = param_value

    if args["mode"] == MODE_HASHJOIN:
        # the hash join is given the same space the radix join uses
        r_size = args["relation_r_size"]
        s_size = args["relation_s_size"]
        ht_fill = math.ceil((r_size * 100) / (r_size + s_size))
        if "max_ht_fill" in run:  # dlht cannot go past ~30% before its links spill
            ht_fill = min(ht_fill, run["max_ht_fill"])
        args["ht-fill"] = ht_fill
    elif args["mode"] in RADIX_MODES:
        l2 = spec["l2_bytes_per_core"] // spec.get("smt_per_core", 1)
        args["radix"] = get_optimal_radix(args["relation_r_size"], args["ht-fill"], l2)

    return args


def to_command(spec, args):
    cmd = [spec.get("dramhit_exec", "/opt/DRAMHiT/build/dramhit")]
    for key, val in args.items():
        cmd.extend([f"--{key}", str(val)])
    return cmd


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


def radix_arena_bytes(args):
    """estimate_bytes_needed in radixjoin2016(), minus the relation slice."""
    partition_num = 1 << args["radix"]
    est_join_ht = (
        args["relation_r_size"] * 2 * 100 * TUPLE_BYTES
    ) // (partition_num * args["ht-fill"])
    return (
        CACHELINE_BUFFER_BYTES * partition_num  # swbs
        + 8 * partition_num * 2  # histograms
        + 8 * partition_num * 2  # bucket pointers
        + TWO_MB_PAGE  # the explicit extra 2mb
        + est_join_ht  # per-partition join hashtable
    )


def add(acc, node, pages):
    one_gb, two_mb = acc.get(node, (0, 0))
    acc[node] = (one_gb + pages[0], two_mb + pages[1])


def spread(acc, nodes, pages):
    """An mbind()ed region: bound to one node, or interleaved evenly over several."""
    for node in nodes:
        add(acc, node, (math.ceil(pages[0] / len(nodes)),
                        math.ceil(pages[1] / len(nodes))))


def run_hugepages(args, run, topo):
    """Per-node (1gb, 2mb) pages one dramhit invocation will fault in."""
    threads_by_node = assign_threads(args, topo)
    num_threads = args["num-threads"]
    r_parts = per_thread_split(args["relation_r_size"], num_threads)
    s_parts = per_thread_split(args["relation_s_size"], num_threads)

    pages = {}

    # 1. per-thread relation arena, holding this shard's slice of r and s.
    #    Never bound: it lands on the node its own thread runs on.
    tid = 0
    for node, count in sorted(threads_by_node.items()):
        for _ in range(count):
            add(pages, node, arena_pages(
                TUPLE_BYTES * (r_parts[tid] + s_parts[tid]), relation_arena=True))
            tid += 1

    if args["mode"] == MODE_HASHJOIN:
        # 2. the one global hashtable, hashjoin() -> init_ht() -> calloc_ht().
        capacity = next_pow2(args["relation_r_size"] * 100 // args["ht-fill"])
        ht_nodes = hashtable_nodes(args, topo)
        spread(pages, ht_nodes, calloc_ht_pages(capacity * KV_BYTES))

        # dlht additionally allocates a link table of capacity>>3 entries.
        if args["ht-type"] == HT_DLHT:
            spread(pages, ht_nodes, calloc_ht_pages((capacity >> 3) * KV_BYTES))

    elif args["mode"] in RADIX_MODES:
        # 2. per-thread radix arena, live at the same time as the relation
        #    arena above. Bound to the mem mask under split 10, first touch
        #    otherwise.
        fixed = radix_arena_bytes(args)
        bound_nodes = radix_arena_nodes(args, threads_by_node, topo)
        tid = 0
        for node, count in sorted(threads_by_node.items()):
            for _ in range(count):
                est = fixed + TUPLE_BYTES * (r_parts[tid] + s_parts[tid])
                arena = arena_pages(est, relation_arena=False)
                if bound_nodes is None:
                    add(pages, node, arena)
                else:
                    spread(pages, bound_nodes, arena)
                tid += 1
    else:
        raise SystemExit(
            f"[!] run '{run['name']}': --mode {args['mode']} is not a join mode "
            f"({MODE_HASHJOIN} hash, {MODE_PARTITIONJOIN_V1}/"
            f"{MODE_PARTITIONJOIN_V2} radix)"
        )

    return pages


def ordinary_memory_bytes(args):
    """g_zipf_values: one std::vector<uint64_t> of r+s keys, ordinary pages."""
    return 8 * (args["relation_r_size"] + args["relation_s_size"])


def plan_hugepages(resolved, run, topo):
    """Per-node page counts covering every point of the sweep.

    The reservation has to satisfy the largest point, so take the per-node
    max over all of them rather than the max of the totals -- the worst point
    for one node is not necessarily the worst for another.
    """
    plan = {}
    ordinary = 0
    for args in resolved:
        for node, (one_gb, two_mb) in run_hugepages(args, run, topo).items():
            have = plan.get(node, (0, 0))
            plan[node] = (max(have[0], one_gb), max(have[1], two_mb))
        ordinary = max(ordinary, ordinary_memory_bytes(args))

    # slack, plus one spare 1gb page so a lone rounded-up allocation cannot
    # tip a node over.
    for node, (one_gb, two_mb) in plan.items():
        two_mb = math.ceil(two_mb * (1 + HUGEPAGE_SLACK_FRAC)) + HUGEPAGE_SLACK_2MB_PAGES
        plan[node] = (one_gb + 1 if one_gb else 0, two_mb)

    return plan, ordinary


def check_memory_fits(spec, plan, ordinary_bytes, topo):
    """Abort before touching the machine if the plan cannot physically fit.

    g_zipf_values is allocated by the main thread before any pinning happens,
    so charge it to every node in the plan rather than guessing which one it
    lands on.
    """
    headroom = spec.get("node_mem_headroom_frac", 0.15)
    ok = True
    print("[*] memory budget:")
    for node, (one_gb, two_mb) in sorted(plan.items()):
        huge = one_gb * ONE_GB_PAGE + two_mb * TWO_MB_PAGE
        total = topo[node]["mem_total"]
        budget = total * (1 - headroom)
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
            "[!] this sweep does not fit in memory on node(s) "
            f"{sorted(plan)}. Shrink the sweep in the spec's 'params', or give "
            "the run a numa policy that spreads over more nodes."
        )


def reserve_hugepages(spec, plan):
    """Reset the pools, reserve the plan, and verify the kernel honoured it."""
    script = spec["scripts"]["reserve_hugepages"]

    print("[*] Resetting hugepages before reservation...")
    subprocess.run([script, "reset"], check=True)

    # reserve_hugepages.sh takes 2mb pages as a total megabyte count
    reserve_args = [
        f"n{node}_{one_gb}gb_{two_mb * 2}mb" for node, (one_gb, two_mb) in sorted(plan.items())
    ]
    print(f"[*] Reserving hugepages: {' '.join(reserve_args)}")
    subprocess.run([script, *reserve_args], check=True)

    short = []
    for node, (want_one_gb, want_two_mb) in sorted(plan.items()):
        base = Path(f"/sys/devices/system/node/node{node}/hugepages")
        got_one_gb = int((base / "hugepages-1048576kB" / "nr_hugepages").read_text())
        got_two_mb = int((base / "hugepages-2048kB" / "nr_hugepages").read_text())
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
# RUNNING
# =============================================================================


def set_prefetcher(spec, state):
    """Turns the hardware prefetcher 'on' or 'off'."""
    print(f"[*] Setting prefetcher to: {state.upper()}")
    subprocess.run([spec["scripts"]["prefetch"], state], check=True)


_built = set()


def build_dramhit(spec):
    flags = " ".join(spec.get("cmake_flags", []))
    configure = (
        f"cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build {flags} "
        f"-DCPUFREQ_MHZ={spec['cpufreq_mhz']}"
    )
    if configure in _built:
        return
    subprocess.run(configure, shell=True, check=True)
    subprocess.run("cmake --build /opt/DRAMHiT/build", shell=True, check=True)
    _built.add(configure)


def run_and_parse(cmd, log_path):
    """Run the benchmark once, save its output, and pull out the metrics.

    Returns a dict; "generated" says whether this run paid to build the dataset,
    in which case the caller discards the sample (see collect()).
    """
    print(f"    Running: {' '.join(cmd)}")
    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    out = result.stdout

    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(out)

    joined = re.search(r"joined\s*:\s*(\d+) out of (\d+), ([0-9.]+)%", out)
    if joined and joined.group(3) != "100.00":
        print(f"    -> WARNING: only {joined.group(3)}% of probes joined")

    def grab(pattern, cast=float):
        m = re.search(pattern, out)
        return cast(m.group(1)) if m else None

    metrics = {
        "throughput_mops": grab(r"throughput_mops\s*:\s*([0-9.]+)"),
        "build_cyc_per_op": grab(r"build_phrase_mops : \d+, cycle_per_op : (\d+)", int),
        "probe_cyc_per_op": grab(r"probe_phrase_mops : \d+, cycle_per_op : (\d+)", int),
        "generated": "Generating hashjoin dataset" in out,
    }
    if metrics["throughput_mops"] is None:
        print(f"    -> ERROR: no throughput_mops in output! See {log_path}")
        metrics["throughput_mops"] = 0.0
    else:
        print(f"    -> throughput_mops: {metrics['throughput_mops']}"
              f"  (build {metrics['build_cyc_per_op']}, probe {metrics['probe_cyc_per_op']} cyc/op)")
    return metrics


def update_manifest(data_dir, entry):
    path = data_dir / "manifest.json"
    manifest = json.loads(path.read_text()) if path.exists() else {"sets": []}
    manifest["sets"] = [
        s for s in manifest["sets"]
        if not (s["run"] == entry["run"] and s["param_name"] == entry["param_name"])
    ]
    manifest["sets"].append(entry)
    manifest["sets"].sort(key=lambda s: (s["param_name"], s["run"]))
    path.write_text(json.dumps(manifest, indent=2) + "\n")


def collect(spec, run, param_name, param_values, topo, dry_run, reps):
    machine = spec["machine"]
    data_dir = SCRIPT_DIR / spec["data_dir"]
    set_dir = data_dir / param_name
    log_dir = set_dir / "logs" / run["name"]

    resolved = [resolve_args(spec, run, param_name, v) for v in param_values]
    threads_by_node = assign_threads(resolved[0], topo)

    print(f"\n=== {run['name']} / {param_name} ===")
    print(
        f"    numa-split {resolved[0]['numa-split']}, "
        f"{resolved[0]['num-threads']} threads on nodes "
        f"{ {n: c for n, c in sorted(threads_by_node.items())} }, "
        f"mode {resolved[0]['mode']}, ht-type {resolved[0]['ht-type']}"
    )
    print(f"    sweeping --{param_name} across {param_values}")

    plan, ordinary = plan_hugepages(resolved, run, topo)
    check_memory_fits(spec, plan, ordinary, topo)

    if dry_run:
        for args in resolved:
            print(f"    {' '.join(to_command(spec, args))}")
        print("[*] --dry-run: nothing reserved, built or run.")
        return

    reserve_hugepages(spec, plan)

    # init_hashjoin_dist() caches generated datasets here and silently warns
    # if the directory is missing.
    Path(spec.get("dataset_cache_dir", "/opt/DRAMHiT/cache")).mkdir(
        parents=True, exist_ok=True)

    build_dramhit(spec)
    set_prefetcher(spec, run.get("prefetcher", "off"))

    results = {
        "machine": machine,
        "tag": spec.get("tag"),
        "run": run["name"],
        "param_name": param_name,
        "param_values": param_values,
        "reps": reps,
        "cpufreq_mhz": spec["cpufreq_mhz"],
        "threads_by_node": {str(n): c for n, c in sorted(threads_by_node.items())},
        "args": [dict(a) for a in resolved],
        "log_dir": str(log_dir),
        # throughput_mops is the per-point MEDIAN, so consumers that predate
        # repetition keep working; the raw samples are alongside it.
        "throughput_mops": [],
        "throughput_samples": [],
        "probe_cyc_per_op_samples": [],
        "build_cyc_per_op_samples": [],
    }

    for value, args in zip(param_values, resolved):
        print(f"--- {param_name} = {value}  ({reps} reps) ---")
        cmd = to_command(spec, args)
        samples = []
        attempts = 0

        while len(samples) < reps and attempts < reps + 3:
            attempts += 1
            log_path = log_dir / f"{param_name}_{value}_rep{len(samples) + 1}.log"
            metrics = run_and_parse(cmd, log_path)

            # init_hashjoin_dist() writes the generated dataset to the cache dir
            # with a plain ofstream and no fsync, then the join starts
            # immediately. The kernel flushes those dirty pages *during* the
            # timed region, which costs a memory-bound benchmark up to ~20%,
            # unevenly. Throw that run away and re-measure cache-warm, so every
            # saved sample is comparable.
            if metrics["generated"]:
                print("    -> this run generated the dataset; syncing and "
                      "discarding the sample")
                subprocess.run(["sync"], check=False)
                log_path.unlink(missing_ok=True)
                continue

            samples.append(metrics)

        if len(samples) < reps:
            print(f"    [!] only got {len(samples)}/{reps} clean samples")

        thr = [s["throughput_mops"] for s in samples]
        probe = [s["probe_cyc_per_op"] for s in samples]
        build = [s["build_cyc_per_op"] for s in samples]
        results["throughput_mops"].append(statistics.median(thr) if thr else 0.0)
        results["throughput_samples"].append(thr)
        results["probe_cyc_per_op_samples"].append(probe)
        results["build_cyc_per_op_samples"].append(build)
        if thr:
            print(f"    => median {statistics.median(thr):.0f} mops "
                  f"(min {min(thr):.0f}, max {max(thr):.0f}) over {len(thr)} reps")

    set_dir.mkdir(parents=True, exist_ok=True)
    out = set_dir / f"{machine}_{run['name']}_{param_name}.json"
    out.write_text(json.dumps(results, indent=2) + "\n")
    print(f"[*] Data saved to {out}")

    update_manifest(data_dir, {
        "run": run["name"],
        "param_name": param_name,
        "path": str(out.relative_to(data_dir)),
        "machine": machine,
        "tag": spec.get("tag"),
    })


# =============================================================================
# MAIN
# =============================================================================


def main():
    parser = argparse.ArgumentParser(
        description="Collect join throughput for the runs in a machine spec json."
    )
    parser.add_argument("spec", help="machine spec, e.g. amd-9354p.json")
    parser.add_argument("--run", action="append", default=None,
                        help="only this run (repeatable; default: all).")
    parser.add_argument("--param", action="append", default=None,
                        help="only this sweep (repeatable; default: all).")
    parser.add_argument("--reps", type=int, default=None,
                        help="repeat every sweep point this many times and save "
                             "every sample (default: the spec's \"reps\", else 1). "
                             "The per-point median is what lands in "
                             "throughput_mops; raw samples go to *_samples.")
    parser.add_argument("--dry-run", action="store_true",
                        help="print the per-node memory budget and the dramhit "
                             "command lines, then exit without reserving "
                             "hugepages, rebuilding or running anything.")
    parser.add_argument("--list", action="store_true",
                        help="list the runs in the spec and exit.")
    args = parser.parse_args()

    spec = load_spec(args.spec)
    topo = read_topology()

    if args.list:
        for run in spec["runs"]:
            print(f"  {run['name']:<14} {run['args']}")
        return

    runs = spec["runs"]
    if args.run:
        known = {r["name"] for r in runs}
        unknown = set(args.run) - known
        if unknown:
            raise SystemExit(f"[!] no such run(s): {sorted(unknown)}. Known: {sorted(known)}")
        runs = [r for r in runs if r["name"] in args.run]

    reps = args.reps if args.reps is not None else int(spec.get("reps", 1))
    if reps < 1:
        raise SystemExit("[!] --reps must be >= 1")

    print(
        f"[*] machine '{spec['machine']}' tag '{spec.get('tag')}' ({reps} reps/point) -- "
        f"{len(topo)} numa nodes, "
        f"{sum(len(v['cpus']) for v in topo.values())} cpus, "
        f"{gb(sum(v['mem_total'] for v in topo.values())):.0f} gb"
    )

    summary = []
    for run in runs:
        for param_name, values in sorted(run_params(spec, run).items()):
            if args.param and param_name not in args.param:
                continue
            try:
                collect(spec, run, param_name, values, topo, args.dry_run, reps)
                summary.append(f"{run['name']}/{param_name} -> ok")
            except SystemExit as err:
                print(f"[!] {run['name']}/{param_name} failed: {err}")
                summary.append(f"{run['name']}/{param_name} -> FAILED: {err}")
            except subprocess.CalledProcessError as err:
                print(f"[!] {run['name']}/{param_name} failed: {err}")
                summary.append(f"{run['name']}/{param_name} -> FAILED: {err}")

    print("\n=== SUMMARY ===")
    for line in summary:
        print(f"  {line}")


if __name__ == "__main__":
    main()
