#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes

# to run: ./collect_macro_benchmark.sh 
# from within work dir


test=$1
numa_policy=$2
numThreads=$3
# elif [ "$numa_policy" = "dual" ]; then
numa_policy=1

# size=536870912 # 8gb
size=268435456
numThreads=128

# 'Constants' hash table types
DRAMHIT25=3
GROWT=6
CLHT=7
DRAMHIT23=8
TBB=9

# Produces raw output of all runs in args1.txt and plottable data in args1.csv
run_ht_dual() 
{
file_name_txt=results/$1.txt
file_name_csv=results/$1.csv

> $file_name_txt #create or empty file
for fill in $(seq 10 10 90);
do  
    echo "Generating $file_name_txt (fill=$fill)"

    cmd="--perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv \
    --find_queue 64 --ht-fill $fill --ht-type $2 \
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size \
    --hw-pref $3 --batch-len 16 --relation_r_size $size"
   
    echo "Command executed: "/opt/DRAMHiT/build/dramhit $cmd >> $file_name_txt
    sudo /opt/DRAMHiT/build/dramhit $cmd >> $file_name_txt
    echo >> $file_name_txt # New line
done    

# just fills we used on new lines
fills="10\\n20\\n30\\n40\\n50\\n60\\n70\\n80\\n90"

# Match on reprobe factor results & save to temp file
grep get_mops "$file_name_txt" | sed 's/.*set_mops : \([0-9.]*\).*/\1/' > tmp1.txt

grep get_mops "$file_name_txt" | sed 's/.*get_mops : \([0-9.]*\).*/\1/' > tmp2.txt

# Write header of csv
echo "fill,set_mops,get_mops" > $file_name_csv

# Append the combination of both files & seperate by ","
paste -d, <(echo -e "$fills") tmp1.txt tmp2.txt >> $file_name_csv
# Clean up
rm tmp1.txt tmp2.txt
}

rm /opt/DRAMHiT/build/CMakeCache.txt
cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DDRAMHiT_VARIANT=2025_INLINE -DDATA_GEN=HASH -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DGROWT=ON -DCLHT=ON 
cmake --build /opt/DRAMHiT/build
run_ht_dual dramhit_2023 $DRAMHIT23 0
run_ht_dual dramhit_2025 $DRAMHIT25 0
run_ht_dual GROWT $GROWT 1
run_ht_dual TBB $TBB 1
run_ht_dual CLHT $CLHT 1


