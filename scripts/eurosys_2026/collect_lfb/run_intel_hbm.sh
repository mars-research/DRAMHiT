#!/usr/bin/env bash
# Recollect batch_test for every instruction mode on the Xeon Max (HBM) box.
# Data array bound to HBM node 2, thread pinned to CPU 2 (socket 0, local to node 2).
# HW prefetchers fully off (0x2f) during the run, previous MSR value restored after.
set -e
cd "$(dirname "$0")"
NODE=${NODE:-2}; CPU=${CPU:-2}; RANGE=${RANGE:-10-60}; ITER=${ITER:-200}
OUT=intel_hbm
PFCTL=../../prefetch_control_hbm.sh
prev=$(sudo env PATH="$PATH" rdmsr -p $CPU 0x1a4)
sudo env PATH="$PATH" $PFCTL off
trap 'sudo env PATH="$PATH" $PFCTL 0x$prev' EXIT
gcc batch_test.c -O3 -mcrc32 -lnuma -o batch_test
names=(load avx512 t0 t1 t2 nta prefetchw)
mkdir -p $OUT
for m in 0 1 2 3 4 5 6; do
  taskset -c $CPU ./batch_test -m $m -b $RANGE -i $ITER -n $NODE -o $OUT/batch_${names[$m]}.csv > /dev/null
  echo "mode $m -> $OUT/batch_${names[$m]}.csv"
done
