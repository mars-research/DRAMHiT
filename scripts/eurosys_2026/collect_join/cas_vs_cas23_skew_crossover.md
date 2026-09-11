# Why cas23 overtakes cas at high skew (AMD EPYC 9354P, NPS4)

Investigation of the crossover visible in `amd_nps4/skew/` — cas leads cas23 by
1.32x at skew 0.1 and trails it by 0.87x at skew 1.2. Data: `amd_nps4/` (n4 =
64 threads over all 4 NUMA nodes, r = 1 GB, s = 15 GB, ht-fill 7, 16 GiB table).

## Answer in one paragraph

The crossover is **entirely in the probe phase**, and it is not cas losing —
cas barely changes across the sweep while cas23 improves by 1.86x. cas's probe
loop is engineered to hide DRAM latency (63-deep software prefetch queue, a
second prefetch 8 slots ahead, and a single AVX-512 compare that tests all 4
slots of a cacheline at once), so it is already latency-tolerant at low skew
and has almost no headroom left to gain when the working set becomes
cache-resident. cas23's loop consumes one 16-byte slot per demand load, and at
low skew **53.4% of its entire probe time sits on one instruction** — the `cmp`
that consumes that load. Skew shrinks the hot set until it fits in cache, that
one stall collapses to 17.0%, and cas23's lighter instruction path wins.
Reprobing, the obvious first hypothesis, is ruled out: both tables resolve
>99.2% of probes on the first cacheline access.

## 1. The crossover is in probe, and probe is 15/16 of the work

Per-point figures from `amd_nps4/skew/logs/{n4_cas,n4_cas23}/`:

| skew | build cas | build cas23 | probe cas | probe cas23 | probe ratio | total cas | total cas23 |
|---|---|---|---|---|---|---|---|
| 0.1 | 1229 | 1595 | 3686 | 2586 | 0.70 | 3277 | 2490 |
| 0.3 | 1051 | 1527 | 3780 | 2724 | 0.72 | 3252 | 2597 |
| 0.5 | 1242 | 1597 | 3185 | 2776 | 0.87 | 2901 | 2653 |
| 0.7 | 1242 | 1588 | 3791 | 3143 | 0.83 | 3360 | 2961 |
| 0.8 | 1237 | 1595 | 4100 | 3567 | 0.87 | 3582 | 3312 |
| **0.9** | 1228 | 1598 | 4166 | 4307 | **1.03** | 3624 | 3894 |
| 1.0 | 1260 | 1587 | 4306 | 4809 | 1.12 | 3741 | 4268 |
| 1.2 | 1247 | 1595 | 4315 | 4819 | 1.12 | 3740 | 4279 |

(mops; the cas build outlier at skew 0.3 is 1051, the other eleven points are
1228-1260.)

**Build is a red herring.** cas23 wins the build phase by a flat 1.28x at every
single skew point (130 vs 167 cyc/op) with no trend whatsoever. Nothing about
the crossover happens there.

**Probe crosses at 0.9**, exactly where the total crosses. Across the sweep
cas's probe improves 1.17x (56 -> 48 cyc/op) while cas23's improves 1.86x
(80 -> 43).

Because `s = 15r`, probe is 15/16 of all ops, so the total is essentially the
probe number. Weighting the two phases reproduces the reported
`cycle_per_tuple` to within 1 cycle:

| skew | cas23 build saves | cas23 probe costs | net | winner |
|---|---|---|---|---|
| 0.1 | -2.4 cyc/tuple | **+22.5** | +20.1 | cas (63 vs 83) |
| 0.9 | -2.4 | -0.9 | -3.4 | cas23 (57 vs 53) |
| 1.2 | -2.2 | -4.7 | -6.9 | cas23 (55 vs 48) |

cas23's 37 cyc/op build advantage is worth only ~2.4 cyc/tuple after the 1/16
weighting. It can never pay for a 24 cyc/op probe deficit, which costs 22.5.
**This benchmark is decided almost purely on probe.**

## 2. Reprobing is ruled out (CALC_STATS)

Built separately as `build_calc_stats/` with `-DCALC_STATS=ON` so the counters
do not perturb the timing build:

| | reprobes / 1.007 G finds | reprobe_factor |
|---|---|---|
| cas @ 0.1 | 28,457 | 1.0000 |
| cas23 @ 0.1 | 7,981,109 | 1.0079 |
| cas @ 1.0 | 4,388 | 1.0000 |
| cas23 @ 1.0 | 2,052,861 | 1.0020 |

cas23 reprobes ~280x more often than cas in relative terms, but 0.79% of
probes cannot explain a 43% throughput gap. At 6.25% table fill (67.1 M keys
in a 2^30-slot table) collisions are simply rare for both. **The difference is
cost per probe, not number of probes.**

## 3. The two probe loops are structurally different

Build flags select genuinely different code: `DRAMHiT_VARIANT=2025_INLINE`,
`BUCKETIZATION=ON`, `BRANCH=simd`, `PREFETCH=DOUBLE`, `UNIFORM_PROBING=ON`.

**cas** — `cas_kht.hpp:567` `find_batch`, the `DRAMHiT_2025_INLINED` branch:
- `_mm512_load_si512` pulls the whole 64 B cacheline; one
  `_mm512_mask_cmpeq_epu64_mask` with `KEYMSK = 0b01010101` tests **all 4 KV
  slots at once** (keys and values are interleaved, so the mask picks the 4 key
  lanes).
- Queue held at `find_queue_sz - 1` = **63** entries (`--find_queue 64`), so
  every prefetch has 63 keys of lead time.
- `DOUBLE_PREFETCH` issues a *second* `prefetcht0` for the queue entry
  `PREFETCH_FIND_NEXT_DISTANCE = 8` slots ahead.
- On a miss with no empty slot, `UNIFORM_HT_SUPPORT` re-hashes with
  `_mm_crc32_u64` to a fresh bucket rather than walking linearly.
- Fully inlined, no calls in the loop.

**cas23** — `cas23_kht.hpp:340` `__find_branched`:
- `curr->find(q, &retry, vp)` compares **one 16 B slot** (`kvtypes.hpp:187`).
- On retry, `idx++` then `if ((idx & KEYS_IN_CACHELINE_MASK) != 0) goto
  try_find;` — walks the rest of the same cacheline synchronously; only
  crossing a cacheline boundary triggers a prefetch and a requeue.
- `find_batch` drains only while queue depth `> FLUSH_THRESHOLD = 32` out of
  `PREFETCH_FIND_QUEUE_SIZE = 64`, i.e. roughly **half** cas's prefetch lead,
  and no double prefetch.

cas is built for memory-level parallelism; cas23 is the lighter-weight table.

## 4. perf counters: cas is already latency-tolerant, cas23 is not

`perf stat`, normal build, idle machine, 1.007 G probes:

| | cycles (G) | instr (G) | IPC | backend stalls/slot | DRAM fills/probe | far% | probe cyc/op |
|---|---|---|---|---|---|---|---|
| cas @ 0.1 | 119.3 | 94.4 | 0.79 | 0.542 | 0.951 | 20.9% | 55 |
| cas23 @ 0.1 | 148.2 | 102.3 | 0.69 | 0.606 | 1.662 | 52.8% | 79 |
| cas @ 1.0 | 111.5 | 94.3 | 0.85 | 0.511 | 0.733 | 25.9% | 49 |
| cas23 @ 1.0 | 104.0 | 101.3 | 0.97 | 0.431 | 0.968 | 36.7% | 38 |

Change from skew 0.1 to 1.0:

| | cycles | instructions | IPC | stalls/slot | DRAM fills/probe |
|---|---|---|---|---|---|
| cas | **-6.6%** | -0.1% | 0.79 -> 0.85 | 0.542 -> 0.511 | 0.951 -> 0.733 |
| cas23 | **-29.8%** | -1.0% | 0.69 -> **0.97** | 0.606 -> **0.431** | 1.662 -> 0.968 |

