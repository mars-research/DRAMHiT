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

> **Correction:** an earlier version of this
> section claimed `get_find_queue_sz()` is re-evaluated on every loop
> iteration in `bin/no_inline`. That is wrong. `CAS_FAST_PATH` defaults `ON`
> in `CMakeLists.txt:35` (`-DFAST_PATH`), and disassembly confirms the
> `if (get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)` predicate
> (`cas_kht.hpp:533`) is evaluated **exactly once**, at function entry
> (`43c624`-`43c643` below), exactly like the `fast_path` check in
> `bin/inline`. The corrected trace and root cause are below.

**`no_inline` binary — entry (single queue-fullness check, matches
`cas_kht.hpp:533` under `FAST_PATH`):**
```
43c624: mov ecx, DWORD PTR [rdi+0xb0]   ; load head            (ONCE, before loop)
43c62a: mov eax, DWORD PTR [rdi+0xb4]   ; load tail            (ONCE, before loop)
43c634-643:  esi = (ecx - eax) & mask; cmp r8d, esi; ja 43c718  ; get_find_queue_sz() >= MASK ?
                                                                  ; jumps to the slow/priming
                                                                  ; loop only if the queue is
                                                                  ; NOT yet full (rare/first call)
```
So far this is identical in spirit to `bin/inline`'s entry — one check, not
a per-iteration one. The steady-state ("queue already full") case falls
through to an **unconditional** `for` loop at `43c690` that just does
`pop_find_queue(); add_to_find_queue();` every iteration, with no re-check —
exactly matching the `FAST_PATH` branch's first arm in
`cas_kht.hpp:533-538`. Tracing the memory accesses that are actually on
*that* per-key loop (as opposed to the one-time priming preamble at
`43c718-43c7ca`, which only ever runs on the first, not-yet-full call and
is not part of steady-state cost):

```
43c941: mov DWORD PTR [rdi+0xb4], eax   ; store tail  — pop_find_queue()'s own
                                         ; "this->find_tail++; find_tail &= MASK;"
                                         ; (cas_kht.hpp:494-495), committed every key
43c9b2: mov DWORD PTR [rdi+0xb0], ecx   ; store head  — add_to_find_queue()'s own
                                         ; "this->find_head++; find_head &= MASK;"
                                         ; (cas_kht.hpp:1176-1177), committed every key
43c9c3: mov eax, DWORD PTR [rdi+0xb4]   ; reload tail right after, before the next iteration
43ca1d/43ca23/43ca8e: same store-head/store-tail pattern on the "genuine reprobe,
                       no new key consumed this round" side of the branch
```
So the per-key cost is real, but it isn't a redundant re-check of the
fullness predicate — `get_find_queue_sz()` really is called only once. It's
that `pop_find_queue()` and `add_to_find_queue()` **each, by themselves,
commit their own cursor field to memory as a normal part of doing their job,
every single key**, because in source neither function ever receives
`find_head`/`find_tail` as a local — they always operate on `this->`.

## 3. Why the compiler couldn't hoist it in `no_inline`

This isn't "the fullness check runs every iteration" (it doesn't, in either
binary) — it's a direct, mechanical consequence of how the two code paths in
`cas_kht.hpp` are written and how GCC laid the inlined code out:

- **Fast/inlined path** (`cas_kht.hpp:570-693`, compiled into `bin/inline`):
  computes `fast_path` **once**, then hoists `this->find_tail`/`find_head`
  into local variables `tail`/`head` **before** entering the per-key loop,
  and writes them back **once** after the loop. Because `tail`/`head` are
  plain local `uint32_t`s (not `this->` member accesses) for the loop's
  entire duration, the compiler has no aliasing question to resolve inside
  the loop — the two cursors are pure register-resident scalars for the
  whole batch, and reprobing (the `goto retry` in source) operates purely on
  registers. There is exactly one straight-line copy of this loop body.

