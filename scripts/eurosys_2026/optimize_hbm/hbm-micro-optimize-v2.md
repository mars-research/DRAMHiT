# find_batch micro-optimization, round 2 (for review)

This revises `hbm-micro-optimize.md` using what attempts 1–2 and the throttling work measured:
- `report.md`: using both sockets is a loss.
- `report-attempt2.md`: branch-free find is correct but slower. The code is reverted.
- `report-throttling.md`: finds run at ~2.15 GHz under the 350 W package limit, and energy per
  op costs clock.

Nothing here is implemented yet. It is the proposal for review.

State of the tree:
- `include/hashtables/cas_kht.hpp` and `CMakeLists.txt` are back at the committed version, and
  the CAS_FIND_BRANCHLESS option is gone.
- `build/dramhit` was rebuilt and is byte-identical to `attempt2/before/dramhit`, the binary all
  the "before" profiles below come from.
- `build_branchless/` was deleted.
- The branchless change is kept as `attempt2/branchless.diff`.

## 1. The find path, instruction by instruction

Build: the paper flags (`DRAMHiT_VARIANT=2025_INLINE`, BUCKETIZATION, BRANCH=simd,
PREFETCH=DOUBLE, UNIFORM_PROBING, RelWithDebInfo -O3).

Measured at fill 10 (`attempt2/before/fill10`): **57.1 instructions and 30.8 core cycles per find
inside find_batch**. At fill 10 essentially no key reprobes, so this is the hit path. The
source lines come from `objdump -d -l`, i.e. the DWARF line table.

| group | what it is | instr | find_batch cycles % (fill 10) | ≈ core cycles/find |
|-------|-----------|-------|-------------------------------|--------------------|
| A | DOUBLE_PREFETCH second prefetch: `next_tail=(tail+8)&mask`, load `find_queue[next_tail].idx`, `prefetcht0 ht[idx]` (L2→L1) | 6 | **37.8** | **11.6** |
| B | pop: `&find_queue[tail]` (mov/shl/add), load `q->idx`, `ht+idx*16` (shl/add), load `q->key` | 7 | 4.7 | 1.4 |
| C | probe: `vmovdqa64` bucket, `vpbroadcastq` key, `vpcmpequq {0x55}`, `kortestb`, `je` | 5 | 9.6 | 3.0 |
| D | ring indices: `tail=(tail+1)&mask`, `head=(head+1)&mask`, `&find_queue[head]` (mov/shl/add) | 7 | 4.0 | 1.2 |
| E | hit: `xor`, `kmovb`, `tzcnt`, `inc`, `movslq`, load `bucket[off+1]`, load `q->key_id`, 2 result stores, `vp_result++` | 10 | 11.8 | 3.6 |
| F | next input: load `in->key`, `crc32`, `& HT_BUCKET_MASK`, pack (idx, `in->id`) with `vmovd`+`vpinsrd`, `in++` | 8 | 8.4 | 2.6 |
| G | first prefetch: `idx*16`, `prefetcht2 ht[idx]` (HBM→L2) | 3 | 9.3 | 2.9 |
| H | push: store key, store key_hash, store packed (idx, id) | 3 | 4.5 | 1.4 |
| I | loop: `cmp end(%rsp)`, `jne` | 2 | 4.2 | 1.3 |
| | **loop body** | **51** | 94.1 | 29.0 |
| | per-batch entry (42) + exit (17) + call/ret, over 16 keys | ~3.7 | ~5 | ~1.5 |
| | reprobe iterations + sampling skid of the instructions event | ~2.4 | | |
| | **find_batch total** | **57.1** | | **30.8** |

Outside find_batch, the harness (`ZipfianTest::run`) adds ~17 instructions per op, split across
the two phases. That is ~8–9 per key per phase: read `workload[idx]`, the prefetch check, and
three stores into the 24 B `InsertFindArgument`, including a `value` field that find never
reads. With the harness, a find costs ~37.5 core cycles in all (46 TSC cycles, at ~2.15 GHz).

### What the listing says

- **The time is in one place, not spread over the instructions.** Group A is 6 instructions
  and 38% of the cycles. Its `prefetcht0` alone is 33% (~10 core cycles/find). The other 45
  instructions retire at roughly 1 cycle each, which is the ~4% PEBS spread seen in the
  profile.
- **Where A's cost likely comes from.** A is the fill-buffer (LFB) stall described in
  `report-attempt2.md`: every find issues two software prefetches that each need an L1 fill
  buffer, and the first one holds its buffer for the whole HBM trip.
