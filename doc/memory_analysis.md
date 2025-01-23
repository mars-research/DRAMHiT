Intel® Xeon® Gold 6254 Processor
    Total Cores - 18
    Total Threads - 36
    Processor Base Frequency - 3.10 GHz
    Memory Types - DDR4-2933
    Maximum Memory Speed - 2933 MHz
    Max # of Memory Channels - 6 

https://www.intel.com/content/www/us/en/products/sku/192451/intel-xeon-gold-6254-processor-24-75m-cache-3-10-ghz/specifications.html

Dandelion Machine specs
    Commodity Server Two-socket 18-core Intel Xeon Gold 6254
    72 h/w threads in total (incl. hyper-threads)
    System Memory 8× 32GB DDR4-2933 (256GB in total)

Bandwidth of 1 dimm
> 2933 * 8 = 23.464 Gb/s

Bandwidth of using 4 Channels
> 23.464 * 4 = 93.856 Gb/s

---
Cache Lines (64 bytes)
1 dim
> 366_625_000 cache line reads or writes per second

To saturate bandwidth need to request a cache line every 1/366_625_000 seconds. 

4 dims
> 1_466_500_000 cache line reads or writes per second

To saturate bandwidth need to request a cache line every 1/1_466_500_000 seconds 
> 1/1_466_500_000 seconds = ~.68 ns

Using all 18 cores for memory operations would mean a request every ~12 ns
> 18/1_466_500_000 = ~12 ns

Or assuming the base frequency of the processor, 3.1 Ghz 
> (18/1_466_500_000)* 3100000000 = ~38 cycles

Gives each core a cycle budget of 38 cycles (76 cycles with 2 threads)

Using both sockets, 8 dim theoretical bandwidth
> 366_625_000*8 = 2_933_000_000 cache line reads or writes per second

Estimating for latency of random reads
> 2_933_000_000 *(85.4/127.8) = ~1_959_923_318

DRAMHiT Random Memory Reads Latency (Intel Xeon Gold 6142)
> 85.4/127.8 = ~0.67
