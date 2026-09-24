#!/bin/bash
# Collect latency.c + mlc latency on AMD EPYC 9354P (1 socket, NPS4 -> 4 NUMA nodes)
cd "$(dirname "$0")"
MLC=${MLC:-$(ls /opt/nix/store/*/tools/mlc/mlc | head -1)}
ITERS=${ITERS:-5}
OUT=amd_results
mkdir -p $OUT
for loaded in 0 1; do
  for mem in 0 1 2 3; do
    for cpu in 0 1 2 3; do
      f=$OUT/latency_mem${mem}_cpu${cpu}_loaded${loaded}.txt
      echo "== mem=$mem cpu=$cpu loaded=$loaded"
      ./latency $mem $cpu $ITERS $loaded 0 0 > $f 2>&1
      grep "Sample Mean" $f
    done
  done
done
sudo $MLC --latency_matrix     > $OUT/mlc_latency_matrix.txt 2>&1
sudo $MLC --latency_matrix -r  > $OUT/mlc_latency_matrix_rand.txt 2>&1
sudo $MLC --idle_latency       > $OUT/mlc_idle_latency.txt 2>&1
sudo $MLC --loaded_latency     > $OUT/mlc_loaded_latency.txt 2>&1
