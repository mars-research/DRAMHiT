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
    echo "Usage: $0 <small|large> <num_threads> <fill>:3"
    exit 1
fi
test=$1
numThreads=$2
fill=$3
#TEST 256 KB
if [ "$test" = "small" ]; then
    size=16384
    insertFactor=100000
#TEST 2GB HT
elif [ "$test" = "large" ]; then
    size=134217728
    insertFactor=50
fi

# size=134217728
# insertFactor=10
# size=2048
# insertFactor=1000000
# numThreads=1
batch=16

#for fill in $(seq 10 10 10);
#do  
    sudo ./build/dramhit \
    --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue_sz 32 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor \
    --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 \
    --hw-pref 0 --batch-len $batch

    echo "$(pwd)/build/dramhit \
    --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue_sz 32 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor \
    --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 \
    --hw-pref 0 --batch-len $batch"
#done


