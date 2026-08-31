# Why the "inline" `find_batch` binary is faster than "no_inline"

Goal (from `instruction.txt`): explain, via static binary analysis of
`bin/inline` vs `bin/no_inline`, why the manually-inlined version of
`CASHashTable::find_batch` (the DRAMHiT "cas_kht" find-batch path, used
heavily by the `hashtable_test` / dramblast workload) is faster than the
non-inlined version. **No benchmarks were run** — this is disassembly +
source-code archaeology only, per instructions.

## 0. Setup

Both binaries are unstripped (`file` shows `with debug_info, not stripped`),
so full demangled symbol names are available via `nm -C` / `objdump -dC`.

```
file bin/inline bin/no_inline
nm -C bin/inline  | grep find_batch
nm -C bin/no_inline | grep find_batch
```

Both expose exactly one interesting symbol:

```
kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::find_batch(...)
```

This is the `find_batch` defined in `include/hashtables/cas_kht.hpp` (the
"cas kht" / DRAMHiT hashtable mentioned in the instructions). Sizes from
`nm --size-sort -C`:

| binary     | `find_batch` size |
|------------|-------------------|
| `inline`   | `0x40d` = 1037 B  |
| `no_inline`| `0x4b9` = 1209 B  |

So the "inline" binary's `find_batch` is actually **smaller**, not just
faster — first hint that this isn't simply "more code got unrolled", but
that something structural changed.

## 1. Extracting and reading the disassembly

```
objdump -d -C -M intel bin/inline    > inline_full.disasm
objdump -d -C -M intel bin/no_inline > no_inline_full.disasm
# then slice out the find_batch symbol range from each (saved under asm/)
```

The extracted bodies are saved in `asm/inline_find_batch.asm` and
`asm/no_inline_find_batch.asm` for reference.

**First check: is this actually about inlining `__find_one`/`__find_branched`
calls?**

```
grep -c call asm/inline_find_batch.asm asm/no_inline_find_batch.asm
```

Result: **zero `call` instructions in either binary.** GCC/Clang at `-O3`
already fully inlines `add_to_find_queue`, `pop_find_queue`, `__find_one`,
`__find_branched`, `prefetch_read`, etc. into `find_batch` in *both*
binaries. So "manual inlining" here is not about eliminating a function-call
boundary in the classic sense — both are already leaf-inlined. Something
else must differ.

**Second check: is this AVX-512 vs scalar?**

Both bodies contain `vmovdqa64`, `vpcmpequq`, `kortestb`, `tzcnt`, `crc32`
(hash), `prefetcht0`/`prefetcht2` — i.e. **both binaries use the same
bucketized AVX-512 cacheline-compare strategy** (`BUCKETIZATION` +
`CAS_SIMD`, matching the `DRAMHiT_2025_INLINE` / `2023_INLINE` CMake variant
in `CMakeLists.txt:82-89`, which turns on `-DBUCKETIZATION -DCAS_SIMD`). Each
64B hashtable cacheline holds up to 4 packed `(key,value)` pairs; the mask
`KEYMSK = 0b01010101` (`0x55`, visible as `and eax,0x55` after `kmovb`)
selects only the 4 key lanes out of the 8 `uint64_t` lanes in the ZMM
register, `vpcmpequq` compares all 4 keys against the broadcast search key
in one shot, and `tzcnt` finds the first matching lane. This confirms the
code matches `cas_kht.hpp:573-679` (the `DRAMHiT_2025_INLINED` branch of
`find_batch`, guarded by `[[likely]] fast_path`).

