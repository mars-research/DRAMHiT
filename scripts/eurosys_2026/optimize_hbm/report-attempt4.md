# Attempt 4: more instruction trimming (open research 2)

From `human.md` ("More instruction trimming"). This builds on the winning build of
`report-attempt3.md` (`rc` = byte-offset ring + hit value via `vpcompressq`) and asks how much
is left in `find_batch`, with energy per op and the mesh clock recorded alongside throughput.

**Result.**
- **One more small change is worth keeping.** `CAS_FIND_KSHIFT` removes 2.2 instructions per
  find and adds a measured **+1.5% to +3.5%** over `rc`. Cumulatively against the paper build:
  **finds +10.5% / +9.6% / +8.9% (fills 10/50/90), −9.2% / −8.9% / −8.3% energy per find.**
- **An instruction *swap* with the same count did nothing** (`CAS_FIND_SCALAR_PACK`, three
  SIMD operations replaced by three scalar ones). Neutral to slightly negative; not kept.
- **A larger `--batch-len` is not the free win I predicted.** 64 gains +0.8% to +2.0% on finds
  and loses 1–3% on inserts; 32 loses on both.
- **What remains in `find_batch` is close to the floor.** The rest of the per-find work is the
  algorithm itself plus the stall that instructions cannot remove. The larger remaining
  overheads are outside `find_batch`: the benchmark harness and the per-call fixed cost
  (§5).

## 1. Where the instructions go after attempt 3

`attempt3/rc/dramhit`, hit path, source lines from the DWARF line table (`objdump -d -l`). Two
things in that listing were avoidable:

1. **A mask shift done in the wrong register file.** `(__mmask8)(key_cmp << 1)` is integer
   arithmetic, so gcc emitted `kmovb k→r; add r,r; kmovb r→k` (3 instructions) before
   `vpcompressq`. `_kshiftli_mask8` does it in 1.
2. **A scalar job done through the vector unit.** The new queue entry's two adjacent 32-bit
   fields (`idx`, `key_id`) were packed with `vmovd` + `vpinsrd` + `vmovq` (3 instructions, all
   port 5). Two scalar stores do the same, with the same instruction count but no vector work.
   This is the `human.md` "instruction swap" in miniature.

## 2. The changes

Both are new CMake options on top of the attempt-3 ones, OFF by default. Delta against the
attempt-3 source (`attempt4/attempt4_only.diff`); the cumulative diff against HEAD is
`attempt4/cumulative.diff`.

```diff
+#ifdef CAS_FIND_KSHIFT
+          // One mask-register shift. Written as integer arithmetic (key_cmp << 1)
+          // gcc moves the mask to a GPR, shifts, and moves it back: 3 instructions.
+          const __mmask8 value_lanes = _kshiftli_mask8(key_cmp, 1);
+#else
+          const __mmask8 value_lanes = (__mmask8)(key_cmp << 1);
+#endif
           vp_result->value = _mm_cvtsi128_si64(_mm512_castsi512_si128(
-              _mm512_maskz_compress_epi64((__mmask8)(key_cmp << 1), cacheline)));
+              _mm512_maskz_compress_epi64(value_lanes, cacheline)));
 ...
+#ifdef CAS_FIND_SCALAR_PACK
+        {
+          // idx and key_id are adjacent 32-bit fields. Left alone, gcc packs them
+          // through an xmm register (vmovd + vpinsrd + vmovq, all port 5). Passing
+          // both through an empty asm leaves two scalar stores.
+          uint32_t pack_idx = new_idx, pack_id = key_data->id;
+          __asm__("" : "+r"(pack_idx), "+r"(pack_id));
+          FQ(head).idx = pack_idx;
+          FQ(head).key_id = pack_id;
+        }
+#else
           FQ(head).idx = new_idx;
           FQ(head).key_id = key_data->id;
+#endif
```

Codegen checks (`objdump` of `find_batch`):
- **`kshift`:** `kmovb` 6 → 4 in the function, one `kshiftlb`.
- **`scalar pack`:** in the hot loop, the `vmovd`/`vpinsrd`/`vmovq` triple became
  `mov -0x8(%r14),%r11d; mov %edi,0x10(%rcx); mov %r11d,0x14(%rcx)`: still 3 instructions, zero
  SIMD operations. The loop tail from `vpcompressq` to the back-branch is 23 instructions in
  both builds.
- The new code touches only the 2025_INLINE find fast path. `insert_batch` is the same code in
  every variant.

Builds (paper flags + `-DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE
-DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON`, plus the option):

