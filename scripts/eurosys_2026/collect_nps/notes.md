
# Latency matrix:
> sudo ./tools/mlc/mlc --latency_matrix -h
## nps1
u1399218@node-0:/opt/DRAMHiT$ sudo ./tools/mlc/mlc --latency_matrix -h
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --latency_matrix -h 

Using buffer size of 1800.000MiB
Measuring idle latencies for random access (in ns)...
                Numa node
Numa node            0
       0         113.0

## nps4
u1399218@node-0:/opt/DRAMHiT$ sudo ./tools/mlc/mlc --latency_matrix -h
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --latency_matrix -h 

Using buffer size of 1800.000MiB
Measuring idle latencies for random access (in ns)...
                Numa node
Numa node            0       1       2       3
       0         105.6   113.1   118.6   117.7
       1         113.9   105.0   117.8   117.5
       2         116.0   115.8   104.6   112.9
       3         118.4   118.0   114.7   106.5







# Latency under load
>  sudo ./tools/mlc/mlc --loaded_latency -h

## nps1
u1399218@node-0:/opt/DRAMHiT$ sudo ./tools/mlc/mlc --loaded_latency -h
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --loaded_latency -h 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes

Measuring Loaded Latencies for the system
Using all the threads from each core if Hyper-threading is enabled
Using Read-only traffic type
Using large pages for buffers
Inject  Latency Bandwidth
Delay   (ns)    MB/sec
==========================
 00000  493.91   352646.2
 00002  494.00   352823.0
 00008  491.23   351761.7
 00015  491.82   351749.6
 00050  339.79   354548.4
 00100  127.53   246834.7
 00200  123.10   126176.9
 00300  121.94    84863.7
 00400  121.37    62498.1
 00500  117.07    50533.2
 00700  114.51    36528.0
 01000  114.11    25893.7
 01300  113.97    20109.0
 01700  113.86    15547.3
 02500  113.75    10779.3
 03500  113.76     7871.4
 05000  113.69     5685.1
 09000  113.41     3413.5
 20000  113.26     1848.3


 ## nps4
 u1399218@node-0:/opt/DRAMHiT$  sudo ./tools/mlc/mlc --loaded_latency -h
Intel(R) Memory Latency Checker - v3.11b
Command line parameters: --loaded_latency -h 

Using buffer size of 100.000MiB/thread for reads and an additional 100.000MiB/thread for writes

Measuring Loaded Latencies for the system
Using all the threads from each core if Hyper-threading is enabled
Using Read-only traffic type
Using large pages for buffers
Inject  Latency Bandwidth
Delay   (ns)    MB/sec
==========================
 00000  471.66   369264.0
 00002  470.37   369578.7
 00008  469.05   368002.7
 00015  468.12   368022.6
 00050  207.44   371725.4
 00100  118.39   246919.0
 00200  115.22   126237.8
 00300  114.36    84910.4
 00400  113.94    62541.5
 00500  110.58    50574.1
 00700  106.76    36576.1
 01000  106.39    25936.6
 01300  106.30    20150.0
 01700  106.12    15588.4
 02500  106.03    10820.5
 03500  105.94     7913.4
 05000  105.90     5726.8
 09000  105.82     3454.6
 20000  105.74     1888.5








 # dramhit mops
 | Line | set_mops                             | get_mops                             |
|------|--------------------------------------|--------------------------------------|
| 1    | 1858 / 1824 = 1.019x  -> +1.92%     | 4923 / 4646 = 1.060x  -> +5.96%     |
| 2    | 1880 / 1764 = 1.066x  -> +6.58%     | 4705 / 4399 = 1.070x  -> +6.96%     |
| 3    | 1844 / 1832 = 1.007x  -> +0.66%     | 4716 / 4543 = 1.038x  -> +3.81%     |
| 4    | 1833 / 1867 = 0.982x  -> -1.82%     | 4707 / 4491 = 1.048x  -> +4.81%     |
| 5    | 1792 / 1881 = 0.953x  -> -4.73%     | 4592 / 4236 = 1.084x  -> +8.40%     |
| 6    | 1734 / 1949 = 0.890x  -> -11.03%    | 4297 / 4139 = 1.038x  -> +3.82%     |
| 7    | 1656 / 2036 = 0.813x  -> -18.66%    | 4119 / 3979 = 1.035x  -> +3.52%     |
| 8    | 1549 / 1722 = 0.900x  -> -10.05%    | 3691 / 2944 = 1.254x  -> +25.37%    |
| 9    | 1382 / 1626 = 0.850x  -> -15.01%    | 2973 / 2817 = 1.055x  -> +5.54%     |