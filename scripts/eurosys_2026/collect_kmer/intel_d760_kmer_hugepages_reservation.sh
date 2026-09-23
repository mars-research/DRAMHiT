#!/usr/bin/env bash
#
# Reserve the one hugepage pool that serves EVERY k-mer configuration we run on
# this machine, so the pool can be set up once and left alone.
#
# The pool is not a guess. It is the per-page-class maximum over every case,
# for --ht-size 2147483648 on the 18,144,334,284 byte ERR4846928.fastq:
#
#   case                                            1GB     2MB   GiB/node
#   ------------------------------------------------------------------------
#   global  (ht 3, 8) 128t, table on one node        32   17408      66.0
#   global  (ht 3, 8) 128t, table interleaved        16   17408      50.0
#   part.   (ht 1,12) policy 1/2, node with prods    64    1920      67.8
#   part.   (ht 1,12) policy 1/2, node with tables    0   16384      32.0
#   part.   (ht 1,12) policy 3/4, even 32/32         32    9152      49.9
#   ------------------------------------------------------------------------
#   UNION                                            64   17408      98.0
#
# 98 GiB per node, 196 GiB of the 251 GiB box, ~55 GiB spare.
#
# The two variants peak in DIFFERENT page classes, which is why the union is
# cheaper than reserving each one's worst case:
#
#   * global at 128 readers stages 0.53 GiB per thread -- under 1 GiB, so all of
#     it comes from 2MB pages -- and puts its whole 32 GiB table in 1GB pages.
#   * partitioned at 64 readers stages 1.06 GiB per producer, which crosses into
#     1GB pages, while its 64 private 0.5 GiB tables are all 2MB-backed.
#
# Maxing each class independently therefore costs 64 x 1GB + 17408 x 2MB rather
# than the sum of the two profiles.
#
# Because it covers every placement, it is independent of --numa-split: the
# policies that pile one role onto one socket (PROD_CONS_SEQUENTIAL 1 and
# SEPARATE_NODES 2 put every producer on node 0 and every consumer on node 1)
# are already inside the union above.
#
# ONE RESTRICTION: global runs must use --num-threads 128, not 64. At 64 readers
# the global arena is also 1.06 GiB, so a node-0-pinned policy (--numa-split
# 3/4/5/9) stacks 64 x 1GB of staging plus the 32 GiB table on a single node =
# 96 x 1GB, i.e. 130 GiB/node and 260 GiB total, over this box. No uniform pool
# covers that, and an asymmetric one does not help either, since policy 3 loads
# node 1 while 4/5 load node 0. This costs nothing in practice: 128 threads is
# the thread-matched comparison against 64 prod + 64 cons anyway, and at 128
# threads those policies abort at startup regardless, because generate_cpu_list()
# wants every thread on node 0 and node 0 has only 64 cpus.
#
# Machine this was computed for:
#   Intel Xeon Gold 6548Y+, 2 numa nodes x 64 cpus, 251 GiB RAM (cloudlab d760)
# The checks below refuse to run on a box or dataset that does not match, rather
# than reserving numbers that no longer hold. --force overrides them.
#
# Usage:
#   ./intel_d760_kmer_hugepages_reservation.sh            # reserve
#   ./intel_d760_kmer_hugepages_reservation.sh --dry-run  # print, reserve nothing
#   ./intel_d760_kmer_hugepages_reservation.sh --reset    # release everything
#   ./intel_d760_kmer_hugepages_reservation.sh --force    # skip the machine checks
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
RESERVE="$HERE/../../reserve_hugepages.sh"

# --- the union, per node ---------------------------------------------------
PAGES_1GB=64
PAGES_2MB=17408

# --- what the numbers were derived for -------------------------------------
EXPECT_NODES=2
EXPECT_CPUS=128
EXPECT_MEM_GIB=251
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
    -h|--help) sed -n '2,62p' "$0"; exit 0 ;;
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
  warn=1
fi

if (( warn )) && ! (( FORCE )); then
  cat >&2 <<EOF

REFUSING to reserve. The page counts in this script are the union of the k-mer
configurations on the machine and dataset named above; on anything else they are
just numbers. Recompute them with:

    ./plan_hugepages.sh --ht-type 3  --num-threads 128 --ht-size $EXPECT_HT_SIZE --dry-run
    ./plan_hugepages.sh --ht-type 12 --nprod 64 --ncons 64 --ht-size $EXPECT_HT_SIZE \\
                        --worst-case --dry-run

and take the larger of each page class. Pass --force to reserve anyway.
EOF
  exit 1
fi

TOTAL_GIB=$(( (PAGES_1GB + PAGES_2MB / 512) * EXPECT_NODES ))
SPEC_MB=$(( PAGES_2MB * 2 ))   # reserve_hugepages.sh takes MB and derives MB/2 pages

echo
echo "reserving per node: ${PAGES_1GB} x 1GB + ${PAGES_2MB} x 2MB  ($(( PAGES_1GB + PAGES_2MB / 512 )) GiB)"
echo "total             : ${TOTAL_GIB} GiB across ${EXPECT_NODES} nodes"
echo "covers            : ht-type 3/8 at 128 threads, ht-type 1/12 at 64+64,"
echo "                    any --numa-split, --ht-size ${EXPECT_HT_SIZE}"
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
