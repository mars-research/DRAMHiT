# Attempt 2: branch-free find_batch fast path (micro-optimization idea 1)

This implements suggestion 1 from `hbm-micro-optimize.md`: every iteration of the find fast
path does exactly one queue pop, one cacheline test and one push. The hit/empty/reprobe
branches are replaced by selects, so the only data-dependent branch left is the loop exit.

Setup: the same as the baseline in `report.md`.
- dramblast (cas, ht-type 3), uniform, 8 GiB table bound to HBM node 2
- 64 threads on node 0
- hardware prefetchers off (MSR 0x1a4 = 0x2f)

**Result: correct, but a net loss.** The change removes almost all find mispredicts, but it
costs more instructions than the mispredicts it saves:
- Fills 10–60, where mispredicts were already rare: find throughput is 17–20% lower.
- Fill 90: find throughput is 9% lower.
- Inserts are unchanged.

## Change

All of the change is behind a new CMake option, `CAS_FIND_BRANCHLESS`, which defaults to OFF.
With it OFF, `build/` and every paper build compile the original code.

The option only affects the `DRAMHiT_2025_INLINED` find_batch fast path. It is disabled under
`LATENCY_COLLECTION`, which the original loop still handles.

Full diff: `attempt2/branchless.diff`, reproduced below.

```diff
@@ CMakeLists.txt
 option(CAS_FAST_PATH "minimize branch in cas" ON)
+option(CAS_FIND_BRANCHLESS "branch-free find_batch fast path (2025_INLINE)" OFF)
 ...
+if(CAS_FIND_BRANCHLESS)
+    add_definitions(-DCAS_FIND_BRANCHLESS)
+endif()

@@ include/hashtables/cas_kht.hpp  (DRAMHiT_2025_INLINED find_batch, fast path)
-      uint32_t not_found = 0;
+      [[maybe_unused]] uint32_t not_found = 0;
 ...
       KVQ *q;
       uint64_t hash;
+#if defined(CAS_FIND_BRANCHLESS) && !defined(LATENCY_COLLECTION)
+      // Branch-free variant: every iteration pops one entry, tests one
+      // cacheline and pushes one entry. A reprobe pushes the popped key back
+      // with its next hash; otherwise the next input is pushed and consumed.
+      // The only data-dependent branch left is the loop exit.
+      const InsertFindArgument *in = kp.data();
+      const InsertFindArgument *const in_end = in + kp.size();
+      while (in != in_end) {
+#ifdef DOUBLE_PREFETCH
+        uint32_t next_tail = (tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
+        __builtin_prefetch(&this->hashtable[this->find_queue[next_tail].idx],
+                           false, 3);
+#endif
+        q = &this->find_queue[tail];
+        key = q->key;
+        uint32_t q_id = q->key_id;
+        bucket = (uint64_t *)&this->hashtable[q->idx];
+        key_vector = _mm512_set1_epi64(key);
+        cacheline = _mm512_load_si512(bucket);
+        key_cmp = _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
+        __mmask8 ept_cmp =
+            _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, zero_vector);
+        tail = (tail + 1) & FIND_QUEUE_SZ_MASK;
+
+        uint32_t found = key_cmp != 0;
+        uint32_t retry = (key_cmp | ept_cmp) == 0;
+#ifdef CALC_STATS
+        this->num_reprobes += retry;
+#endif
+        // All-ones on a reprobe, zero otherwise. The empty asm hides that it
+        // came from a compare; without it gcc rebuilds the retry branch and
+        // splits the push into two paths.
+        uint64_t sel = -(uint64_t)retry;
+        asm("" : "+r"(sel));
+
+        // Always write the result slot and advance only on a hit. KEYMSK
+        // sets even bits only, so with no hit off = 6 and the value load
+        // stays inside this cacheline.
+        uint32_t off = _tzcnt_u32(key_cmp | 0x40);
+        vp_result->value = bucket[off + 1];
+        vp_result->id = q_id;
+        vp_result += found;
+
+        // Both candidate hashes are computed; the push picks one by mask.
+        uint64_t in_key = in->key;
+        uint32_t in_id = in->id;
+        uint64_t in_hash = _mm_crc32_u64(0xffffffff, in_key);
+#ifdef UNIFORM_HT_SUPPORT
+        uint64_t q_hash = _mm_crc32_u64(0xffffffff, q->key_hash);
+        hash = (q_hash & sel) | (in_hash & ~sel);
+        uint32_t new_idx = hash & HT_BUCKET_MASK;
+#else
+        uint64_t q_idx = (q->idx + CACHELINE_SIZE / sizeof(KV)) & HT_BUCKET_MASK;
+        uint32_t new_idx = (q_idx & sel) | (in_hash & HT_BUCKET_MASK & ~sel);
+#endif
+        prefetch_read(new_idx);
+        this->find_queue[head].key = (key & sel) | (in_key & ~sel);
+        this->find_queue[head].idx = new_idx;
+        this->find_queue[head].key_id = (q_id & sel) | (in_id & ~sel);
+#ifdef UNIFORM_HT_SUPPORT
+        this->find_queue[head].key_hash = hash;
+#endif
+        head = (head + 1) & FIND_QUEUE_SZ_MASK;
+        in += sel + 1;  // +1 unless reprobing
+      }
+
+      this->find_tail = tail;
+      this->find_head = head;
+      vp.first += vp_result - vp.second;
+#else
       // c++ iterator is faster than a regular integer loop.
       for (auto &data : kp) {
 ...
       vp.first += (kp.size() - not_found);
+#endif  // CAS_FIND_BRANCHLESS
     }  // end of fast path
```

