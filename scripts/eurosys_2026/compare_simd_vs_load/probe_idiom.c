// Isolates the two probe idioms DRAMHiT's cas / cas23 hashtables use, on data
// of controlled cache residency, to answer: when the bucket is already in
// cache, is the AVX-512 bucket scan slower than a plain scalar load+compare?
//
//   scalar1 : 8B load  + cmp                        <- cas23 (hash -> one slot)
//   scalar4 : up to 4x (8B load + cmp)              <- 4-way search, no vectors
//   simd4   : vpbroadcastq / vmovdqa64 / vpcmpequq
//             / kortestb / kmovb                    <- cas (hash -> 4-slot bucket)
//
// simd4's inner loop is byte-for-byte the one gcc emits for
// CASHashTable::find_batch in the DRAMHiT_2025_INLINED path; see README.md.
//
// Notes on measurement hygiene:
//  - ITERS is a power of two so the index stream really covers the footprint.
//  - Indices are precomputed already reduced into [0,nbuckets), so the inner
//    loop contains no integer division (verify with `make check-nodiv`).
//  - One variant and one footprint per process, selected on the command line,
//    so `perf stat` counters attribute to a single idiom.
//
// usage: ./probe_idiom <nthreads> [variant] [footprint]
//          variant   : scalar1 | scalar4 | simd4 | all   (default all)
//          footprint : l1 | l2 | l3 | dram | all         (default all)
//
// build: gcc -O2 -march=native -pthread -o probe_idiom probe_idiom.c
#define _GNU_SOURCE
#include <immintrin.h>
#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { uint64_t k, v; } KV;            // 16B, like kmercounter::Item
#define SLOTS 4                                   // 4 KV per 64B cacheline
#define ITERS (1u << 24)                          // power of two: 16.7M probes
#define IMASK (ITERS - 1)

static KV *table;
static uint32_t *idxs;                            // already in [0,nbuckets)
static volatile uint64_t sink;

static uint64_t probe_scalar1(uint32_t t) {
  uint64_t acc = 0;
  for (uint32_t i = 0; i < ITERS; i++) {
    uint32_t b = idxs[(i + (t << 12)) & IMASK];
    KV *slot = &table[(size_t)b * SLOTS];         // hash points at one slot
    if (slot->k == (uint64_t)b + 1) acc += slot->v;
  }
  return acc;
}

static uint64_t probe_scalar4(uint32_t t) {
  uint64_t acc = 0;
  for (uint32_t i = 0; i < ITERS; i++) {
    uint32_t b = idxs[(i + (t << 12)) & IMASK];
    KV *bk = &table[(size_t)b * SLOTS];
    uint64_t want = (uint64_t)b + 1;
    for (int s = 0; s < SLOTS; s++)
      if (bk[s].k == want) { acc += bk[s].v; break; }
  }
  return acc;
}

static uint64_t probe_simd4(uint32_t t) {
  uint64_t acc = 0;
  const __mmask8 KEYMSK = 0x55;                   // key lanes of {k,v} x4
  for (uint32_t i = 0; i < ITERS; i++) {
    uint32_t b = idxs[(i + (t << 12)) & IMASK];
    uint64_t *bucket = (uint64_t *)&table[(size_t)b * SLOTS];
    __m512i cl = _mm512_load_si512(bucket);
    __m512i kv = _mm512_set1_epi64((long long)b + 1);
    __mmask8 cmp = _mm512_mask_cmpeq_epu64_mask(KEYMSK, cl, kv);
    if (cmp) acc += bucket[__builtin_ctz(cmp) + 1];
  }
  return acc;
}

struct arg { int tid; int variant; uint64_t cycles; };

static void *worker(void *p) {
  struct arg *a = (struct arg *)p;
  cpu_set_t set; CPU_ZERO(&set); CPU_SET(a->tid, &set);
  pthread_setaffinity_np(pthread_self(), sizeof(set), &set);
  uint64_t acc = 0, t0 = __rdtsc();
  switch (a->variant) {
    case 0: acc = probe_scalar1(a->tid); break;
    case 1: acc = probe_scalar4(a->tid); break;
    case 2: acc = probe_simd4(a->tid); break;
  }
  a->cycles = __rdtsc() - t0;
  sink += acc;
  return NULL;
}

static const char *vnames[3] = {"scalar1", "scalar4", "simd4"};
static const uint64_t sizes[4] = {256, 8192, 262144, 16777216};
static const char *snames[4] = {"l1", "l2", "l3", "dram"};
static const char *slabels[4] = {"16 KB  L1", "512 KB L2", "16 MB  L3", "1 GB   DRAM"};

int main(int argc, char **argv) {
  int nthreads = argc > 1 ? atoi(argv[1]) : 1;
  int v0 = 0, v1 = 3, s0 = 0, s1 = 4;
  if (argc > 2 && strcmp(argv[2], "all")) {
    for (v0 = 0; v0 < 3 && strcmp(argv[2], vnames[v0]); v0++);
    if (v0 == 3) { fprintf(stderr, "bad variant %s\n", argv[2]); return 1; }
    v1 = v0 + 1;
  }
  if (argc > 3 && strcmp(argv[3], "all")) {
    for (s0 = 0; s0 < 4 && strcmp(argv[3], snames[s0]); s0++);
    if (s0 == 4) { fprintf(stderr, "bad footprint %s\n", argv[3]); return 1; }
    s1 = s0 + 1;
  }

  idxs = aligned_alloc(64, (size_t)ITERS * 4);

  int single = (v1 - v0 == 1);
  if (!single) {
    printf("%-13s %-11s", "footprint", "");
    for (int v = v0; v < v1; v++) printf("%11s", vnames[v]);
    printf("  simd4/scalar1  simd4/scalar4\n");
  }

  for (int si = s0; si < s1; si++) {
    uint64_t nb = sizes[si];
    table = aligned_alloc(64, nb * SLOTS * sizeof(KV));
    memset(table, 0, nb * SLOTS * sizeof(KV));
    for (uint64_t b = 0; b < nb; b++) {           // one key per bucket, slot 0
      table[b * SLOTS].k = b + 1;
      table[b * SLOTS].v = b + 100;
    }
    uint64_t r = 88172645463325252ull;            // reduce once, outside the loop
    for (uint32_t i = 0; i < ITERS; i++) {
      r ^= r << 13; r ^= r >> 7; r ^= r << 17;
      idxs[i] = (uint32_t)((r >> 11) % nb);
    }
    double cpo[3] = {0, 0, 0};
    for (int v = v0; v < v1; v++) {
      pthread_t th[256]; struct arg ar[256];
      for (int t = 0; t < nthreads; t++) { ar[t].tid = t; ar[t].variant = v; }
      for (int t = 0; t < nthreads; t++) pthread_create(&th[t], NULL, worker, &ar[t]);
      uint64_t sum = 0;
      for (int t = 0; t < nthreads; t++) { pthread_join(th[t], NULL); sum += ar[t].cycles; }
      cpo[v] = (double)sum / ((double)ITERS * nthreads);
    }
    if (single) {
      printf("%-11s %-9s %2d thr  %8.2f cyc/probe   (%llu probes total)\n",
             slabels[si], vnames[v0], nthreads, cpo[v0],
             (unsigned long long)ITERS * nthreads);
    } else {
      printf("%-13s %-11s", slabels[si], "cyc/probe");
      for (int v = v0; v < v1; v++) printf("%11.2f", cpo[v]);
      printf("%14.2fx %14.2fx\n", cpo[2] / cpo[0], cpo[2] / cpo[1]);
    }
    free(table);
  }
  return 0;
}
