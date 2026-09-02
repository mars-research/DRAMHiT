#!/usr/bin/env bash
set -uo pipefail
cd /opt/DRAMHiT/scripts/eurosys_2026/intel_hbm

RUNS=(
  "hash cas"
  "hash cas23"
  #"hash dlht"
  "hash folklore"
  "radix -"
)

for entry in "${RUNS[@]}"; do
  read -r join_type hashtable <<< "$entry"
  if [ "$join_type" == "hash" ]; then
    echo "=========================================================="
    echo "=== RUNNING: join-type=hash hashtable=$hashtable ==="
    echo "=========================================================="
    python3 run_single_join.py --join-type hash --hashtable "$hashtable" --param-name relation_size
    rc=$?
  else
    echo "=========================================================="
    echo "=== RUNNING: join-type=radix ==="
    echo "=========================================================="
    python3 run_single_join.py --join-type radix --param-name relation_size
    rc=$?
  fi
  echo "=== FINISHED $entry with exit code $rc ==="
done

echo "ALL_RUNS_DONE"