So **the SIMD/bucketization strategy is identical in both binaries** — that
rules out "vectorized vs scalar" as the explanation. The difference has to
be something the compiler did (or didn't do) around that shared SIMD core.

## 2. The real difference: is `find_head`/`find_tail` kept in registers?

`find_head` and `find_tail` are the circular-queue cursor fields of
`CASHashTable` (offsets `0xb0`/`0xb4` off `this` in both binaries — confirmed
identical layout via `nm`/`objdump`). Every key that flows through
`find_batch` needs to read and advance these two `uint32_t` fields. Counting
every memory access to these two offsets *inside `find_batch` only* (i.e.
excluding the unrelated `flush_find_queue` symbol that follows it in the
`.text` dump):

```
grep -E "0xb0\]|0xb4\]" asm/inline_find_batch.asm     # restricted to addresses < flush_find_queue
grep -E "0xb0\]|0xb4\]" asm/no_inline_find_batch.asm
```

**`inline` binary — fast path (`43cb50`–`43ccb2`, the `[[likely]]` SIMD
loop):**
```
43cb0c: mov edi, DWORD PTR [rdi+0xb0]     ; load find_head  (ONCE, before loop)
43cb16: mov edx, DWORD PTR [r15+0xb4]     ; load find_tail  (ONCE, before loop)
   ... entire per-key SIMD compare-and-reprobe loop runs on registers edx/edi only ...
43cc93: mov DWORD PTR [r15+0xb4], edx     ; store find_tail (ONCE, after loop)
43cc9a: mov DWORD PTR [r15+0xb0], edi     ; store find_head (ONCE, after loop)
```
That's it — **4 total memory touches of the queue cursors for the entire
batch**, no matter how many keys (`config.batch_len`, typically 16–256) are
in `kp`. This corresponds exactly to source `cas_kht.hpp:575-576` and
`:681-682`:

```cpp
uint32_t tail = this->find_tail;
uint32_t head = this->find_head;
...                                  // whole batch loop operates on tail/head locals
this->find_tail = tail;
this->find_head = head;
```

**`no_inline` binary — the only loop it has:**
```
43c624: mov ecx, DWORD PTR [rdi+0xb0]   ; load head (entry)
43c62a: mov eax, DWORD PTR [rdi+0xb4]   ; load tail (entry)
43c6ed: mov DWORD PTR [rdi+0xb4], eax   ; store tail          <- inside per-key path
43c7bf: mov DWORD PTR [rdi+0xb0], ecx   ; store head          <- every key (add_to_find_queue)
43c7d0: mov eax, DWORD PTR [rdi+0xb4]   ; reload tail          <- every key (get_find_queue_sz)
43c7e4: mov ecx, DWORD PTR [rdi+0xb0]   ; reload head
43c82e: mov r9d, DWORD PTR [rdi+0xb0]   ; reload head          <- inside pop path
43c865: mov DWORD PTR [rdi+0xb0], edx   ; store head
43c86b: mov DWORD PTR [rdi+0xb4], eax   ; store tail
43c8cc: mov DWORD PTR [rdi+0xb4], eax   ; store tail
43c941: mov DWORD PTR [rdi+0xb4], eax   ; store tail
43c9b2: mov DWORD PTR [rdi+0xb0], ecx   ; store head
43c9c3: mov eax, DWORD PTR [rdi+0xb4]   ; reload tail
43ca1d: mov DWORD PTR [rdi+0xb0], ecx   ; store head
43ca23: mov DWORD PTR [rdi+0xb4], eax   ; store tail
43ca8e: mov DWORD PTR [rdi+0xb4], eax   ; store tail
```
That's **15 additional loads/stores of the same two fields**, and critically
the two marked "every key" (`43c7bf` store-head, `43c7d0` reload-tail) sit on
the unconditional per-iteration path of the `for (auto &data : kp)` loop, so
they execute **once per key, every single key**, not once per batch.

## 3. Why the compiler couldn't hoist it in `no_inline`

This isn't a missed-optimization accident — it's a direct, mechanical
consequence of how the two code paths in `cas_kht.hpp` are written:

- **Fast/inlined path** (`cas_kht.hpp:570-693`, compiled into `bin/inline`):
  computes `fast_path` **once**, then hoists `this->find_tail`/`find_head`
  into local variables `tail`/`head` **before** entering the per-key loop,
  and writes them back **once** after the loop. Because `tail`/`head` are
  plain local `uint32_t`s (not `this->` member accesses) for the loop's
  entire duration, the compiler has no aliasing question to resolve inside
  the loop — the two cursors are pure register-resident scalars for the
  whole batch, and reprobing (the `goto retry` in source) operates purely on
  registers.

- **Non-inlined path** (`cas_kht.hpp:528-554`, the `DRAMHiT_2025` variant
  compiled into `bin/no_inline`): every iteration of `for (auto &data : kp)`
  calls `get_find_queue_sz()` (`(this->find_head - this->find_tail) & MASK`,
  `cas_kht.hpp:453-455`) to decide whether to pop, then
  `add_to_find_queue()` (`cas_kht.hpp:1148-1178`), which reads-increments-
  masks-writes `this->find_head` as a **member access through `this`** every
  single call, and — when the queue is full — `pop_find_queue()` does the
  same for `this->find_tail`. Nothing in this source path ever caches
  `find_head`/`find_tail` in a local across more than one key. Even though
  the compiler fully inlines these helpers (no `call` instructions, as shown
  above), each inlined instance still faithfully reproduces "read member,
  compute, write member" *every time the source says to*, because that's
  what the un-inlined algorithm literally does — it re-checks the queue's
  fill level per key instead of assuming, for the whole batch, that the
  queue is already saturated.

In other words: the "manual inlining" isn't just a code-shape trick — it's
an **algorithmic hoist**. It amortizes the "is the retry queue full enough
to have a bucket ready for every key" decision once per *batch* instead of
once per *key*, which is only valid because the fast path is guarded by a
single `fast_path` check at the top (`[[likely]]`) that assumes steady
state. That single source-level restructuring is what lets the register
allocator keep `find_head`/`find_tail` live in `edx`/`edi` for an entire
batch in `bin/inline`, versus round-tripping them through memory on every
key in `bin/no_inline`.

## 4. Why that matters for performance

Each `store` immediately followed by a dependent `load` of the same address
(as seen repeatedly in `no_inline`, e.g. `43c7bf` store-head then `43c9b2`
store-head again after a reload) is a **store-to-load-forwarding** round
trip: several cycles of latency even when it hits the store buffer, and it
also blocks the CPU from reordering/pipelining independent iterations as
aggressively, because each iteration has a real (not just apparent)
read-after-write dependency on the *previous* iteration's stores to
`this->find_head`/`find_tail`. With `HT_TESTS_BATCH_LENGTH` typically in the
16–256 range (`include/constants.hpp:17,20`), `bin/no_inline` pays this
penalty on the order of `O(batch_len)` times per `find_batch` call, while
`bin/inline` pays it a constant 4 times **per call regardless of batch
size** — the win scales with batch size, and DRAMHiT is specifically tuned
to run with large batches to amortize prefetch latency, so this is exactly
the regime where the workload described in `instruction.txt` ("a large
amount of find and insertion occurs via find batch") lives.

This also explains the earlier size numbers: `bin/inline`'s `find_batch` is
*smaller* (1037 B vs 1209 B) even though it's faster — the extra bytes in
`no_inline` are exactly these repeated load/store/mask sequences for
`find_head`/`find_tail`, not "more work being done"; they're pure overhead
from not being able to prove the fields are safe to keep in registers across
the loop.

## 5. Supporting/negative-control evidence

- `vtable for kmercounter::CASHashTable<...>` (`objdump -s -j .data.rel.ro`)
  contains `find_batch`'s address in **both** binaries — `find_batch` is
  still virtual/overriding in both, so this is not a devirtualization
  difference at the `find_batch` call site itself.
- The call sites that invoke `find_batch` polymorphically
  (`ZipfianTest::run(Shard*, BaseHashTable*, ...)`,
  `rw_experiment::run(...)`) are **byte-identical** in size between the two
  binaries and dispatch exclusively through indirect `call QWORD PTR
  [reg+offset]` — i.e. the difference is not "inlined into the caller vs.
  not"; it is entirely internal to `find_batch`'s own instruction selection.
- `git log --all --oneline | grep -i inline` surfaces
  `6fffb21 "Changed find_batch to non-virtual function so compiler can
  properly inline"`, which is the historical commit that split the old
  single virtual `find_batch` into `find_batch_simple` /
  `find_batch_unrolled` — the unrolled version in that commit already
  contains the `uint32_t tail = this->find_tail; uint32_t head =
  this->find_head;` hoist that we observe compiled into `bin/inline` today.

## 6. Conclusion

Both binaries compile `find_batch` down to a fully-inlined (no `call`s),
AVX-512-vectorized, bucketized cacheline-compare loop — the SIMD strategy
itself is identical. The measured speedup of the "inline" binary comes from
a specific, source-visible restructuring of the *find-queue bookkeeping*:
the manually-inlined fast path caches the circular queue's `find_head`/
`find_tail` cursors in local variables for the duration of an entire batch
and writes them back once, while the non-inlined path re-derives and
re-stores both cursors through `this->` on every single key (confirmed by
counting `[rdi/r15+0xb0]`/`[+0xb4]` accesses: 4 total for the whole batch
in `bin/inline` vs. 15+ with at least 2 guaranteed per key in
`bin/no_inline`). That difference in memory-traffic-per-key, not a
difference in vector width or arithmetic, is the mechanism behind the
observed slowdown in the non-inlined binary.
