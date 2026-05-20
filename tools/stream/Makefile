# https://www.cs.virginia.edu/stream/ref.html

run:
	gcc -O3 -fopenmp -mcmodel=medium -DSTREAM_ARRAY_SIZE=335000000 -DNTIMES=1000 stream.c -lm
	./a.out


# -------------------------------------------------------------
# STREAM version $Revision: 5.10 $
# -------------------------------------------------------------
# This system uses 8 bytes per array element.
# -------------------------------------------------------------
# Array size = 335000000 (elements), Offset = 0 (elements)
# Memory per array = 2555.8 MiB (= 2.5 GiB).
# Total memory required = 7667.5 MiB (= 7.5 GiB).
# Each kernel will be executed 1000 times.
#  The *best* time for each kernel (excluding the first iteration)
#  will be used to compute the reported bandwidth.
# -------------------------------------------------------------
# Number of Threads requested = 64
# Number of Threads counted = 64
# -------------------------------------------------------------
# Your clock granularity/precision appears to be 1 microseconds.
# Each test below will take on the order of 18388 microseconds.
#    (= 18388 clock ticks)
# Increase the size of the arrays if this shows that
# you are not getting at least 20 clock ticks per test.
# -------------------------------------------------------------
# WARNING -- The above is only a rough guideline.
# For best results, please be sure you know the
# precision of your system timer.
# -------------------------------------------------------------
# Function    Best Rate MB/s  Avg time     Min time     Max time
# Copy:          289336.8     0.018638     0.018525     0.026401
# Scale:         188030.3     0.028606     0.028506     0.034556
# Add:           202253.9     0.039850     0.039752     0.045903
# Triad:         203199.7     0.039660     0.039567     0.044223
# -------------------------------------------------------------
# Solution Validates: avg error less than 1.000000e-13 on all three arrays
# -------------------------------------------------------------