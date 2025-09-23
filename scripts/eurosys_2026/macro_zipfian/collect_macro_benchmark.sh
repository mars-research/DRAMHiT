#  rm build/CMakeCache.txt
#     cmake -S . -B build
#     cmake --build build/ --clean-first
#  sudo apt-get install cmake-curses-gui
#  nix develop --extra-experimental-features nix-command --extra-experimental-features flakes

# to run: ./collect_macro_benchmark.sh 
# from within work dir


echo "Collecting zipfian stats on: <8gb> <dual> <128 threads> ʕ•ᴥ•ʔ"

# elif [ "$numa_policy" = "dual" ]; then
numa_policy=1
size=536870912
insertFactor=100
readFactor=100
numThreads=128

# 'Constants' hash table types
DRAMHIT=3
GROWT=6
CLHT=7
DRAMHIT23=8
TBB=9
fill=70
# Produces raw output of all runs in args1.txt and plottable data in args1.csv
run_ht_dual() 
{
file_name_txt=results/$1.txt
file_name_csv=results/$1.csv

touch $file_name_txt
echo "skew,get_mops,set_mops" > $file_name_csv

for skew in $(seq -f "%.2f" 0.80 0.05 1.10);
do  
    echo "Generating $file_name_txt (fill=$fill)"

    cmd="--find_queue 64 --ht-fill $fill --ht-type $2 --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew $skew\
    --hw-pref $3 --batch-len 16 --drop-caches true"
   
    sudo /opt/DRAMHiT/build/dramhit $cmd > $file_name_txt
    grep get_mops "$file_name_txt" | sed 's/.*get_mops : \([0-9.]*\).*/\1/' > tmp1.txt
    grep set_mops "$file_name_txt" | sed 's/.*set_mops : \([0-9.]*\).*/\1/' > tmp2.txt
    paste -d, <(echo -e "$skew") tmp1.txt tmp2.txt >> $file_name_csv
done    
# Clean up
rm tmp1.txt tmp2.txt $file_name_txt
}

# sudo rm -rf /opt/DRAMHiT/build
# mkdir -p /opt/zipfian
# mkdir -p ./results

# cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DPREFETCH=DOUBLE -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON 
# cmake --build /opt/DRAMHiT/build
# run_ht_dual dramhit_2025_best_uniform $DRAMHIT 0

# cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DPREFETCH=DOUBLE -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=OFF -DREAD_BEFORE_CAS=ON
# cmake --build /opt/DRAMHiT/build
# run_ht_dual dramhit_2025_best_linear $DRAMHIT 0
# run_ht_dual dramhit_2023 $DRAMHIT23 0


cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DGROWT=ON
cmake --build /opt/DRAMHiT/build
run_ht_dual GROWT $GROWT 1