- **The old suggestion 3 (hoist members into locals, `__restrict`) is already done by gcc.**
  `hashtable`, `HT_BUCKET_MASK`, `find_queue`, `FIND_QUEUE_SZ_MASK` and the CRC seed are loaded
  once before the loop (r10, r13d, r9, r8d, r12), and nothing is reloaded inside it.
  **Dropped.**
- **The old suggestion 1 (branch-free) was tried and lost** (attempt 2). At low fill there
  are 0.002 mispredicts per find. **Dropped.**
- **Index arithmetic is avoidable overhead.** 13 of the 51 instructions are only address
  arithmetic on 32-bit indices, the `shl $5` / `shl $4` / `add` in groups A, B, D and G. The
  find queue stores a 32-bit bucket *index* and uses 32-bit ring *indices*, so every access
  rebuilds a pointer.
- **The queue entry is 32 B, but a find uses 24 B of it.** `ItemQueue` is
  {key 8, value 8, idx 4, key_id 4, key_hash 8}, and `value` is never written or read on the
  find path.

## 2. Three proposed changes

Each change is independent, sits behind its own CMake option, and is measured on its own
against `attempt2/before`, with the same protocol as before:
- `attempt2/perf_profile.sh` at fills 10 / 50 / 90
- `run_uniform_hbm.py --binary ... --tag ...`, 3 reps
- `found == find_ops` in every run

Change 1 needs no code for its first test.

### Change 1: one prefetch per find instead of two (drop group A)

**What.**
- Replace DOUBLE_PREFETCH on the find path with a single prefetch at enqueue that brings the
  bucket all the way to L1 (`prefetcht0`), i.e. `-DPREFETCH=L1`.
- This removes the second `prefetcht0` at tail+8 and the queue load that computes its address.

**Why.** Group A is the single largest cost: 37.8% of find_batch cycles, ~11.6 core cycles per
find. It is also 6 instructions (~10% of the count), which matters for power as well as time.

**Will a line prefetched at enqueue still be in L1 when it is popped?**
- Lookahead: 64 queue slots at ~17 ns per find per thread is ~1.1 µs between prefetch and use,
  against ~130–160 ns HBM latency.
- Footprint: 64 lines per thread × 2 hyperthreads = 128 lines = 8 KB of the 48 KB L1D.
- That leaves room for the lines to survive.

**Risk.**
- The L1 fill-buffer pressure may not go away. With PREFETCH=L1, the single `prefetcht0` holds
  an L1 buffer for the full HBM trip, where DOUBLE holds one for the L2→L1 hop only. The stall
  could move from the second prefetch to the first one, or to the demand load.
- `../intel_hbm/readme.txt` measured this trade on the hash join: DOUBLE vs L1 was within ±4%.
  The uniform find loop is tighter, so it is worth measuring directly.
- Second variant, also just a flag: `-DPREFETCH=L2`, one prefetch at enqueue into L2 and no
  second prefetch. The demand load then takes an L2 hit (~15 cycles), which the queue depth
  should hide, and no L1 buffer is held for the HBM trip by a prefetch that goes to L1.

**Cost to test.** Build flags only: `-DPREFETCH=L1` and `-DPREFETCH=L2`, each with
`-DCAS_PREFETCH_INSERTION=DOUBLE` set explicitly so inserts are not affected. Checked in
`CMakeLists.txt`: L1 defines `L1_PREFETCH` (`prefetch_read` issues a `prefetcht0`) and L2 defines
`L2_PREFETCH`, and neither defines `DOUBLE_PREFETCH`, so group A compiles out.

**Expected.** −6 instructions per find, and most of group A's ~11.6 cycles if the stall does not
simply move. That is the uncertain part, and the reason this is the first thing to measure.

### Change 2: pointer/offset-based find queue (cut the index arithmetic in B, D, G, A)

**What.** For the find queue only; the insert queue is untouched:
- Keep `find_head` / `find_tail` as **byte offsets** into the ring
  (`off = (off + sizeof(entry)) & ring_bytes_mask`). Queue accesses then use base+offset
  addressing directly, and the three-instruction `mov/shl/add` to form `&find_queue[i]`
  disappears. This happens twice per find (pop and push), and a third time if change 1 is not
  taken (the tail+8 read).
- Store the **bucket pointer** (`KV *`, 8 B) in the entry instead of the 32-bit `idx`. The pop
  then loads the pointer and uses it: `load ptr` instead of `load idx; shl; add`. The push
  already computes `ht + idx*16` for its prefetch, so storing it costs one `add`.
