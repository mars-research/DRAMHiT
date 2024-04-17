#!/bin/bash

GENOME="fvesca"
LOG_DIR=.
DATASET_DIR=/opt/dramhit/kmer_dataset
declare -A DATASET_ARRAY
DATASET_ARRAY["dmela"]=${DATASET_DIR}/ERR4846928.fastq
DATASET_ARRAY["fvesca"]=${DATASET_DIR}/SRR1513870.fastq
declare -A HT_SIZE_ARRAY
HT_SIZE_ARRAY["dmela"]=8589934592
HT_SIZE_ARRAY["fvesca"]=4294967296

FASTA_FILE=${DATASET_ARRAY[${GENOME}]}
# HT_SIZE=${HT_SIZE_ARRAY[$GENOME]}
HT_SIZE=4

function command_regular() 
{
    sudo ./build/dramhit \
    --mode 4 \
    --ht-type 3 \
    --numa-split 1 \
    --num-threads 64 \
    --ht-size $HT_SIZE \
    --in-file $FASTA_FILE \
    --k 10 > $LOG_DIR/kmer_k${1}.log
}

function command_baseline() 
{
    sudo ./build/dramhit \
    --mode 15 \
    --ht-type 4 \
    --numa-split 1 \
    --num-threads 1 \
    --ht-size $1 \
    --datasize $2 \
    --workload $3 > logs/baseline_d${2}_ht${1}.log
}


function bench_baseline() 
{
    #ht=300
    #d=100
    w=1000000
    for (( i=5; i<=15; i+=1 )); do
        d=$((1<<i))
        ht=$((2*d))
        command_baseline $ht $d $w
    done    
}

function command_radix() 
{
    sudo ./build/dramhit \
    --mode 14 \
    --ht-type 3 \
    --numa-split 1 \
    --num-threads $3 \
    --ht-size ${HT_SIZE} \
    --in-file ${FASTA_FILE} \
    --k $1 --d $2 > $LOG_DIR/kmer_radix_k${1}_d${2}.log
}

function bench_radix()
{
    echo ">>> Input File: ${FASTA_FILE} Hashtable Size: ${HT_SIZE}"
    t=1 # thread number
    k=15
    for d in $(seq 5 8); do
        echo "-> Starting to run with d ${d} k ${k} t ${t}"
        command_radix $k $d $t
    done
}

function debug() 
{
    sudo gdb --args ./build/dramhit \
    --mode 15 \
    --ht-type 4 \
    --numa-split 1 \
    --num-threads 1 \
    --ht-size 64 \
    --datasize 32 \
    --workload 1 
}


function bench() {
    bench_radix
    #command_regular
    #bench_baseline
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
elif [ "$1" == "perf" ]; then
    perf;
else
    echo "Invalid option"
fi