Notes on the change:
- **Why the empty asm.** The first version used plain ternaries. gcc turned the retry select
  back into a branch: `jne` on `key_cmp|ept_cmp`, with the push duplicated into two tails so
  only one CRC runs on each. That is exactly the mispredict this change is meant to remove.
  The empty `asm("" : "+r"(sel))` stops gcc from seeing that `sel` came from a compare.
  With it, the loop compiles to one branch, the loop exit, and every select is an xor/and/xor
  blend.
- **Out-of-bounds safety.** The result store is unconditional. At any iteration the number of
  hits so far is at most the number of inputs consumed so far, which is at most
  `kp.size() - 1`. So the store always lands inside the `batch_len` result buffer (zipfian_test
  allocates `batch_len` entries). With no hit, `off = 6`, so the value load is `bucket[7]`,
  which is still inside the same cacheline.
- **Semantics unchanged.** Reprobes use the same chained CRC as before, so probe sequences are
  identical, and `vp.first` counts hits as before.

## Build

The before binary is `build/` built with the paper flags (see `report.md`), copied to
`attempt2/before/dramhit`. The after binary is built in a separate directory so `build/` stays
the paper configuration:

```
cmake -S /opt/DRAMHiT -B /opt/DRAMHiT/build_branchless -DCPUFREQ_MHZ=2700 -DDRAMHiT_VARIANT=2025_INLINE \
  -DBUCKETIZATION=ON -DBRANCH=simd -DAVX_SUPPORT=ON -DPREFETCH=DOUBLE -DCAS_PREFETCH_INSERTION=DOUBLE \
  -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DCAS_NO_ABSTRACT=OFF -DGROWT=OFF -DCALC_STATS=OFF \
  -DCAS_FIND_BRANCHLESS=ON
cmake --build /opt/DRAMHiT/build_branchless -j 64
cp /opt/DRAMHiT/build_branchless/dramhit attempt2/after/dramhit
```

## Commands

Perf profiles (fills 50 and 90, one run each). The script is `attempt2/perf_profile.sh`:

```
attempt2/perf_profile.sh <binary> <fill> <out dir>
# runs:
sudo perf record -o <out>/perf.data \
  -e cycles/period=10000019/pp,instructions/period=10000019/,br_misp_retired.all_branches/period=100003/pp \
  -- <binary> --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill <F> \
  --num-threads 64 --numa-split 10 --np_cpu_node_msk 1 --np_mem_node_msk 4 --np_mem_local 0 \
  --batch-len 16 --find_queue 64 --no-prefetch 0 --hw-pref 0 --insert-factor 100 --read-factor 100 \
  --skew 0.01 --seed 1775762440565610239
# then: perf report --sort sym -n (per event), perf annotate --stdio --no-source
```

- `attempt2/summarize.py <dirs>` turns the per-symbol sample counts into per-op numbers. It
  multiplies samples by the period and divides by `find_ops`; inserts use the same count.
- `attempt2/loop_view.py <dir>` prints the find loop with cycles% and mispredict% for each
  instruction.

Throughput sweep of the after binary. It uses the macro_uniform collector (perf stat HBM
bandwidth, 3 reps, median), exactly as the baseline in `report.md` did:

```
python3 run_uniform_hbm.py --config baseline --binary $PWD/attempt2/after/dramhit \
  --tag attempt2_branchless --reps 3
```

Outputs:
- `attempt2/{before,after}/fill{50,90}/`: `perf.data`, `run.log`, `report.txt`,
  `annotate_{find,insert}_{cycles,misp}.txt`, `loop_view.txt`
- `results/attempt2_branchless/`: the sweep json and logs

## Correctness

Every run reported `found == find_ops`:
- perf runs at fill 50 and 90, e.g. `find_ops : 48318382000, found : 48318382000`
- all 18 sweep runs (fills 10–60 × 3 reps); the collector rejects any run where the two differ

