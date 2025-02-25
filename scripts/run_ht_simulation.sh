
N=262144
FILL_F=1
TABLE_SIZE=$(echo "$N * $FILL_F / 1" | bc)
K=4
B=$(echo "$TABLE_SIZE / $K" | bc)
echo "level 0 table size $TABLE_SIZE"
echo "number items inserted $N"
echo "fill factor $FILL_F"
echo "N $N B $B K $K"

python simulation.py --N $N --B $B --K $K --trials 10
