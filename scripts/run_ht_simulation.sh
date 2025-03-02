
TOTAL_SIZE=32768
FILL_F=0.9
N=$(echo "$TOTAL_SIZE * $FILL_F / 1" | bc)

TABLE_PROP=0.8
FIRST_LEVEL_TABLE_SIZE=$(echo "$TOTAL_SIZE * $TABLE_PROP" | bc)
SECOND_LEVEL_TABLE_SIZE=$(echo "$TOTAL_SIZE - $FIRST_LEVEL_TABLE_SIZE" | bc)

K=4
B=$(echo "$FIRST_LEVEL_TABLE_SIZE / $K" | bc)
echo "Total table size $TOTAL_SIZE, first level $FIRST_LEVEL_TABLE_SIZE, second level $SECOND_LEVEL_TABLE_SIZE"
echo "number items inserted $N"
echo "fill factor $FILL_F"
echo "N $N B $B K $K"

python /opt/mnt/DRAMHiT/scripts/simulation.py --N $N --B $B --K $K --trials 10
