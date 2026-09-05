#!/usr/bin/env bash
#
# Administers the join experiments over both numa configurations --
# single socket (numa-split 4, local memory) and dual socket (numa-split 1,
# global hashtable spread evenly over both nodes) -- for every hash-join
# hashtable plus radix join.
#
# usage: ./run_all.sh <snoop-mode> [param-name ...] -- [numa-config ...]
#   snoop-mode    name of the machine's BIOS snoop setting, e.g. directory
#                 or snoop. Results are written under a tree of that name so
#                 a second BIOS mode can be collected without clobbering the
#                 first. Required, so it cannot be forgotten after a BIOS
#                 change.
#   param-name    relation_size and/or skew   (default: both)
#   numa-config   single and/or dual          (default: both)
#
# The default is all four sets. Results land in one directory per set:
#   <snoop-mode>/{single,dual}_{relation_size,skew}/
# each holding the per-join json plus logs/<join>/ of raw dramhit output.
#
# Every (set, join) pair reserves its own hugepages and rebuilds, so the runs
# are independent; a failing pair does not stop the rest.

set -uo pipefail
cd /opt/DRAMHiT/scripts/eurosys_2026/collect_join

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <snoop-mode> [param-name ...] -- [numa-config ...]" >&2
  echo "  e.g. $0 directory          # all four sets, BIOS in directory mode" >&2
  echo "       $0 snoop skew -- dual # just the dual skew set, BIOS in snoop mode" >&2
  exit 1
fi
SNOOP_MODE="$1"
shift

PARAMS=()
NUMA_CONFIGS=()
seen_sep=0
for arg in "$@"; do
  if [ "$arg" == "--" ]; then
    seen_sep=1
    continue
  fi
  if [ "$seen_sep" -eq 0 ]; then
    PARAMS+=("$arg")
  else
    NUMA_CONFIGS+=("$arg")
  fi
done

[ "${#PARAMS[@]}" -eq 0 ] && PARAMS=(relation_size skew)
[ "${#NUMA_CONFIGS[@]}" -eq 0 ] && NUMA_CONFIGS=(single dual)

# "join_type hashtable"; "-" where the join has no hashtable to pick.
RUNS=(
  "hash cas"
  "hash cas23"
  "hash dlht"
  "hash folklore"
  "radix -"
)

SUMMARY=()

for numa_config in "${NUMA_CONFIGS[@]}"; do
  for param_name in "${PARAMS[@]}"; do
    for entry in "${RUNS[@]}"; do
      read -r join_type hashtable <<< "$entry"

      echo "=========================================================="
      echo "=== RUNNING: snoop=$SNOOP_MODE numa-config=$numa_config param=$param_name" \
           "join-type=$join_type hashtable=$hashtable ==="
      echo "=========================================================="

      if [ "$join_type" == "hash" ]; then
        python3 -u run_join.py --join-type hash --hashtable "$hashtable" \
          --numa-config "$numa_config" --param-name "$param_name" \
          --snoop-mode "$SNOOP_MODE"
      else
        python3 -u run_join.py --join-type radix \
          --numa-config "$numa_config" --param-name "$param_name" \
          --snoop-mode "$SNOOP_MODE"
      fi
      rc=$?

      echo "=== FINISHED $numa_config $param_name $entry with exit code $rc ==="
      SUMMARY+=("$numa_config/$param_name $join_type $hashtable -> rc=$rc")
    done
  done
done

echo "=========================================================="
echo "=== SUMMARY ($SNOOP_MODE) ==="
for line in "${SUMMARY[@]}"; do
  echo "  $line"
done
echo "ALL_RUNS_DONE"
