#!/usr/bin/env bash
#
# Compute -- and then reserve, through scripts/reserve_hugepages.sh -- exactly
# the hugepage pool one dramhit k-mer run needs, itemised so that every page
# reserved is attributable to a line of source.
#
# A k-mer run takes hugepages from exactly TWO places. Nothing else in the run
# maps MAP_HUGETLB, so nothing else is reserved here:
#
#   1. THE STAGING ARENA -- include/utils/kmer_staging.hpp, one HugepageArena
#      per reader thread. Both counting paths pre-encode their slice of the
#      FASTQ into a flat uint64 array before the timed region, so what gets
#      measured is insert throughput and not FASTQ parsing.
#
#   2. THE HASHTABLE -- calloc_ht(), include/hashtables/ht_helper.hpp.
#
# Both are shaped by --ht-type, because it picks the code path (Application.cpp:
# prod_cons_path = mode==FASTQ_WITH_INSERT && ht_type in {1,12}; that goes to
# qt.run_test(), everything else to spawn_shard_threads()):
#
#                      ht-type 1, 12                 everything else (3, 8, ...)
#                      "partitioned"                 "global"
#   source             src/tests/queue_tests.cpp     src/tests/kmer_tests.cpp
#   readers (stage)    --nprod                       --num-threads
#   tables             --ncons, one private each     1, shared by all threads
#   slots per table    --ht-size / ncons             --ht-size
#
# Getting the reader count wrong under-reserves by 2x in the usual symmetric
# 64+64 setup. Getting the table shape wrong reserves the wrong PAGE CLASS,
# which no amount of extra headroom fixes -- see section 2 of the report.
#
# Pages are reserved PER NUMA NODE, and evenly: mmap(MAP_HUGETLB) takes pages
# from the node the faulting thread runs on, so a globally sufficient pool still
# aborts mid-run when one node is short.
#
# An even split assumes the threads are spread over the nodes. Most policies do
# spread them, but PROD_CONS_SEQUENTIAL (--numa-split 1) and SEPARATE_NODES (2)
# put every producer on node 0 and every consumer on node 1, so each node needs
# the WHOLE staging or table requirement rather than half. Pass --worst-case to
# reserve the full requirement on every node; it costs 2x the memory and is
# still independent of --numa-split -- it just covers every placement.
#
# Usage:
#   ./plan_hugepages.sh --ht-type 3 --num-threads 128 --ht-size 2147483648 \
#                       --in-file /opt/datasets/ERR4846928.fastq
#   ./plan_hugepages.sh --ht-type 1 --nprod 64 --ncons 64 --ht-size 2147483648
#   ./plan_hugepages.sh ... --worst-case # cover any thread placement (see below)
#   ./plan_hugepages.sh ... --dry-run    # print the attribution, reserve nothing
#   ./plan_hugepages.sh --reset          # release every hugepage on every node
#
# --ht-size is the TOTAL on both paths, exactly as dramhit takes it.
set -euo pipefail

HERE="$(dirname "$(readlink -f "$0")")"
RESERVE="${HERE}/../../reserve_hugepages.sh"

IN_FILE="/opt/datasets/ERR4846928.fastq"
HT_TYPE=3
NUM_THREADS=128        # global path only
NPROD=64               # partitioned path only
NCONS=64               # partitioned path only
HT_SIZE=2147483648     # slots, TOTAL, both paths
BATCH_LEN=16           # --batch-len; HT_TESTS_BATCH_LENGTH in constants.hpp
KV_SIZE=16             # sizeof(KVType): Aggr_KV and Item are both 8B key + 8B value
NODES_ARG=""           # e.g. "0,1"; default = every node the kernel reports
WORST_CASE=0           # reserve the whole requirement on every node
SLACK_1GB=0            # attribution stays exact by default; add headroom by hand
SLACK_2MB=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset)            exec "${RESERVE}" reset ;;
    --in-file)          IN_FILE="$2";     shift 2 ;;
    --ht-type)          HT_TYPE="$2";     shift 2 ;;
    --num-threads)      NUM_THREADS="$2"; shift 2 ;;
    --nprod)            NPROD="$2";       shift 2 ;;
    --ncons)            NCONS="$2";       shift 2 ;;
    --ht-size)          HT_SIZE="$2";     shift 2 ;;
    --numa-split)       shift 2 ;;   # accepted and ignored: the pool does not depend on it
    --np_mem_node_msk)  shift 2 ;;   # likewise
    --batch-len)        BATCH_LEN="$2";   shift 2 ;;
    --kv-size)          KV_SIZE="$2";     shift 2 ;;
    --nodes)            NODES_ARG="$2";   shift 2 ;;
    --slack-1gb)        SLACK_1GB="$2";   shift 2 ;;
    --slack-2mb)        SLACK_2MB="$2";   shift 2 ;;
    --worst-case)       WORST_CASE=1;     shift ;;
    --dry-run)          DRY_RUN=1;        shift ;;
    -h|--help)          sed -n '2,45p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