## Perf, per find (find_batch symbol only)

Counts are summed over all 64 threads, so cyc/op is thread-cycles per find. insert_batch is
untouched by the change and serves as the control.

**Read with the correction section at the end.** cyc/op is:
- *core* cycles, at the ~2.2 GHz the cores actually run during the benchmark phases, not at
  2.7 GHz;
- only the time inside the find_batch function, not the whole find phase.

It is therefore not the benchmark's `get_cycles`, and it cannot be put directly into the
bandwidth-budget formula. Before-vs-after comparisons within this table are still valid.

| profile      | fn     | cyc/op | ins/op | IPC  | misp/op | get Mops (under perf) |
|--------------|--------|--------|--------|------|---------|-----------------------|
| before, f50  | find   | 32.8   | 58.8   | 1.79 | 0.054   | 3494                  |
| after,  f50  | find   | 43.5   | 85.8   | 1.97 | 0.034   | 2934                  |
| before, f90  | find   | 50.0   | 74.5   | 1.49 | 0.374   | 2459                  |
| after,  f90  | find   | 59.1   | 116.3  | 1.97 | 0.049   | 2233                  |
| before, f50  | insert | 36.3   | 67.9   | 1.87 | 0.054   |                       |
| after,  f50  | insert | 36.5   | 68.2   | 1.87 | 0.054   |                       |
| before, f90  | insert | 54.3   | 89.3   | 1.64 | 0.379   |                       |
| after,  f90  | insert | 54.9   | 90.0   | 1.64 | 0.382   |                       |

The insert rows agree within 1%, so the two sets of runs are comparable, and the find
differences come from the change.

### Hot instructions, before

`attempt2/before/fill90/loop_view.txt`. The top samples in find_batch, in cycles%:

```
 30.65%  prefetcht0 (%r10,%r11,1)   <- DOUBLE_PREFETCH second prefetch, tail+8
  4.86%  prefetcht2 (%r10,%rsi,1)   <- reprobe push prefetch
  4.76%  prefetcht2 (%r10,%rsi,1)   <- new-key push prefetch
  3.91%  vpcmpequq  (key compare)
  3.33%  kortestb   (hit test)
  3.2%   mov 0x10(..) (x2: load find_queue[tail].idx / [tail+8].idx)
  3.10%  tzcnt
```

Where the mispredicts land:

| branch                                   | share of find mispredicts, fill 90 | fill 50 |
|------------------------------------------|------------------------------------|---------|
| `je` on key_cmp==0 (hit vs not)          | 92.5%                              | 82.7%   |
| loop exit                                | 7.4%                               | 16.1%   |

So the premise holds, but only at high fill. At fill 90 find mispredicts 0.374 times per op;
at ~20 cycles each that is about 7.5 of its 50 cycles per find. At fill 50 it is 0.054 per op,
about 1 cycle. The single largest cost at both fills is the `prefetcht0` of the second
(DOUBLE_PREFETCH) prefetch: 11 cycles per find at fill 50 and 15 at fill 90. That is the core
stalling on a full fill buffer, not branching.

### Hot instructions, after

`attempt2/after/fill90/loop_view.txt`:
- `prefetcht0` falls to 18.4% (10.9 cycles per find).
- The rest of the cost is spread almost evenly over the ~70-instruction loop body, at 2–3% per
  instruction: both CRCs, the xor/and/xor blends, the unconditional result store, and two
  stack spills (`mov %ecx,-0x8(%rsp)` / `mov -0x8(%rsp),%esi`).
- The loop exit now accounts for all of the remaining mispredicts (87% `cmp`, 13% `jne` in
  PEBS attribution). Its trip count now varies with reprobes (16 + reprobes per batch), which
  is about 0.8 mispredicts per batch.

Find cycles, split into the two prefetch instructions and everything else (cycles per find):

| profile      | total | prefetcht0 | prefetcht2 | rest  |
|--------------|-------|------------|------------|-------|
| before, f50  | 32.8  | 11.2       | 1.8        | 19.9  |
| after,  f50  | 43.5  | 7.9        | 3.3        | 32.3  |
| before, f90  | 50.0  | 15.3       | 4.8        | 29.9  |
| after,  f90  | 59.1  | 10.9       | 4.8        | 43.4  |

The "rest" column is where the loss is: +12 cycles per find at fill 50 and +13.5 at fill 90.

## Throughput (no perf), 64 threads on node 0

Median of 3 runs. Mops = millions of operations per second; BW = HBM bandwidth in GB/s.
"Before" is the baseline sweep in `report.md` (same binary, same day). The sweep was stopped
by request after fill 60; for fill 90 there is only the single run taken under perf in the
table above.