| name | extra option | binary |
|---|---|---|
| `base` | (attempt-3 build with all new options OFF) | `attempt3/base/dramhit` |
| `rc` | – (rebuilt with the attempt-4 header; same code as attempt 3's `rc`) | `attempt4/rc4/dramhit` |
| `rck` | `-DCAS_FIND_KSHIFT=ON` | `attempt4/rck/dramhit` |
| `rcp` | `-DCAS_FIND_SCALAR_PACK=ON` | `attempt4/rcp/dramhit` |
| `rckp` | both | `attempt4/rckp/dramhit` |
| `rckp_b32`, `rckp_b64` | `rckp`, run with `--batch-len 32` / `64` | same binary |

## 3. Protocol

```
attempt4/run_all.sh 3
#  per (rep, variant): python3 run_uniform_hbm.py --config baseline --energy --reps 1 \
#     --fill 10 --fill 50 --fill 90 --batch-len <n> [--no-hugepages] --binary <bin> --tag a4_<name>_r<rep>
attempt3/summarize.py --prefix a4 --variants base rc rck rcp rckp rckp_b32 rckp_b64 --json attempt4/summary.json
```

- **One hugepage pool, reps interleaved**, as in attempt 3.
- `--energy` records package W, core GHz, **mesh GHz** and nJ/op per phase
  (`report-uncore.md` §5). `--batch-len` is a new option of `run_uniform_hbm.py`.
- Every run passed `found == find_ops`. `failures` is empty for all 63 runs.
- Perf validation: `attempt2/perf_profile.sh <bin> 10 attempt4/prof_<name>`.
- The `base` and `rc` rows agree with attempt 3 and the mesh session (base finds 3880 / 3624 /
  2439 Mops here; 3926 / 3646 / 2428 in attempt 3; rc +8.3% / +7.9% / +5.2% here against
  +7.1% / +7.5% / +7.0% there).

## 4. Results

### Find (get), median of 3

| fill | variant | Mops (min–max) | vs base | HBM GB/s | core GHz | mesh GHz | nJ/find | vs base |
|---|---|---|---|---|---|---|---|---|
| 10 | base | 3880 (3750–3922) | – | 245 | 2.25 | 1.69 | 90.1 | – |
| 10 | rc | 4202 (4197–4282) | +8.3% | 276 | 2.19 | 1.68 | 83.5 | −7.4% |
| 10 | **rck** | **4287** (4213–4296) | **+10.5%** | 256 | 2.15 | 1.64 | **81.8** | **−9.2%** |
| 10 | rcp | 4196 (4154–4202) | +8.1% | 260 | 2.18 | 1.67 | 84.0 | −6.8% |
| 10 | rckp | 4228 (4188–4301) | +9.0% | 266 | 2.17 | 1.66 | 82.3 | −8.7% |
| 50 | base | 3624 (3556–3701) | – | 243 | 2.18 | 1.68 | 96.2 | – |
| 50 | rc | 3912 (3859–3958) | +7.9% | 261 | 2.13 | 1.63 | 89.2 | −7.4% |
| 50 | **rck** | **3971** (3964–4001) | **+9.6%** | 266 | 2.11 | 1.62 | **87.7** | **−8.9%** |
| 50 | rcp | 3846 (3838–3858) | +6.1% | 259 | 2.13 | 1.64 | 90.5 | −5.9% |
| 50 | rckp | 3920 (3898–3937) | +8.2% | 265 | 2.13 | 1.64 | 88.8 | −7.7% |
| 90 | base | 2439 (2414–2468) | – | 242 | 2.15 | 1.66 | 143.2 | – |
| 90 | rc | 2566 (2504–2609) | +5.2% | 255 | 2.08 | 1.60 | 135.9 | −5.1% |
| 90 | **rck** | **2657** (2618–2658) | **+8.9%** | 259 | 2.07 | 1.60 | **131.3** | **−8.3%** |
| 90 | rcp | 2599 (2593–2613) | +6.6% | 256 | 2.09 | 1.60 | 134.3 | −6.2% |
| 90 | rckp | 2636 (2623–2638) | +8.1% | 258 | 2.08 | 1.60 | 132.3 | −7.6% |

Increment of each change over `rc` (find Mops):

| change | fill 10 | fill 50 | fill 90 |
|---|---|---|---|
| `kshift` (rck vs rc) | +2.0% | +1.5% | +3.5% |
| scalar pack (rcp vs rc) | −0.1% | −1.7% | +1.3% |
| both (rckp vs rck) | −1.4% | −1.3% | −0.8% |

- **`kshift`:** positive at all three fills. The rep ranges overlap at fill 10 and separate
  only narrowly at fills 50 and 90 (rck's minimum 3964 vs rc's maximum 3958; 2618 vs 2609), so
  the size is uncertain but the sign is consistent, and it matches the perf profile below.
- **Scalar pack:** mixed sign, within noise by itself. Adding it to `rck` (`rckp`) lowers
  throughput by 0.8% to 1.4% in all three fills. It is neutral at best.
- Inserts are unchanged for `rc`, `rck`, `rcp` and `rckp`: within −1.3% to +1.2% of base at
  every fill (the control).

### Instructions and cycles per find (perf, fill 10, one run each, `find_batch` symbol)

| build | instr/find | core cycles/find | IPC |
|---|---|---|---|
| base | 57.1 | 30.1 | 1.89 |
| rc | 49.2 | 27.2 | 1.81 |
| **rck** | **47.0** | **26.3** | 1.79 |
| rcp | 49.0 | 27.6 | 1.78 |
| rckp | 47.1 | 26.6 | 1.77 |

- `kshift` removes the 2.2 instructions the listing predicted (49.2 → 47.0) and 0.9 cycles.
- The scalar pack removes 0.2 instructions (the count was meant to be equal) and costs 0.4
  cycles: not an improvement.
- **The cost of an instruction is well under 1/IPC here.** From base to rck, 10.1 instructions
  removed buys 3.8 cycles, 0.38 cycles per instruction, against 0.53 (1/IPC). The rest of the
  time is the fill-buffer stall of `report-attempt3.md` §5, which removing instructions does
  not touch. This is why the gains are +9–10% for −18% instructions, and why every additional
  instruction removed is worth less than the last.

### Batch length, relative to `rckp` at the default 16

Same binary, `--batch-len` only.

| | finds, fill 10 / 50 / 90 | inserts, fill 10 / 50 / 90 | nJ/find |
|---|---|---|---|
| 32 | −1.5% / −2.4% / −3.2% | −5.4% / −6.0% / −4.4% | +6% / +3% / +3% |
| 64 | +2.0% / +1.0% / +0.8% | −2.4% / −2.6% / −1.2% | +5% / −1% / −1% |

- At 64, finds gain about what the instruction accounting predicted (the ~60-instruction
  per-call cost over 16 keys is 3.7 per find; over 64 it is 0.9). Inserts lose, so it is not
  free: the benchmark does both phases with the same batch length.
- **At 32, both phases get worse. This is not explained.** It is not monotonic (16 → 32 worse,
  64 better than 32), I did not investigate it, and I will not guess at a cause. The practical
  reading is that batch length interacts with something else in the benchmark (the 24 B
  argument array, the 64-slot queue, the harness's prefetch pattern) and is not a knob to turn
  without a reason.
- Not recommended. The paper's default of 16 stays.

## 5. What is left, and what I did not touch

Per-find instruction budget in the winning build (`rck`), at fill 10:

| where | instructions per find | notes |
|---|---|---|
| `find_batch` loop body | ~43 | prefetch × 2 and its address math (5 of these), key compare, hit handling, next-key CRC, queue push stores, ring updates |
| `find_batch` per-call fixed cost | ~3.7 | prologue/epilogue and member loads, ~60 instructions per call over 16 keys |
| `ZipfianTest::run` (the harness) | not measured separately for the find phase | attempt 2 measured ~17 instructions per op summed over insert and find; the split was not measured |

- **What is in the loop is mostly algorithm.** Two prefetches with their address math, a
  64-byte compare, the hit result, the next key's hash, and the queue push are needed by the
  scheme itself. The micro-level candidates left are 1–2 instructions each (the ring wrap
  `and`, the CRC seed copy `mov`, a mask copy `mov`). Mov elimination makes the register copies
  nearly free, and the wrap needs an unrolled loop that breaks on reprobes. I did not pursue
  them.
- **The stored bucket pointer from the v2 proposal stays dropped**: the slow path pops entries
  the fast path pushed and reads `idx`, so `idx` must still be stored, and the net saving is
  about one instruction.
- **The harness is the largest untouched piece, and I did not edit it.** `src/tests/zipfian_test.cpp`
  does per key: a workload read, a `!(idx & 7) && idx + 16 < request_num` prefetch test, and
  three stores into the 24 B argument struct, including a `value` field that `find_batch` never
  reads. Moving the prefetch to once per batch and dropping that store would remove a few
  instructions per find from the measured per-find cost. It would not change the hashtable, but
  it would change the benchmark every other figure in the paper uses, so it needs your decision.
  Say so if you want it measured as a separate, labeled result.

## 6. Conclusion

- Keep `CAS_FIND_RING_OFFSETS=ON`, `CAS_FIND_COMPRESS_VALUE=ON`, `CAS_FIND_KSHIFT=ON` with
  `PREFETCH=DOUBLE`: **finds +10.5% / +9.6% / +8.9%, −9.2% / −8.9% / −8.3% energy per find**,
  inserts unchanged. All three options are still OFF by default, so the paper build is
  unchanged; turning them on is your decision.
- Drop `CAS_FIND_SCALAR_PACK`. As a "swap SIMD for scalar at equal count" test it gives no
  measurable benefit at this resolution (about ±2%): with the clock held to a fixed power budget
  by the controller, 3 port-5 operations out of ~47 are too small a share to show.
- Batch length stays at 16.
- Trimming is now at diminishing returns inside `find_batch` (each instruction removed is worth
  ~0.4 cycles). The dominant cost is still the fill-buffer wait, which is open research item 3
  in `human.md`.

Files: `attempt4/{run_all.sh,summary.json,attempt4_only.diff,cumulative.diff,prof_*}`,
`attempt4/{rc4,rck,rcp,rckp}/dramhit`, `results/a4_<name>_r<rep>/`,
`run_uniform_hbm.py` (`--batch-len`).
