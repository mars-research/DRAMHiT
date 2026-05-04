#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
# 'Constants' hash table types
DRAMHIT=3
GROWT=6
DRAMHIT23=8

# Ensure correct usage
if [ "$#" -ne 3 ]; then
     echo "Usage: $0 <small|large> <numa_policy> <num_threads> ʕ•ᴥ•ʔ"
     exit 1
fi
# if [ "$#" -ne 2 ]; then
#    echo "Usage: $0 <small|large> <num_threads> ʕ•ᴥ•ʔ"
#    exit 1
# fi
test=$1
numa_policy=$2
numThreads=$3

if [ "$numa_policy" = "single-local" ]; then
    numa_policy=4
elif [ "$numa_policy" = "single-remote" ]; then
    numa_policy=3
elif [ "$numa_policy" = "even" ]; then
    numa_policy=6
elif [ "$numa_policy" = "dual" ]; then
    numa_policy=1
fi

#TEST 256 KB
if [ "$test" = "small" ]; then
    size=524288
    insertFactor=10000
    readFactor=10000
#TEST 2GB HT
elif [ "$test" = "large" ]; then
    # size=4294967296
    # size=268435456
    size=536870912

    # size=1073741824
    # size=268435456
    # size=134217728
    insertFactor=1
    readFactor=100
fi

# size=134217728
# insertFactor=10
# size=2048
# insertFactor=1000000
# numThreads=1

fill=70

HASHJOIN=13
ZIPFIAN=11
UNIFORM=14

rsize=536870912

HOME_DIR=/opt/DRAMHiT
cmake -S $HOME_DIR -B $HOME_DIR/build -DCALC_STATS=OFF -DCPUFREQ_MHZ=3250 -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE
cmake --build $HOME_DIR/build

#for skew in $(seq 0.01 0.5 2.0);
#for fill in $(seq 10 10 10);
#do


FILE_NAME=output.txt
    cmd="--find_queue 64 --ht-fill $fill --ht-type $DRAMHIT --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --seed 2190830198 --numa-split $numa_policy --no-prefetch 0 --mode $ZIPFIAN --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16 --relation_r_size $rsize"
    echo $(pwd)/build/dramhit $cmd
    # sudo $(pwd)/build/dramhit $cmd
    
    # sudo /usr/bin/perf stat -a -M umc_mem_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd > /dev/null 2> $FILE_NAME
    # # sudo /usr/bin/perf stat -a -M umc_data_bus_utilization -I 1000 -- $HOME_DIR/build/dramhit $cmd > /dev/null 2> $FILE_NAME
    # sudo $(pwd)/build/dramhit $cmd > $FILE_NAME
    sudo /usr/bin/perf stat -a -M umc_mem_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd &> $FILE_NAME
    
    #echo $(pwd)/build/dramhit $cmd
#done


# dramhit="$(pwd)/build/dramhit $cmd"
# export dramhit
# sudo bash -c '
#         mkfifo ctl.fifo ack.fifo
#         exec 10<>ctl.fifo
#         exec 11<>ack.fifo

#         /usr/bin/perf stat --delay=1 -I 1000  --control fd:10,11 -e 'UNC_M_CAS_COUNT.ALL' $dramhit

#         exec 10>&-
#         exec 11>&-
#         rm ctl.fifo ack.fifo
#     '

#     sudo /opt/intel/oneapi/vtune/latest/bin64/vtune -collect memory-access -result-dir vtune_mem_bw -start-paused -- ./u.sh large single-local 64
#     sudo /opt/intel/oneapi/vtune/latest/bin64/vtune -report summary -r vtune_mem_bw -filter "Task Name==find_test"
#     sudo /opt/intel/oneapi/vtune/latest/bin64/vtune -report summary -r vtune_mem_bw
#     rm -rf vtune_mem_bw
