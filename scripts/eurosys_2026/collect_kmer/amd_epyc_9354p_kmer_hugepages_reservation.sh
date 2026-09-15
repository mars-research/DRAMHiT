#!/usr/bin/env bash
#
# Reserve the one hugepage pool that serves EVERY k-mer configuration we run on
# this machine, so the pool can be set up once and left alone.
#
# THIS BOX IS NOT THE d760. It is a single-socket AMD EPYC 9354P that the BIOS
# exposes as FOUR numa nodes (NPS4), 16 cpus and ~47 GiB of RAM each -- versus
# d760's 2 nodes of 64 cpus / 125 GiB each (see intel_d760_kmer_hugepages_
# reservation.sh). Both the cpu-per-node count and the RAM-per-node count are
# smaller here, and that is what makes the d760 script's "charge the whole
# table/staging requirement to every node" trick blow the budget: 4 nodes x
# the d760-style worst case is ~99.6 GiB on a node that only has ~47 GiB.
#
# So this pool does NOT cover every --numa-split. It covers exactly the
# placements that fit in ~47 GiB/node, and REQUIRES the run to use one of
# them (see RESTRICTIONS below). That is a materially different tradeoff from
# the d760 script, not a smaller version of the same one.
#
# Prerequisites (do these first, once):
#   ./scripts/setup_amd.sh                  # disable turbo, pin freq, hugepages on,
#                                            # disable prefetchers, perf-setup
#   ./scripts/eurosys_2026/collect_kmer/download_dataset.sh
#                                            # fetches /opt/datasets/ERR4846928.fastq
#   CPUFREQ_MHZ=3250 ./scripts/eurosys_2026/collect_kmer/build_dramhit.sh
#                                            # this box runs its cores pinned at 3250MHz
#
# The pool is not a guess. It is the per-page-class maximum over the global
# and partitioned paths, each evaluated at the ONE placement this script
# requires (see RESTRICTIONS), for --ht-size 2147483648 on the 18,144,334,284
# byte ERR4846928.fastq:
#
#   case                                              1GB    2MB   GiB/node
#   -------------------------------------------------------------------------
#   global  (ht 3, 8) 64t, numa-split 1, table         24     480     24.9
#            interleaved across all 4 nodes (8GB/node)
#   part.   (ht 1,12) 32+32, numa-split(q) 3 or 4,     16    4568     24.9
#            8 prod + 8 cons + 8 tables per node
#   -------------------------------------------------------------------------
#   UNION                                              24    4568     32.9
#
# 32.9 GiB per node, 131.75 GiB of the 188 GiB box, ~56.6 GiB spare (~14
# GiB/node) for the OS, page tables, and everything setup_amd.sh's turbo/
# prefetch/perf tweaks do not touch.
#
# Why the union is only 32.9 GiB/node and not 24.9 + 24.9: the global run's
# worst class is 1GB pages (24, from 16 staging + 8 table), the partitioned
# run's worst class is 2MB pages (4568, from 472 staging + 4096 table per
# node) -- maxing each class independently costs less than the sum of the two
# profiles, same reasoning as the d760 script.
#
# RESTRICTIONS (read this or the run will abort mid-way, or the reservation
# above will silently be too small):
#
#   * GLOBAL runs (--ht-type 3, 8, ...) MUST use --num-threads 64 with
#     --numa-split left at its default (1) or set to 6. Both spread the 64
#     threads 16/node and either interleave the table across all 4 nodes
#     (default, distribute_mem_to_nodes()'s else-branch) or split it into 4
#     even 8 GiB chunks (6, THREADS_SPLIT_EVEN_NODES) -- either way, 8 GiB of
#     table lands on every node. --numa-split 3, 4, 5, 9 pin EVERY thread (and
#     for 4/5, the table too) onto node 0 alone: with a 32 GiB table that is
#     ~99.6 GiB demanded from a node that has ~47 GiB, and it fails outright
#     regardless of the pool, because node 0 here has only 16 cpus (they cap
#     --num-threads at 16, same shape of restriction as d760's cpu-count
#     limit, just a different number).
#
#   * PARTITIONED runs (--ht-type 1, 12) MUST use --nprod 32 --ncons 32 with
#     --numa-split (the QUEUES enum, a different set of numbers from the one
#     above) set to 3 (PROD_CONS_EQUAL_PARTITION) or 4 (PROD_CONS_SAME_NODE).
#     Both spread producers and consumers 8+8 per node, so every node carries
#     8 private tables (4096 x 2MB) alongside 8 producers' staging. --numa-
#     split 1 or 2 (SEQUENTIAL / SEPARATE_NODES) pile all 32 producers onto 2
#     nodes and all 32 tables onto the other 2: a producer-node then wants 32
#     x 1GB of staging (this pool only has 24) and a table-node wants 8192 x
#     2MB of table (this pool only has 4568) -- both short, so the run aborts
#     partway through mmap.
#
#   * --ht-size and the input file must match EXPECT_HT_SIZE / EXPECT_FILE_SZ
#     below, same as the d760 script -- the byte counts above are attributable
#     to exactly those two numbers, not to "a 2 GiB hashtable" in the abstract.
#
# Machine this was computed for:
#   AMD EPYC 9354P, 1 socket / 4 numa nodes (NPS4) x 16 cpus, ~188 GiB RAM
# The checks below refuse to run on a box or dataset that does not match,
# rather than reserving numbers that no longer hold. --force overrides them.
#
# Usage:
#   ./amd_epyc_9354p_kmer_hugepages_reservation.sh            # reserve
#   ./amd_epyc_9354p_kmer_hugepages_reservation.sh --dry-run  # print, reserve nothing
#   ./amd_epyc_9354p_kmer_hugepages_reservation.sh --reset    # release everything
#   ./amd_epyc_9354p_kmer_hugepages_reservation.sh --force    # skip the machine checks
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
RESERVE="$HERE/../../reserve_hugepages.sh"

