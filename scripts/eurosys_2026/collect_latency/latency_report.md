# Memory latency report — Xeon Max 9462 (HBM, flat mode)

Date: 2026-09-24. Raw outputs are in `results_hbm/`.

## Machine / setup

| | |
|---|---|
| CPU | 2x Intel Xeon CPU Max 9462, 32 cores/socket, HT on (128 logical CPUs) |
| NUMA | node 0/1 = DDR5 (128 GB each, has CPUs); node 2/3 = HBM2e (64 GB each, CPU-less, flat mode) |
| Distances | node0→{0,1,2,3} = 10, 21, 13, 23 |
| Frequency | fixed 2.7 GHz (scaling min=max), turbo off, C-states disabled. TSC = 2.7 GHz, so **1 cycle = 0.370 ns** |
| Hugepages | 1 GB pages on every node (chase array), 2 MB pages for loaders |
| MLC | Intel MLC v3.11b (run with sudo, HW prefetchers disabled by MLC) |

The latency thread is always on **CPU 0 (socket 0)**. "Local" means socket 0 memory (DDR node 0, HBM node 2), and "remote" means socket 1 memory (DDR node 1, HBM node 3).

### What latency.c measures

A dependent pointer chase (plain `mov` loads, `prefetch_type=0`) over a 1 GB random permutation of 16M cachelines on a single 1 GB hugepage. This defeats OOO overlap, the HW prefetchers and the TLB. Loaded mode starts one loader thread on each logical CPU of the loader socket (except the latency core and its HT sibling). Each loader does random accesses over its own 128 MB buffer.

### Changes made to latency.c for this run

1. **Loaders on CPU-less HBM nodes.** Loaders used to be pinned to the CPUs of `mem_node`. HBM nodes 2/3 have no CPUs, so **0 loaders were spawned**, and that is why the README says "idle is same as loaded" on this machine. Loaders now fall back to the nearest node that has CPUs (node 2 → socket 0, node 3 → socket 1). This matches the existing DDR behavior, where loaders are local to the memory under test.
2. **Load-only loaders.** New optional 7th argument `loader_write` (default `1` = original load+store behavior, `0` = loads only). The old 6-argument command line works as before.
3. **Loader bandwidth report.** Loaders count the lines they touch, and loaded runs print `Loader traffic : X GB/s`.

```
./latency <mem_node> <cpu_node> <iters> <loaded> <lookahead> <prefetch_type> [loader_write]
./run_latency.sh <outdir>      # sweep used here
./run_mlc.sh <outdir>          # MLC equivalents (SWEEP=1 for full delay curves)
```

---

## 1. Idle latency

| Memory | latency.c cycles | latency.c ns | MLC idle (default) ns | MLC idle (`-r -L`, 1 GB buf) ns | MLC latency_matrix ns |
|---|---:|---:|---:|---:|---:|
| node 0 DDR local   | 302.7 | 112.1 | 108.6 | 109.7 | 111.7 |
| node 2 HBM local   | 365.9 | 135.5 | 132.8 | 132.3 | 137.6 |
| node 1 DDR remote  | 594.3 | 220.1 | 207.8 | 209.7 | 238.7 |
| node 3 HBM remote  | 657.9 | 243.7 | 239.0 | 242.9 | 243.2 |

- latency.c agrees with MLC to within about 2–6%. latency.c is slightly higher, most likely due to loop overhead and the `rdtsc` bracket.
- **Idle HBM is about 23 ns (about 63 cycles, +21%) slower than DDR**, both locally and remotely. HBM helps bandwidth, not latency.
- A remote access adds about 100–110 ns over UPI for both memory types.
- Remote DDR had more run-to-run noise (samples 581–638 cycles).

## 2. Loaded latency — latency.c

Pointer chase from CPU 0 while loaders run on the socket local to the target memory. The results come from `results_hbm/latency_c_run2_bw` (3 iterations). Run 1 (5 iterations) is in brackets, which shows the run-to-run spread.

| Memory (loader socket) | Loaders | Latency cycles | ns | Loader traffic |
|---|---|---:|---:|---:|
| node 0 DDR local (S0)  | 62 load-only  | 392.7 [397.7] | 145.5 | 170 GB/s rd |
| node 0 DDR local (S0)  | 62 load+store | 710.8 [739.5] | 263.3 | 82 GB/s rd + 82 GB/s wb |
| node 2 HBM local (S0)  | 62 load-only  | 439.0 [406.0] | 162.6 | 162 GB/s rd |
| node 2 HBM local (S0)  | 62 load+store | 487.2 [457.5] | 180.4 | 148 GB/s rd + 148 GB/s wb |
| node 1 DDR remote (S1) | 64 load-only  | 685.0 [686.8] | 253.7 | 175 GB/s rd |
| node 1 DDR remote (S1) | 64 load+store | 1022.5 [1053.3] | 378.7 | 83 GB/s rd + 83 GB/s wb |
| node 3 HBM remote (S1) | 64 load-only  | 703.3 [691.3] | 260.5 | 179 GB/s rd |
| node 3 HBM remote (S1) | 64 load+store | 765.6 [763.6] | 283.6 | 157 GB/s rd + 157 GB/s wb |