- **Non-inlined path** (`cas_kht.hpp:528-554`, `FAST_PATH`'s first arm,
  compiled into `bin/no_inline`): `get_find_queue_sz()` is checked once, as
  shown above — but `pop_find_queue()` (`cas_kht.hpp:480-498`) and
  `add_to_find_queue()` (`cas_kht.hpp:1148-1178`) are each written as
  self-contained functions that read-modify-write `this->find_tail` /
  `this->find_head` **as their own side effect**, with no local caching
  across keys. GCC fully inlines both (no `call` instructions, confirmed
  earlier) — but it also **cross-jump/tail-merges** the inlined body of
  `add_to_find_queue` into a single shared code chunk (`43c7e4`-`43c9c9`)
  that is reached via `jmp` from **three different points** in `find_batch`:
  the one-time priming preamble (`43c760 -> 43c7ea`), the "key found" case
  (`43c8d7 -> 43c7e4`), and the "empty slot, stop reprobing" case
  (`43ca94 -> 43c7e4`) — confirmed by grepping for jump targets landing on
  those two addresses. Because a single physical block now has multiple
  predecessors with different live-register assumptions, the compiler can't
  keep `find_head`/`find_tail` purely in registers across the merge point —
  it re-loads/stores them through memory at the boundary instead. This is a
  direct, visible cost of *not* having a single straight-line loop: sharing
  one copy of `add_to_find_queue`'s inlined code across multiple call sites
  (a code-size optimization) is exactly what forces the cursors back out to
  memory at those seams, something that can't happen to `bin/inline`'s
  single fast-path loop because it has no equivalent internal fan-in.

In other words: the "manual inlining" isn't just a code-shape trick — it's
an **algorithmic hoist that also happens to produce a single, unshared loop
body**. `bin/inline` amortizes the "is the retry queue full enough" decision
once per *batch*, and — because that decision produces exactly one
straight-line loop instead of a helper reused from multiple call sites —
keeps `find_head`/`find_tail` in registers (`edx`/`edi`) for the entire
batch. `bin/no_inline` checks fullness once too, but its steady-state loop
still round-trips both cursors through memory at least twice per key
(`43c941`, `43c9b2`, plus the `43c9c3` reload) because of the shared/merged
`add_to_find_queue` code path.

## 4. Why that matters for performance

