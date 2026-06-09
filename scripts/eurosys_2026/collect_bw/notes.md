

FILE_NAME=output.txt
./collect_amd.sh 3250  single-local 64 r &> $FILE_NAME
./collect_amd.sh 3250  single-local 64 rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 stream_rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 ratio &>> $FILE_NAME

r
mem: 3435973836800 bytes, took 10.038 sec, bandwidth: 342.3 GB/s
rw
mem: 6871947673600 bytes, took 25.319 sec, bandwidth: 271.4 GB/s
stream+rw
mem: 7730941132800 bytes, took 26.031 sec, bandwidth: 297.0 GB/s
1.5r_1w
mem: 6871947673600 bytes, took 20.976 sec, bandwidth: 280.0 GB/s

> python plot_bw.py amd/dramblast.txt amd/dramhit.txt amd/growt.txt 



# intel


> python plot_bw.py intel/dramblast.txt intel/dramhit.txt intel/growt.txt 

r: 254
rw: 289
stream+rw: 281
1.5r_1w: 284


u1399218@node-0:/opt/DRAMHiT/scripts/eurosys_2026/collect_upi$ sudo /opt/DRAMHiT/tools/mlc/mlc --bandwidth_matrix -U
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --bandwidth_matrix -U 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes
Measuring Memory Bandwidths between nodes within system 
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using Read-only traffic type
                Numa node
Numa node            0       1
       0        246871.0        120242.6
       1        120368.5        247393.3




u1399218@node-0:/opt/DRAMHiT/scripts/eurosys_2026/collect_upi$ sudo /opt/DRAMHiT/tools/mlc/mlc --bandwidth_matrix -U -W5
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --bandwidth_matrix -U -W5 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes
Measuring Memory Bandwidths between nodes within system 
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
                Numa node
Numa node            0       1
       0        159004.2        147900.4
       1        147842.0        159100.3