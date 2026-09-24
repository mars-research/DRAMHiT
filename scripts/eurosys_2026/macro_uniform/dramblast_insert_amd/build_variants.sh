#!/usr/bin/env bash
# Build the three insert-prefetch variants used by variants.py / pfdrop.py next
# to this script, without touching /opt/DRAMHiT/build (the baseline).
#   build_pw   CAS_PREFETCH_INSERTION=PREFETCHW  (one prefetchw at enqueue)
#   build_d16  DOUBLE, PREFETCH_INSERT_NEXT_DISTANCE 8 -> 16
#   build_d32  DOUBLE, PREFETCH_INSERT_NEXT_DISTANCE 8 -> 32
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=/opt/DRAMHiT
FLAGS="-DCPUFREQ_MHZ=3250 -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd
       -DAVX_SUPPORT=ON -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON
       -DCAS_NO_ABSTRACT=OFF -DGROWT=OFF -DCALC_STATS=OFF"

cmake -S "$SRC" -B "$HERE/build_pw" $FLAGS -DCAS_PREFETCH_INSERTION=PREFETCHW
cmake --build "$HERE/build_pw" -j 32 --target dramhit

for d in 16 32; do
  copy="$HERE/src_d$d"
  rm -rf "$copy" && mkdir -p "$copy"
  (cd "$SRC" && git ls-files -z | xargs -0 -I{} cp --parents {} "$copy/")
  for sub in $(cd "$SRC" && git submodule --quiet foreach 'echo $sm_path'); do
    cp -r "$SRC/$sub/." "$copy/$sub/"
  done
  sed -i "s/#define PREFETCH_INSERT_NEXT_DISTANCE 8/#define PREFETCH_INSERT_NEXT_DISTANCE $d/" \
    "$copy/include/hashtables/cas_kht.hpp"
  grep -q "PREFETCH_INSERT_NEXT_DISTANCE $d" "$copy/include/hashtables/cas_kht.hpp"
  cmake -S "$copy" -B "$HERE/build_d$d" $FLAGS -DCAS_PREFETCH_INSERTION=DOUBLE
  cmake --build "$HERE/build_d$d" -j 32 --target dramhit
done
