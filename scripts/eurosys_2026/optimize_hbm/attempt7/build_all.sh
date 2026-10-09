#!/usr/bin/env bash
# attempt7: deep-vectorization variants of the find fast path (cas_kht.hpp), on top of the attempt6
# build (rck options + keys-in-HBM harness). Each variant: attempt7/<name>/build -> attempt7/<name>/dramhit
set -e
cd "$(dirname "$0")"
COMMON="-DCMAKE_BUILD_TYPE=RelWithDebInfo -DBRANCH=simd -DBUCKETIZATION=ON -DCAS_FAST_PATH=ON -DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON -DCAS_FIND_KSHIFT=ON -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DHASHER=crc -DCPUFREQ_MHZ=2700 -DKEY_LEN=8 -DKMER_LEN=8 -DBENCHMARK_BACKEND=NONE -DDRAMHiT_VARIANT=2025_INLINE"
declare -A EXTRA=(
  [base]="-DCAS_FIND_EMBCAST=OFF -DCAS_FIND_VEC4=OFF -DCAS_FIND_VEC4_SCALAR_RES=OFF"
  [emb]="-DCAS_FIND_EMBCAST=ON -DCAS_FIND_VEC4=OFF -DCAS_FIND_VEC4_SCALAR_RES=OFF"
  [vec4s]="-DCAS_FIND_EMBCAST=ON -DCAS_FIND_VEC4=ON -DCAS_FIND_VEC4_SCALAR_RES=ON"
  [vec4]="-DCAS_FIND_EMBCAST=ON -DCAS_FIND_VEC4=ON -DCAS_FIND_VEC4_SCALAR_RES=OFF"
)
for v in ${@:-base emb vec4s vec4}; do
  mkdir -p $v/build
  (cd $v/build && cmake ../../../../../.. $COMMON ${EXTRA[$v]} > cmake.log 2>&1 && make -j24 dramhit > make.log 2>&1)
  cp $v/build/dramhit $v/dramhit
  echo "$v $(md5sum $v/dramhit | cut -d' ' -f1)"
done