Three things to read off this:

1. **cas23 executes 7.6% MORE instructions than cas, and the same count at both
   skews.** Its entire 30% speedup is cycles-per-instruction — removed stalls,
   not less work. IPC 0.69 -> 0.97 is a 41% improvement; cas manages 8%.
2. **cas's backend-stall fraction is flat** (0.542 -> 0.511) while cas23's
   collapses (0.606 -> 0.431). cas was not the one stalling.
3. cas issues **fewer DRAM fills per probe than cas23 even at skew 0.1**
   (0.95 vs 1.66), and far fewer *remote* ones (20.9% vs 52.8% of fills). Its
   prefetches land lines in L2 ahead of use — `local_l2` fills are 2.45 G for
   cas vs 1.76 G for cas23.

## 5. Instruction-level: one `cmp` is 53% of cas23's probe

`perf record -F 299 -e cycles`, then `perf annotate` on `find_batch`.

`find_batch`'s share of total cycles:

| | skew 0.1 | skew 1.0 |
|---|---|---|
| cas | 27.79% | 23.36% |
| cas23 | **36.90%** | 22.04% |

Hottest instructions **inside** `cas23::find_batch`:

| instruction | skew 0.1 | skew 1.0 |
|---|---|---|
| `cmp %rsi,%r9` @ 446ded | **53.40%** | **16.98%** |
| `cmp 0x70(%rbx),%r9` | 2.71% | 6.52% |
| `crc32 %r11,%rax` | 2.79% | 5.06% |

That one instruction is the load consumer in `Item::find()`
(`kvtypes.hpp:187`):

```
mov (%r15),%rsi     ; load the hashtable slot's key
cmp %rsi,%r9        ; 53.40% of find_batch cycles at skew 0.1
```
```cpp
uint64_t found = !this->is_empty() && (this->kvpair.key == elem->key);
```

Zen 4 charges a load's stall to the consuming instruction, so this is cas23
waiting on the hashtable cacheline. **53.4% at skew 0.1, 17.0% at skew 1.0** —
the stall is the whole story, and cache residency is what removes it.

The same region of cas, by contrast, is flat with no dominant instruction:

| instruction | skew 0.1 | skew 1.0 |
|---|---|---|
| `add $0x10,%r15` (queue advance) | 12.58% | 14.05% |
| `and $..,%rsp` | 9.44% | 15.05% |
| `prefetcht0 (%r13,%r15,1)` | 8.39% | 6.81% |
| `kmovb %k0,%r14d` | 7.43% | 8.26% |
| `kortestb %k0,%k0` | 6.43% | 6.19% |
| `vmovdqa64 (%rsi),%zmm2` | 0.50% | - |
| `vpcmpequq %zmm1,%zmm2,%k0{%k1}` | 1.14% | - |

cas's entire load-consuming chain — the cacheline load, the 4-way SIMD
compare, and consuming the mask — costs about **8%**, against cas23's 53.4%.
Its single largest line item at low skew is the software `prefetcht0` itself
(8.39%), i.e. useful work rather than a stall. And the distribution barely
moves with skew, which is the same fact as cas's cycles dropping only 6.6%.

## 6. Data generation: the zipf keyrange is silently truncated to 15% of R

`init_hashjoin_dist()` (`hashjoin_test.cpp:140-250`) enforces a minimum
samples-per-key ratio (`hashjoin_test.cpp:215-227`):

```cpp
uint64_t keyrange_width = r_size;
constexpr uint64_t target_density = 100;
if ((s_size / keyrange_width) < target_density) {
    keyrange_width = s_size / target_density;
}
```

For the skew sweep `s_size / r_size = 15 < 100`, so

```
keyrange_width = 1006632960 / 100 = 10,066,329   (15.0% of r_size = 67,108,864)
```

`zipf_distribution_apache::sample()` returns a 1-based rank in
`[1, keyrange_width]`, and that rank is used **directly as an index into R**
(`g_zipf_values->at(zipf_v)`). Consequences:

- **Only 15% of R is ever probed.** The other 85% is inserted into the table
  and never looked up.
- `R[0]` is never probed either — off-by-one from the 1-based rank.
- The hottest keys are the *lowest R indices* (rank 1 -> `R[1]`), so they all
  live in shard 0's slice of the relation. Their key *values* are random, so
  they still hash to scattered buckets.

Verified empirically against the skew 1.0 dataset (200 M-probe sample of S):

```
distinct keys in S sample                       : 8,931,883
predicted keyrange_width                        : 10,066,329
distinct S keys found in R[1 .. keyrange]       : 8,931,883 / 8,931,883 (100.0000%)
distinct S keys found in R[0] or R[keyrange+1..]: 0
```

This is not a correctness bug — the join still returns 100% and the hit rate is
exactly 1.0 — but it changes what the sweep measures, and it is what makes the
crossover possible at all. With exact harmonic sums over
`n = 10,066,329`, the smallest key set carrying 90% of probes is:

| skew | keys carrying 90% of probes | cacheline footprint |
|---|---|---|
| 0.1 | 8,954,256 | 546 MB |
| 0.5 | 8,154,144 | 498 MB |
| 0.8 | 6,061,506 | 370 MB |
| **0.9** | 4,316,142 | **263 MB** |
| **1.0** | 1,894,593 | **116 MB** |
| 1.1 | 279,892 | 17 MB |
| 1.2 | 14,268 | 0.87 MB |

The working set crosses this part's 256 MB of aggregate L3 (8 CCDs x 32 MB)
between skew 0.9 and 1.0 — the same place cas23 overtakes cas. Treat the
numerical coincidence as suggestive rather than exact: each CCD's 32 MB L3 is
private, so a shared read-mostly working set gets replicated across CCDs and
the *effective* capacity is below 256 MB. The direction and rough magnitude are
what matter, and they are corroborated directly by the measured DRAM
fills/probe and stall fractions in section 4.

## 7. `verify_dataset.py` cannot see the truncation

Both sweep endpoints pass `scripts/verify_dataset.py`:

| dataset | R uniqueness | hit rate (expected 1.0) | fitted skew |
|---|---|---|---|
| skew 0.1 | Passed | 1.0000 | 0.1347 |
| skew 1.0 | Passed | 1.0000 | 1.0577 |

Both within the script's `HIT_RATE_DELTA = 0.02` and `SKEW_DELTA = 0.15`. So
the generator is correct on everything the script checks.

But the script is **structurally blind to the keyrange truncation**.
`estimate_zipf_skew()` fits `log(count)` against `log(rank)` over
`np.unique(data)` counts, and the fitted exponent is a property of the
rank-frequency *slope*, not of the support size. A 10 M-key support and a 67 M-key
support with the same exponent both pass identically.

Suggested addition to `check_hashjoin()` — cheap and would have caught this:

```python
support = len(np.unique(S))
print(f"S support:  {support:,} distinct keys ({100*support/r_size:.1f}% of R)")
if support < 0.9 * r_size:
    print(f"WARNING: S probes only {100*support/r_size:.1f}% of R "
          f"-- zipf keyrange was truncated (target_density in init_hashjoin_dist)")
```

## 8. Addendum: answers to two follow-up questions

Two questions came out of the first draft. The first now has a definitive
answer that **changes a conclusion above**; the second is partly answered and
partly still open, with five candidate explanations eliminated.

### 8a. Why does cas23 always win the build phase? It doesn't — cas is handicapped by a default build flag.

The build phase of *both* tables is dominated by one instruction: the branch
consuming `lock cmpxchg16b` is 58.8% of cas's `insert_batch` and 57.1% of
cas23's. So the question is not how many instructions each executes, it is
what coherence state the line is in when the CAS runs. It differs:

| | insert prefetch | line arrives | CAS pays |
|---|---|---|---|
| cas | `prefetch_insert()` -> `__builtin_prefetch(addr, **false**, 3)` = `prefetcht0` | Shared | S->E upgrade |
| cas23 | `prefetch()` -> `prefetch_object<**true**>` = `prefetchw` | Exclusive | nothing |

