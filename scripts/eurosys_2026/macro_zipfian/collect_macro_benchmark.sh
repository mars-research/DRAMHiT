echo "Collecting zipfian stats on: <8gb> <dual> <128 threads> ʕ•ᴥ•ʔ"

numa_policy=1
size=536870912
insertFactor=100
readFactor=100
numThreads=128

DRAMHIT=3
GROWT=6
CLHT=7
DRAMHIT23=8
TBB=9
fill=70

run_ht_dual()
{
file_name_txt=results/$1.txt
file_name_csv=results/$1.csv

touch $file_name_txt
echo "skew,get_mops,set_mops" > $file_name_csv

for skew in $(seq -f "%.2f" 0.80 0.05 1.10) 0.20 0.40; do
    echo "Generating $file_name_txt (fill=$fill)"

    cmd="--find_queue 64 --ht-fill $fill --ht-type $2 --insert-factor $insertFactor --read-factor $readFactor\
    --num-threads $numThreads --numa-split $numa_policy --no-prefetch 0 --mode 11 --ht-size $size --skew $skew\
    --hw-pref 0 --batch-len 16 --drop-caches true"

    sudo /opt/DRAMHiT/build/dramhit $cmd > $file_name_txt
    grep get_mops "$file_name_txt" | sed 's/.*get_mops : \([0-9.]*\).*/\1/' > tmp1.txt
    grep set_mops "$file_name_txt" | sed 's/.*set_mops : \([0-9.]*\).*/\1/' > tmp2.txt
    paste -d, <(echo -e "$skew") tmp1.txt tmp2.txt >> $file_name_csv
done
# Clean up
rm tmp1.txt tmp2.txt $file_name_txt
}

mkdir -p results
cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build -DPREFETCH=DOUBLE -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd -DUNIFORM_PROBING=ON -DGROWT=ON
cmake --build /opt/DRAMHiT/build

/opt/DRAMHiT/scripts/prefetch_control.sh off
run_ht_dual dramhit_2025 $DRAMHIT
run_ht_dual dramhit_2023 $DRAMHIT23

/opt/DRAMHiT/scripts/prefetch_control.sh on
run_ht_dual GROWT $GROWT
