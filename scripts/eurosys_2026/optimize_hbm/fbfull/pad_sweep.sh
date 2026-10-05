#!/usr/bin/env bash
# Calibration: cycles per line vs instructions per line, two prefetch schemes, two data sizes.
set -u
cd "$(dirname "$0")"
BW=../../machine_stats/build
for size in "256mb $BW/bandwidth_rand hbm" "256kb $BW/bandwidth_rand_long l2"; do
  set -- $size; mem=$1; bin=$2; where=$3
  for mode in t1pad double; do
    for pad in 0 8 16 24 32 48; do
      python3 mlp_profile.py bw $mode --threads 64 --mem $mem --bwbin $bin --pad $pad --near 8 --groups l1 \
        --tag "pad_${where}_${mode}_p${pad}" 2>&1 | grep -E "^==|^\[!\]"
    done
  done
done
/opt/DRAMHiT/scripts/reserve_hugepages.sh reset >/dev/null
/opt/DRAMHiT/scripts/reserve_hugepages.sh n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb >/dev/null
echo "[OK] pad sweep done"
