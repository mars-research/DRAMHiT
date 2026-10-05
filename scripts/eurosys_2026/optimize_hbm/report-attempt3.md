# Attempt 3: energy per op as a metric, and the three find_batch changes

This attempt tests the three changes proposed in `hbm-micro-optimize-v2.md`, plus a new metric:
package energy per operation. Background is in `report-throttling.md`: the socket runs at its
350 W package limit, so throughput ≈ 350 W / (energy per op).

**Result.**
- **Changes 2 (byte-offset ring) and 3 (hit value via `vpcompressq`) both help, and they
  stack.** Together (`rc`) they give **+7.0% to +7.5% find throughput** and **−6.4% to −7.6%
  energy per find** at fills 10, 50 and 90. Instructions per find fall from 57.0 to 49.2.
- **Change 1 (one prefetch per find instead of two) is worse, at −5% to −17%.** The second
  prefetch is not wasted: it is the cheapest place for an unavoidable wait. Counters below.
- Inserts are unchanged, which is the control.

Setup:
- dramblast (cas, ht-type 3), uniform, fills 10/50/90
- 8 GiB table on HBM node 2, 64 threads on node 0
- hw prefetchers off (MSR 0x1a4 = 0x2f)
- 3 reps per point

## 1. Method 1: energy per op in every uniform run

`run_uniform_hbm.py --energy` wraps the macro_uniform collector without changing it:
- **Events:** adds `power/energy-pkg/`, `cycles` and `ref-cycles` to its `perf stat --per-socket`
  command. It also adds `-a`, which `--per-socket` needs once core events are present.
- **Parser:** a second parser reads the same interval stream. It uses socket 0 only, the
  same phase markers, drops the boundary intervals, and applies the same 0.3 s warm-up cut.
- **Recorded per phase:**
  - `pkg_w`: median of Joules / interval length
  - `core_ghz`: median of cycles / ref-cycles × 2.7 GHz, over socket 0's 64 cpus, all of which
    run benchmark threads
  - `nj_per_op`: pkg_w / Mops × 1000

The added counters do not perturb the run: the smoke test gave get 3972 Mops against the
stored 3933.

```
python3 run_uniform_hbm.py --config baseline --energy --fill 10 --reps 1 --tag energy_smoke
#   energy fill=10: set 372.9 W 2.157 GHz 107.09 nJ/op | get 343.6 W 2.242 GHz 86.51 nJ/op
```

## 2. The changes

All three go through CMake flags. The two source changes are new options that default to OFF.

| name | flags (on top of the paper flags, with `CAS_PREFETCH_INSERTION=DOUBLE` explicit) | what |
|------|------|------|
| base  | `PREFETCH=DOUBLE` | unchanged paper build |
| l1    | `PREFETCH=L1` | change 1: one `prefetcht0` at enqueue, no second prefetch |
| l2    | `PREFETCH=L2` | change 1 variant: one `prefetcht1` at enqueue, no second prefetch |
| ring  | `PREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON` | change 2 |
| cmp   | `PREFETCH=DOUBLE -DCAS_FIND_COMPRESS_VALUE=ON` | change 3 |
| rc    | ring + cmp, DOUBLE | changes 2 + 3 |
| rc_l1 | ring + cmp, L1 | |
| rc_l2 | ring + cmp, L2 | |

Base flags, the same as `report.md`: `-DCPUFREQ_MHZ=2700 -DDRAMHiT_VARIANT=2025_INLINE
-DBUCKETIZATION=ON -DBRANCH=simd -DAVX_SUPPORT=ON -DCAS_PREFETCH_INSERTION=DOUBLE
-DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DCAS_NO_ABSTRACT=OFF -DGROWT=OFF -DCALC_STATS=OFF`.

Each variant was built in `build_a3_<name>/`, and its binary is in `attempt3/<name>/dramhit`.
`attempt3/base/dramhit` is `build/` with both new options OFF.

### Diff (`attempt3/ring_cmp.diff`)

