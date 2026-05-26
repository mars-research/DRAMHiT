#  To run: nohup bash ./collect.sh large even 64 amd
# nohup bash ./collect.sh large single-local 64 intel

DRAMHIT=3
GROWT=6
DRAMHIT23=8

# Ensure correct usage
if [ "$#" -ne 4 ]; then
     echo "Usage: $0 <small|large> <numa_policy> <num_threads> <amd|intel> ʕ•ᴥ•ʔ"
     exit 1
fi

test=$1
numa_policy=$2
numThreads=$3
arch=$4

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

elif [ "$test" = "large" ]; then
    # size=4294967296
    # size=268435456
    size=536870912
    insertFactor=1000
    readFactor=1000
fi

ZIPFIAN=11


HOME_DIR=/opt/DRAMHiT

if [ "$arch" = "amd" ]; then
    cmake -S $HOME_DIR -B $HOME_DIR/build -DCPUFREQ_MHZ=3250 -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE -DGROWT=ON
else
    cmake -S $HOME_DIR -B $HOME_DIR/build -DCPUFREQ_MHZ=2500 -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE -DGROWT=ON
fi

cmake --build $HOME_DIR/build


EVENTS="unc_m_cas_count.all,unc_m_cas_count.rd,unc_m_cas_count.wr"
EVENTS="umc_mem_bandwidth"
# FILE_NAME=dramblast.txt
# lscpu &> $FILE_NAME
# for fill in $(seq 10 10 90);
# do
#     cmd="--find_queue 64 --ht-fill $fill --ht-type $DRAMHIT --insert-factor $insertFactor --read-factor $readFactor\
#     --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode $ZIPFIAN --ht-size $size --skew 0.01\
#     --hw-pref 0 --batch-len 16 --relation_r_size 1 --seed 1"
    
#     if [ "$arch" = "amd" ]; then
#         sudo /usr/bin/perf stat -a -M umc_mem_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
#     else
#         sudo /usr/bin/perf stat -e unc_m_cas_count.all -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
#     fi

#     echo $(pwd)/build/dramhit $cmd &>> $FILE_NAME
# done



# FILE_NAME=dramhit.txt
# lscpu &> $FILE_NAME
# for fill in $(seq 10 10 90);
# do
#     cmd="--find_queue 64 --ht-fill $fill --ht-type $DRAMHIT23 --insert-factor $insertFactor --read-factor $readFactor\
#     --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode $ZIPFIAN --ht-size $size --skew 0.01\
#     --hw-pref 0 --batch-len 16 --relation_r_size 1 --seed 1"
    
#     if [ "$arch" = "amd" ]; then
#         sudo /usr/bin/perf stat -a -M umc_mem_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
#     else
#         sudo /usr/bin/perf stat -e unc_m_cas_count.all -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
#     fi

#     echo $(pwd)/build/dramhit $cmd &>> $FILE_NAME
# done




FILE_NAME=growt.txt
lscpu &> $FILE_NAME
for fill in $(seq 10 10 90);
do
    cmd="--find_queue 64 --ht-fill $fill --ht-type $GROWT --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode $ZIPFIAN --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16 --relation_r_size 1 --seed 1"
    
    if [ "$arch" = "amd" ]; then
        sudo /usr/bin/perf stat -a -M umc_mem_bandwidth -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
    else
        sudo /usr/bin/perf stat -e unc_m_cas_count.all -I 1000 -- $HOME_DIR/build/dramhit $cmd  &>> $FILE_NAME
    fi
    echo $(pwd)/build/dramhit $cmd &>> $FILE_NAME
done


