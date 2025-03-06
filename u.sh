#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first

size=268435456
insertFactor=30
numThreads=56
batch=16

for fill in $(seq 10 10 90);
do  
    sudo ./build/dramhit --find_queue_sz 32 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
done


# grep command to show results
# grep -E "find_queue_size|mops" 1.txt
# [12-16],[24,32,40,64,128]
# for sz in 8 9 10 11 12 13 14 15 16 24 32 40 64 128;
# do  
#     echo "find_queue_size=$sz" 
#     sudo ./build/dramhit --find_queue_sz $sz --ht-fill 10 --ht-type 3 --insert-factor $insertFactor --num-threads $numThreads --numa-split 1 --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01 --hw-pref 0 --batch-len $batch
# done

