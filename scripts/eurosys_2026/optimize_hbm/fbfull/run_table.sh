#!/usr/bin/env bash
# Occupancy / latency table: bandwidth_rand family, then dramhit builds and queue depths.
set -u
cd "$(dirname "$0")"
OPT=..
G="--groups l1 l2"
echo "### bandwidth_rand (pool: 17 GB of 2 MB pages on node 2)"
for spec in "t1 8" "t1 16" "t1 32" "t1 48" "t1 64" "load 64" "t1avx512 64" "t1avx512heavy 64"; do
  set -- $spec; python3 mlp_profile.py bw $1 --threads $2 --mem 256mb $G --tag "bw_$1_t$2" 2>&1 | grep -E "^==|^\[!\]"
done
/opt/DRAMHiT/scripts/reserve_hugepages.sh reset >/dev/null
/opt/DRAMHiT/scripts/reserve_hugepages.sh n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb >/dev/null
echo "### dramhit (its own pool restored)"
for spec in "attempt3/base base 10 64" "attempt3/l1 l1 10 64" "attempt3/l2 l2 10 64" "attempt4/rck rck 10 64" "attempt4/rck rck 90 64" \
            "attempt4/rck rck 10 16" "attempt4/rck rck 10 32" "attempt4/rck rck 10 128"; do
  set -- $spec; python3 mlp_profile.py dramhit $PWD/$OPT/$1/dramhit --fill $3 --find-queue $4 $G --tag "dh_$2_f$3_q$4" 2>&1 | grep -E "^==|^\[!\]"
done
echo "[OK] table done"