```diff
@@ CMakeLists.txt
+option(CAS_FIND_RING_OFFSETS "find_batch fast path: byte-offset find-queue ring (2025_INLINE)" OFF)
+option(CAS_FIND_COMPRESS_VALUE "find_batch fast path: hit value via vpcompressq (2025_INLINE)" OFF)
+if(CAS_FIND_RING_OFFSETS)
+    add_definitions(-DCAS_FIND_RING_OFFSETS)
+endif()
+if(CAS_FIND_COMPRESS_VALUE)
+    add_definitions(-DCAS_FIND_COMPRESS_VALUE)
+endif()

@@ include/hashtables/cas_kht.hpp, DRAMHiT_2025_INLINED find_batch fast path
       __m512i zero_vector = _mm512_setzero_si512();
+#ifdef CAS_FIND_RING_OFFSETS
+      // Inside this loop tail/head are byte offsets into find_queue, so a slot
+      // is base + offset with no index scaling; converted back on exit.
+      static_assert((sizeof(KVQ) & (sizeof(KVQ) - 1)) == 0,
+                    "find queue entry size must be a power of two");
+      char *const fq_base = reinterpret_cast<char *>(this->find_queue);
+      // 64-bit so an offset can be used directly as an addressing-mode index.
+      const uint64_t fq_mask = (uint64_t)this->find_queue_sz * sizeof(KVQ) - 1;
+      uint64_t tail = (uint64_t)this->find_tail * sizeof(KVQ);
+      uint64_t head = (uint64_t)this->find_head * sizeof(KVQ);
+#define FQ(off) (*reinterpret_cast<KVQ *>(fq_base + (off)))
+#else
       uint32_t tail = this->find_tail;
       uint32_t head = this->find_head;
+#define FQ(i) (this->find_queue[i])
+#endif
 ...
 #ifdef DOUBLE_PREFETCH
+#ifdef CAS_FIND_RING_OFFSETS
+        uint64_t next_tail =
+            (tail + PREFETCH_FIND_NEXT_DISTANCE * sizeof(KVQ)) & fq_mask;
+#else
         uint32_t next_tail = (tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
+#endif
         const void *next_tail_addr =
-            &this->hashtable[this->find_queue[next_tail].idx];
+            &this->hashtable[FQ(next_tail).idx];
 ...
-        q = &this->find_queue[tail];
+        q = &FQ(tail);
 ...
+#ifdef CAS_FIND_RING_OFFSETS
+        tail = (tail + sizeof(KVQ)) & fq_mask;
+#else
         tail = (tail + 1) & FIND_QUEUE_SZ_MASK;
+#endif
         if (key_cmp > 0) {
+#ifdef CAS_FIND_COMPRESS_VALUE
+          // The value sits in the lane after its key; take it from the line
+          // already in cacheline rather than locating and reloading it.
+          vp_result->value = _mm_cvtsi128_si64(_mm512_castsi512_si128(
+              _mm512_maskz_compress_epi64((__mmask8)(key_cmp << 1), cacheline)));
+#else
           __mmask8 offset = _bit_scan_forward(key_cmp);
           vp_result->value = bucket[(offset + 1)];
+#endif
 ...   (both pushes, reprobe and new key)
-            this->find_queue[head].key = key;       ... (every field)
+            FQ(head).key = key;                     ...
+#ifdef CAS_FIND_RING_OFFSETS
+            head = (head + sizeof(KVQ)) & fq_mask;
+#else
             head += 1;
             head &= FIND_QUEUE_SZ_MASK;
+#endif
 ...
+#ifdef CAS_FIND_RING_OFFSETS
+      this->find_tail = tail / sizeof(KVQ);
+      this->find_head = head / sizeof(KVQ);
+#else
       this->find_tail = tail;
       this->find_head = head;
+#endif
+#undef FQ
```

Design notes:
- **The ring change is local to the fast loop.** `find_tail` / `find_head` stay indices
  everywhere else (slow path, `flush_if_needed`, `pop_find_queue`, `get_find_queue_sz`). They
  are converted to byte offsets on entry and back on exit. That costs 4 instructions per batch,
  ~0.25 per find.
- **The first version produced a different default build.** It used a `fq()` lambda and
  local copies of the mask in both branches of the `#ifdef`, and with the options OFF it changed
  the default path's register allocation. The final version keeps every original line verbatim
  under `#else`. The only shared edit is `FQ(i)`, which expands to exactly
  `(this->find_queue[i])`.
- **The first ring build used 32-bit offsets and saved only the `shl`.** gcc still needed a
  zero-extending `mov` plus an `add` per queue access. With 64-bit offsets, the tail+8 read
  addresses `0x10(%r9,%rbx,1)` directly, and pop/push use one `lea` each.
