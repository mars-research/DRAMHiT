#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
# 'Constants' hash table types
DRAMHIT=3
GROWT=6
CLHT=7
DRAMHIT23=8
TBB=9

# Ensure correct usage
if [ "$#" -ne 3 ]; then
     echo "Usage: $0 <small|large> <numa_policy> <num_threads> ʕ•ᴥ•ʔ"
     exit 1
fi
#if [ "$#" -ne 2 ]; then
#    echo "Usage: $0 <small|large> <num_threads> ʕ•ᴥ•ʔ"
#    exit 1
#fi
test=$1
numa_policy=$2
numThreads=$3

if [ "$numa_policy" = "single-local" ]; then
    numa_policy=4  
elif [ "$numa_policy" = "single-remote" ]; then
    numa_policy=3
elif [ "$numa_policy" = "dual" ]; then
    numa_policy=1
fi

#TEST 256 KB
if [ "$test" = "small" ]; then
    size=102400
    insertFactor=1
    readFactor=1
#TEST 2GB HT
elif [ "$test" = "large" ]; then
    # size=1073741824
    # size=268435456
    # size=536870912
    # size=1073741824
    size=268435456
    # size=134217728
    insertFactor=1
    readFactor=1
fi

# size=134217728
# insertFactor=10
# size=2048
# insertFactor=1000000
# numThreads=1

fill=70
#for skew in $(seq 0.01 0.5 2.0);
#for fill in $(seq 10 10 10);
#do  
    cmd="--perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue 64 --ht-fill $fill --ht-type $TBB --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd
    sudo $(pwd)/build/dramhit $cmd
    echo $(pwd)/build/dramhit $cmd
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