| fill | set before | set after | Δ set | get before | get after | Δ get | get BW before | get BW after |
|------|------------|-----------|-------|------------|-----------|-------|---------------|--------------|
| 10   | 3480       | 3497      | +0.5% | 3933       | 3166      | −19.5% | 246          | 197          |
| 20   | 3388       | 3360      | −0.8% | 3948       | 3154      | −20.1% | 252          | 200          |
| 30   | 3303       | 3280      | −0.7% | 3877       | 3133      | −19.2% | 248          | 200          |
| 40   | 3146       | 3255      | +3.5% | 3785       | 3094      | −18.3% | 246          | 201          |
| 50   | 3151       | 3072      | −2.5% | 3699       | 2984      | −19.3% | 246          | 198          |
| 60   | 2848       | 2991      | +5.0% | 3497       | 2900      | −17.1% | 243          | 200          |
| 90*  | 2075       | 2109      | +1.6% | 2459       | 2233      | −9.2%  | –            | –            |

\* fill 90: single run each under `perf record`, not the sweep.

- **Inserts (set).** Unchanged within run-to-run noise (−2.5% to +5%). insert_batch is not
  touched by this change.
- **Finds (get).** 17–20% slower from fill 10 to 60. The loss narrows at fill 90 (−9%), where
  there are mispredicts to recover.
- **Find bandwidth.** Drops from ~246 to ~200 GB/s. The find phase moves less memory per
  second because the core issues work more slowly; this is further from the HBM ceiling, not
  closer to it.

## Why it loses

- **Instruction count.** The branchy loop runs a light path on a reprobe: CRC of the stored
  hash, then a push, with no result write. On a hit it runs the other path. The branch-free
  loop pays for both paths on every iteration, plus the unconditional result store and spills
  from register pressure. That is ~75 instructions per iteration, and there are
  1 + reprobes iterations per find. Instructions per find rise 46% at fill 50 and 56% at fill 90.
- **Too few mispredicts to pay for it.** Removing 0.32 mispredicts per find at fill 90 saves
  about 6–7 cycles, and the added ~42 instructions at IPC ~2 cost more than that. At fill 50
  there are only 0.02 mispredicts per find to remove.
- **The branchy loop is not stalled by its branch.** IPC rises from 1.49 to 1.97 after the
  change, but useful work per cycle falls. The mispredicts in the original loop were cheaper
  than 20 cycles each: the core resolves them while it is also waiting on the prefetches, so
  part of the flush cost is hidden.
- **The real bottleneck is untouched.** The largest single cost at every fill is the
  DOUBLE_PREFETCH `prefetcht0` stalling on the fill buffer. This change does not address it.

## Conclusion

- Idea 1 (branch-free find) does not pay off on HBM uniform, so `CAS_FIND_BRANCHLESS` stays
  OFF. The code is kept behind the flag for reference; it is correct, but slower.
- Branch mispredicts are a real cost only at high fill (≥80–90%), and even there the
  instructions added to remove them cost more than the mispredicts did.
- Where to go next, based on this profile:
  1. The second prefetch (`prefetcht0` at tail+8) is the single hottest instruction, at about
     a third of find cycles before the change. Trying `PREFETCH=L1` (one prefetch per op)
     and/or a different queue depth is suggestion 5 in `hbm-micro-optimize.md`, and it is the
     most direct test.
  2. If mispredicts are revisited, a hybrid should be tried: keep the branchy loop, but make
     only the reprobe push branch-free. Only the hit/miss decision needs to go, not the whole
     push. It could also be enabled only at high fill.
  3. Suggestions 2 and 3 (smaller queue entries, hoisting members into locals) cut
     instructions, which this profile shows is what the loop is sensitive to.

## Addendum: before-code hotspots at low fill (fill 10)

Command: `attempt2/perf_profile.sh $PWD/attempt2/before/dramhit 10 $PWD/attempt2/before/fill10`.
Output is in `attempt2/before/fill10/`. It is one run under perf, so throughput reads ~5% low:
get 3690 / set 3207 Mops, against 3933 / 3480 in the sweep.

Per op for the before code at all three profiled fills:

| fill | fn     | cyc/op | ins/op | IPC  | misp/op |
|------|--------|--------|--------|------|---------|
| 10   | find   | 30.8   | 57.1   | 1.85 | 0.002   |
| 50   | find   | 32.8   | 58.8   | 1.79 | 0.054   |
| 90   | find   | 50.0   | 74.5   | 1.49 | 0.374   |
| 10   | insert | 34.7   | 65.5   | 1.88 | ~0 (under 1% of 28 samples) |
| 50   | insert | 36.3   | 67.9   | 1.87 | 0.054   |
| 90   | insert | 54.3   | 89.3   | 1.64 | 0.379   |