cas's read-only insert prefetch is not a bug so much as an unset option:
`CAS_PREFETCHW` defaults to `OFF` (`CMakeLists.txt:34`), and
`prefetch_insert()` carries a comment saying exactly what that costs. cas23 has
no such switch — it always prefetches for write, because
`PREFETCH_WITH_PREFETCH_INSTR` routes `prefetch()` through
`prefetch_object<true>`. cas's `DOUBLE_PREFETCH` in the insert loop is also
`false` (read).

Rebuilt with `-DCAS_PREFETCHW=ON`, everything else identical:

| build phase, cyc/op | baseline | CAS_PREFETCHW=ON |
|---|---|---|
| cas | 167 | **124** |
| cas23 | 130 | 130 (unchanged, as expected) |

**cas's build is 1.35x faster with the flag on, and it now beats cas23
(124 vs 130) rather than losing to it by 1.28x.** cas23 is unaffected because
it already prefetched for write. Probe is unchanged in both (57 / 50 cyc/op for
cas), which is the control this experiment needs: the flag touches only the
insert prefetch.

So section 1's "cas23 wins the build phase by a flat 1.28x" is an artifact of
the build configuration used for `amd_nps4/`, not a property of the
hashtables. Note this does **not** move the crossover, because the crossover
is a probe phenomenon and the fix is a build-phase fix:

| estimated total cyc/tuple | skew 0.1 | skew 1.0 |
|---|---|---|
| baseline: cas / cas23 | 62.9 / 83.1 (cas 1.32x) | 55.3 / 48.4 (cas23 1.14x) |
| CAS_PREFETCHW=ON: cas / cas23 | 61.2 / 85.0 (cas 1.39x) | 54.6 / 44.7 (cas23 1.22x) |

Every `amd_nps4/` number was collected with `CAS_PREFETCHW=OFF`, so all four
hash tables' build phases are understated there. **Worth re-collecting with the
flag on** — it is a one-word change to `cmake_flags` in `amd-9354p.json`.

### 8b. Why does cas23 win probe once the working set is cached? Partly answered.

The reading that prompted the question is correct: cas is the
distribution-resistant implementation. Its IPC is nearly skew-invariant
(0.79 -> 0.85), its backend-stall fraction is flat (0.542 -> 0.511) and its
cycles move only 6.6% across the whole sweep. That is exactly what a
well-pipelined, latency-tolerant loop looks like. Three separate questions hide
inside "why does cas23 win", and they have different answers:

**(i) Why does cas23 improve so much?** Settled — section 5. Its probe is one
dependent demand load per key, and at low skew 53.4% of its probe time sits on
the single `cmp` that consumes that load. Cache residency removes precisely
that stall (53.4% -> 17.0%), which is worth 80 -> 39 cyc/op.

**(ii) Why doesn't cas improve?** Settled — it has nothing to remove. It was
never latency-bound: its load-consuming chain costs ~8% of `find_batch` at
skew 0.1, and its largest single line item there is its own `prefetcht0`.

**(iii) Why does cas23 end up *ahead* rather than merely level?** **Answered in
section 9c: it is the AVX-512 probe idiom.** The text below is what was known
before that experiment and is kept for the record.
cas floors at ~48-50 cyc/op while cas23 reaches 38-41. cas executes ~6.5
*fewer* instructions per op overall (87.8 vs 94.3) yet needs more cycles, so
the residual is stall, not work. Five candidate causes were tested and **all
five are eliminated**:

| hypothesis | test | cas probe cyc/op @ skew 1.0 | verdict |
|---|---|---|---|
| prefetch queue too deep | `--find_queue` 8 / 16 / 32 / 64 | 68 / 51 / **49** / 51 | **refuted** — 32 vs 64 is ~4%, inside noise; and 8 is far worse |
| double prefetch is overhead | `-DPREFETCH=L1` (single) | 48 (vs 49) | **refuted** — no gain at high skew (but worth 26 cyc/op at skew 0.1) |
| AVX-512 bucket scan is the cost | `-DBRANCH=branched` (scalar) | 50 (vs 49) | ~~refuted~~ **INVALID TEST — see section 9c.** `BRANCH` does not gate the `DRAMHiT_2025_INLINED` probe path: `build_branched/dramhit` contains the same 12 vector ops in `find_batch` as the default build (`objdump` count). The experiment removed nothing. Section 9c tests the hypothesis properly and **confirms** it. |
| read-vs-write prefetch | `-DCAS_PREFETCHW=ON` | 50 (vs 49) | **refuted** for probe (it is the *build* answer, 8a) |
| SMT contention (64 threads / 32 cores) | `de_no_dispatch_per_slot.smt_contention` | 0.116 vs cas23's 0.124 of dispatch slots | **refuted** — nearly identical |

Top-down slots at skew 1.0 (Zen 4, 6 dispatch slots/cycle) put the residual in
the backend, not the frontend:

| | backend stalls | no ops from frontend | SMT contention | retiring |
|---|---|---|---|---|
| cas | **0.537** | 0.218 | 0.116 | 0.129 |
| cas23 | **0.496** | 0.251 | 0.124 | 0.129 |

cas23 actually stalls *more* in the frontend (more instructions, larger code
footprint) and still wins, because cas stalls more in the backend. But this
measurement cannot close the question: `perf stat` spans the whole process, and
the run used `build/` with `CAS_PREFETCHW=OFF`, so cas's much slower build
phase inflates its backend-stall share. **Settling (iii) needs phase-scoped
counters** — wrapping the timed probe region in `perf_event_open` /
`ioctl(PERF_EVENT_IOC_ENABLE)` so build, dataset load and probe are counted
separately. That is the right next step and is not something the binary
currently supports.

What can be said without that: in the cache-resident limit cas23's inner loop
retires one 8-byte load plus one compare per probe, while cas's retires a
64-byte load, a masked compare, mask extraction, a bit scan, a crc32, two
prefetches and a queue push/pop — and the queue round trip is the one part of
that list not eliminated by any experiment above, because `--find_queue` only
changes its *depth*, never removes it. A cas variant that bypasses the queue
entirely when the bucket is already in L1 would test it, but that is a code
change rather than a flag.

## 9. Second addendum: three follow-ups

### 9a. `CAS_PREFETCHW=ON` is now the spec default; cas skew re-collected

`amd-9354p.json` now carries `-DCAS_PREFETCHW=ON` (with a `_cmake_flags` note
saying why it must stay). `n4_cas`/`skew` was re-collected; the previous
collection is archived under `amd_nps4_pre_prefetchw/` so sections 1-7 stay
reproducible. It is held *outside* `amd_nps4/` deliberately, because
`plot_data.py` discovers sets by rglob and two `n4_cas` skew sets in one tree
would collide.

| skew | build OFF | build ON | delta | probe OFF | probe ON | total OFF | total ON |
|---|---|---|---|---|---|---|---|
| 0.1 | 169 | 122 | -47 | 56 | 55 | 3277 | 3471 |
| 0.5 | 167 | 125 | -42 | 65 | 54 | 2901 | 3532 |
| 1.0 | 165 | 124 | -41 | 48 | 49 | 3741 | 3821 |
| 1.2 | 166 | 123 | -43 | 48 | 50 | 3740 | 3760 |
| **mean** | **169.7** | **123.4** | **-46** | - | - | 3401 | 3592 |

Build is 1.37x faster at every point; probe is unchanged, which is the control
this experiment needs. The crossover does not move (skew 0.9: cas 3659 vs
cas23 3894) — a build-phase fix cannot move a probe-phase crossover.

One noise point: skew 1.1 probe reads 60 cyc/op against 47/48/50 at its
neighbours, dragging that total to 3208 (0.85x). Treat it as an outlier.

