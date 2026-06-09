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
if [ "$#" -ne 5 ]; then
     echo "Usage: $0 <CPU_MHZ> <numa_policy> <num_threads> <amd|intel> <test>ʕ•ᴥ•ʔ"
     exit 1
fi

CPU_FREQ=$1
numa_policy=$2
numThreads=$3
platform=$4
test=$5

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
elif [ "$test" = "seq_r" ]; then
workload=1
elif [ "$test" = "rw" ]; then
workload=2
elif [ "$test" = "ratio" ]; then
workload=3
elif [ "$test" = "seq_rw" ]; then
workload=4
elif [ "$test" = "stream_rw" ]; then
workload=5
elif [ "$test" = "cas" ]; then
workload=6
fi


insertFactor=1
readFactor=200
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

    echo $HOME_DIR/build/dramhit $cmd
    # sudo $(pwd)/build/dramhit $cmd
    
if [ "$platform" = "amd" ]; then
    sudo /usr/bin/perf stat -a -M umc_mem_bandwidth,umc_mem_read_bandwidth,umc_mem_write_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd
else
    sudo /usr/bin/perf stat -e unc_m_cas_count.all,unc_m_cas_count.rd,unc_m_cas_count.wr -I 1000 -- $HOME_DIR/build/dramhit $cmd
fi

# results in output.txt
# ./collect_amd.sh 3250  single-local 64 amd rw
# ./collect_amd.sh 3250  single-local 64 amd read
# ./collect_amd.sh 3250  single-local 64 amd seq_rw

# objdump -d /opt/DRAMHiT/build/dramhit | grep 'prefetcht1' 
# objdump -d /opt/DRAMHiT/build/dramhit | grep -i vmovdqa