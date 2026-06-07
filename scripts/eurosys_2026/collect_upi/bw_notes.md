# MLC Random read
> sudo /opt/DRAMHiT/tools/mlc/mlc --bandwidth_matrix -U
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --bandwidth_matrix -U 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes
Measuring Memory Bandwidths between nodes within system 
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using Read-only traffic type
                Numa node
Numa node            0       1
       0        161312.2    55389.3
       1        55351.6     161276.7

# MLC Random 1Read 1Write
> sudo /opt/DRAMHiT/tools/mlc/mlc --bandwidth_matrix -U -W5
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --bandwidth_matrix -U -W5 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes
Measuring Memory Bandwidths between nodes within system 
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
                Numa node
Numa node            0       1
       0        126540.1  85279.5
       1        85158.3   126795.6


# Our BW test: 1 read 1 write
> /opt/DRAMHiT/build/dramhit --num-threads 72 --numa-split 4 --mode 15 --ht-size 16777216 --sequential 2
141 GB Total, ~70.5GB Reads, ~70.5GB Writes


# Our BW test: read
> /opt/DRAMHiT/build/dramhit --num-threads 72 --numa-split 4 --mode 15 --ht-size 16777216 --sequential 0

155GB reads
