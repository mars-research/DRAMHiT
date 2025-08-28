# to run: gnuplot plot.gnuplot
set terminal pngcairo size 900,1000 enhanced font 'Arial,12'
set output "combined.png"

set datafile separator ","
set key outside bottom right

# Line styles
set style line 1 lc rgb "#FF0000" lw 4 pt 7      # red
set style line 2 lc rgb "#FF8080" lw 4 pt 5      # light red
set style line 3 lc rgb "#0000FF" lw 4 pt 9      # blue
set style line 4 lc rgb "#80C0FF" lw 4 pt 9      # light blue

set multiplot layout 2,1 title "Reprobe Factor and MOPS vs Fill" font ",14"

####################
# Top plot (Reprobe Factor)
####################
set xlabel "Fill"
set ylabel "Reprobe Factor"

plot "branched_no_bucket_linear_reprobes.csv" using 1:2 with linespoints ls 1 title "Linear, Branch, No Bucket", \
     "branched_bucket_linear_reprobes.csv"    using 1:2 with linespoints ls 2 title "Linear, Branch, Bucket", \
     "simd_bucket_uniform_reprobes.csv"       using 1:2 with linespoints ls 4 title "Uniform, Simd, Bucket", \
     "simd_bucket_linear_reprobes.csv"        using 1:2 with linespoints ls 3 title "Linear, Simd, Bucket"

####################
# Bottom plot (MOPS)
####################
set xlabel "Fill"
set ylabel "MOPS"

plot "branched_no_bucket_linear_reprobes.csv" using 1:3 with linespoints ls 1 title "Linear, Branch, No Bucket", \
     "branched_bucket_linear_reprobes.csv"    using 1:3 with linespoints ls 2 title "Linear, Branch, Bucket", \
     "simd_bucket_uniform_reprobes.csv"       using 1:3 with linespoints ls 4 title "Uniform, Simd, Bucket", \
     "simd_bucket_linear_reprobes.csv"        using 1:3 with linespoints ls 3 title "Linear, Simd, Bucket"

unset multiplot
unset output
