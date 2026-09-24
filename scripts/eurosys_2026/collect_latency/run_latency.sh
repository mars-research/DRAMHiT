#!/usr/bin/env bash
# Sweep latency.c: CPU node 0 -> memory nodes 0-3, idle / loaded (load-only) / loaded (load+store)
OUT=${1:-results}
ITERS=${ITERS:-5}
mkdir -p $OUT
for mem in 0 2 1 3; do
  ./latency $mem 0 $ITERS 0 0 0   > $OUT/idle_mem${mem}.txt
  ./latency $mem 0 $ITERS 1 0 0 0 > $OUT/loaded_ld_mem${mem}.txt
  ./latency $mem 0 $ITERS 1 0 0 1 > $OUT/loaded_ldst_mem${mem}.txt
done
grep -H 'Sample Mean' $OUT/*.txt
