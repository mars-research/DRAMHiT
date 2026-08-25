# wrapper script to run dramblast
# Ensure correct usage
if [ "$#" -ne 4 ]; then
     echo "Usage: $0 <numa_policy> <num_threads> <amd|intel> <test>ʕ•ᴥ•ʔ"
     exit 1
fi

numa_policy=$1
numThreads=$2
platform=$3
test=$4

HOME_DIR=/opt/DRAMHiT
size=4194304
# size=16777216
BW=15
readFactor=1

if [ "$numa_policy" = "single-local" ]; then
    numa_policy=4
elif [ "$numa_policy" = "single-remote" ]; then
    numa_policy=3
elif [ "$numa_policy" = "single-mixed" ]; then
    numa_policy=9
elif [ "$numa_policy" = "dual-local" ]; then
    numa_policy=8
elif [ "$numa_policy" = "dual-remote" ]; then
    numa_policy=7
elif [ "$numa_policy" = "dual-even" ]; then
    numa_policy=6
fi

if [ "$test" = "rand_r" ]; then
workload=0
elif [ "$test" = "seq_r" ]; then
workload=1
elif [ "$test" = "rand_rw" ]; then
workload=2
elif [ "$test" = "ratio" ]; then
workload=3
elif [ "$test" = "seq_rw" ]; then
workload=4
elif [ "$test" = "stream_rw" ]; then
workload=5
elif [ "$test" = "cas" ]; then
workload=6
fi

cmd="--num-threads $numThreads --numa-split $numa_policy --mode $BW --ht-size $size --sequential $workload --read-factor $readFactor"
echo $HOME_DIR/build/dramhit $cmd

if [ "$platform" = "amd" ]; then
    perf stat -a -M umc_mem_bandwidth,umc_mem_read_bandwidth,umc_mem_write_bandwidth -I 10 -- $HOME_DIR/build/dramhit $cmd
else
    perf stat -e unc_m_cas_count.all,unc_m_cas_count.rd,unc_m_cas_count.wr -I 10 -- $HOME_DIR/build/dramhit $cmd > bw.txt
    perf stat -e unc_upi_txl_flits.all_data,unc_upi_txl_flits.non_data,unc_upi_clockticks -I 10 -- $HOME_DIR/build/dramhit $cmd > upi_out.txt
fi
