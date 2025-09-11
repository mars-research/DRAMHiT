#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes

# to run: ./collect_macro_benchmark.sh 
# from within work dir


echo "Collecting reprobe stats on: <8gb> <dual> <128 threads> ʕ•ᴥ•ʔ"

test=$1
numa_policy=$2
numThreads=$3
# elif [ "$numa_policy" = "dual" ]; then
numa_policy=1

# size=536870912 # 8gb
size=268435456 
insertFactor=1
readFactor=100
numThreads=128

# 'Constants' hash table types
DRAMHIT=3
GROWT=6
CLHT=7
UMAP=8
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
    --find_queue 64 --ht-fill $fill --ht-type $2 --insert-factor $insertFactor --read-factor $readFactor --read-snapshot 1\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew 0.01\
    --hw-pref $3 --batch-len 16"
   
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
cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DDRAMHiT_VARIANT=2023 -DDATA_GEN=HASH -DBUCKETIZATION=OFF -DBRANCH=branched -DUNIFORM_PROBING=OFF -DGROWT=OFF -DCLHT=OFF
cmake --build /opt/DRAMHiT/build
run_ht_dual dramhit_2023 $DRAMHIT 0

rm /opt/DRAMHiT/build/CMakeCache.txt
cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DDRAMHiT_VARIANT=2025_INLINE -DDATA_GEN=HASH -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DCAS_NO_ABSTRACT=ON -DREAD_BEFORE_CAS=ON
cmake --build /opt/DRAMHiT/build
run_ht_dual dramhit_inline_uniform $DRAMHIT 0

rm /opt/DRAMHiT/build/CMakeCache.txt
cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DDATA_GEN=HASH -DGROWT=ON -DCLHT=ON -DCAS_NO_ABSTRACT=OFF
cmake --build /opt/DRAMHiT/build
run_ht_dual GROWT $GROWT 1
run_ht_dual TBB $TBB 1
run_ht_dual CLHT $CLHT 1


