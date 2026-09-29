# Micro-optimization ideas for DRAMHiT find_batch / insert_batch (HBM, uniform)

## Context
`hbm-debug.md`: the HBM box sustains ~250 GB/s on finds, which works out to ~44 cycles per cacheline. The target of ~420 GB/s allows ~26 cycles, so each probe needs to lose ~18 cycles of CPU work. Config: `DRAMHiT_VARIANT=2025_INLINE` (which turns on BUCKETIZATION and CAS_SIMD), `PREFETCH=DOUBLE`, `UNIFORM_PROBING=ON`, KV=`Item` (16 B, 4 per line). This is static reasoning only; nothing can be run on this machine.
Hot code: the `DRAMHiT_2025_INLINED` fast paths in `include/hashtables/cas_kht.hpp` (insert_batch at about line 269, find_batch at about line 583).

## Suggestions (highest expected gain first)

### 1. Make the find fast path branch-free: one pop and one push per iteration
Right now each iteration branches three ways (hit / empty / reprobe). A reprobe does `goto retry` without consuming an input. With uniform probing, whether a bucket is full is random, so these branches mispredict at a rate that rises with fill. Each mispredict costs ~15–20 cycles, about the whole gap to the target.
Restructure the loop so every iteration does exactly one pop, one cacheline test and one push:
- `retry = (key_cmp==0) & (ept_cmp==0)`, `found = key_cmp!=0`
- Always write `*vp_result = {id, bucket[off+1]}` and advance `vp_result += found`. The value load needs a safe `off` when there is no hit, e.g. `off = tzcnt(key_cmp|0x80)`.
- Pick the entry to push with cmov/blend. key: `retry ? q->key : in->key`. hash: `retry ? crc(q->key_hash) : crc(in->key)`. Compute both CRCs every time; CRC32 is 1 per cycle. Then advance the input pointer by `!retry`.
- The loop becomes `while (in != end)`, so the loop exit is the only branch that is hard to predict.
Also apply this to insert_batch's reprobe path. The CAS branch stays there, but the full-bucket/requeue branch can become the same kind of select.

### 2. Shrink the find queue entry from 32 B to 16 B and drop `idx`
`ItemQueue` (kvtypes.hpp:85) with UNIFORM_HT_SUPPORT is {key 8, value 8, idx 4, key_id 4, key_hash 8} = 32 B. Finds never use `value`. `_mm_crc32_u64(0xffffffff, x)` always returns a value below 2^32, and `idx == key_hash & HT_BUCKET_MASK`. So a find-only entry `{u64 key; u32 hash; u32 key_id;}` (16 B) holds everything:
- 3 stores per push instead of 4, or a single 16 B store.
- 4 entries per cacheline instead of 2, so the queue ring takes half the L1 space, and the DOUBLE_PREFETCH lookahead load (`find_queue[next_tail].idx`) more often lands on a line already in L1.
- The chained rehash `crc32_u64(hash)` gives the same result whether the stored hash is zero-extended from u32 or not, so probe sequences don't change.
Use a separate `FindQueueEntry` type for `find_queue` so the insert queue (which needs `value`) is untouched.

### 3. Hoist members into locals and add `__restrict`
In the loops, `HT_BUCKET_MASK` and `capacity` are `uint64_t` members, and each iteration stores `uint64_t` values (`find_queue[head].key/key_hash`, `vp_result->value`). Under strict aliasing those stores may alias the members, so the compiler has to reload `this->HT_BUCKET_MASK`, `this->capacity`, `this->hashtable` and `this->find_queue` after every store. `insert_batch` also computes `capacity - 1` and `& ~KEYS_IN_CACHELINE_MASK` several times per op (the TODO at line 274 already points at this).
Fix: load `const uint64_t mask`, `KV *__restrict ht`, `KVQ *__restrict fq/iq` and `FindResult *__restrict out` once before the loop. In insert, use `hash & mask` (one AND) in place of `(hash & (cap-1)) & ~KEYS_IN_CACHELINE_MASK`. Each fix saves only a few uops, but they are paid on every probe.

### 4. insert_batch: call CRC directly and avoid the locked 16-byte CAS
- The insert fast path hashes through `this->hash()` → `Hasher::operator()` (hasher.hpp:25). That function switches on the runtime `key_length`, and it is called twice (new key and rehash). find_batch already calls `_mm_crc32_u64` inline; do the same in insert.
- The common uniform case is a unique key landing in an empty slot, which takes `lock cmpxchg16b` (line 342). That instruction is microcoded (~20+ cycles), acts as a full fence and drains the store buffer. This is likely related to the "store queue full" investigation in commit 3e15160. Options:
  (a) Claim the slot with a 64-bit `lock cmpxchg` on the key, then do a plain store of the value. This is cheaper, but a concurrent find can briefly see value 0, which is fine when insert and find phases are separate.
  (b) Turn on READ_BEFORE_CAS when the SIMD snapshot shows the slot is already taken.
- On requeue, copy the 32 B entry with one `_mm256_load/store` and then patch idx/hash, instead of 4–5 separate field stores.

### 5. Make the second (DOUBLE_PREFETCH) prefetch cheaper
Each find currently does two prefetch instructions: prefetcht2 at enqueue, then prefetcht0 at tail+8. The second one depends on a load of `find_queue[next_tail].idx`, plus an address calculation. Options:
- With suggestion 2 in place, compute the tail+8 address from the hash (`hash & mask`), which comes from the same compact entry.
- Try PREFETCH=L1 (a single prefetcht0 at enqueue) with a larger queue, because on HBM the latency is the same while bandwidth is plentiful. This drops one load and one prefetch per op.
- Minor: read the hit value straight from the `cacheline` register (`_mm512_maskz_compress_epi64(key_cmp<<1, cacheline)` → `_mm_cvtsi128_si64`) instead of reloading `bucket[off+1]`.

## Suggested implementation order
Start with 3 and 4a/hash (low risk, mechanical), then 2, then 1 (the biggest change and likely the biggest win). Keep each one behind its own CMake option so it can be measured separately on the HBM machine.

## Verification (on the HBM machine)
- Correctness: run the existing uniform insert/find tests (synth_test and similar) with CALC_STATS, and check that found counts and fill are identical before and after.
- Performance: compare cycles/op and memory bandwidth against 250 GB/s. Use `perf stat -e cycles,instructions,branch-misses,uops_issued.any` to confirm the branch-miss drop from suggestion 1 and the uop drop from suggestions 2, 3 and 4.
- Inspect the generated asm (`objdump -d`) of find_batch_inline for member reloads before and after suggestion 3.
