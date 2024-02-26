#!/bin/bash

# ./build/dramhit --help to see flags
# 8589934592 
function bench_regular() 
{
    sudo ./build/dramhit \
    --mode 4 \
    --ht-type 3 \
    --numa-split 1 \
    --num-threads 64 \
    --ht-size  8589934592 \
    --in-file /opt/dramhit/kmer_dataset/SRR1513870.fastq \
    --k 8 > jerry_benchmark_regular.log
}

function bench_radix() 
{
    sudo ./build/dramhit \
    --mode 14 \
    --ht-type 3 \
    --numa-split 1 \
    --num-threads 64 \
    --ht-size 8589934592 \
    --in-file /opt/dramhit/kmer_dataset/SRR1513870.fastq \
    --k 8 --d 6 > jerry_benchmark_radix.log
}

function debug() 
{
    sudo gdb --args ./build/dramhit "--mode" "14" "--k" "6" "--d" "2" "--ht-type" "3" "--numa-split" "1" "--num-threads" "1" "--ht-size" "100" "--in-file" "/opt/dramhit/kmer_dataset/SRR1513870.fastq"     
}

function bench() {
    #bench_radix
    bench_regular
}

function build() {
    cmake --build build/ 
}

if [ "$1" == "build" ]; then
    build
elif [ "$1" == "bench" ]; then
    bench
elif [ "$1" == "debug" ]; then
    debug
elif [ "$1" == "all" ]; then
    build;
    bench;
else
    echo "Invalid option"
fi