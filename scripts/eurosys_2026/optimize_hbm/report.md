# HBM optimization report

Machine: Intel Xeon Max 9462 (2 sockets × 32 cores / 64 threads, 2.7 GHz), HBM in flat mode.
Numa nodes 0/1 have cpus and DDR, and nodes 2/3 are cpu-less 64 GiB HBM nodes. Node 2 belongs
to socket 0 (distance 13 from node 0, 23 from node 1).

## Idea 1: use the cpus of both packages, table still on HBM node 2

Question (from `hbm-debug.md`): a single socket (64 threads) reaches only ~250 GB/s of HBM
bandwidth on finds, about 44 cycles per cacheline, against a ~420 GB/s ceiling. Can socket 1's
cores add work and raise throughput, given that the hashtable does not saturate HBM?

### Setup

The workload is the one `../macro_uniform/collect_data_intel_hbm.py` runs for dramblast, with no
changes:
- ht-type 3 (cas / dramblast, 2025 inlined), mode 11 (uniform)
- 8 GiB table (2^29 entries of 16 B), bound to node 2
- batch 16, find queue 64, insert and read factor 100, skew 0.01
- hardware prefetchers off (MSR 0x1a4 = 0x2f)

The two configs differ only in thread count and cpu mask:

| config   | threads | cpus                 | `--np_cpu_node_msk` | table (`--np_mem_node_msk`) |
|----------|---------|----------------------|---------------------|-----------------------------|
| baseline | 64      | node 0 (socket 0)    | 0x1                 | 0x4 (node 2)                |
| allcpu   | 128     | node 0 + node 1      | 0x3                 | 0x4 (node 2)                |

With `--numa-split 10` (THREADS_CUSTOM), threads fill node 0's cpus first, then node 1's.

### Build

These are the same flags as `collect_data_intel_hbm.py`:

```
cmake -S /opt/DRAMHiT -B /opt/DRAMHiT/build -DCPUFREQ_MHZ=2700 -DDRAMHiT_VARIANT=2025_INLINE \
  -DBUCKETIZATION=ON -DBRANCH=simd -DAVX_SUPPORT=ON -DPREFETCH=DOUBLE -DCAS_PREFETCH_INSERTION=DOUBLE \
  -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DCAS_NO_ABSTRACT=OFF -DGROWT=OFF -DCALC_STATS=OFF
cmake --build /opt/DRAMHiT/build -j 64
```

### Commands

The driver is `run_uniform_hbm.py` in this directory. It imports the macro_uniform collector and
overrides only `NUM_THREADS` and `NP_CPU_NODE_MSK`, so the command line, perf bandwidth sampling
and json format are the collector's.

```
python3 run_uniform_hbm.py --config baseline --reps 3
python3 run_uniform_hbm.py --config allcpu   --reps 3
```

Before each sweep it runs these setup steps:

```
/opt/DRAMHiT/scripts/reserve_hugepages.sh reset
/opt/DRAMHiT/scripts/reserve_hugepages.sh n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb
sudo env PATH="$PATH" /opt/DRAMHiT/scripts/prefetch_control_hbm.sh off
```

The node 1 2 MB pool is new compared with the collector. Each thread's key buffer is allocated on
that thread's own node, so node 1 threads need it.

The dramhit command for one point is below (`<F>` = fill). The collector runs it under
`sudo perf stat --per-socket -I 50 -x,` on the raw `uncore_hbm_*` CAS events (0x05/0xcf rd,
0x05/0xf0 wr) to get per-phase HBM bandwidth.

```
# baseline
sudo /opt/DRAMHiT/build/dramhit --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill <F> \
  --num-threads 64 --numa-split 10 --np_cpu_node_msk 1 --np_mem_node_msk 4 --np_mem_local 0 \
  --batch-len 16 --find_queue 64 --no-prefetch 0 --hw-pref 0 --insert-factor 100 --read-factor 100 \
  --skew 0.01 --seed 1775762440565610239

# allcpu: same, with
  --num-threads 128 --np_cpu_node_msk 3
```