- Keep the 32-bit hash for reprobes (uniform probing chains `crc32(hash)`). `_mm_crc32_u64`
  returns a value below 2^32, so the chained rehash is the same for a 32-bit stored hash.
  The entry becomes {key 8, bucket ptr 8, hash 4, key_id 4} = 24 B, or 32 B aligned with the
  unused `value` gone. A separate `FindQueueEntry` type is used, so `ItemQueue` and the insert
  path do not change.

**Why.** 13 of the 51 loop instructions are index-to-pointer arithmetic. This removes about 8
of them on the hit path:
- −3 on the pop address
- −3 on the head address
- −2 on the bucket address
- +1 on the push, for the stored pointer
- −1 more on the tail+8 prefetch, if change 1 is not taken

**Risk.**
- Low for correctness: probe sequences and results are unchanged, which the
  `found == find_ops` check and the existing tests cover.
- The byte-offset ring needs `find_queue_sz × sizeof(entry)` to be a power of two. It is
  64 × 32 B.
- The expected cycle gain is modest (groups B+D+G are ~15% of the cycles). The main point is
  fewer instructions per find, which at a fixed 350 W should return some clock.

**Expected.** −7 to −8 instructions per find; a few percent of cycles directly, plus whatever
clock the lower instruction rate buys back.

### Change 3: take the hit value from the register instead of reloading it (group E)

**What.** On a hit the loop currently runs `xor; kmovb; tzcnt; inc; movslq`, then loads
`bucket[off+1]` again from memory. The cacheline is already in `zmm8`. Instead:

```c
__mmask8 vmask = key_cmp << 1;                        // value slot next to the matching key
__m128i v = _mm512_castsi512_si128(_mm512_maskz_compress_epi64(vmask, cacheline));
vp_result->value = _mm_cvtsi128_si64(v);
```

That is `kshiftlb`, `vpcompressq` and `vmovq`, 3 instructions instead of 6, with no second load
of the line.

**Why.**
- Group E is the second-largest group by cycles (11.8%, ~3.6 core cycles) and the largest by
  instruction count (10).
- The reload also re-reads a line that is in L1 but may be evicted by then under the queue's
  L1 footprint.

**Risk.**
- `vpcompressq` runs on port 5 with ~3–6 cycles of latency. It is off the critical path here,
  because only the result store consumes it.
- It is light AVX-512 integer work, which `report-throttling.md` §5 measured as free of any
  frequency license at this clock.
- If there is more than one match, it takes the lowest set bit, the same as `tzcnt` does now.

**Expected.** −3 instructions per find, and −1 load.

**Free companion knob, measured alongside change 3 at no code cost.** `--batch-len 32` or `64`
instead of 16 amortizes the per-batch entry/exit (~60 instructions per call) over more keys:
~3.7 → ~1.9 or ~0.9 instructions per find.

## 3. Summary for review

| change | removes (instr/find, hit path) | targets | cost to try | confidence |
|--------|--------------------------------|---------|-------------|------------|
| 1. single prefetch (PREFETCH=L1 or L2) | −6 | group A: 38% of cycles, the LFB stall | build flag only | uncertain: the stall may move |
| 2. byte-offset ring + stored bucket pointer | −7 to −8 | groups A/B/D/G index math | small code change, new FindQueueEntry | high for instructions, modest for cycles |
| 3. hit value via `vpcompressq` from the loaded line | −3 (−1 load) | group E | ~5 lines | high for instructions, small for cycles |

- **All three together:** 57 → ~40 instructions per find inside find_batch (−30%).
- **The cycle target is still far off.** From `report-throttling.md`, reaching the sustained
  ~400 GB/s at ~2.15 GHz needs ~22 core cycles per find. The find is at ~37.5 today, including
  the harness.
- **Only change 1 attacks the dominant stall.** Changes 2 and 3 cut instruction count and power.
  That makes change 1 the first to measure, and its result decides how much the other two can
  matter.

## Not proposed (and why)

- **Branch-free find (old 1):** measured as a loss (attempt 2). Mispredicts are ~0 at low fill.
- **Hoisting members / `__restrict` (old 3):** gcc already does it (see §1).
- **Insert-path changes (old 4):** out of scope for find_batch. The profile does show the same
  shape there (the second prefetch, a `prefetchw`, is 29.6% of insert cycles, and
  `lock cmpxchg16b` only 1.1%), so change 1's result should carry over to inserts via
  `CAS_PREFETCH_INSERTION`.
- **Harness (`ZipfianTest::run`):** ~8–9 instructions per key per phase, including a store of
  the unused `value`. It is outside find_batch, but it is part of the measured per-find cost
  and cheap to trim later.