At fill 10 there are essentially no mispredicts: only 28 samples in the whole run, 0.002 per
find. The reprobe path (`43d590`–`43d5cb`) gets no samples at all. So at low fill the find loop
is a straight line of ~57 instructions per find, and branch work is not a factor.

find_batch at fill 10, cycles% in program order (hot lines only, `loop_view.txt` has all):

```
  4.36  43d5da: mov    0x10(%r9,%rax,1),%r11d   ; find_queue[tail+8].idx   (DOUBLE_PREFETCH addr)
  4.65  43d5e8: mov    0x10(%rax),%esi          ; find_queue[tail].idx
 33.42  43d5f6: prefetcht0 (%r10,%r11,1)        ; 2nd prefetch, bucket of tail+8 -> L1
  1.05  43d5fe: vmovdqa64 (%rsi),%zmm8          ; load bucket of tail
  4.32  43d60a: vpcmpequq ...                   ; key compare
  4.16  43d624: kortestb %k4,%k4                ; hit?
  5.05  43d634: tzcnt                           ; slot of hit
  3.80  43d642: mov    0x14(%rax),%eax          ; q->key_id
  3.97  43d650: mov    (%r14),%rbx              ; next input key
  3.87  43d65f: and    %r11d,%eax               ; crc & mask
  4.24  43d677: prefetcht2 (%r10,%rsi,1)        ; 1st prefetch, new key's bucket -> L2
  4.04  43d67c: mov    %rbx,(%rdx)              ; push to find_queue[head]
  4.21  43d68d: jne    43d5d0                   ; loop
```

- **The one real hotspot is `prefetcht0`: 33% of find cycles, ~10 cycles per find.** This is the
  DOUBLE_PREFETCH second prefetch. It pulls the bucket for the entry 8 slots behind the tail
  from L2 into L1. Everything else is flat at ~4%. That even spread is PEBS attributing cycles
  to each retirement group, and means the rest of the loop is not stalled on any one
  instruction.
- **insert_batch shows the same shape.** The second prefetch there (`prefetchw` at `43ce08`) is
  29.6% of insert cycles. `lock cmpxchg16b` is only 1.1%, so the locked CAS is not the insert
  bottleneck at low fill (suggestion 4a in `hbm-micro-optimize.md` would gain little here).
- **Likely cause: the core runs out of L1 fill buffers.** A software prefetch that misses L1
  needs an L1 fill buffer; if none is free, the prefetch waits and blocks retirement. This
  matches `../intel_hbm/readme.txt` ("prefetchT1 stalls cpu if continuously issued at 16").
  Both prefetches per find take a fill buffer, and the first one holds it for the full HBM
  latency. A Little's-law estimate:
  - assumptions: 16 fill buffers per core, shared by the 2 hyperthreads; ~145 ns HBM latency
    (the 130–160 ns in `hbm-debug.md`)
  - 32 cores × 16 × 64 B / 145 ns ≈ 226 GB/s
  - measured find bandwidth: ~246 GB/s
  The two are close. This is consistent with find being bound by memory-level parallelism
  (fill buffers), not by instruction count or branches. It is not proven; a direct check is
  `perf stat -e l1d_pend_miss.fb_full,l1d_pend_miss.fb_full_periods` on the find phase.
- **What this means for the next attempts.** At low fill, removing instructions or branches
  cannot help much while the fill buffers are saturated. The levers are the ones that change
  how fill buffers are used:
  - one prefetch per op instead of two (`PREFETCH=L1`, or `CAS_PREFETCH_INSERTION=PREFETCHW` on insert)
  - prefetch hints that do not hold an L1 fill buffer for the whole HBM trip

## Correction: cycle accounting and core frequency

The addendum's "30.8 cycles per find" at fill 10 does not match the `hbm-debug.md` budget. At
2.7 GHz it would mean 64 × 2.7e9 / 30.8 = 5.6 Gops ≈ 359 GB/s, but the run measures
~3.7–3.9 Gops ≈ 240–250 GB/s. Two things were wrong in how I read the perf numbers.

**1. The perf `cycles` event runs at ~2.2 GHz, not 2.7 GHz.** The cores are configured at a
fixed 2.7 GHz (governor powersave, min = max = 2.7 GHz, no_turbo = 1), and they do run at 2.7
during setup. During the insert and find phases they throttle.

Evidence:
- `perf stat -e cycles,ref-cycles` over the whole fill-10 run gives cycles at 2.199 GHz and
  ref-cycles at 2.700 GHz. ref-cycles counts at the fixed TSC rate, which is also what the
  benchmark's rdtsc-based `set_cycles` / `get_cycles` use.
- Sampling cycles/ref-cycles every 0.5 s (`perf stat -a -C 0,2,4,6 -I 500`) gives 2.69 GHz
  before the insert-start marker, 1.93–2.30 GHz between insert start and find end, and 2.69
  again afterwards.