Results:
- `results/baseline/baseline_uniform.json`, logs in `results/baseline/logs/`
- `results/allcpu/allcpu_uniform.json`, logs in `results/allcpu/logs/`
- console output of both sweeps in `results/sweep.log`

### Data

Each value is the median of 3 reps. Mops is millions of operations per second. BW is HBM
bandwidth in decimal GB/s, summed over all uncore_hbm boxes on both sockets.

Baseline (64 threads, node 0). The two "stored" columns are the `cas_hwpf_off` curve in
`../macro_uniform/intel_hbm/intel-max9462-hbm_uniform.json`:

| fill | set Mops | get Mops | set BW | get BW | stored set | stored get |
|------|----------|----------|--------|--------|------------|------------|
| 10   | 3480     | 3933     | 454    | 246    | 3264       | 3866       |
| 20   | 3388     | 3948     | 448    | 252    | 3354       | 3918       |
| 30   | 3303     | 3877     | 429    | 248    | 3323       | 3896       |
| 40   | 3146     | 3785     | 408    | 247    | 3208       | 3791       |
| 50   | 3151     | 3699     | 414    | 246    | 3124       | 3666       |
| 60   | 2848     | 3497     | 396    | 243    | 2963       | 3478       |
| 70   | 2690     | 3206     | 376    | 236    | 2752       | 3220       |
| 80   | 2433     | 2860     | 360    | 235    | 2438       | 2857       |
| 90   | 2089     | 2447     | 342    | 243    | 2083       | 2399       |

The baseline reproduces the stored curve: get is within 2% at every fill, and set is within 2%
except fill 10 (+7%) and fill 60 (−4%). The find phase stays at ~235–252 GB/s at every fill.

Allcpu (128 threads, nodes 0+1). The sweep was stopped by request after fill 40, because the
result was already clear:

| fill | set Mops | get Mops | set BW | get BW | set vs baseline | get vs baseline |
|------|----------|----------|--------|--------|-----------------|-----------------|
| 10   | 2016     | 2249     | 145    | 79     | −42%            | −43%            |
| 20   | 1987     | 2216     | 142    | 78     | −41%            | −44%            |
| 30   | 2007     | 2246     | 143    | 80     | −39%            | −42%            |
| 40   | 1946     | 2167     | 141    | 79     | −38%            | −43%            |

The reps are tight: get samples fall within ±0.5% of each other at every allcpu point, e.g.
2249 / 2251 / 2248 at fill 10.

### Conclusion

- Idea 1 fails. Using both packages with the table on node 2 cuts throughput by ~40% for both
  inserts and finds, at every fill measured. The extra 64 cores more than cancel their own
  contribution.
- This matches the earlier microbenchmark in `../intel_hbm/readme.txt`: `bandwidth_rand` random
  reads drop from 348 GB/s (n0a2t64) to 208 GB/s (n0a2,3t64 n1a2,3t64). Remote HBM access over UPI
  degrades the whole run, not just the remote threads. That the hashtable does not saturate HBM on
  one socket does not help here.
- Caveat: this run changes the thread count and adds remote access at the same time, so it does
  not separate the two. Two runs would separate them:
  - 64 threads all on node 1 (msk 0x2): every access remote
  - 32 on node 0 + 32 on node 1: same thread count as the baseline
- Open issue: the allcpu HBM bandwidth numbers look inconsistent. At the baseline's ~62 B per find,
  2249 Mops should be ~140 GB/s on finds, but the counters report ~79 GB/s (and 142 vs ~260
  expected on inserts). Either the uncore_hbm counters do not see all of the traffic that comes
  from socket 1, or each op really moves fewer bytes. The raw perf rows in `results/allcpu/logs/`
  have not been checked yet. Until they are, treat the allcpu BW column as unverified; the Mops
  numbers are not affected.
- Next: stay on one socket and pursue idea 2, code-level optimization (`hbm-micro-optimize.md`).