**The other four hash tables in `amd_nps4/` are still `CAS_PREFETCHW=OFF`** and
their build phases are understated by roughly this much. cas23 is genuinely
unaffected (130 cyc/op either way), but cas23 is not the only other table.

### 9b. Testing the truncation theory: it does *not* remove the crossover, and the low-skew dataset fails verification

`init_hashjoin_dist()` gained an experiment-only hook: `HASHJOIN_TARGET_DENSITY`
in the environment overrides `target_density`, and *only when it is set* the
cache filename gains a `_kr<keyrange>` suffix so a truncated and an untruncated
dataset for the same r/s/skew/seed cannot alias. Unset, behaviour and filenames
are bit-identical to before, so the existing ~96 GB dataset cache stays valid.
`HASHJOIN_TARGET_DENSITY=1` gives `keyrange_width = r_size` (no truncation).

`verify_dataset.py` was extended to accept the optional `_kr` suffix and to
report **S support** and **samples per key** — the two things that reveal a
truncated keyrange, which the skew fit cannot see.

**Distribution check first, because it decides whether the timings mean
anything:**

| dataset | S support | samples/key | fitted skew | verdict |
|---|---|---|---|---|
| skew 0.1, truncated (kr 10.07 M) | 8.9 M (13%) | ~100 | 0.1347 | pass |
| skew 0.1, untruncated (kr 67.1 M) | 67,108,830 (100%) | 15 | **0.2504** | **FAILS** (deviates 0.150 > `SKEW_DELTA` 0.15) |
| skew 1.0, truncated | ~10 M | ~100 | 1.0577 | pass |
| skew 1.0, untruncated | 53,762,615 (80%) | 18.7 | 1.0391 | pass |

So `target_density = 100` is buying something real at low skew. With only 15
samples per distinct key a near-uniform draw cannot be recovered: most keys
appear 0, 1 or 2 times, and sorting those counts by rank manufactures a decay
slope, biasing the fitted exponent up to 0.25 for a nominal 0.1. **The
untruncated skew-0.1 dataset is not a valid skew-0.1 dataset**, so the
low-skew row below is confounded and must not be read as a like-for-like
comparison. The skew-1.0 dataset is clean (1.0391, and its 80% support is the
unsampled zipf tail, not a truncation).

> **Corrected.** The first version of this section reported cas at probe 59 /
> total 3283 (skew 1.0) and probe 81 (skew 0.1), and concluded cas23's lead
> *widened* to 1.28x. Those cas runs were contaminated: cas **generated** both
> untruncated datasets while cas23 loaded them from cache, so cas paid the
> dataset-writeback penalty documented in the methodology note. `run_join.py`
> re-measures for exactly this; the hand-written experiment script did not.
> The table below is cache-warm (`gen=0` verified), two repeats each.

| | skew 0.1 | skew 1.0 |
|---|---|---|
| truncated (kr 10.07 M) | cas 3471 / cas23 2490 -> cas **1.39x** | cas 3821 / cas23 4268 -> cas23 **1.12x** |
| untruncated (kr 67.1 M) | cas ~2453 / cas23 ~2386 -> **tie, 1.03x** *(dataset invalid, see above)* | cas ~3729 / cas23 ~4338 -> cas23 **1.16x** |

probe cyc/op, cache-warm:

| | cas | cas23 |
|---|---|---|
| skew 0.1: truncated -> untruncated | 55 -> **82** | 82 -> 84 |
| skew 1.0: truncated -> untruncated | 49 -> 51 | 39-43 -> ~42 |

**Open question 2 predicted that untruncating would push the crossover past 1.2
or remove it. That prediction is wrong**, but not in the way the first draft
said. At skew 1.0 the ratio barely moves (1.12x -> 1.16x, and cas23's two
repeats there were 4633 and 4043, 14% apart, so treat that as unchanged). What
actually happens is at the *low* end: **cas collapses to cas23's level**
(probe 55 -> 82) and the 1.39x lead becomes a tie.

The striking asymmetry is that **cas23's probe is nearly invariant to the
keyrange** — 82 -> 84 cyc/op at skew 0.1 for a 6.7x larger support, ~41 -> ~42
at skew 1.0 — while cas's degrades. Section 10 investigates that.

Build phases are untouched (cas 122-125, cas23 129-130), as expected for a
probe-distribution change, and every run still joins 100.00%.

### 9c. Why cas23 wins on cache-resident data: it *is* the AVX-512 idiom — but not for the obvious reason

Section 8b's claim that AVX-512 was refuted **was wrong**: `BRANCH=branched`
does not gate the inlined probe path, so that build still executed the same
vector code (verified by `objdump`: 12 vector ops in `find_batch` in both
builds). The hypothesis was never tested.

Testing it inside DRAMHiT needs a scalar `find_batch`, which does not exist, so
it was tested in isolation instead — `probe_idiom.c` (in the scratchpad;
worth committing to `scripts/` if this is pursued). It reproduces the two
idioms exactly as compiled in DRAMHiT and probes a 64 B-bucket array of
controlled footprint:

- `scalar1` — 8 B load + `cmp`. cas23's idiom (its hash points at one slot).
- `scalar4` — up to 4x (8 B load + `cmp`). A 4-way search *without* vectors,
  to separate "vector cost" from "searching 4 slots".
- `simd4` — `vpbroadcastq` / `vmovdqa64` / `vpcmpequq` / `kortestb` / `kmovb`.
  Byte-for-byte cas's inner loop.

`simd4 / scalar1`, cycles per probe:

| footprint | 1 thread | 32 threads (1/core, no SMT) | 64 threads (SMT, as the join runs) |
|---|---|---|---|
| 16 KB (L1) | **1.00x** | 1.04x | **1.24x** |
| 512 KB (L2) | **1.02x** | 1.15x | **1.29x** |
| 16 MB (L3) | 1.23x | 1.37x | 1.28x |
| 1 GB (DRAM) | 1.64x | 1.54x | 1.38x |

**"Vector instructions are just slower than a scalar load when the target is
cached" is not true as stated.** Single-threaded on L1-resident data the two
idioms are indistinguishable (23.85 vs 23.78 cyc/probe). Two separate effects
produce the penalty:

1. **A 512-bit load must wait for the entire cacheline; a scalar load needs
   only the critical word.** Present even single-threaded, and it scales with
   distance: 1.00x (L1) -> 1.02x (L2) -> 1.23x (L3) -> 1.64x (DRAM).
   `scalar1` can retire as soon as its 8 requested bytes arrive under
   critical-word-first delivery; `vmovdqa64` cannot.
2. **Under SMT the double-pumped 512-bit op contends for the shared 256-bit
   datapath.** This is what creates a penalty for *cache-resident* data, where
   effect 1 contributes nothing: L1 goes 1.00x (1 thread) -> 1.04x (32 threads,
   one per core) -> 1.24x (64 threads). Same shape at L2.

**This accounts for the residual gap quantitatively.** The join at skew 1.0 has
a ~116 MB 90%-mass working set (L3/DRAM boundary) and runs 64 threads — the
regime where the microbenchmark measures a 1.28-1.38x vector penalty. The
observed cas/cas23 probe ratio is 49/41 ~ 1.20x. The idiom explains all of it.

Two corollaries: `scalar1` and `scalar4` are within noise at every footprint,
so cas's 4-way bucket *search* is essentially free — it is the vector
*implementation* of that search that costs; and `simd4/scalar4` (1.24-1.35x) is
as large as `simd4/scalar1`, confirming the cost is the vector ops rather than
the associativity.

**Actionable:** a scalar or 256-bit (`_mm256`, not double-pumped on Zen 4)
variant of the `DRAMHiT_2025_INLINED` `find_batch` looks likely to recover
cas's high-skew deficit outright, while keeping the deep prefetch queue that
wins it the low-skew case. That is the highest-value code change suggested by
this whole investigation.

## 10. Finding 2: why cas23 still wins at skew 1.0 with no truncation