- turbostat on cpus 0 and 64 (`turbostat --cpu 0,64 --show CPU,Busy%,Bzy_MHz,PkgWatt,PkgTmp -i 1`):

  ```
  phase           Bzy_MHz   PkgWatt   PkgTmp
  setup           2700      313-323   84-86
  insert + find   2147-2270 337-368   84-88
  teardown        2700      318-319   84-85
  ```

  Package power reaches or exceeds the 9462's 350 W TDP, which suggests the power limit is
  throttling socket 0 below base clock. The AVX-512 frequency license may also contribute.
  This perf build exposes no `core_power.*_turbo_license` events to separate the two, so the
  cause is not confirmed.

**2. The find_batch symbol is not the whole find phase.** ZipfianTest::run fills each batch
(key generation, the workload read, loop overhead) and takes ~9 core cycles per op across the
two phases. Reconciling at fill 10 (thread-cycles per op):

| source                                       | cycles per op                                 |
|----------------------------------------------|-----------------------------------------------|
| benchmark rdtsc, set + get                   | 53 + 46 = 99 (at 2.7 GHz reference rate)      |
| perf core cycles, all symbols                | 77.4 (99 × 2.2/2.7 = 80.7; close)             |
|   insert_batch                               | 34.7                                          |
|   find_batch                                 | 30.8                                          |
|   ZipfianTest::run (both phases)             | 9.1                                           |

So one find costs:
- 46 TSC cycles ≈ 17 ns per thread
- ≈ 37.5 core cycles at 2.2 GHz, of which find_batch is 30.8 (~82%) and the rest is batch
  feeding and loop overhead in ZipfianTest::run

**Budget check (the `hbm-debug.md` formula), now consistent.**
- Measured: 64 threads × 2.7e9 / 46 = 3.76 Gops × 64 B = 240 GB/s, against 246 GB/s at the HBM
  controllers and 62.5 B per find. With a real 2.2 GHz clock, the same is
  64 × 2.2e9 / 37.5 core cycles.
- Budget at 420 GB/s: 64 × 2.2 GHz × 64 B / 420 GB/s ≈ **21.5 core cycles per find**, not the
  26 in `hbm-debug.md`, which assumes 2.7 GHz. At the current ~37.5 core cycles, finds would
  have to lose ~16 core cycles each, counting the harness overhead as well.

**What changes in the conclusions.**
- The attempt-2 verdict does not change. It rests on Mops from the sweep, and on
  before/after perf ratios taken under the same conditions.
- The prefetcht0 hotspot share (33% of find_batch) is still correct. In absolute terms it is
  ~10 core cycles ≈ 4.7 ns per find. The Little's-law fill-buffer estimate is in ns and is
  unaffected.
- New item: **the socket is running 19% below its configured clock during the benchmark.** Any
  cycles-per-op budget has to use ~2.2 GHz. Energy/power is also a lever: work that burns
  less power per op (fewer instructions, fewer zmm ops) may get some of that clock back.

## Power limit: why the cores run below 2.7 GHz, and bandwidth_rand for comparison

### The cause is the package power limit, not the governor

| check | result |
|-------|--------|
| governor / EPP | `powersave` / `balance_performance` (intel_pstate, HWP active); min = max = 2.7 GHz; no_turbo = 1 |
| same run with `performance` / `performance` | no change: 2143–2225 MHz, get 3936 Mops (vs 3909 with powersave). Settings restored afterwards. |
| RAPL package limits (`/sys/class/powercap/intel-rapl:{0,2}`) | PL1 = 350 W over a ~1 s window, PL2 = 420 W (corrected later: 350 W is the default policy and the TDP, not the maximum PL1 can be set to; lock bit clear, MSR 0x614 max 812 W, see `report-throttling.md`) |
| thermal throttle counters (`cpu0/thermal_throttle/*`) | all 0 |
| `IA32_THERM_STATUS` (0x19c), cpu 0 | power-limit log bit 11 set by the run, thermal log bit 1 not set; 77–90 °C against TjMax 100 °C |
| cpuidle | POLL, C1, C1E and C6 all disabled by `scripts/constant_freq.sh`, which `setup_hbm.sh` calls; idle cpus spin in the poll loop (POLL% ≈ 99.5) |

turbostat on cpu 0 (socket 0) during a dramhit fill-10 run, one row per second:

```
phase          Bzy_MHz     PkgWatt    UncMHz
setup          2700        316-325    2500
insert+find    2142-2225   337-367    1200-1700   <- both core and mesh clocks cut
teardown       2700        318-321    2500
```

