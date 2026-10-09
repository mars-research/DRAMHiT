#!/usr/bin/env bash
# attempt9: 16 B find-queue entries (CAS_FIND_QUEUE16) and 4-entry block push/pop (with CAS_FIND_VEC4),
# on top of the attempt8 harness (configurable key-stream prefetch). attempt9/<v>/build -> attempt9/<v>/dramhit
set -e
cd "$(dirname "$0")"
COMMON="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DBRANCH=simd -DBUCKETIZATION=ON -DCAS_FAST_PATH=ON -DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON -DCAS_FIND_KSHIFT=ON -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DHASHER=crc -DCPUFREQ_MHZ=2700 -DKEY_LEN=8 -DKMER_LEN=8 -DBENCHMARK_BACKEND=NONE -DDRAMHiT_VARIANT=2025_INLINE -DCAS_FIND_EMBCAST=OFF -DCAS_FIND_VEC4_SCALAR_RES=OFF"
declare -A EXTRA=(
  [base]="-DCAS_FIND_VEC4=OFF -DCAS_FIND_QUEUE16=OFF -DCAS_FIND_QUEUE16_XMM=OFF"
  [q16]="-DCAS_FIND_VEC4=OFF -DCAS_FIND_QUEUE16=ON -DCAS_FIND_QUEUE16_XMM=OFF"
  [q16x]="-DCAS_FIND_VEC4=OFF -DCAS_FIND_QUEUE16=ON -DCAS_FIND_QUEUE16_XMM=ON"
  [q16v]="-DCAS_FIND_VEC4=ON -DCAS_FIND_QUEUE16=ON -DCAS_FIND_QUEUE16_XMM=OFF"
  [v4]="-DCAS_FIND_VEC4=ON -DCAS_FIND_QUEUE16=OFF -DCAS_FIND_QUEUE16_XMM=OFF"
)
for v in ${@:-base q16 q16x q16v v4}; do
  mkdir -p $v/build
  (cd $v/build && cmake ../../../../../.. $COMMON ${EXTRA[$v]} > cmake.log 2>&1 && \
     { make -j24 dramhit > make.log 2>&1 || { grep -m3 -A6 "error" make.log; exit 1; }; })
  cp $v/build/dramhit $v/dramhit
  echo "$v $(md5sum $v/dramhit | cut -d' ' -f1)"
done