> **Margins superseded by section 13b.** The ratios in this section come from
> 1-2 repetitions and predate the `constexpr` queue fix. Post-fix, with 10
> interleaved repeats, cas trails cas23 by ~1.10x at skew 1.0, not 1.16-1.20x.
> The qualitative findings (active-line sizes, equal DRAM traffic, no bandwidth
> saturation, equal hotspots) are unaffected.

Section 9b left a puzzle. The explanation in sections 4-5 leaned on the probe
working set becoming *cache-resident* at high skew. But with the truncation
removed the skew-1.0 active set is far larger than L3, and cas23 still wins.
This section measures that case directly. Everything here uses the
`CAS_PREFETCHW=ON` build, `HASHJOIN_TARGET_DENSITY=1`, cache-warm datasets, and
the verified-clean skew-1.0 distribution (fitted exponent 1.0391).

### 10a. Size of the active lines

Exact partial sums of the zipf mass, converted to the cachelines those keys
occupy (each key lands in its own 64 B line: 67 M keys scattered over a 2^30-slot
16 GiB table):

| probe mass | truncated (n = 10,066,329) | untruncated (n = 67,108,864) |
|---|---|---|
| top-1 key | 5.99% of probes | 5.38% of probes |
| 50% | 2,377 keys -> **0.1 MB** | 6,138 keys -> **0.4 MB** |
| 75% | 154,697 keys -> 9.4 MB | 641,822 keys -> 39.2 MB |
| 90% | 1,894,593 keys -> 115.6 MB *(fits L3)* | 10,448,014 keys -> **637.7 MB (2.5x L3)** |
| 99% | 8,517,960 keys -> 519.9 MB | 55,719,252 keys -> 3400.8 MB |

**The distribution is bimodal in residency terms, and that is the resolution.**
Untruncating multiplies the *tail* by ~5.5x but leaves the *hot core* nearly
unchanged: 50% of all probes still land in well under 1 MB, comfortably inside
a 1 MB L2, and 75% inside 39 MB. So "the working set is cache-resident" was
never the right description even for the truncated case — what is true at skew
1.0, truncated or not, is that **a large fraction of probes hit a very small
hot core** while the remainder streams from DRAM. L3 residency of the 90%
figure was a coincidence of the truncated configuration, not the mechanism.

This matters because the vector penalty measured in
`../compare_simd_vs_load/` is, at 64 threads, **roughly independent of
residency** — 1.26x (L1), 1.29x (L2), 1.27x (L3), 1.38x (DRAM). A penalty that
applies everywhere does not need the working set to fit anywhere.

### 10b. Counters, untruncated skew 1.0

| | cas | cas23 |
|---|---|---|
| probe cyc/op | 47-51 | 43-46 |
| total mops | 3773-3868 | 4043-4633 |
| cycles | 133.1 G | 136.4 G |
| instructions | 94.4 G | **101.7 G** (+7.7%) |
| IPC | 0.71 | **0.75** |
| backend stalls / slot | **0.531** | 0.494 |
| smt_contention / slot | 0.120 | 0.111 |
| frontend / slot | 0.219 | **0.269** |
| retiring / slot | 0.130 | 0.126 |

Same shape as the truncated case in section 8b: cas23 executes ~8% *more*
instructions, stalls more in the frontend, and still wins, because cas stalls
more in the backend. IPC is lower for both than truncated (0.85 / 0.97),
consistent with the bigger tail.

### 10c. Hotspots are identical

`perf record -F 299 -e cycles`, share of total cycles:

| symbol | cas | cas23 |
|---|---|---|
| `Application::shard_thread` | 34.67% | 35.82% |
| `*HashTable::find_batch` | **21.36%** | **21.01%** |
| kernel `0xffffffff821d9c27` | 18.24% | 17.25% |
| `*HashTable::insert_batch` | 4.94% | 5.67% |

`find_batch` takes the same share in both. There is no hotspot asymmetry to
find here — the difference is in what a cycle *inside* that function buys, not
in where the cycles go. (Contrast the truncated skew-0.1 case in section 5,
where cas23's `find_batch` was 36.9% against cas's 27.8%.)

### 10d. Three more explanations eliminated

**Not DRAM traffic volume.** All 12 UMC channels, whole run
(`amd_umc_*/umc_cas_cmd.rd|wr/`):

| | read beats | write beats |
|---|---|---|
| cas, skew 1.0 | 2,280,980,021 | 1,437,490,204 |
| cas23, skew 1.0 | 2,272,251,164 | 1,436,476,646 |
| cas, skew 0.1 | 2,956,114,695 | 1,438,427,760 |
| cas23, skew 0.1 | 2,955,437,959 | 1,438,675,742 |

The two tables move the **same** DRAM traffic to within 0.4%. Whatever
separates them, it is not how many bytes cross the memory bus.

**Not bandwidth saturation.** Per-100 ms interval, all channels:

| run | peak interval | % of 461 GB/s peak |
|---|---|---|
| cas, skew 0.1 | 262 GB/s | 57% |
| cas, skew 1.0 | 230 GB/s | 50% |
| cas23, skew 0.1 | 225 GB/s | 49% |
| cas23, skew 1.0 | 207 GB/s | 45% |

The join never gets past ~57% of theoretical peak (~65% of a realistic 75-85%
achievable ceiling). I had hypothesised that the large untruncated working set
saturates DRAM and thereby erases cas's prefetch-pipeline advantage. **That is
refuted.** 100 ms intervals do straddle phase boundaries, so the true in-probe
peak is somewhat higher than these figures, but not by the 2x that saturation
would require.

**Not identical prefetching.** A real code difference turned up while chasing
the fill counters. `__builtin_prefetch` maps hint 3 -> `prefetcht0` (L1),
hint 1 -> `prefetcht2` (L2/L3):

| | far prefetch (at enqueue) | near prefetch |
|---|---|---|
| cas | `prefetch_read` hint **1** -> `prefetcht2`, 63 slots ahead | `__builtin_prefetch(next_tail_addr, false, 3)` -> `prefetcht0`, 8 slots ahead |
| cas23 | `prefetch_read` -> `prefetch_object<false>` = hint **3** -> `prefetcht0`, 32 slots ahead | none |

cas runs a deliberate **two-level** scheme: park the line in L2/L3 long before
it is needed, then pull it into L1 shortly before use. cas23 issues a single
L1 prefetch. This shows up in the core-side fill counters — cas takes
1,005,462,131 fills from L2 against cas23's 507,682,320 (2.0x), and cas23 takes
correspondingly more from L3 (547,826,250 vs 305,413,155). cas's far prefetch
does what it was designed to do. It is a point in cas's favour, and therefore
not an explanation for cas losing.

### 10e. Conclusion

At skew 1.0 with no truncation the two tables move the same DRAM traffic, at
half of peak bandwidth, with the same hotspot distribution, and cas23 wins by
~1.16x on total and ~1.20x on probe while executing 8% more instructions. Every
memory-side explanation is eliminated: not traffic volume, not bandwidth, not
prefetch quality (cas's is strictly better), not cache residency of the 90%
working set (it is 2.5x beyond L3 and cas23 wins anyway).

What remains is the per-probe execution cost of the two idioms.
`../compare_simd_vs_load/` measures the AVX-512 bucket scan at **1.26-1.38x**
the cost of a scalar load+compare at 64 threads across *every* footprint from
L1 to DRAM, driven by SMT contention for the shared 256-bit vector datapath
(0.427 of dispatch slots vs 0.240 for scalar on L1-resident data) plus the
full-cacheline wait on a 512-bit load. The observed probe ratio here is
51/42.5 ~ 1.20x, inside that range.

> **Corrected by section 11.** This section originally concluded the vector
> idiom "accounts for the whole gap". A direct test — building cas with a
> genuinely scalar probe path — shows it accounts for only about half, and that
> a scalar cas still loses to cas23 at skew 1.0. Read section 11 before relying
> on this paragraph.

So the corrected story for the whole document is:

- cas and cas23 differ in **two** ways that matter: cas has a deeper,
  two-level prefetch pipeline (63 slots, L2/L3 then L1), and cas pays a
  ~1.3x SMT vector-datapath penalty on every probe.
- The pipeline advantage only pays when there is memory latency left to hide.
  Skew shrinks the hot core until most probes are cache hits, at which point
  the advantage tends to zero and the constant vector penalty decides the
  result. That is the crossover, and it does not require the *whole* working
  set to fit in any particular cache — only the hot core, which is under 1 MB
  at skew 1.0 either way.
- Removing the truncation enlarges the DRAM tail without touching the hot core,
  which is why it costs cas its low-skew lead (more tail to hide, and cas's
  advantage there is what it was winning on) while leaving the high-skew result
  essentially unchanged.

The open item is no longer "why does cas23 win" but "why does cas's
pipeline advantage collapse on the larger tail at skew 0.1" (probe 55 -> 82
cyc/op while cas23 goes 82 -> 84). Bandwidth saturation is refuted; the
remaining candidates are miss-queue/MAB occupancy limits per core and L2
capacity for the far-prefetched lines, neither of which these counters resolve.

