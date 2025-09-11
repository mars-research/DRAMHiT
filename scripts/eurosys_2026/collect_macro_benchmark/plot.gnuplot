# to run: gnuplot plot.gnuplot
set terminal pngcairo size 900,1000 enhanced font 'Arial,12'
set output "combined.png"

set datafile separator ","
set key outside bottom right

# Line styles
set style line 1 lc rgb "#003366" lw 4 pt 7      # dark blue
set style line 2 lc rgb "#E31B23" lw 4 pt 5      # red
set style line 3 lc rgb "#FFC325" lw 4 pt 9      # yellow
set style line 4 lc rgb "pink" lw 4 pt 9      
set style line 5 lc rgb "#4DAF4A" lw 4 pt 11     # green
set style line 6 lc rgb "#984EA3" lw 4 pt 13     # purple

set multiplot layout 2,1 title "Mops vs Fill" font ",14"

####################
# Top plot (Reprobe Factor)
####################
set xlabel "Fill"
set ylabel "Set Mops"

plot "results/dramhit_2023.csv"             using 1:2 with linespoints ls 1 title "Dramhit 2023", \
     "results/dramhit_inline_uniform.csv"   using 1:2 with linespoints ls 2 title "Dramhit inline Uniform", \
     "results/CLHT.csv"                     using 1:2 with linespoints ls 4 title "clht", \
     "results/GROWT.csv"                    using 1:2 with linespoints ls 3 title "growt", \
     "results/TBB.csv"                      using 1:2 with linespoints ls 5 title "TBB"

####################
# Bottom plot (MOPS)
####################
set xlabel "Fill"
set ylabel "Get Mops"

plot "results/dramhit_2023.csv"             using 1:3 with linespoints ls 1 title "Dramhit 2023", \
     "results/dramhit_inline_uniform.csv"   using 1:3 with linespoints ls 2 title "Dramhit inline Uniform", \
     "results/CLHT.csv"                     using 1:3 with linespoints ls 4 title "clht", \
     "results/GROWT.csv"                    using 1:3 with linespoints ls 3 title "growt", \
     "results/TBB.csv"                      using 1:3 with linespoints ls 5 title "TBB"

unset multiplot
unset output