Each `store` immediately followed by a dependent `load` of the same address
(e.g. `43c9b2` store-head then `43c9c3` reload-tail right after, at the
merged block's boundary) is a **store-to-load-forwarding** round trip:
several cycles of latency even when it hits the store buffer, and it also
creates a real (not just apparent) dependency between what should be
independent per-key iterations. With `HT_TESTS_BATCH_LENGTH` typically in
the 16–256 range (`include/constants.hpp:17,20`), `bin/no_inline` pays this
penalty at least twice **per key** (`O(batch_len)` total per `find_batch`
call), while `bin/inline` pays a fixed cost of 4 memory touches **per call,
regardless of batch size**. The win scales with batch size, and DRAMHiT is
specifically tuned to run with large batches to amortize prefetch latency,
so this is exactly the regime the workload in `instruction.txt` ("a large
amount of find and insertion occurs via find batch") lives in.

This also explains the earlier size numbers: `bin/inline`'s `find_batch` is
*smaller* (1037 B vs 1209 B) even though it's faster — the extra bytes in
`no_inline` are exactly these repeated load/store/mask sequences for
`find_head`/`find_tail`, not "more work being done"; they're pure overhead
from the code-sharing mechanism explained in section 7 below.

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
observed slowdown in the non-inlined binary. Section 7 explains *why* the
compiler ends up in this state rather than just hoisting the fields itself.

## 7. Why doesn't the compiler hoist `find_head`/`find_tail` itself?

The natural follow-up question: `pop_find_queue()` and `add_to_find_queue()`
are both fully inlined into `find_batch` in `bin/no_inline` (no `call`
instructions, confirmed in section 1) — so why does the compiler still
round-trip their fields through memory instead of just keeping them live in
registers across the whole loop, the same way it does for the manually
hoisted `bin/inline` version? This is *not* the same question as "why is
`get_find_queue_sz()` re-checked every iteration" (section 2's correction
already ruled that out) — it's a separate, deeper mechanism.

**It isn't a failure to prove aliasing safety. It's a deliberate code-size
transform called tail-merging (cross-jumping).** Grepping every jump
instruction in `bin/no_inline`'s `find_batch` for targets landing on the
address where `find_head` finally gets stored back to memory (`43c9b2`)
shows **three separate places** in the function jump into that exact same
block:

```
43c760 -> 43c7ea   (the one-time "queue not yet full" priming loop)
43c8d7 -> 43c7e4   (the "key was found" path)
43ca94 -> 43c7e4   (the "empty slot found, stop reprobing" path)
```

Those three call sites correspond to three **textually distinct** places in
`cas_kht.hpp` that all do the same conceptual thing — "push a new entry onto
`find_queue` and bump `find_head`":

1. `add_to_find_queue()` called from the `if` arm of `FAST_PATH`'s outer
   branch (`cas_kht.hpp:534-537`).
2. `add_to_find_queue()` called from the `else` arm of the same outer branch
   (`cas_kht.hpp:539-544`) — two *textually separate* call sites at the
   source level, even though only one runs per invocation.
3. The near-identical inline logic inside `__find_simd()`'s own reprobe path
   (`cas_kht.hpp:866-873`) — same "write key/key_id/idx into
   `find_queue[find_head]`, then `find_head++`" shape, just computing the
   new `idx` a different way (cacheline-stride vs. rehash).

GCC inlines all three call sites (confirmed — zero `call` instructions
anywhere in the function), but a later CFG-cleanup pass notices the three
inlined copies end in an identical-or-near-identical instruction sequence
and **collapses them into one physical copy**, redirecting all three sites
to jump into it. This is a pure code-size optimization: three copies of a
fairly large chunk (hash computation, prefetch, three field writes) become
one. This class of transform is generally called cross-jumping /
tail-merging (`-fcrossjumping`, part of `-O2`/`-O3`); I have not inspected
GCC's own pass dumps (`-fdump-tree-all`/`-fopt-info`) to confirm this is the
exact named pass responsible — that would require a build-level
investigation (see the experiment below) rather than binary-only analysis —
but the *effect* (one physical block, three provably-distinct predecessors)
is directly, unambiguously visible in the disassembly regardless of which
pass produced it.

**Why the merge forces a memory round-trip:** register allocation runs on
the *final* control-flow graph, after this merging has already happened.
Before the merge, each of the three call sites could have `find_head`/
`find_tail` sitting in whatever register was locally convenient. Once they
are forced to jump into one shared block with three predecessors, the
compiler needs a single, unambiguous way to communicate "what is the current
value of `find_head`" into that block that works no matter which of the
three predecessors was taken. The only thing all three predecessors agree on
unconditionally is the field's actual home location — `this->find_head` in
memory — so the compiler stores the register value to memory right before
jumping in, and reloads it right after if needed downstream. That is exactly
the `43c941`(store tail)→`43c9b2`(store head)→`43c9c3`(reload tail)
sequence documented in sections 2-3.

**Why `bin/inline` never hits this:** in the manually-hoisted source, the
"enqueue a new key" step is written **once**, as a single straight-line
statement inside one loop (`cas_kht.hpp:652-678`). There is no second or
third copy of that logic anywhere else in the function for a merge pass to
find — nothing to deduplicate, so no merge point, so no
predecessor-reconciliation problem. As a control, I checked whether
`bin/inline`'s fast path has any comparable multi-predecessor join points:
the only ones present (`43cb90` and `43cbc5`, each with 2 incoming jumps)
are a loop's completely ordinary entry+back-edge shape — every compiled loop
has that — not a fan-in of otherwise-distinct source-level operations like
`bin/no_inline`'s three call sites collapsing into one block.

**Why doesn't the compiler just do both (merge the code *and* keep the
registers consistent)?** In principle it could — the tail-merging pass and
the register allocator would need to cooperate: only merge two blocks if
every predecessor can also be arranged to place the live values in the same
registers beforehand. That is a much harder, higher-risk optimization than
either pass does in isolation, and GCC's pipeline runs them largely
independently: cross-jumping runs as a CFG-cleanup step focused purely on
code size, with no visibility into how much register-pressure/memory-
traffic cost its merge will impose on the code the register allocator
produces afterward. There is no feedback loop where the allocator can say
"undo that merge, keeping these two scalars live is worth more than the
code-size saving." This is a well-known general limitation in optimizing
compilers — size-reduction CFG transforms and register allocation are
separate phases with no shared cost model — not a bug specific to this
codebase.

**Open question, left for a build-level experiment rather than static
analysis:** recompiling the non-inlined source with `-fno-crossjumping` (or
inspecting `-fdump-tree-all`/`-fopt-info` output) would confirm whether this
specific GCC pass is responsible, and whether disabling it recovers the
register-hoisting behavior (at the cost of a larger `.text` size) without
requiring the manual source restructuring `bin/inline` uses. This has not
been tested here.
