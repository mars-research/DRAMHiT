# to run: gnuplot plot.gnuplot

set terminal pngcairo size 900,600 enhanced font 'Arial,12'
set output "plot.png"

# Labels
set xlabel "Fill"
set ylabel "Reprobe Factor"

# Legend (key) outside bottom right
set key outside bottom right

# Line styles
set style line 1 lc rgb "red"    lw 4 pt 7
set style line 2 lc rgb "blue"   lw 4 pt 5
set style line 3 lc rgb "green"  lw 4 pt 9

# Plot CSV files
set datafile separator ","

plot "branched_no_bucket_linear_reprobes.csv" using 1:2 with linespoints ls 1 title "Linear, No Bucket", \
     "simd_bucket_linear_reprobes.csv"   using 1:2 with linespoints ls 2 title "Linear, Bucket", \
     "simd_bucket_uniform_reprobes.csv"  using 1:2 with linespoints ls 3 title "Uniform, Bucket"
