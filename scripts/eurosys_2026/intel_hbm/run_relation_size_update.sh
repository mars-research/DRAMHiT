#!/usr/bin/env bash
# Refresh the equal-relation-size (R = S) curves under intel_hbm/.
#
# 1. cas is re-collected end to end with CAS_PREFETCH_INSERTION=DOUBLE, the
#    configuration measured to be ~6% faster on the build phase than a single
#    prefetchw. Its stored curve predates that, so every point is replaced.
# 2. cas23, folklore and radix get the new 16gb point. The insert knob does not
#    reach them (it only gates cas_kht), so their existing points stand -- but
#    each re-runs 8gb as well, and merge_relation_size_points.py compares that
#    against the stored value before the new point is trusted.
# 3. dlht is left alone: at 16gb its table plus secondary store does not fit in
#    node 2's hbm.
set -uo pipefail
cd /opt/DRAMHiT/scripts/eurosys_2026/intel_hbm

echo "=== START $(date -Is) ==="

echo "=========================================================="
echo "=== cas: full sweep, CAS_PREFETCH_INSERTION=DOUBLE ==="
echo "=========================================================="
python3 -u run_single_join.py --join-type hash --hashtable cas \
  --param-name relation_size --cas-prefetch-insertion DOUBLE
echo "=== FINISHED cas with exit code $? ==="

for entry in "hash cas23" "hash folklore" "radix -"; do
  read -r join_type ht <<< "$entry"
  echo "=========================================================="
  echo "=== $join_type $ht: 8gb (check) + 16gb (new) ==="
  echo "=========================================================="
  if [ "$join_type" == "hash" ]; then
    python3 -u run_single_join.py --join-type hash --hashtable "$ht" \
      --param-name relation_size --relation-sizes-gib 8 16 --out-suffix _new
  else
    python3 -u run_single_join.py --join-type radix \
      --param-name relation_size --relation-sizes-gib 8 16 --out-suffix _new
  fi
  echo "=== FINISHED $entry with exit code $? ==="
done

echo "=========================================================="
echo "=== MERGING new points into the collected curves ==="
echo "=========================================================="
for pair in "hash_cas23" "hash_folklore" "radix"; do
  new="intel_hbm_single_${pair}_relation_size_new.json"
  cur="intel_hbm_single_${pair}_relation_size.json"
  if [ -f "$new" ]; then
    echo "--- $pair ---"
    python3 -u merge_relation_size_points.py "$new" "$cur"
  else
    echo "--- $pair: no new data ($new missing) ---"
  fi
done

echo "=== REGENERATING PLOT ==="
python3 -u plot_relation_size.py

echo "=== DONE $(date -Is) ==="
echo "ALL_RUNS_DONE"
