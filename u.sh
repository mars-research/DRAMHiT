#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes

# 28 threads
# { set_cycles : 51, get_cycles : 28, set_mops : 1152.941, get_mops : 2100.000 }

# 56 threads
# { set_cycles : 89, get_cycles : 42, set_mops : 1321.348, get_mops : 2800.000 }


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
    size=16384
    insertFactor=10000
    readFactor=10000
#TEST 2GB HT
elif [ "$test" = "large" ]; then
    # size=1073741824
    size=536870912
    # size=1073741824
    #size=268435456
    #size=134217728
    insertFactor=0
    readFactor=100
fi

# size=134217728
# insertFactor=10
# size=2048
# insertFactor=1000000
# numThreads=1

fill=10
#for skew in $(seq 0.01 0.5 2.0);
#for fill in $(seq 10 10 10);
#do  
    cmd="--perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd
    sudo $(pwd)/build/dramhit $cmd
    echo $(pwd)/build/dramhit $cmd
#done    
# sudo ./tools/mlc/mlc   --bandwidth_matrix -h -U -W6 

# sudo bash -c '
#         mkfifo ctl.fifo ack.fifo
#         exec 10<>ctl.fifo
#         exec 11<>ack.fifo
#         cmd="./build/dramhit \
#         --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
#         --find_queue_sz 32 --ht-fill 10 --ht-type 3 --insert-factor 500 \
#         --num-threads 56 --numa-split 1 --no-prefetch 0 --mode 11 \
#         --ht-size 134217728 --skew 0.01 --hw-pref 0 --batch-len 16"
        
#         /nix/store/ad3jjs95bcnwncb71bvm9zjd9ifd0fbw-perf-linux-5.15.47/bin/perf \
#         stat --delay=-1 --control fd:10,11 \
#         -e 'cpu/event=0x5,umask=0xFF/' \
#         -e 'cycles'\
#         \
#         $cmd
#         exec 10>&-
#         exec 11>&-
#         rm ctl.fifo ack.fifo
#     '

