#!/usr/bin/env bash
# MLC equivalents of latency.c runs: latency thread on core 0, memory on node 0-3,
# loaders on all other node-0 logical CPUs (excluding core 0 and its HT sibling).
MLC=${MLC:-$(ls /nix/store/*-source/tools/mlc/mlc | head -1)}
OUT=${1:-mlc_results}
mkdir -p $OUT
SIB=$(cat /sys/devices/system/cpu/cpu0/topology/thread_siblings_list | tr ',' ' ')
LOADERS=$(for c in $(numactl -H | awk '/^node 0 cpus:/{for(i=4;i<=NF;i++)print $i}'); do
  skip=0; for s in $SIB; do [ $c = $s ] && skip=1; done; [ $skip = 0 ] && echo $c; done | paste -sd,)
# Loaded runs: single max-load point by default; SWEEP=1 for the full delay curve
LD="-d0 -t1"; [ -n "$SWEEP" ] && LD=""
echo "MLC=$MLC loaders=$LOADERS"
sudo $MLC --latency_matrix > $OUT/latency_matrix.txt
for mem in 0 2 1 3; do
  sudo $MLC --idle_latency -c0 -j$mem                  > $OUT/idle_default_mem$mem.txt
  sudo $MLC --idle_latency -c0 -j$mem -r -L -b1000000  > $OUT/idle_rand_mem$mem.txt
  sudo $MLC --loaded_latency -c0 -j$mem -k$LOADERS $LD > $OUT/loaded_rd_mem$mem.txt
  sudo $MLC --loaded_latency -c0 -j$mem -k$LOADERS -W5 $LD > $OUT/loaded_w5_mem$mem.txt
  sudo $MLC --loaded_latency -c0 -j$mem -k$LOADERS -r -b200000 -d0 -t1 > $OUT/loaded_rd_rand_mem$mem.txt
done
# Remote memory with loaders on the memory's own socket (matches latency.c's remote setup)
LOADERS1=$(numactl -H | awk '/^node 1 cpus:/{for(i=4;i<=NF;i++)print $i}' | paste -sd,)
for mem in 1 3; do
  sudo $MLC --loaded_latency -c0 -j$mem -k$LOADERS1 $LD > $OUT/loaded_rd_node1loaders_mem$mem.txt
  sudo $MLC --loaded_latency -c0 -j$mem -k$LOADERS1 -W5 $LD > $OUT/loaded_w5_node1loaders_mem$mem.txt
done
