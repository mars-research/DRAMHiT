#!/usr/bin/env bash
set -uo pipefail
cd /opt/DRAMHiT/scripts/eurosys_2026/intel_hbm

for ht in cas cas23 dlht folklore; do
  echo "=========================================================="
  echo "=== RUNNING: join-type=hash hashtable=$ht ==="
  echo "=========================================================="
  python3 -u run_single_join.py --join-type hash --hashtable "$ht" --param-name relation_size
  echo "=== FINISHED hash $ht with exit code $? ==="
done

echo "ALL_RUNS_DONE"