[[ -x "${RESERVE}" ]] || { echo "ERROR: ${RESERVE} not found or not executable" >&2; exit 1; }
[[ -f "${IN_FILE}" ]] || { echo "ERROR: input file not found: ${IN_FILE}" >&2; exit 1; }

IN_FILE_SZ=$(stat -c %s "${IN_FILE}")

if [[ -n "${NODES_ARG}" ]]; then
  NODE_IDS="${NODES_ARG//,/ }"
else
  NODE_IDS=$(for d in /sys/devices/system/node/node[0-9]*; do
               basename "$d" | tr -dc '0-9'; echo
             done | sort -n | tr '\n' ' ')
fi

# The report and the per-node page counts come out of one calculation: the
# numbers printed ARE the numbers handed to reserve_hugepages.sh.
PLAN_FILE=$(mktemp)
trap 'rm -f "${PLAN_FILE}"' EXIT

python3 - "${PLAN_FILE}" <<PY
import sys

sz         = ${IN_FILE_SZ}
ht_type    = ${HT_TYPE}
nthreads   = ${NUM_THREADS}
nprod      = ${NPROD}
ncons      = ${NCONS}
ht_size    = ${HT_SIZE}
batch_len  = ${BATCH_LEN}
kv         = ${KV_SIZE}
worst_case = ${WORST_CASE}
slack_1gb  = ${SLACK_1GB}
slack_2mb  = ${SLACK_2MB}
in_file    = "${IN_FILE}"
nodes      = [int(x) for x in "${NODE_IDS}".split()]

GB, MB2 = 1 << 30, 2 << 20
ARG_SZ  = 24        # sizeof(InsertFindArgument): 8 key + 8 value + 4 id + 4 part_id
nn      = len(nodes)