## 11. Direct test: a scalar cas, and uniform probing off

Section 10e attributed the high-skew gap to the AVX-512 idiom. Two builds were
made to test that head-on, plus a third to test a separate hypothesis. All
codegen and flags were verified rather than assumed this time -- the failed
`BRANCH=branched` test in section 8b is why.

`DRAMHiT_VARIANT=2025` (not `2025_INLINE`) routes `find_batch` through
`pop_find_queue` -> `__find_one`, which dispatches on `CAS_SIMD`; with
`BRANCH=branched` that lands in a scalar `__find_branched` structurally
near-identical to cas23's. Verified by counting vector ops in the CAS find
path:

| build | vector ops in CAS find path |
|---|---|
| `2025_INLINE` + simd (the baseline `build/`) | 14 |
| `2025` + simd | 12 |
| `2025` + **branched** | **0** |

`2025+simd` is included as the control: it shares the non-inlined structure
with the branched build, so the pair isolates the idiom rather than confounding
it with the loss of the unrolled loop.

### Results (probe cyc/op, stock truncated datasets, cache-warm, medians)

| configuration | skew 0.1 | skew 1.0 |
|---|---|---|
| cas `2025_INLINE`+simd, uniform ON *(baseline)* | 55-57 | **48** |
| cas `2025_INLINE`+simd, uniform **OFF** | 55 | 51 |
| cas `2025`+simd, uniform ON | ~70 | ~66 |
| cas `2025`+**branched**, uniform ON | ~71 | **60** |
| cas `2025`+**branched**, uniform **OFF** | 73 | 61 |
| **cas23** | 80-81 | **40** |

### What this settles

**1. The vector idiom is real but explains about half the gap, not all of it.**
Within the identical non-inlined structure, removing SIMD buys 66 -> 60 cyc/op
at skew 1.0 (~10%) and nothing at skew 0.1 (70 -> 71). The *shape* is exactly
what the cached-hot-core story predicts -- the penalty appears only where
memory latency is not the limiter. But the magnitude is ~10%, well below the
1.26-1.38x that `../compare_simd_vs_load/` measures in isolation, and
**a fully scalar cas still loses to cas23 at skew 1.0 by 1.45x** (60 vs 40).

**2. Losing the inlined loop costs more than SIMD does.** `2025_INLINE`+simd is
48 cyc/op; `2025`+simd is ~66. That ~18 cyc/op structural penalty dwarfs
SIMD's ~6, which is why the scalar-but-non-inlined build (60) is *worse* than
the vector-but-inlined baseline (48). **The decisive configuration -- inlined
*and* scalar -- does not exist**: `DRAMHiT_2025_INLINED`'s `find_batch` uses
`_mm512` unconditionally with no `BRANCH` guard. Writing one is the only way to
finish this argument. Projecting the ~6 cyc/op saving onto the inlined path
would put cas near 42, i.e. level with cas23, but that is arithmetic across two
code structures, not a measurement.

**3. Uniform probing is not the cause.** `UNIFORM_HT_SUPPORT` appears at 11
sites in `cas_kht.hpp` and **zero** in `cas23_kht.hpp`, so it is a cas-only
cost, and in the probe fast path it adds a store per probe
(`find_queue[head].key_hash = hash`) plus a `crc32` rehash on reprobe. Turning
it off changes nothing at skew 0.1 (55 -> 55) and is marginally worse at skew
1.0 (48 -> 51, inside noise). The store is free: it targets an L1-resident
queue entry, and stores do not block retirement. Note CMake defaults this
option **OFF** while every collection here has run it **ON**; it appears to be
performance-neutral either way on this workload.

**4. Reprobing is still irrelevant, now confirmed three ways.**

| | skew 0.1 | skew 1.0 |
|---|---|---|
| cas `2025_INLINE`+simd, uniform ON | 24,238 | 4,453 |
| cas `2025_INLINE`+simd, uniform OFF | 22,512 | 4,743 |
| cas `2025`+branched | 19,724 | 5,440 |
| **cas23** | **8,088,908** | **2,073,337** |

Uniform probing barely moves cas's reprobe count -- at 6.25% fill, collisions
are rare whether you rehash or step to the next cacheline. And cas23 reprobes
~400x more often, touching 0.8% more cachelines, **while winning**. Any
explanation that runs through probe-sequence quality is dead.

### What is still unexplained

After this round the eliminated list is:

| hypothesis | verdict |
|---|---|
| reprobe count / probe-sequence quality | refuted (3 builds, 400x difference the wrong way) |
| prefetch queue depth | refuted (`--find_queue` 8/16/32/64: 68/51/49/51) |
| double vs single prefetch | refuted (`PREFETCH=L1`: 48 vs 49) |
| read- vs write-prefetch on insert | it is the **build**-phase answer (section 8a), not probe |
| SMT contention as a whole-workload effect | refuted (0.120 vs 0.111 of slots) |
| DRAM traffic volume | refuted (UMC beats equal to 0.4%) |
| DRAM bandwidth saturation | refuted (45-57% of peak) |
| prefetch quality / locality hints | refuted -- cas's two-level scheme is *better* |
| cache residency of the 90% working set | refuted (2.5x beyond L3 and cas23 still wins) |
| hotspot distribution | refuted (`find_batch` 21.4% vs 21.0%) |
| uniform probing | refuted (this section) |
| AVX-512 bucket scan | **partial** -- ~10% of a ~20% gap, and ~1.3x in isolation |

The largest remaining structural difference is the **drain pattern**. cas23's
`find_batch` calls `flush_if_needed` before and after enqueuing a whole batch,
draining in **bursts** while the queue exceeds `FLUSH_THRESHOLD = 32`; cas's
2025 path pops exactly one entry per key pushed, and the inlined path does the
same 1:1 interleave. A burst of ~32 independent finds back-to-back, with no
enqueue bookkeeping interleaved, offers materially more instruction-level
parallelism than a 1:1 alternation. Testing it needs a code change, not a flag
-- as does the inlined-scalar build that would close point 2.

Run-to-run variance was worse in this round than elsewhere in the document:
cas23 at skew 1.0 gave 40 / 34 / 43 cyc/op and cas 48 / 46 / 60 across three
repeats. Medians are quoted; single points here are not reliable to better
than ~10%.

## 12. Matched-configuration test: reprobes converge, and the "bug" is a reload

The prediction: build cas as `DRAMHiT_2023` + `BRANCH=branched` +
`UNIFORM_PROBING=OFF` and it should reprobe almost identically to cas23; if not,
something is wrong. **Confirmed, once one more flag is included.**

### 12a. BUCKETIZATION is the entire reprobe difference

`add_to_find_queue` aligns the start index down to a cacheline boundary only
under `BUCKETIZATION`:

```cpp
size_t idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);   // align to bucket start
#endif
```

