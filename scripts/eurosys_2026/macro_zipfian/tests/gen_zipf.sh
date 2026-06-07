# set -e 
#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
#  python ./scripts/verify_dataset.py 
# rm /opt/DRAMHiT/cache/*.bin
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
    # size=16777216
   
    # size=4194304  # 67Mb

    insertFactor=0
    readFactor=0
fi


HASHJOIN=13
ZIPFIAN=14
UNIFORM=11
BW=15

rsize=536870912

HOME_DIR=/opt/DRAMHiT
cmake -S $HOME_DIR -B $HOME_DIR/build -DBENCHMARK_BACKEND=VTUNE -DCALC_STATS=OFF -DCPUFREQ_MHZ=2100 -DDRAMHiT_VARIANT=2025 -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DPREFETCH=DOUBLE
cmake --build $HOME_DIR/build

for skew in .01 .1 .2 .3 .4 .5 .6 .7 .8 .9 1.0 1.1 1.2;
do

fill=10
    cmd="--find_queue 64 --ht-fill $fill --ht-type $DRAMHIT --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --seed 2190830198 --numa-split $numa_policy --no-prefetch 0 --mode $ZIPFIAN --ht-size $size --skew $skew\
    --hw-pref 0 --batch-len 16 --relation_r_size $rsize --scale_factor 50"

    sudo $HOME_DIR/build/dramhit $cmd 
    echo $(pwd)/build/dramhit $cmd 

done
