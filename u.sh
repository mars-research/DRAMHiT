#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
# for thr in $(seq 1 1 56);
# do  
#     sudo ./build/dramhit --find_queue_sz 32 --ht-fill 10 --ht-type 3 --insert-factor $insertFactor --num-threads $thr --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
# done

# grep command to show results
# grep -E "find_queue_size|mops" 1.txt
# [12-16],[24,32,40,64,128]
# for sz in 8 9 10 11 12 13 14 15 16 24 32 40 64 128;
# do  
#     echo "find_queue_size=$sz" 
#     sudo ./build/dramhit --find_queue_sz $sz --ht-fill 10 --ht-type 3 --insert-factor $insertFactor --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
# done

# 28 threads
# { set_cycles : 51, get_cycles : 28, set_mops : 1152.941, get_mops : 2100.000 }

# 56 threads
# { set_cycles : 89, get_cycles : 42, set_mops : 1321.348, get_mops : 2800.000 }


#size=268435456
size=134217728
#size=2048
# insertFactor=1
insertFactor=10
numThreads=1
batch=16

for fill in $(seq 10 10 10);
do  
    sudo ./build/dramhit \
    --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue_sz 32 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor \
    --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 \
    --hw-pref 0 --batch-len $batch
done

# #Manually run 2 threads
#  sudo ./build/dramhit \
#     --find_queue_sz 32 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor \
#     --num-threads 2 --numa-split 2 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 \
#     --hw-pref 0 --batch-len $batch

# # extract counter results into tmp.txt, expects output from ./u.sh > 1.txt
# sed -n '/^-------/,/^---/p' 1.txt > tmp.txt
