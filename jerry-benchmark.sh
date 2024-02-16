#!/bin/bash

# ./build/dramhit --help to see flags

function bench_regular() 
{
    sudo ./build/dramhit \
    --mode 4 \
    --ht-type 3 \
    --numa-split 1 \
    --num-threads 64 \
    --ht-size 8589934592 \
    --in-file /opt/dramhit/kmer_dataset/SRR1513870.fastq \
    --k 6 > jerry_benchmark.log
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
    --k 6 --d 8 > jerry_benchmark.log
}

function bench() {
    bench_radix
    #bench_regular
}

function build() {
    cmake --build build/ 
}

if [ "$1" == "build" ]; then
    build
elif [ "$1" == "bench" ]; then
    bench
else
    echo "Invalid option"
fi