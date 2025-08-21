FILE="DIRECTORY_REMOTE.txt"
echo "Directory mode" >> ${FILE}

for fill in $(seq 10 10 90); 
do
    numa_policy=3
    numThreads=64
    insertFactor=1
    readFactor=500
    size=536870912
    cmd="--find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor --read-snapshot 1\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
    echo $(pwd)/build/dramhit $cmd >> "$FILE"
    sudo $(pwd)/build/dramhit $cmd | grep -E "get_mops|Read\ssnapshot\siter\s500|Read\ssnapshot\siter\s0" >> "$FILE"
done