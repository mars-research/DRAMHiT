set -e 
#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
#  python ./scripts/verify_dataset.py 
DRAMHIT=3
GROWT=6
DRAMHIT23=8


# Ensure correct usage
if [ "$#" -ne 4 ]; then
     echo "Usage: $0 <CPU_MHZ> <numa_policy> <num_threads> <test>ʕ•ᴥ•ʔ"
     exit 1
fi

CPU_FREQ=$1
numa_policy=$2
numThreads=$3
test=$4

if [ "$numa_policy" = "single-local" ]; then
    numa_policy=4
elif [ "$numa_policy" = "single-remote" ]; then
    numa_policy=3
elif [ "$numa_policy" = "even" ]; then
    numa_policy=6
elif [ "$numa_policy" = "dual" ]; then
    numa_policy=1
fi

if [ "$test" = "r" ]; then
workload=0
elif [ "$test" = "rw" ]; then
workload=2
elif [ "$test" = "1.2rw" ]; then
workload=3
elif [ "$test" = "seq_rw" ]; then
workload=4
elif [ "$test" = "stream_rw" ]; then
workload=5
fi


insertFactor=1
readFactor=100
# 1GB per threads
# size=16777216
size=8388608
# size=2097152

HASHJOIN=13
ZIPFIAN=14
UNIFORM=11
BW=15

rsize=536870912

HOME_DIR=/opt/DRAMHiT
cmake -S $HOME_DIR -B $HOME_DIR/build  -DBENCHMARK_BACKEND=NONE  -DCALC_STATS=OFF -DCPUFREQ_MHZ=$CPU_FREQ -DDRAMHiT_VARIANT=2025 -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE
cmake --build $HOME_DIR/build



    FILE_NAME=output.txt
    cmd="--num-threads 64 --numa-split $numa_policy --mode $BW --ht-size $size --sequential $workload --read-factor $readFactor" 

    echo $(pwd)/build/dramhit $cmd
    # sudo $(pwd)/build/dramhit $cmd
    
    sudo /usr/bin/perf stat -a -M umc_mem_bandwidth,umc_mem_read_bandwidth,umc_mem_write_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd &> $FILE_NAME
    # # sudo /usr/bin/perf stat -a -M umc_data_bus_utilization -I 1000 -- $HOME_DIR/build/dramhit $cmd > /dev/null 2> $FILE_NAME
    # sudo $(pwd)/build/dramhit $cmd > $FILE_NAME
    # sudo /usr/bin/perf stat -e UNC_M_CAS_COUNT.ALL -I 1000 -- $HOME_DIR/build/dramhit $cmd &> $FILE_NAME
    # sudo $HOME_DIR/build/dramhit $cmd  
    # echo $(pwd)/build/dramhit $cmd &>> $FILE_NAME


# results in output.txt
# ./collect_amd.sh 3250  single-local 64 rw
# ./collect_amd.sh 3250  single-local 64 read
# ./collect_amd.sh 3250  single-local 64 seq_rw

# objdump -d /opt/DRAMHiT/build/dramhit | grep 'prefetcht1' 
# objdump -d /opt/DRAMHiT/build/dramhit | grep -i vmovdqa