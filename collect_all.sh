
FILE="DIRECTORY.txt"
echo "NOTE: single local <-> numa_policy=4\n dual <-> numa_policy=1" >> ${FILE}

for fill in $(seq 10 10 90); 
do
    numa_policy=4
    numThreads=64
    insertFactor=1
    readFactor=10
    size=536870912
    cmd="--find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd >> "$FILE"
    sudo $(pwd)/build/dramhit $cmd | grep "get_mops" >> "$FILE"
done

# dual
for fill in $(seq 10 10 90); 
do
    numa_policy=1
    numThreads=128
    insertFactor=1
    readFactor=10
    size=536870912
    cmd="--find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd >> "$FILE"
    sudo $(pwd)/build/dramhit $cmd | grep "get_mops" >> "$FILE"
done

# read factor 500
for fill in $(seq 10 10 90); 
do
    numa_policy=4
    numThreads=64
    insertFactor=1
    readFactor=500
    size=536870912
    cmd="--find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd >> "$FILE"
    sudo $(pwd)/build/dramhit $cmd | grep "get_mops" >> "$FILE"
done

# read factor 500
for fill in $(seq 10 10 90); 
do
    numa_policy=1
    numThreads=128
    insertFactor=1
    readFactor=500
    size=536870912
    cmd="--find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd >> "$FILE"
    sudo $(pwd)/build/dramhit $cmd | grep "get_mops" >> "$FILE"
done