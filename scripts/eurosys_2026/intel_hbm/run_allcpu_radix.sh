#!/usr/bin/env bash
# Collect the whole-machine radix join data point: 128 threads over both
# sockets, every thread's arena (partition buckets + join hashtable) bound to
# the hbm node attached to its own socket -- node 0 cpus allocate from node 2,
# node 1 cpus from node 3. dramhit verifies that placement per thread and the
# runner echoes the summary, so a run that fell back to remote memory is
# visible in this log.
#
# Sweeps skew and relation size (build size), then regenerates both graphs so
# the new curve lands next to the existing single-socket ones.
set -uo pipefail
cd /opt/DRAMHiT/scripts/eurosys_2026/intel_hbm

echo "=== START $(date -Is) ==="

for param in skew relation_size; do
  echo "=========================================================="
  echo "=== RUNNING: join-type=radix cpu-scope=all param=$param ==="
  echo "=========================================================="
  python3 -u run_single_join.py --join-type radix --cpu-scope all --param-name "$param"
  echo "=== FINISHED $param with exit code $? ==="
done

echo "=== REGENERATING PLOTS ==="
python3 -u plot_skew.py
python3 -u plot_relation_size.py

echo "=== DONE $(date -Is) ==="
echo "ALL_RUNS_DONE"