def gib(b): return b / GB
def next_pow2(v): return 1 << (v - 1).bit_length()
def ceil_div(a, b): return -(-a // b)

# ============================================================== which path
partitioned = ht_type in (1, 12)
if partitioned:
    readers, n_tables = nprod, ncons
    src, path_name = "src/tests/queue_tests.cpp", "partitioned (producer/consumer)"
    reader_why = "--nprod: only producers read the file; num_threads there is nprod+ncons"
    table_why  = "one private table per consumer"
    # queue_tests.cpp passes args_bytes = 0: it enqueues one kmer at a time
    # (StagingBuffer batch_len = 1), so there is no batch buffer in the arena.
    args_bytes = 0
else:
    readers, n_tables = nthreads, 1
    src, path_name = "src/tests/kmer_tests.cpp", "global (one shared table)"
    reader_why = "--num-threads: every thread stages its own slice of the file"
    table_why  = "one table, allocated once (the CAS tables hold it in a static member)"
    args_bytes = ARG_SZ * batch_len

if readers < 1 or (partitioned and ncons < 1):
    sys.stderr.write("ERROR: reader or consumer count is 0\n"); sys.exit(2)

# ============================================================== 1. staging
# kmer_staging.hpp shard_kmer_bytes(): at most one kmer per 2 bytes of FASTQ
# (a record is @hdr/SEQ/+/QUAL, so at least 2 bytes on disk per base), and each
# kmer is 2-bit packed into one uint64 -> file/readers/2 * 8. A hard upper
# bound, not an estimate: the arena is a bump allocator and cannot grow.
kmer_bytes  = (sz // readers // 2 + 1) * 8
# shard_arena_bytes(): + the batch buffer + one 2MB page so the two 64B-aligned
# bumps always fit.
arena_bytes = kmer_bytes + args_bytes + MB2
# one_gb_pages()/two_mb_pages(): the two pools TOGETHER cover the request, and
# StagingBuffer splits the array to match, so no single allocation spans them.
shard_1gb = arena_bytes // GB
shard_2mb = (arena_bytes - shard_1gb * GB) // MB2 + 1

# ============================================================ 2. hashtable
if partitioned:
    # queue_tests.cpp get_ht_size(): config.ht_size / n_cons, rounded up to a
    # multiple of 4. --ht-size is the TOTAL here too.
    slots = ht_size // ncons
    if slots & 0x3:
        slots += 4 - (slots % 4)
    slots_why = f"--ht-size / ncons = {ht_size} / {ncons}, rounded up to a multiple of 4"
else:
    slots = ht_size
    slots_why = "--ht-size, used as-is"

# PartitionedHashStore (ht-type 1) keeps capacity == c (simple_kht.hpp); every
# other table runs the request through utils::next_pow2 first.
if ht_type == 1:
    cap = slots
    cap_why = "capacity = slots, unrounded (simple_kht.hpp)"
elif next_pow2(slots) == slots:
    cap = slots
    cap_why = "capacity = next_pow2(slots) = slots (already a power of two)"
else:
    cap = next_pow2(slots)
    cap_why = (f"capacity = next_pow2(slots) = {cap} slots"
               f"  <-- {cap/slots:.2f}x the request, and it is the allocated size")

table_bytes = cap * kv

# calloc_ht -> round_hugepage(): below 1GiB round up to a 2MB multiple, else to
# a 1GB multiple; then <= 1GiB maps MAP_HUGE_2MB and anything larger
# MAP_HUGE_1GB. Decided per ALLOCATION, never on the total -- 64 private 0.5GiB
# tables are 2MB-backed even though they sum to 32GiB, and reserving 1GB pages
# for them starves the class the run actually uses.
rounded = ceil_div(table_bytes, MB2) * MB2 if table_bytes < GB else ceil_div(table_bytes, GB) * GB
if rounded <= GB:
    tbl_1gb, tbl_2mb, page_class = 0, rounded // MB2, "2MB"
else:
    tbl_1gb, tbl_2mb, page_class = rounded // GB, 0, "1GB"

# ======================================================== 3. numa placement
# Reserved evenly across the nodes, with no dependence on --numa-split: mmap
# takes pages from the faulting thread's node, the readers are spread over the
# nodes, and each node has to be able to back the readers that land on it.
# --worst-case reserves the whole requirement on every node instead of an even
# share. Still no dependence on --numa-split: it simply covers any placement the
# policy might pick. Needed for the policies that pile one role onto one socket
# -- PROD_CONS_SEQUENTIAL (1) and SEPARATE_NODES (2) put every producer on node
# 0 and every consumer on node 1, so an even split leaves both nodes short and
# the run dies with SIGBUS on the first hugepage it touches.
if worst_case:
    readers_per_node = readers
    stage_why_extra = " (worst case: every reader charged to every node)"
else:
    readers_per_node = ceil_div(readers, nn)
    stage_why_extra = ""
stage_1gb_on = [shard_1gb * readers_per_node] * nn
stage_2mb_on = [shard_2mb * readers_per_node] * nn

if partitioned:
    # One private table per consumer; the consumers spread over the nodes the
    # same way the producers do -- unless we are covering every placement.
    tables_per_node = n_tables if worst_case else ceil_div(n_tables, nn)
    tables_on = [tables_per_node] * nn
    tbl_why = (f"all {n_tables} private tables charged to every node (worst case)"
               if worst_case else
               f"{n_tables} private tables spread over {nn} nodes, {tables_per_node} per node")
else:
    # A single shared table, allocated once by whichever shard constructs it
    # first. It can land entirely on one node, so charge the whole thing to
    # every node rather than guessing which.
    tables_on = [1] * nn
    tbl_why = "one shared table, charged in full to every node (it can land on any one)"

tbl_1gb_on = [tbl_1gb * tables_on[n] for n in range(nn)]
tbl_2mb_on = [tbl_2mb * tables_on[n] for n in range(nn)]
readers_on = [readers_per_node] * nn

per_node = [(stage_1gb_on[n] + tbl_1gb_on[n] + slack_1gb,
             stage_2mb_on[n] + tbl_2mb_on[n] + slack_2mb) for n in range(nn)]

# ================================================================= report
W = 78
def rule(c="-"): print(c * W)

print()
rule("=")
print(f"  dramhit hugepage plan -- {path_name}")
rule("=")
print(f"  --ht-type {ht_type}  ->  {src}")
print(f"  input       {in_file}")
print(f"              {sz} bytes ({gib(sz):.2f} GiB)")
print(f"  readers     {readers}   {reader_why}")
print(f"  tables      {n_tables}   {table_why}")
print(f"  numa        nodes {', '.join(str(x) for x in nodes)}")
print()

rule()
print("  1. STAGING ARENA        include/utils/kmer_staging.hpp, one per reader")
rule()
print(f"     kmer array       (file_sz / readers / 2 + 1) * 8B")
print(f"                      = ({sz} / {readers} / 2 + 1) * 8")
print(f"                      = {kmer_bytes} B  ({gib(kmer_bytes):.3f} GiB)")
print(f"                      1 kmer per 2 file bytes is a hard bound: a FASTQ")
print(f"                      record is @hdr/SEQ/+/QUAL, so at least 2 bytes on")
print(f"                      disk per base; each kmer packs into one uint64.")
if args_bytes:
    print(f"     batch buffer     sizeof(InsertFindArgument)={ARG_SZ}B * --batch-len {batch_len}")
    print(f"                      = {args_bytes} B")
else:
    print(f"     batch buffer     none -- this path enqueues one kmer at a time")
print(f"     alignment slack  1 x 2MB page, so the 64B-aligned bumps always fit")
print(f"     ----------------------------------------------------------------")
print(f"     per reader       {arena_bytes} B  ->  {shard_1gb} x 1GB + {shard_2mb} x 2MB")
print(f"                      the two pools together cover it; StagingBuffer")
print(f"                      splits the array to match, so no one allocation")
print(f"                      has to span the 1GB and the 2MB pool")
print(f"     x {readers} readers    = {shard_1gb * readers} x 1GB + {shard_2mb * readers} x 2MB"
      f"   ({(shard_1gb*readers*GB + shard_2mb*readers*MB2)/GB:.2f} GiB)")
print()

rule()
print("  2. HASHTABLE            calloc_ht(), include/hashtables/ht_helper.hpp")
rule()
print(f"     slots per table  {slots}")
print(f"                      {slots_why}")
print(f"                      {cap_why}")
print(f"     bytes per table  {cap} slots * {kv}B = {table_bytes} B ({gib(table_bytes):.3f} GiB)")
print(f"     page class       {page_class}")
print(f"                      round_hugepage(): one allocation of <= 1GiB is")
print(f"                      mapped MAP_HUGE_2MB, above that MAP_HUGE_1GB.")
print(f"                      Decided per allocation, never on the total.")
print(f"     per table        {tbl_1gb} x 1GB + {tbl_2mb} x 2MB")
print(f"     x {n_tables} table(s)     = {tbl_1gb * n_tables} x 1GB + {tbl_2mb * n_tables} x 2MB"
      f"   ({(tbl_1gb*n_tables*GB + tbl_2mb*n_tables*MB2)/GB:.2f} GiB)")
print()

rule()
print("  3. PER-NODE RESERVATION")
rule()
print(f"     staging  {readers} readers over {nn} nodes -> {readers_per_node} per node"
          f"{stage_why_extra}")
print(f"     table    {tbl_why}")
print()
print(f"     {'node':<6}{'readers':>9}{'tables':>9}{'1GB':>8}{'2MB':>9}{'GiB':>9}")
for n in range(nn):
    p1, p2 = per_node[n]
    print(f"     {nodes[n]:<6}{readers_on[n]:>9}{str(tables_on[n]):>9}{p1:>8}{p2:>9}"
          f"{(p1*GB + p2*MB2)/GB:>9.1f}")
if slack_1gb or slack_2mb:
    print(f"     (each row includes the requested slack of {slack_1gb} x 1GB + {slack_2mb} x 2MB)")
total = sum(p1 * GB + p2 * MB2 for p1, p2 in per_node)
print()
stage_total = shard_1gb * readers * GB + shard_2mb * readers * MB2
table_total = tbl_1gb * n_tables * GB + tbl_2mb * n_tables * MB2
extra = ""
if worst_case and nn > 1:
    extra = f"  (charged in full to each of the {nn} nodes, so any placement works)"
elif not partitioned and nn > 1:
    extra = f"  (the shared table is counted on each of the {nn} nodes)"
elif total > stage_total + table_total:
    extra = "  (plus per-node rounding and slack)"
print(f"     TOTAL RESERVED   {total/GB:.1f} GiB"
      f"  =  {gib(stage_total):.1f} GiB staging"
      f"  +  {gib(table_total):.1f} GiB table{extra}")
rule("=")
print()

# reserve_hugepages.sh takes n<node>_<gb>gb_<mb>mb and derives 2MB pages as mb/2.
args = " ".join(f"n{nodes[n]}_{per_node[n][0]}gb_{per_node[n][1]*2}mb" for n in range(nn))
with open(sys.argv[1], "w") as f:
    f.write(args + "\n")
    f.write(f"{ceil_div(total, GB)}\n")
PY

RESERVE_ARGS=$(sed -n 1p "${PLAN_FILE}")
TOTAL_GIB=$(sed -n 2p "${PLAN_FILE}")
MEM_TOTAL_GIB=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))