- **Base frequency is not guaranteed here.** 2.7 GHz is the base frequency, and it only holds
  while the package stays within its 350 W TDP. On Xeon Max the HBM stacks and the mesh are
  inside the package, so HBM traffic draws on the same 350 W as the cores.
- **What the power controller does.** When the ~1 s power average goes over PL1, it overrides
  the OS's 2.7 GHz request and lowers both the core clock (to ~2.15 GHz) and the uncore/mesh
  clock (from 2.5 GHz to 1.2–1.7 GHz).
- **Why the governor cannot help.** With intel_pstate, the governor and EPP only choose a
  frequency within [min, max]. Both are 2.7 GHz, and the hardware power limit sits below that.
- **What the C-state setting does.** Because C-states are disabled, socket 0 draws 313–320 W
  even when idle, which is ~90% of PL1. During the benchmark every cpu on socket 0 is busy
  anyway, so this setting is not what triggers the throttle. It does show that simply running
  all 64 threads at 2.7 GHz leaves almost no headroom. The HBM traffic, mesh activity and
  AVX-512 work push the package over.

### bandwidth_rand (machine_stats/bandwidth.c) is throttled too, just less

Commands:

```
cd scripts/eurosys_2026/machine_stats && mkdir -p build && make build/bandwidth_rand
# needs 64 x 128 MB of 2 MB pages on node 2 (the dramhit reservation has only 2 GB of 2 MB pages there):
scripts/reserve_hugepages.sh reset && scripts/reserve_hugepages.sh n2_0gb_9216mb n0_0gb_2048mb
sudo perf stat -e cycles,ref-cycles,instructions -- ./build/bandwidth_rand -m 128mb \
  -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
# run alongside: sudo turbostat --quiet --cpu 0 --show CPU,Bzy_MHz,PkgWatt,UncMHz -i 0.5
# afterwards the dramhit reservation was restored:
scripts/reserve_hugepages.sh reset && scripts/reserve_hugepages.sh n2_12gb_2048mb n0_0gb_8192mb n1_0gb_8192mb
```

|                              | bandwidth_rand t1           | bandwidth_rand t0           | dramhit find, fill 10 (before code) |
|------------------------------|-----------------------------|-----------------------------|-------------------------------------|
| reported bandwidth           | 370 GB/s                    | 324 GB/s                    | ~246 GB/s (HBM counters)            |
| run length                   | 2.2 s                       | 2.5 s                       | insert 1.6 s + find 1.4 s           |
| avg core clock (cycles/ref)  | 2.56 GHz                    | 2.63 GHz                    | 2.20 GHz                            |
| clock after the first ~1 s   | 2461–2559 MHz               | 2559–2641 MHz               | 2142–2225 MHz                       |
| peak package power           | 377 W                       | 376 W                       | 367 W                               |
| instructions per cache line  | ~15                         | ~15                         | ~57 in find_batch + harness         |
| per-access work              | 2 crc32, 1 prefetch, 1 scalar load | same                 | 2 queue loads, 2 prefetches, zmm load + 2 zmm compares, tzcnt, crc32, 4-field queue push, result store |

Notes:
- Instructions per line for bandwidth_rand: 188.8e9 instructions / (370 GB/s × 2.16 s / 64 B)
  ≈ 15; this includes setup.
- In this session, `-inst t1` gave 370 GB/s, not the ~400–465 GB/s in `../intel_hbm/readme.txt`.
  That readme number came from `benchmark_rand`, a different binary, and I did not re-run it.

bandwidth_rand does not stay under the power limit. It exceeds PL1 by more than dramhit does
(377 W vs 367 W), and it is throttled too. It fares better for two reasons:

1. **It spends part of its run before the throttle engages.** PL1 is a ~1 s running average,
   and PL2 allows 420 W in the short term. In both bandwidth_rand runs the first second is at
   2700 MHz and 373–377 W, and only then does the clock fall. With the whole run lasting
   ~2.2 s, about half of it is at full clock.
   dramhit gets almost no head start: its clock drops within the first 1 s sample of the
   insert phase, and the find phase then starts already throttled. One likely reason is that
   it enters the insert phase with less banked headroom. Its setup phase draws ~316–325 W,
   against ~307–309 W before bandwidth_rand's loop, so its running average starts closer to
   350 W. That mechanism is an inference from the 1 s turbostat samples, not measured
   directly.
2. **Much less core work per cache line.** It is ~15 instructions per line with no zmm compares
   and no queue traffic, against ~57+ for the hashtable find. For the same 350 W budget the
   controller has less core power to shed, so it only needs to cut the clock to ~2.5 GHz, not
   ~2.15 GHz. The hashtable spends more energy per byte moved, and pays for it in clock.

### What this means

- **The HBM ceiling is also a power ceiling.** Moving ~400 GB/s through HBM, the mesh and the
  cores costs about as much as PL1 allows. Every instruction per op competes with memory
  traffic for the same 350 W.