# --- the union, per node ---------------------------------------------------
PAGES_1GB=24
PAGES_2MB=4568

# --- what the numbers were derived for -------------------------------------
EXPECT_NODES=4
EXPECT_CPUS=64
EXPECT_MEM_GIB=188
EXPECT_HT_SIZE=2147483648
IN_FILE="/opt/datasets/ERR4846928.fastq"
EXPECT_FILE_SZ=18144334284

DRY_RUN=0
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reset)   exec "$RESERVE" reset ;;
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) sed -n '2,90p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

[[ -x "$RESERVE" ]] || { echo "ERROR: $RESERVE not found or not executable" >&2; exit 1; }

# ---------------------------------------------------------------------------
# refuse to reserve numbers that no longer apply
# ---------------------------------------------------------------------------
warn=0
check() {  # check <what> <got> <want>
  if [[ "$2" != "$3" ]]; then
    echo "  MISMATCH  $1: got $2, expected $3" >&2
    warn=1
  else
    printf "  ok        %-22s %s\n" "$1" "$2"
  fi
}

echo "verifying this is the machine the pool was computed for:"
check "numa nodes"   "$(ls -d /sys/devices/system/node/node[0-9]* | wc -l)" "$EXPECT_NODES"
check "cpus"         "$(nproc)"                                            "$EXPECT_CPUS"
check "RAM (GiB)"    "$(awk '/MemTotal/{printf "%.0f", $2/1024/1024}' /proc/meminfo)" "$EXPECT_MEM_GIB"
if [[ -f "$IN_FILE" ]]; then
  check "input file size" "$(stat -c %s "$IN_FILE")" "$EXPECT_FILE_SZ"
else
  echo "  MISSING   input file: $IN_FILE" >&2
  echo "            run ./download_dataset.sh first" >&2
  warn=1
fi

if (( warn )) && ! (( FORCE )); then
  cat >&2 <<EOF

REFUSING to reserve. The page counts in this script are the union of the
global (--num-threads 64, --numa-split 1) and partitioned (--nprod 32 --ncons
32, --numa-split 3 or 4) k-mer configurations on the machine and dataset named
above; on anything else they are just numbers. Recompute them with:

    ./plan_hugepages.sh --ht-type 3  --num-threads 64 --ht-size $EXPECT_HT_SIZE --dry-run
    ./plan_hugepages.sh --ht-type 12 --nprod 32 --ncons 32 --ht-size $EXPECT_HT_SIZE --dry-run

take the per-node numbers plan_hugepages.sh prints for each (NOT --worst-case
-- on this box that charges every node the full 32 producer/table count, which
overshoots what --numa-split 1/3/4 actually place on any one node), and union
each page class. Pass --force to reserve anyway.
EOF
  exit 1
fi

TOTAL_GIB=$(( (PAGES_1GB + PAGES_2MB / 512) * EXPECT_NODES ))
SPEC_MB=$(( PAGES_2MB * 2 ))   # reserve_hugepages.sh takes MB and derives MB/2 pages

echo
echo "reserving per node: ${PAGES_1GB} x 1GB + ${PAGES_2MB} x 2MB  ($(( PAGES_1GB + PAGES_2MB / 512 )) GiB)"
echo "total             : ${TOTAL_GIB} GiB across ${EXPECT_NODES} nodes"
echo "covers            : ht-type 3/8 at --num-threads 64 --numa-split 1 (or 6),"
echo "                    ht-type 1/12 at --nprod 32 --ncons 32 --numa-split 3 (or 4),"
echo "                    --ht-size ${EXPECT_HT_SIZE}"
echo "does NOT cover    : --numa-split 3/4/5/9 (global) or 1/2 (partitioned) --"
echo "                    those pile threads/tables onto one node and do not fit"
echo "                    on this box's ~47 GiB/node regardless of pool size"
echo

ARGS=()
for ((n = 0; n < EXPECT_NODES; n++)); do
  ARGS+=("n${n}_${PAGES_1GB}gb_${SPEC_MB}mb")
done

echo "\$ $RESERVE ${ARGS[*]}"
if (( DRY_RUN )); then
  echo "(dry run, nothing reserved)"
  exit 0
fi

# Release first: a pool left over in another shape fragments memory, and the
# kernel then cannot assemble the 1GB pages this one needs.
"$RESERVE" reset > /dev/null
"$RESERVE" "${ARGS[@]}" > /dev/null

echo
echo "result:"
rc=0
for d in /sys/devices/system/node/node[0-9]*; do
  n=$(basename "$d")
  got1=$(cat "$d/hugepages/hugepages-1048576kB/nr_hugepages")
  got2=$(cat "$d/hugepages/hugepages-2048kB/nr_hugepages")
  printf "  %-7s %5s x 1GB (want %s)   %6s x 2MB (want %s)\n" \
         "$n" "$got1" "$PAGES_1GB" "$got2" "$PAGES_2MB"
  if (( got1 < PAGES_1GB || got2 < PAGES_2MB )); then
    echo "  ERROR: $n came up short -- memory is too fragmented." >&2
    echo "         Stop any running dramhit, then re-run this script." >&2
    rc=1
  fi
done
exit "$rc"