- **Storing the bucket pointer in the entry was dropped.** It was part of the v2 proposal. The
  slow path (`__find_simd` → `Item::find_simd`) reads `idx`, so the pointer would have to be
  stored in addition. Counted precisely, it nets ≈ −2 instructions and needs edits to shared
  `kvtypes.hpp` code.

### Codegen checks

- **Default build unchanged.** With both new options OFF, the machine code of `find_batch`
  (283 instructions) and `insert_batch` (457) is identical to `attempt2/before/dramhit`'s,
  compared as objdump output with addresses stripped. Byte comparison of the whole binary
  does not work: the build is RelWithDebInfo, so added header lines shift DWARF line numbers
  and `__LINE__` constants.
- **insert_batch unchanged in every variant.** Across all variants the only differences are
  RIP-relative displacements.
- **Prefetch instructions in find_batch** (all call sites):
  - base, ring, cmp, rc: 2 `prefetcht0` (the second prefetch) + 4 `prefetcht2`
  - l1 / rc_l1: 4 `prefetcht0` and no second prefetch
  - l2 / rc_l2: 4 `prefetcht1` and no second prefetch
  - cmp and the rc variants: 1 `vpcompressq`
- **Hit-path loop body:** base 51 instructions, ring 46.

## 3. Measurement protocol

```
attempt3/run_all.sh "base l1 l2 ring cmp rc rc_l1 rc_l2" "10 50 90" 3
#  per (rep, variant): python3 run_uniform_hbm.py --config baseline --energy --reps 1 \
#     --fill 10 --fill 50 --fill 90 [--no-hugepages] --binary attempt3/<v>/dramhit --tag a3_<v>_r<rep>
attempt3/summarize.py --json attempt3/summary.json
```

- **One hugepage pool for everything.** It is reserved once, before the first run, and every
  later run passes `--no-hugepages`. Variants are therefore never compared across pools, which
  `report-throttling.md` §4 found can shift results by up to ~7%.
- **Interleaved.** Reps are the outer loop and variants the inner loop, so drift during the
  session is spread over all variants.
- **The sweep was split in two.** The background job hit its time limit during rep 3, and the
  missing points (`rc` fill 90, all of `rc_l1` and `rc_l2`) were run right after, on the same
  pool with no re-reservation.
- **Correctness.** Every run passed the collector's `found == find_ops` check. `failures` is
  empty for all 72 runs.
- Outputs: `results/a3_<v>_r<rep>/` (json and logs) and `attempt3/summary.json`.

## 4. Results

### Find (get), median of 3