cas23 has no such alignment. So bucketized cas starts its within-line walk at
slot 0 and covers all four slots; a requeue needs all four occupied *without*
the key, P ~ 0.0625^4 ~ 1.5e-5, i.e. ~15 K of 1.007 G probes. cas23 starts
wherever the hash lands with ~2.5 slots left on average, and requeues whenever
a key was displaced past the line end. Every earlier build passed
`-DBUCKETIZATION=ON`.

With it off (all other flags matched), reprobes converge:

| skew | cas 2023+branched, **no** bucket | cas23 | ratio | cas 2023+branched, bucket ON |
|---|---|---|---|---|
| 0.1 | 7,723,094 (factor 1.0077) | 8,090,590 (factor 1.0080) | 0.955 | 21,751 (1.0000) |
| 1.0 | 1,979,959 (factor 1.0020) | 2,081,009 (factor 1.0021) | 0.951 | 6,099 (1.0000) |

Within 5%, with reprobe factors agreeing to four decimals. **No bug** -- the
400x gap seen throughout sections 2/8b/11 was this one flag. The residual ~5%
is presumably a slightly different insert-time displacement pattern.

Note what this costs cas: bucketization buys it 400x fewer reprobes, a real
advantage that is simply worth nothing at 6.25% fill, where 0.8% extra
cacheline touches are free.

### 12b. The matched build is slower -- because it reloads loop invariants

Fully matched (`2023` + `branched` + `UNIFORM=OFF` + `BUCKETIZATION=OFF` +
`PREFETCH=L1` so cas's single `prefetcht0` matches cas23's, +
`CAS_PREFETCHW=ON` so both insert with `prefetchw`; 0 vector ops verified by
`objdump`), cas is *still* slower, with low variance:

| | cas matched | cas23 |
|---|---|---|
| probe cyc/op, skew 0.1 | 99 / 99 / 100 / 101 | 80 / 81 / 82 / 82 |
| probe cyc/op, skew 1.0 | 62 / 63 / 64 / 65 | 40 / 40 / 40 / 43 |
| build cyc/op, skew 1.0 | 145 | 132 |
| instructions | 97.2 G | **101.6 G** |
| cycles | **138.4 G** | 131.5 G |
| IPC | 0.70 | **0.77** |
| backend stalls / slot | **0.515** | 0.489 |
| `find_batch` share | 22.65% | 19.12% |

cas executes *fewer* instructions and needs *more* cycles. `perf annotate` with
source attribution localises it:

| cas instruction | % of find_batch | source |
|---|---|---|
| `mov %r11d,(%rdx)` | 11.89 | `return (find_head - find_tail) & FIND_QUEUE_SZ_MASK` |
| `test %rsi,%rsi` | 11.07 | `found = !is_empty() && (kvpair.key == elem->key)` -- the real load consumer |
| `crc32 %r9,%r10` | 10.32 | the hash |
| `mov 0xb4(%rdi),%ecx` | 4.87 | **loading `FIND_QUEUE_SZ_MASK` from memory** |
| `and %r14d,%eax` | 4.45 | masking with a *register* |
| `cmp 0x90(%rbx),%r10` | 3.12 | **loading `this->empty_item` from memory** |

cas23's equivalent list is led by `cmp %r10,%r11` (19.45%, register-register,
the load consumer) and includes `and $0x3f,%eax` -- an **immediate**.

**cas's drain loop reloads loop-invariant state from memory on every
iteration.** Its queue geometry is a set of member variables
(`FIND_QUEUE_SZ_MASK` at offset 0xb4, `find_queue_sz`, `HT_BUCKET_MASK`)
because `--find_queue` makes it runtime-configurable; cas23's is `constexpr`
(`PREFETCH_FIND_QUEUE_SIZE = 64`, `FLUSH_THRESHOLD = 32`) and folds to
immediates. Counting memory-operand instructions inside `find_batch`:

| build | memory-operand ops | `and $0x3f` immediates |
|---|---|---|
| cas `2023` matched | **34** | 0 |
| cas23 | 9 | 7 |
| cas `2025_INLINE` | 9 | 0 |

3.8x more. And this **explains the ~18 cyc/op "inlining penalty" of section
11**: `DRAMHiT_2025_INLINED` hoists `find_head`/`find_tail` into locals
(`uint32_t tail = this->find_tail; ... this->find_tail = tail;`) around the
whole batch, reaching the same 9 memory-operand ops by hoisting rather than by
`constexpr`. That is not an inlining effect at all -- it is register promotion
of the queue cursors.

### 12c. Consequence for the whole document

**The matched 2023 build is not a fair stand-in for cas.** It is cas's slowest
path, carrying a per-iteration reload penalty that neither cas23 nor cas's
production `2025_INLINE` path pays. Its 1.55x deficit at skew 1.0 is mostly
that penalty, not the idiom, so section 11's "a scalar cas still loses by
1.45x" should be read as "cas's *non-register-promoted* scalar path loses by
1.45x" -- a statement about the 2023 code path, not about scalar-vs-vector.

The defensible comparison stays the one between each table's best path:
cas `2025_INLINE`+simd at 48 cyc/op against cas23 at 40-42, i.e. **1.15-1.20x**,
of which the vector idiom is worth ~10% by the section 11 A/B and ~1.3x in
isolation (`../compare_simd_vs_load/`).

Two clean code changes follow, and between them they would settle the question
this document could not:

1. **Hoist or `constexpr` the queue geometry in the `2023`/`2025` paths.** Then
   a scalar cas can be compared to cas23 without a 3.8x reload handicap.
2. **Add a scalar/`_mm256` `find_batch` to `DRAMHiT_2025_INLINED`.** That is the
   only configuration that isolates the idiom with register promotion intact,
   and it is the one experiment that would show whether cas can beat cas23 at
   high skew.

## 13. The fix, and corrected margins

### 13a. `constexpr` queue geometry: measured, and it works

`cas_kht.hpp` now compiles the queue geometry in rather than taking it from
`--find_queue_sz`:

```cpp
#ifndef CAS_QUEUE_SZ
#define CAS_QUEUE_SZ 64
#endif
static_assert(CAS_QUEUE_SZ > 1 && (CAS_QUEUE_SZ & (CAS_QUEUE_SZ - 1)) == 0, ...);
static constexpr uint32_t find_queue_sz        = CAS_QUEUE_SZ;
static constexpr uint32_t insert_queue_sz      = CAS_QUEUE_SZ;
static constexpr uint32_t FIND_QUEUE_SZ_MASK   = CAS_QUEUE_SZ - 1;
static constexpr uint32_t INSERT_QUEUE_SZ_MASK = CAS_QUEUE_SZ - 1;
```

The old runtime power-of-two check became the `static_assert` (a bad size is
now a compile error, not a run-time `abort`). `HT_BUCKET_MASK` stays a member --
it depends on runtime capacity. `queue_sz` is accepted and ignored, with a
one-time `PLOGI` warning behind a function-local `std::once_flag` (the
constructor runs once per thread; verified as exactly 1 line of output across
64 threads).

`build_prefetchw/` happens to be a perfect control: byte-identical compile
flags to `build/`, built before the patch (0 mask immediates in `find_batch`)
against `build/` after it (11). 10 interleaved repeats of cas probe cyc/op:

| | member mask | constexpr mask | ratio |
|---|---|---|---|
| skew 1.0 | median 51.0, mean 52.8, sd 4.4 | median **45.5**, mean 44.7, sd 4.4 | **1.12x** |
| skew 0.1 | median 56.5, mean 57.5, sd 3.5 | median 55.0, mean 54.2, sd 3.4 | 1.03x |

Mean difference at skew 1.0 is +8.1 +/- 2.0 (1 se), t ~ 4.0 -- solid. At skew
0.1 it is +3.3 +/- 1.5, marginal. Exactly the predicted shape: the fix removes
per-probe *execution* work, which only shows through where memory latency is
not the limiter.