echo "  reserve command  ${RESERVE} ${RESERVE_ARGS}"
echo "                   ${TOTAL_GIB} GiB of ${MEM_TOTAL_GIB} GiB RAM"
echo

if (( TOTAL_GIB > MEM_TOTAL_GIB * 8 / 10 )); then
  echo "WARNING: this reserves >80% of RAM. Lower --ht-size, or raise the reader" >&2
  echo "         count (--num-threads / --nprod) to shrink the per-reader slice." >&2
  echo >&2
fi

if (( DRY_RUN )); then
  echo "  (dry run, nothing reserved)"
  exit 0
fi

# shellcheck disable=SC2086
"${RESERVE}" ${RESERVE_ARGS}

# A short pool is silent until the run aborts minutes in, so check it here.
echo
echo "  what the kernel actually handed out:"
rc=0
for spec in ${RESERVE_ARGS}; do
  [[ $spec =~ ^n([0-9]+)_([0-9]+)gb_([0-9]+)mb$ ]] || continue
  node="${BASH_REMATCH[1]}"
  want1="${BASH_REMATCH[2]}"
  want2=$(( BASH_REMATCH[3] / 2 ))
  np="/sys/devices/system/node/node${node}/hugepages"
  got1=$(cat "${np}/hugepages-1048576kB/nr_hugepages" 2>/dev/null || echo 0)
  got2=$(cat "${np}/hugepages-2048kB/nr_hugepages" 2>/dev/null || echo 0)
  printf "    node%-4s %6s x 1GB (wanted %s)  %6s x 2MB (wanted %s)\n" \
         "${node}" "${got1}" "${want1}" "${got2}" "${want2}"
  if (( got1 < want1 || got2 < want2 )); then
    echo "    ERROR: node${node} is short -- memory is too fragmented." >&2
    echo "           Free memory, then '$0 --reset' and retry." >&2
    rc=1
  fi
done
exit "${rc}"
