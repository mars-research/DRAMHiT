#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes



echo "Collecting reprobe stats on: <8gb> <single-local> <64 threads> <reads_factor=1:write_factor=1> ʕ•ᴥ•ʔ"

test=$1
numa_policy=$2
numThreads=$3
# if [ "$numa_policy" = "single-local" ]; then
numa_policy=4  

size=536870912 # 8gb
insertFactor=1
readFactor=1
numThreads=64


# Produces raw output of all runs in args1.txt and plottable data in args1.csv
run_ht_local() 
{
file_name=$1.txt
> $file_name #create or empty file
for fill in $(seq 10 10 90);
do  
    cmd="--perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue 64 --ht-fill $fill --ht-type 3 --insert-factor $insertFactor --read-factor $readFactor --read-snapshot 1\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref 0 --batch-len 16"
   
    echo "Command executed: "$(pwd)/build/dramhit $cmd >> $file_name
    sudo $(pwd)/build/dramhit $cmd >> $file_name
    echo >> $file_name # New line
done    

# just fills we used on new lines
fills="10\\n20\\n30\\n40\\n50\\n60\\n70\\n80\\n90"

# Match on reprobe factor results & save to temp file
grep reprobe_factor "$file_name" | sed 's/{reprobe_factor: //;s/}//' > tmp.txt

# Write header of csv
echo "fill,reprobe_factor" > "$1.csv"

# Append the combination of both files & seperate by ","
paste -d, <(echo -e "$fills") tmp.txt >> "$1.csv"

# Clean up
rm tmp.txt

}


cmake -S . -B build -DDATA_GEN=HASH -DCALC_STATS=ON -DOLD_DRAMHiT=OFF -DBUCKETIZATION=OFF -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local branched_no_bucket_linear_reprobes

cmake -S . -B build -DDATA_GEN=HASH -DCALC_STATS=ON -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
cmake --build ./build
run_ht_local simd_bucket_linear_reprobes

cmake -S . -B build -DDATA_GEN=HASH -DCALC_STATS=ON -DOLD_DRAMHiT=OFF -DBUCKETIZATION=ON -DBRANCH=simd -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=ON
cmake --build ./build
run_ht_local simd_bucket_uniform_reprobes

``