#!/usr/bin/env bash
# attempt8: attempt7 "base" build (rck options, keys bound to HBM) + configurable find key-stream prefetch
# (KEY_PF_DIST / KEY_PF_HINT / KEY_PF_MODE in src/tests/zipfian_test.cpp)
set -e
cd "$(dirname "$0")"
mkdir -p build
cd build
cmake ../../../../.. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBRANCH=simd -DBUCKETIZATION=ON -DCAS_FAST_PATH=ON -DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON -DCAS_FIND_KSHIFT=ON -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DHASHER=crc -DCPUFREQ_MHZ=2700 -DKEY_LEN=8 -DKMER_LEN=8 -DBENCHMARK_BACKEND=NONE -DDRAMHiT_VARIANT=2025_INLINE -DCAS_FIND_EMBCAST=OFF -DCAS_FIND_VEC4=OFF -DCAS_FIND_VEC4_SCALAR_RES=OFF > cmake.log 2>&1
make -j24 dramhit > make.log 2>&1 || { grep -m5 -B2 -A5 "error" make.log; exit 1; }
cp dramhit ../dramhit
md5sum ../dramhit