Note the mask was **not** the whole story. Folding it dropped
memory-operand instructions in the 2023 `find_batch` only from 34 to 32; the
remainder are `find_head` / `find_tail` / `empty_item`, which
`DRAMHiT_2025_INLINED` avoids by hoisting the cursors into locals across the
batch. Section 12b attributed the 34-vs-9 gap to the mask; **the mask is the
smaller half, register promotion of the cursors is the larger.**

### 13b. Corrected margins (10 reps, interleaved)

Every margin quoted earlier in this document came from 1-3 repetitions. With
10 interleaved repeats of each table, post-fix:

| | cas | cas23 | ratio |
|---|---|---|---|
| skew 1.0 | median **44.5**, mean 46.0, sd 5.6, range 39-57 | median **40.5**, mean 41.4, sd 2.0, range 39-45 | cas **1.10x slower** |
| skew 0.1 | median **48.0**, mean 51.5, sd 5.2 | median **80.0**, mean 80.0, sd 0.8 | cas **1.67x faster** |

**The crossover is real but the high-skew margin is ~10%, not the 1.16-1.20x
quoted in sections 9b, 10 and 12.** Combined with 13a, the picture is:

| cas at skew 1.0 | probe cyc/op | vs cas23 (40.5) |
|---|---|---|
| member mask (all of sections 1-12) | 51.0 | 1.26x slower |
| constexpr mask (now) | 44.5-45.5 | **1.10x slower** |

So the `constexpr` fix recovered roughly half of the high-skew deficit. cas23
still leads, by about 10%, which is only marginally outside the noise
(Welch t ~ 2.45, p ~ 0.03).

**cas is also intrinsically noisier than cas23** -- sd 5.6 against 2.0 at skew
1.0, with overlapping ranges (both reach 39). That variance is why several
single-run comparisons earlier in this document were unreliable; one
intermediate measurement of 35/35/34 cyc/op looked like a 1.37x win and did not
reproduce.

### 13c. Two methodology facts that should have been established first

**This machine has no cpufreq sysfs.** There is no
`/sys/devices/system/cpu/cpu0/cpufreq/` and no `amd_pstate`, so
`scripts/constant_freq_amd.sh` is a silent no-op here -- every one of its
actions is guarded on that directory existing. DRAMHiT times with `RDTSC` /
`RDTSCP`, which on Zen is invariant at the nominal frequency rather than
counting core cycles, so a boosting core would make every `cycle_per_op` in
this document wrong. Checked directly: `perf cycles / task-clock` gives
**3.249 GHz on every run**, i.e. exactly nominal, so boost is locked and
TSC-as-cycles is valid. The numbers stand -- but this was verified after the
fact, not by design.

**Ten repeats are the minimum for a 10% effect on this workload.** cas's sd is
4-6% of its mean and its range spans 40%. Most measurements in sections 1-12
are 1-3 runs and should be read as indicative; the tables in 13a and 13b are
the only ones here with enough repetition to support a ~10% claim.

### 13d. Consequence for the collected data

**Every number under `amd_nps4/` predates this fix**, so all four hash-table
runs there understate cas -- by ~12% on probe at high skew, less at low skew.
`amd_nps4_pre_prefetchw/` is doubly stale. Re-collecting the cas (and
cas23/dlht/folklore, which the fix does not touch but which were collected
against the old cas figures) sweeps would put the whole tree on one footing.

## Methodology and caveats

- Machine: AMD EPYC 9354P, 1 socket, 32c/64t, BIOS NPS4 -> 4 NUMA nodes of 16
  cpus / ~47 GiB. 1 MB L2 per core (512 KB per hyperthread), 8 x 32 MB L3.
  3.25 GHz.
- Timing runs used `build/` (no CALC_STATS); reprobe counts used a separate
  `build_calc_stats/` so the counters could not perturb timings. Same nix
  toolchain for both.
- Prefetcher off for both tables (`prefetch_control_amd.sh off`), per their
  spec entries in `amd-9354p.json`.
- `perf stat` covers the **whole process**, including the single-threaded 8 GB
  dataset load and the build phase. Absolute per-probe figures therefore carry
  a fixed additive offset. The offset is near-identical between the two tables
  at a given skew (same dataset file, same relation sizes), so the deltas and
  ratios are meaningful; the absolute values are upper bounds.
- The 6-event `perf stat` groups multiplexed at ~83%; perf scaled the counts
  accordingly. Differences of a few percent in that table are not meaningful.
- Run-to-run variance is real: the two cas23 @ 1.0 runs reported probe 5376 and
  4758 mops (13% apart), against ~5% typical for this workload per
  `SUMMARY.md`. Every conclusion here rests on effects far larger than that —
  1.28x, 1.86x vs 1.17x, 53.4% vs 17.0% — but do not read individual points as
  precise.
- `find_batch`'s `and $..,%rsp` at 9-15% is a function-prologue stack
  alignment and is almost certainly sample skid, not real cost. It is listed
  for completeness rather than interpreted.
- Radix join emits no correctness line: `print_stats` takes a different branch
  for partition joins (`misc_lib.cpp:241`, with the hash-join printf at `:260` and the radix one at `:250`), so the `joined : N out of
  N, 100.00%` check exists only for the hash joins. Unrelated to this
  investigation, but worth fixing.

## Reproduction

```bash
# phase decomposition, from the collected logs
grep -E "build_phrase|probe_phrase" amd_nps4/skew/logs/n4_cas{,23}/skew_1.0.log

# reprobe counts
cmake -S . -B build_calc_stats -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON \
  -DBRANCH=simd -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON -DGROWT=ON \
  -DCPUFREQ_MHZ=3250 -DCALC_STATS=ON && cmake --build build_calc_stats -j 32
build_calc_stats/dramhit --mode 13 --ht-type 8 --skew 1.0 --numa-split 1 \
  --num-threads 64 --ht-fill 7 --relation_r_size 67108864 \
  --relation_s_size 1006632960 --find_queue 64 --batch-len 16 \
  --no-prefetch 0 --associativity 1.0 --seed 1774551337382868027 | grep reprobe

# perf counters and annotation  (BIN=build/dramhit, ARGS as above)
perf stat -e ls_any_fills_from_sys.local_l2,ls_any_fills_from_sys.local_ccx,\
ls_any_fills_from_sys.dram_io_near,ls_any_fills_from_sys.dram_io_far,cycles,instructions -- $BIN $ARGS
perf record -F 299 -e cycles -o cas23_1.0.data -- $BIN $ARGS
perf annotate -i cas23_1.0.data --stdio --no-demangle -s "$(perf report -i cas23_1.0.data \
  --stdio --no-children --no-demangle | grep -oE '_ZN11kmercounter[A-Za-z0-9_]*find_batch[A-Za-z0-9_]*' | head -1)"

# dataset distribution
python3 scripts/verify_dataset.py \
  cache/hashjoin_r67108864_s1006632960_skew1_hit1_seed1774551337382868027.bin
```

## Open questions

1. **What sets cas's ~48-50 cyc/op probe floor?** Still open after eliminating
   queue depth, double prefetch, AVX-512, prefetchw and SMT contention (section
   8b). Needs phase-scoped hardware counters around the probe region; the prime
   remaining suspect is the software queue round trip itself, which no build
   flag can remove.
2. **Would `target_density` = 15 (i.e. no truncation) change the crossover?**
   Probing all 67 M keys of R would push the 90%-of-probes working set ~6.7x
   larger at every skew, likely moving the crossover well past 1.2 or removing
   it from the sweep entirely. This is the single highest-value follow-up,
   because it determines whether the crossover is a property of the hashtables
   or of the generator's density heuristic.
3. **Does the same crossover exist on the Xeon?** `directory/dual_skew` has
   cas23 ahead of cas across the whole sweep (mean ratio 0.89), i.e. no
   crossover — consistent with 1 MB L2 per hyperthread there vs 512 KB here,
   but not tested.