Extra data point: remote HBM with loaders on **socket 0**, so all loader traffic crosses UPI (`results_hbm/latency_c_run1/upi_loaded_*`). The results are 1081.8 cycles (400.7 ns) with load-only loaders and 1256.1 cycles (465.2 ns) with load+store loaders.

## 3. Loaded latency — MLC

`mlc --loaded_latency -c0 -j<node> -k<loader cpus> -d0 -t1`, i.e. the maximum-injection point. The default MLC traffic is sequential. "rd" = all reads, and `-W5` = 1:1 read:write, which is the closest match to the load+store loaders.

Loaders on socket 0 (62 threads, CPU 0/64 excluded):

| Memory | rd ns @ BW | `-W5` ns @ BW | rd, random (`-r`) ns @ BW |
|---|---:|---:|---:|
| node 0 DDR local  | 278.3 @ 237 GB/s | 398.8 @ 187 GB/s | 285.1 @ 236 GB/s |
| node 2 HBM local  | 168.6 @ 405 GB/s | 208.8 @ 586 GB/s | 169.6 @ 405 GB/s |
| node 1 DDR remote | 622.0 @ 92 GB/s (UPI-bound)  | 648.9 @ 117 GB/s | 618.3 @ 92 GB/s |
| node 3 HBM remote | 642.5 @ 86 GB/s (UPI-bound)  | 547.2 @ 155 GB/s | 652.8 @ 86 GB/s |

Remote memory with loaders on socket 1 (64 threads), which matches the latency.c remote setup:

| Memory | rd ns @ BW | `-W5` ns @ BW |
|---|---:|---:|
| node 1 DDR remote | 368.1 @ 237 GB/s | 530.4 @ 185 GB/s |
| node 3 HBM remote | 279.6 @ 432 GB/s | 313.8 @ 617 GB/s |

Latency vs. bandwidth curves from the full delay sweep (local, loaders on socket 0):

| Inject delay | DDR rd ns @ GB/s | HBM rd ns @ GB/s | DDR W5 ns @ GB/s | HBM W5 ns @ GB/s |
|---:|---:|---:|---:|---:|
| 0     | 278.3 @ 237 | 168.6 @ 405 | 398.8 @ 187 | 208.8 @ 586 |
| 50    | 251.0 @ 238 | 163.9 @ 292 | 401.6 @ 186 | 212.8 @ 567 |
| 100   | 141.0 @ 160 | 148.1 @ 161 | 403.3 @ 186 | 167.5 @ 394 |
| 200   | 123.2 @ 77  | 141.0 @ 77  | 187.0 @ 134 | 147.8 @ 170 |
| 500   | 114.8 @ 33  | 137.2 @ 33  | 127.9 @ 58  | 139.1 @ 62  |
| 20000 | 109.2 @ 1.6 | 135.7 @ 1.4 | 110.2 @ 2.7 | 135.9 @ 2.6 |

---

## Takeaways

1. **Idle: HBM is slower than DDR.** Local latency is 135 ns for HBM vs. 112 ns for DDR (366 vs. 303 cycles). latency.c and MLC agree.
2. **Under saturation HBM wins by a lot.** At full load, local DDR latency rises to about 280 ns at 237 GB/s (reads) and about 400 ns at 187 GB/s (1:1 R/W). Local HBM only reaches about 170 ns at 405 GB/s and about 210 ns at 586 GB/s. With 62 threads, one socket cannot push HBM into its latency knee. The crossover is about 160 GB/s, where both are about 145 ns.
3. **latency.c's load-only loaders don't saturate DDR.** They top out at about 160–180 GB/s on every memory type, which points to a core-side limit (outstanding misses per core) rather than the memory. At that bandwidth, latency.c's 145 ns (DDR) and 150–163 ns (HBM) match MLC's curve at the same bandwidth (141 ns / 148 ns at about 160 GB/s). Load+store loaders push DDR much further (263 ns at about 164 GB/s total). Writebacks double the traffic and add read/write turnaround, but this is still below MLC's `-W5` worst case (399 ns). To reproduce MLC's worst-case read-only latency with latency.c, the loaders need more MLP, for example several independent streams per thread or sequential access.
4. **Remote HBM under load is limited by UPI, not HBM.** When the loaders are on the far socket (all traffic over UPI), MLC shows only about 86–92 GB/s at about 620–650 ns for both DDR and HBM. latency.c's UPI-loaded remote HBM result is 400–465 ns. When the loaders are local to the remote memory, remote HBM stays at about 280 ns under 432 GB/s, while remote DDR is 368 ns at 237 GB/s.
5. **The README's "idle is same as loaded" on the HBM machine was an artifact.** No loader threads were started on CPU-less HBM nodes. With the fix, local HBM loaded latency is 406–487 cycles vs. 366 idle.
