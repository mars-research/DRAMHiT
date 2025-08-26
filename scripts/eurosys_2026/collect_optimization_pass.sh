#!/bin/bash

HOME=/opt/DRAMHiT
RESULT=result.txt 

run_ht_local() 
{
    insertFactor=500
    readFactor=500
    numThreads=64
    numa_policy=4
    size=536870912

    for fill in $(seq 10 10 90); do
        cmd="--perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
        --find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
        --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 \
        --hw-pref 0 --batch-len 16"
        sudo "$(pwd)"/build/dramhit $cmd | grep mops >> "${RESULT}"
    done   
}

pushd "$HOME" || exit 1

echo "dramhit23" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=OFF -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local

echo "dramhit23 Bucket" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=ON -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local

echo "dramhit23 SIMD" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local

echo "dramhit25" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local

echo "dramhit25 inline" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=ON -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local

echo "dramhit25 uniform" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=ON
cmake --build ./build
run_ht_local

echo "dramhit25 uniform+inline" >> "${RESULT}"
cmake -S . -B build -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=ON -DUNIFORM_PROBING=ON
cmake --build ./build
run_ht_local

popd