| fill | variant | Mops (min–max) | vs base | HBM GB/s | pkg W | core GHz | nJ/find | vs base |
|---|---|---|---|---|---|---|---|---|
| 10 | base  | 3926 (3923–3954) |  –     | 245 | 351 | 2.23 |  89.4 |  –     |
| 10 | l1    | 3269 (3255–3283) | −16.7% | 204 | 351 | 2.56 | 107.2 | +19.9% |
| 10 | l2    | 3712 (3710–3717) |  −5.5% | 230 | 349 | 2.36 |  94.1 |  +5.2% |
| 10 | ring  | 4112 (4085–4161) |  +4.7% | 256 | 351 | 2.20 |  85.4 |  −4.5% |
| 10 | cmp   | 4036 (4007–4037) |  +2.8% | 249 | 350 | 2.19 |  86.7 |  −3.0% |
| 10 | **rc**| **4204** (4181–4232) | **+7.1%** | 267 | 350 | 2.18 | **82.6** | **−7.6%** |
| 10 | rc_l1 | 3432 (3429–3435) | −12.6% | 212 | 349 | 2.56 | 101.6 | +13.6% |
| 10 | rc_l2 | 4013 (3981–4030) |  +2.2% | 251 | 351 | 2.23 |  87.4 |  −2.2% |
| 50 | base  | 3646 (3608–3654) |  –     | 244 | 348 | 2.19 |  95.3 |  –     |
| 50 | l1    | 3084 (3057–3121) | −15.4% | 206 | 349 | 2.51 | 113.2 | +18.8% |
| 50 | l2    | 3448 (3419–3465) |  −5.4% | 231 | 349 | 2.30 | 101.0 |  +6.0% |
| 50 | ring  | 3835 (3755–3849) |  +5.2% | 255 | 349 | 2.15 |  90.9 |  −4.6% |
| 50 | cmp   | 3746 (3712–3751) |  +2.7% | 250 | 349 | 2.16 |  93.1 |  −2.3% |
| 50 | **rc**| **3918** (3885–3926) | **+7.5%** | 261 | 349 | 2.12 | **89.2** | **−6.4%** |
| 50 | rc_l1 | 3248 (3232–3260) | −10.9% | 217 | 348 | 2.45 | 107.2 | +12.5% |
| 50 | rc_l2 | 3657 (3642–3665) |  +0.3% | 244 | 349 | 2.16 |  95.3 |   0.0% |
| 90 | base  | 2428 (2418–2460) |  –     | 244 | 348 | 2.16 | 143.4 |  –     |
| 90 | l1    | 2172 (2164–2177) | −10.5% | 217 | 348 | 2.36 | 160.4 | +11.9% |
| 90 | l2    | 2169 (2141–2193) | −10.7% | 222 | 349 | 2.20 | 160.8 | +12.1% |
| 90 | ring  | 2548 (2415–2555) |  +4.9% | 252 | 349 | 2.11 | 137.2 |  −4.3% |
| 90 | cmp   | 2484 (2481–2489) |  +2.3% | 246 | 349 | 2.12 | 140.6 |  −1.9% |
| 90 | **rc**| **2599** (2598–2603) | **+7.0%** | 254 | 349 | 2.07 | **134.1** | **−6.4%** |
| 90 | rc_l1 | 2270 (2244–2286) |  −6.5% | 228 | 348 | 2.31 | 153.4 |  +7.0% |
| 90 | rc_l2 | 2270 (2253–2273) |  −6.5% | 234 | 349 | 2.12 | 153.8 |  +7.3% |

- **Where rc stands.** Its reps do not overlap base's range at any fill. The base numbers agree
  with the baseline sweep in `report.md` (3933 / 3699 / 2447 there).
- **ring and cmp add up almost linearly.** At fill 10: +4.7% and +2.8% alone, +7.1% together.

### Insert (set): the control

insert_batch is the same code in every variant.
- Fill 50: every variant is within −0.9% to +0.6% of base, at 111.7–113.2 nJ/insert.
- Fill 90: within −0.3% to +0.8%, at 166.2–167.9 nJ/insert.
- Fill 10: every variant reads +1.0% to +3.9%, but base's own reps span 3341–3452 there, so this
  is inside the noise.
- Full table: `attempt3/summarize.py`.

### Instructions and cycles per find (perf, fill 10, one run each)

`attempt2/perf_profile.sh attempt3/<v>/dramhit 10 attempt3/<v>/prof_fill10`, then
`attempt2/summarize.py`. The find_batch symbol only, in core cycles:

| variant | instr/find | Δ | core cycles/find | IPC | predicted Δ (v2 doc) |
|---|---|---|---|---|---|
| base | 57.0 | – | 30.4 | 1.88 | |
| ring | 52.0 | −5.0 | 28.0 | 1.86 | −6 (−5 in the 64-bit version's loop body) |
| cmp  | 54.1 | −2.9 | 29.0 | 1.87 | −3 |
| rc   | 49.2 | −7.8 | 27.3 | 1.80 | −8 to −9 |

The instruction savings land where predicted, and find_batch core cycles fall by 10% (30.4 → 27.3).

## 5. Why change 1 loses: the second prefetch is the cheapest place to wait

Fill-buffer counters for base, l1 and l2 at fill 10 (`perf stat` over the whole run; insert code
is identical, so the differences come from the find path). Raw data:
`attempt3/lfb_counters_fill10.txt`.

| counter | base (DOUBLE) | l1 | l2 |
|---|---|---|---|
| cycles | 413e9 | 481e9 | 428e9 |
| `l1d_pend_miss.fb_full` (cycles a request waited for a free L1 fill buffer) | 224e9 (**54%** of cycles) | 317e9 (66%) | 221e9 (52%) |
| `l1d_pend_miss.pending_cycles` (cycles with ≥1 L1 miss outstanding) | 20e9 | 19e9 | **61e9** |
| `l2_rqsts.swpf_hit` (software prefetches that hit L2) | 5.37e9 (one per find) | 0.14e9 | 0.02e9 |
| `l2_rqsts.swpf_miss` | 5.70e9 | 4.64e9 | 5.98e9 |

- **The find is fill-buffer bound, as `report-attempt2.md` inferred.** Even in base, some
  request is waiting for a free L1 fill buffer in 54% of all cycles.
- **Base (DOUBLE).**
  - The first prefetch (`prefetcht2`) takes the line HBM→L2.
  - The second (`prefetcht0`, 8 slots before the pop) is an L2 hit, one per find (5.37e9 =
    find_ops). It brings the line to L1, and that is where the core waits for a fill buffer.
  - The demand load then hits L1.
- **l1: a single `prefetcht0` at enqueue.** Each prefetch holds an L1 fill buffer for the whole
  HBM round trip, not just for the L2→L1 hop. Fill-buffer-full cycles rise by 93e9, fewer lines
  are in flight, and HBM bandwidth falls to ~205 GB/s.
- **l2: a single `prefetcht1` at enqueue.** Fill-buffer pressure is unchanged, but the demand
  load now misses L1: cycles with a miss outstanding triple (20e9 → 61e9). An L2-hit demand
  load stalls retirement longer than the second prefetch did.
- **Conclusion for change 1.** The ~11 cycles per find attributed to the second prefetch are
  the cost of moving the line into L1 while other misses hold the fill buffers. That cost does
  not disappear when the prefetch is removed; it moves somewhere more expensive.

## 6. The power interplay, seen directly

All variants sit at the 350 W limit (pkg W 348–351 in every find row), so energy per find is
just 350 W over throughput. What varies is how that fixed power is spent:
- **l1 runs at a higher clock and does less.** It gets 2.51–2.56 GHz, against 2.19–2.23 GHz for
  base. Its cores stall on fill buffers more, and a stalled core presumably draws less power per
  cycle (inferred from the clock; per-core power is not measurable here), so the power
  controller gives it more clock. But it completes 15–17% fewer finds, and energy per find
  rises 19–20%. This is the "less efficient code draws less power, but loses performance"
  case: the power freed by stalling returns as clock that the stalled cores cannot use.
- **rc runs at a slightly lower clock and does more.** It gets 2.07–2.18 GHz, against
  2.16–2.23 for base. It moves more HBM traffic (261–267 vs 244–245 GB/s at fills 10–50), and
  that spends part of the same 350 W in the memory system. Its useful work per joule is still
  7% higher, because each find retires 8 fewer instructions.
- **The metric to optimize is nJ/op, not W, GHz or IPC.** l1 has the highest clock and the
  worst nJ/op. rc has the lowest clock and the best.

## 7. Conclusion and next

- **Keep changes 2 and 3** (`-DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON`) with
  `PREFETCH=DOUBLE`: +7.0% to +7.5% finds and −6.4% to −7.6% nJ/find. Both options are still
  OFF by default, so the paper build is unchanged. Turning them on is a decision for review.
- **Drop change 1** (single prefetch, L1 or L2). DOUBLE is the right prefetch scheme on HBM.
- **Where find stands against the budget.**
  - Base: ~37.5 core cycles per find, including the harness.
  - rc: find_batch alone goes from 30.4 to 27.3 core cycles.
  - Target: ~22 core cycles at ~2.15 GHz for the sustained ~400 GB/s.
  - The remaining gap is dominated by fill-buffer occupancy (54% of cycles), not by
    instruction count.
- **Next directions:**
  - **Fewer fill-buffer-cycles per find.** The DOUBLE scheme holds a fill buffer twice per line:
    once for the whole HBM trip (the first prefetch) and once for the L2→L1 hop. Options: the
    distance of the second prefetch (8 now; `PREFETCH_FIND_NEXT_DISTANCE`), and the queue depth
    (`--find_queue`), which set how long each line waits in L2 vs L1. Both are one-line or
    command-line experiments, and they can be read directly on `l1d_pend_miss.fb_full`.
  - **Keep trimming instructions.** At a fixed 350 W, each instruction removed is worth
    about 1% of throughput here: 7.8 fewer gave +7%. The next candidates are the harness's
    per-key stores (~8–9 instructions/key/phase, including the unused `value`) and the per-batch
    overhead (a larger `--batch-len`).