- **Instruction count now costs twice.** Fewer instructions per find saves cycles directly,
  and it also saves power, which returns clock. Attempt 2 did the opposite (+46% instructions
  per find).
- **Budgets need the real clock.** At ~2.2 GHz the 420 GB/s budget is ~21.5 core cycles per find
  (see the correction section), and the find currently takes ~37.5.
- **Short microbenchmarks overstate sustainable bandwidth.** A bandwidth_rand run of ~2 s gets
  up to 1 s of unthrottled time. For a fair ceiling it should run well past the 1 s PL1
  window (e.g. `-m` larger or more iterations) and only the steady state should be reported.
- **Uncore clock is a second suspect.** The mesh drops to 1.2–1.7 GHz under dramhit, against
  1.8–2.1 GHz under bandwidth_rand. A slower mesh plausibly adds memory latency, which lowers
  the bandwidth each core can reach through its fill buffers. Not measured yet. The test is to
  pin the uncore frequency (`/sys/devices/system/cpu/intel_uncore_frequency/`) and watch find
  bandwidth and core clock.

### HBM read ceiling (`measure_hbm_ceiling.py`) under the power limit

Command (a wrapper that reuses the collector's `run()` unchanged but writes to this directory,
so the stored `../macro_uniform/intel_hbm/intel-max9462-hbm_ceiling.json` is not overwritten):

```
python3 ceiling_with_power.py --reps 3
# per rep, via measure_hbm_ceiling.run("lookup", {"mode": "r", "inst": "t1"}, "0x2f", rep):
sudo perf stat --per-socket -e <uncore_hbm_* rd/wr CAS> -I 100 -x, -- \
  machine_stats/build/bandwidth_rand -m 256mb -pattern n0a2t64 -freq 2.7 -inst t1 -lookahead 64 -mode r
# with: sudo turbostat --quiet --cpu 0 --show CPU,Bzy_MHz,PkgWatt,UncMHz -i 0.5
# hugepages: n2_0gb_17408mb n0_0gb_2048mb for the run, dramhit reservation restored after
```

Output: `results/ceiling/ceiling_with_power.json`, per-rep perf logs in
`results/ceiling/intel_hbm/logs/ceiling/`, and turbostat files in `results/ceiling/`.

Results: HBM bandwidth at the controllers, inside the program's own measurement window
(~4.1 s, 41 × 100 ms intervals):

| rep | median (script's number) | peak interval | first 1 s | after 1 s, median | program's own report |
|-----|--------------------------|---------------|-----------|-------------------|----------------------|
| 1   | 404.8                    | 420.8         | 419–421   | 400               | 367.7                |
| 2   | 399.2                    | 419.3         | 418–419   | 398               | 365.5                |
| 3   | 394.1                    | 418.6         | 418–419   | 392               | 363.0                |

The stored value is 405.8 median and 424.4 peak, so this run matches it within the ±7% the
script's docstring gives for different hugepage pools.

Time series of rep 1 (GB/s, 100 ms intervals):
`421 420 420 420 419 419 419 419 419 | 392 347 400 421 416 ...`

turbostat, socket 0, over the loop:

| time        | core MHz  | package W | uncore MHz |
|-------------|-----------|-----------|------------|
| first ~1 s  | 2700      | 367–376   | 2000–2100  |
| after       | 2424–2587 | 337–352   | 1500–2000  |

- **420 GB/s is the unthrottled read ceiling.** It holds for the first ~0.8 s, while the
  package still has PL1 headroom and runs at 2.7 GHz.
- **Then the power limit engages.** The ~1 s average reaches 350 W, bandwidth dips to
  ~347–351 GB/s for one or two intervals as the clock drops, and then swings between ~370 and
  ~420 GB/s at 2.42–2.59 GHz. The **sustained ceiling is ~395–400 GB/s**. That is the fair
  target for a phase that lasts longer than a second, and the hashtable's find phase lasts
  ~1.4 s.
- **The same 350 W buys less clock for the hashtable.** It fits under 350 W only at
  ~2.15 GHz, against ~2.5 GHz for this loop, because it spends more core energy per line
  (~57+ instructions with zmm compares, against ~15 scalar).
- **Budget against the sustained ceiling.** At ~2.15 GHz, matching 400 GB/s needs
  64 × 2.15e9 × 64 B / 400 GB/s ≈ **22 core cycles per find**. The find currently takes ~37.5,
  and it may also get some clock back as its instruction count falls.
- **The program's own figure reads 8–10% below the controllers** (363–368 vs 394–405). The
  controllers count all HBM CAS traffic, including traffic the software loop does not issue.
  The report uses the controller numbers, the same as the uniform panels.
