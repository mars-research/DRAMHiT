// Per-controller read and 1r1w bandwidth on the AMD EPYC 9354P.
//
// Why this exists: the system-wide sweeps in ../collect_scalability show a 1r1w
// ceiling of ~272 GB/s against a ~363 GB/s read ceiling, and could not say whether
// that asymmetry lives in the DRAM channels themselves or in something shared above
// them (CCD links, fabric). Answering that needs a channel driven on its own, which is
// what reversed_amd.c's address predicate gives: it selects the 1/3 of a 1 GiB
// hugepage's lines that a subset of the node's controllers own, so the access loop
// touches those and nothing else.
//
// IMPORTANT, measured not assumed: on this machine in NPS4 the predicate selects lines
// that land on TWO of node 0's three channels, not one. Counting umc0/1/2 over the
// access loop gives ~2.73e6 read CAS on umc0, ~2.73e6 on umc2 and ~0.17e6 on umc1 --
// an even 50/50 split across two controllers. reversed_amd.c calls this "UMC 1", which
// is not what the hardware does here; the hash was derived under a different
// interleave configuration. Per-controller numbers from this probe are therefore
// total/2, and the divisor is verified from the counters on every run rather than
// assumed.
//
// Differences from reversed_amd.c, all in service of a clean measurement:
//   - the access loop repeats (-r) so the steady state lasts seconds, and a
//     `perf stat -I` median lands on it instead of on the one-shot memset and clflush
//     that precede it (that init is what makes a whole-run perf stat show traffic on
//     every channel no matter what the predicate selects);
//   - a 1r1w mode: an 8 B store into a 64 B line, so the controller sees the
//     read-for-ownership fetch and the later writeback -- the same thing
//     machine_stats/bandwidth.c does in `-mode w -inst load`, so the two are
//     comparable;
//   - threads are pinned to an explicit cpu list on the node that owns the page;
//   - a bank-parallelism mode (-c), below.
//
// --- bank parallelism (-c MASK) ----------------------------------------------
// The open question the single-controller numbers leave behind is *why* one controller
// serves 1r1w at ~0.77x its read rate. The leading explanation is bank occupancy: a
// random write holds its bank for ACT->tRCD->WR->WL+burst+tWR->PRE->tRP (~83 ns at
// DDR5-4800) against ~tRC (~48 ns) for a read, so a write stream needs ~1.7x as many
// banks concurrently busy to keep the data bus fed. These are 1Rx8 DIMMs -- 32 banks
// per subchannel and no second rank -- so that headroom is thin.
//
// That is a testable claim: starve the stream of banks and the write side should fall
// away faster than the read side. Two clamps do it, and the difference between them
// matters:
//
//   -c MASK  keeps lines with (phys & MASK) == 0, on the PHYSICAL byte address.
//   -C MASK  keeps lines with (norm & MASK) == 0, on the NORMALIZED address: the
//            address as the controller sees it, after the interleave selector is
//            removed. The channel takes every twelfth 256 B chunk, so its own address
//            space is its owned lines compacted in ascending physical order, and the
//            r-th owned line sits at normalized byte address r * 64.
//
// Measured, and the reason -b exists: neither clamp starves banks. Clamping seven
// normalized bits (8..14) shrinks the working set 128x and swings activates per access
// 4x, and read holds at 30-33 GB/s and 1r1w at 27-29 GB/s throughout. Addresses 1 MiB
// apart in normalized space still reach full bandwidth, which they could not if the
// bank index were a contiguous address field -- they would all be the same bank, in
// different rows. The UMC hashes the bank index out of many address bits, so no bit
// mask can reduce the bank count. -b does it by measurement instead.
//
// --- -b N: N banks, found by row-conflict timing -----------------------------
// Two lines on the same channel but in different banks can be open at once; two in the
// same bank and different rows cannot, and the second pays a precharge plus an
// activate. That latency gap is the standard bank side channel, and it does not care
// how the bank index is hashed. -b N times owned lines against a set of representative
// lines, clusters them into banks, and builds a workload from N of those clusters,
// round-robin so consecutive accesses rotate through all N. The number of clusters it
// finds before saturating is the bank count the controller actually exposes.
//
// This is the experiment the bank-occupancy model makes a sharp prediction for. A read
// holds its bank ~tRC (~48 ns) and a write ~83 ns, i.e. 1.33 and 0.77 GB/s per bank,
// so filling a 38.4 GB/s channel needs ~29 banks of reads or ~50 banks of writes. If
// the model holds, read and 1r1w both climb linearly in N, 1r1w at ~0.58x the slope,
// and read levels off well before 1r1w does.
//
// -C is the bank knob for address-field purposes only. The interleave across 12 channels is not a power of two, so a
// physical bit does not survive into the controller's address as a bit -- measured,
// clamping any single physical bit from 8 up costs nothing (bits 6 and 7 cost 5-7%,
// which is column locality inside the 256 B chunk, not banks). Clamping a normalized
// bit removes exactly half of one of the controller's own fields, so each clamped
// bank or bank-group bit halves the banks the stream can reach, and each clamped row
// bit only halves the footprint. Which normalized bits are which is discovered, not
// assumed -- sweep_bank_parallel.py clamps them one at a time and watches the rate.
//
// Two things make that measurement honest, and both need the larger mapping that -g
// now allows:
//   - clamping n bits divides the working set by 2^n, and a set that fits in the
//     node's 64 MiB of L3 (2 CCDs x 32 MiB) stops being a DRAM measurement. -g 16
//     leaves ~680 MB after 3 clamped bits, ~10x L3. The probe prints the ratio.
//   - the index array is streamed at 4 B per 64 B access, so it is ~6% of the traffic.
//     It is bound to a different node (-i) to keep it off the controller under test.
//
// Build:  make amd_channel_probe
// Run:    sudo perf stat -a -e <umc events> -I 20 -x, -- ./amd_channel_probe -t 16 -m rw
//         sudo ./sweep_bank_parallel.py 1            # the bank sweep on node 1
#define _GNU_SOURCE
#include <fcntl.h>
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <x86intrin.h>

#define ONE_GB (1024ULL * 1024ULL * 1024ULL)
#define CACHE_LINE_SIZE 64
#define LINES_PER_GB (ONE_GB / CACHE_LINE_SIZE)
#define PROCESSOR_FREQ_GHZ 3.25
#define LOOKAHEAD 16
#define MAX_PAGES 64
#define MAX_BANKS 128
#define TIME_REPS 24        // min-of-N is the robust statistic for a latency probe
#define FILL_REPS 8         // classification tolerates more noise than discovery does
#define BANK_TARGET_LINES 8192   // total lines for -b, split over the N banks
#define CAND_STRIDE 2654435761u  // Knuth's multiplier: walk candidates in a scrambled
                                 // order so a bank hash cannot alias with the walk
#define NODE_L3_BYTES (64ULL * 1024 * 1024)  // 2 CCDs x 32 MiB on this part
// -r 0 picks a repeat count that puts roughly this many bytes through the loop, so a
// 340 MB working set and a 5 GB one both give perf -I several seconds of steady state.
#define AUTO_TARGET_BYTES (120ULL * 1000 * 1000 * 1000)

typedef char cacheline_t[CACHE_LINE_SIZE];

enum { MODE_READ, MODE_RW, MODE_NT };

static pthread_barrier_t sync_barrier;

typedef struct {
    int thread_id;
    int cpu;
    int mode;
    int repeats;
    int reps_done;
    uint64_t deadline_tsc;   // 0 = run `repeats` passes; otherwise stop at this tsc
    int flush_dist;
    uint32_t *my_workload;
    uint64_t workload_len;
    cacheline_t *mem_space;
    uint64_t elapsed_cycles;
    uint64_t accumulator;
} thread_args_t;

// --- reversed_amd.c's predicate, verbatim ------------------------------------
// Kept identical so this probe selects exactly the set that file selects; see the
// header comment for what that set actually turns out to be on this machine.
static uint64_t page_phys_base(void *vaddr) {
    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) { perror("open pagemap (run as root)"); exit(EXIT_FAILURE); }
    uint64_t page_size = sysconf(_SC_PAGESIZE);
    uint64_t vpn = (uint64_t)vaddr / page_size;
    uint64_t pfn_item;
    if (pread(fd, &pfn_item, sizeof(pfn_item), vpn * sizeof(pfn_item)) != sizeof(pfn_item)) {
        perror("read pagemap"); exit(EXIT_FAILURE);
    }
    close(fd);
    if ((pfn_item & (1ULL << 63)) == 0) {
        fprintf(stderr, "page not present\n"); exit(EXIT_FAILURE);
    }
    return (pfn_item & ((1ULL << 55) - 1)) * page_size + ((uint64_t)vaddr % page_size);
}

static inline int is_block0_owner_cacheline(uint64_t line_idx, uint64_t cycle_offset) {
    uint64_t rem_12mb = line_idx % 196608;
    uint64_t local_M = rem_12mb / 16384;
    uint64_t absolute_M = (local_M + cycle_offset) % 12;
    uint64_t base_state = ((absolute_M / 2) * 5 + (absolute_M % 2) * 4) % 6;
    uint64_t chunk_in_mb = (rem_12mb % 16384) / 256;
    uint64_t micro_shift = (chunk_in_mb / 4) + (chunk_in_mb % 4);
    uint64_t final_state = (base_state + micro_shift) % 6;
    int is_even_block = (((rem_12mb % 256) / 4) % 2 == 0);
    if (final_state == 0 || final_state == 5) return is_even_block;
    if (final_state == 2 || final_state == 3) return !is_even_block;
    return 0;
}

// --- bank discovery by row-conflict timing -----------------------------------
// Access a then b back to back with both flushed. Different banks: the two activates
// overlap. Same bank, different row: b waits for a's row to close, which shows up as
// tens of nanoseconds. Minimum over TIME_REPS to shed interrupts and stray hits.
static inline uint64_t pair_latency_n(volatile char *a, volatile char *b, int reps) {
    uint64_t best = ~0ULL;
    unsigned aux;
    for (int i = 0; i < reps; i++) {
        _mm_clflush((void *)a);
        _mm_clflush((void *)b);
        _mm_mfence();
        uint64_t t0 = __rdtscp(&aux);
        _mm_lfence();
        (void)*a;
        (void)*b;
        _mm_lfence();
        uint64_t d = __rdtscp(&aux) - t0;
        if (d < best) best = d;
    }
    return best;
}

static inline uint64_t pair_latency(volatile char *a, volatile char *b) {
    return pair_latency_n(a, b, TIME_REPS);
}

static int cmp_u64(const void *a, const void *b) {
    uint64_t x = *(const uint64_t *)a, y = *(const uint64_t *)b;
    return x < y ? -1 : x > y;
}

// Threshold between "different bank" and "same bank, different row", taken from the
// shape of the sample rather than a constant: with tens of banks the large majority of
// random pairs are different-bank, so the bulk sits low and the conflicts form the
// tail. Halfway between the median and the 99th percentile splits them.
static uint64_t conflict_threshold(cacheline_t *mem, uint32_t *owned, uint64_t n) {
    enum { NS = 2000 };
    uint64_t *lat = malloc(NS * sizeof(uint64_t));
    for (int i = 0; i < NS; i++) {
        uint64_t a = ((uint64_t)i * CAND_STRIDE) % n;
        uint64_t b = ((uint64_t)(i + NS) * CAND_STRIDE) % n;
        lat[i] = pair_latency(&mem[owned[a]][0], &mem[owned[b]][0]);
    }
    qsort(lat, NS, sizeof(uint64_t), cmp_u64);
    uint64_t p50 = lat[NS / 2], p99 = lat[(NS * 99) / 100], thr = (p50 + p99) / 2;
    printf("[*] pair latency cycles: p50 %lu  p90 %lu  p99 %lu  -> conflict above %lu\n",
           p50, lat[(NS * 90) / 100], p99, thr);
    free(lat);
    return thr;
}

// Cluster owned lines into banks and return a round-robin workload over `want` of
// them, `per_bank` lines each. Returns the number of lines written to `out`, and
// stores the bank count it observed in *nbanks_seen.
static uint64_t build_bank_workload(cacheline_t *mem, uint32_t *owned, uint64_t n,
                                    int want, uint64_t per_bank, uint32_t *out,
                                    int *nbanks_seen) {
    uint64_t thr = conflict_threshold(mem, owned, n);
    uint32_t rep[MAX_BANKS];
    uint32_t *bucket[MAX_BANKS];
    uint64_t fill[MAX_BANKS];
    int nrep = 0;
    for (int b = 0; b < MAX_BANKS; b++) { bucket[b] = NULL; fill[b] = 0; }

    // Pass 1: representatives. A candidate that conflicts with no existing
    // representative is a bank nobody has seen yet. The count stops growing at the
    // controller's real bank count, which is the number reported.
    uint64_t i = 0, since_new = 0;
    while (nrep < MAX_BANKS && since_new < 4000 && i < n) {
        uint64_t idx = (i++ * CAND_STRIDE) % n;
        int hit = 0;
        for (int b = 0; b < nrep; b++)
            if (pair_latency_n(&mem[owned[idx]][0], &mem[rep[b]][0], FILL_REPS) > thr) { hit = 1; break; }
        if (hit) { since_new++; continue; }
        rep[nrep++] = owned[idx];
        since_new = 0;
    }
    *nbanks_seen = nrep;
    printf("[*] %d banks found on this controller (%lu candidates probed)\n", nrep, i);
    if (nrep < want) {
        fprintf(stderr, "only %d banks found, -b %d impossible\n", nrep, want);
        return 0;
    }

    // Pass 2: fill the first `want` buckets. A candidate is tested against those
    // representatives only, so most are discarded -- cheaper than classifying all.
    for (int b = 0; b < want; b++) bucket[b] = malloc(per_bank * sizeof(uint32_t));
    uint64_t done = 0;
    for (uint64_t k = 0; k < n && done < (uint64_t)want; k++) {
        uint64_t idx = ((k + 1) * CAND_STRIDE) % n;
        for (int b = 0; b < want; b++) {
            if (fill[b] >= per_bank) continue;
            if (pair_latency_n(&mem[owned[idx]][0], &mem[rep[b]][0], FILL_REPS) > thr) {
                bucket[b][fill[b]++] = owned[idx];
                if (fill[b] == per_bank) done++;
                break;
            }
        }
    }
    uint64_t least = per_bank;
    for (int b = 0; b < want; b++) if (fill[b] < least) least = fill[b];
    if (least == 0) { fprintf(stderr, "a bank bucket came up empty\n"); return 0; }

    // Self-check: lines put in one bucket should conflict with each other, lines in
    // different buckets should not. Printed rather than asserted, so a classification
    // that went soft is visible in the log next to the bandwidth it produced.
    if (least > 4) {
        int same_hit = 0, same_n = 0, cross_hit = 0, cross_n = 0;
        for (int k = 0; k < 200; k++) {
            uint64_t r1 = ((uint64_t)k * 7919) % least, r2 = ((uint64_t)k * 104729 + 3) % least;
            if (r1 == r2) continue;
            same_hit += pair_latency(&mem[bucket[0][r1]][0], &mem[bucket[0][r2]][0]) > thr;
            same_n++;
            if (want > 1) {
                cross_hit += pair_latency(&mem[bucket[0][r1]][0],
                                          &mem[bucket[want - 1][r2]][0]) > thr;
                cross_n++;
            }
        }
        printf("[*] cluster check: within-bank conflicts %d/%d, cross-bank %d/%d\n",
               same_hit, same_n, cross_hit, cross_n);
    }

    // Round-robin so consecutive accesses rotate through all `want` banks: with -b 1
    // the stream hammers one bank, with -b 32 it spreads as widely as it can.
    uint64_t total = 0;
    for (uint64_t r = 0; r < least; r++)
        for (int b = 0; b < want; b++) out[total++] = bucket[b][r];
    printf("[*] %d banks x %lu lines = %lu lines, round-robin across banks\n",
           want, least, total);
    for (int b = 0; b < want; b++) free(bucket[b]);
    return total;
}

// -----------------------------------------------------------------------------
static void *memory_worker(void *arg) {
    thread_args_t *t = (thread_args_t *)arg;
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(t->cpu, &set);
    pthread_setaffinity_np(pthread_self(), sizeof(set), &set);

    uint64_t local_acc = 0;
    cacheline_t *mem = t->mem_space;
    uint64_t len = t->workload_len;
    uint32_t *workload = t->my_workload;

    pthread_barrier_wait(&sync_barrier);
    _mm_mfence();
    uint64_t start_tsc = __rdtsc();
    _mm_lfence();

    // Four specialisations rather than a branch in the loop: -f adds a clflushopt on
    // the line F accesses back, which makes every access miss to DRAM no matter how
    // small the clamped working set is (see -f in the usage text).
#define ACCESS_LOOP(BODY, FLUSH)                                                  \
    for (int rep = 0; rep < t->repeats; rep++) {                                  \
        for (uint64_t i = 0; i < len; i++) {                                      \
            if (i + LOOKAHEAD < len)                                              \
                _mm_prefetch(&mem[workload[i + LOOKAHEAD]][0], _MM_HINT_T1);       \
            BODY;                                                                 \
            FLUSH;                                                                \
        }                                                                         \
        FLUSH_TAIL;                                                               \
        __asm__ volatile("" ::: "memory");                                        \
        t->reps_done = rep + 1;                                                   \
        if (t->deadline_tsc && __rdtsc() >= t->deadline_tsc) break;               \
    }
#define RD_BODY local_acc += *(volatile char *)&mem[workload[i]][0]
    // 8 B store into a 64 B line: the line has to be fetched (RFO) and written back,
    // so the controller sees one read and one write per access -- the 1r1w stream
    // this probe exists to measure.
#define WR_BODY *(uint64_t *)&mem[workload[i]][0] = (uint64_t)i
    // Full-line non-temporal store: no ownership fetch, so the bank pays one write row
    // cycle per line instead of a read cycle plus a write cycle. This is the term the
    // 1r1w rate is supposed to decompose into, measured on its own.
#define NT_BODY _mm512_stream_si512((void *)&mem[workload[i]][0], ntval)
#define DO_FLUSH if (i >= (uint64_t)fd) _mm_clflushopt(&mem[workload[i - fd]][0])
#define NO_FLUSH (void)0
#define FLUSH_TAIL                                                                \
    do {                                                                          \
        if (fd) {                                                                 \
            for (uint64_t k = (len > (uint64_t)fd ? len - fd : 0); k < len; k++)  \
                _mm_clflushopt(&mem[workload[k]][0]);                             \
            _mm_sfence();                                                         \
        }                                                                         \
    } while (0)

    const int fd = t->flush_dist;
    const __m512i ntval = _mm512_set1_epi32(t->thread_id + 1);
    if (t->mode == MODE_NT)               ACCESS_LOOP(NT_BODY, NO_FLUSH)
    else if (t->mode == MODE_READ && !fd) ACCESS_LOOP(RD_BODY, NO_FLUSH)
    else if (t->mode == MODE_READ)        ACCESS_LOOP(RD_BODY, DO_FLUSH)
    else if (!fd)                         ACCESS_LOOP(WR_BODY, NO_FLUSH)
    else                                  ACCESS_LOOP(WR_BODY, DO_FLUSH)
    if (t->mode == MODE_NT) _mm_sfence();

    _mm_mfence();
    uint64_t end_tsc = __rdtsc();
    _mm_lfence();
    pthread_barrier_wait(&sync_barrier);

    t->elapsed_cycles = end_tsc - start_tsc;
    t->accumulator = local_acc;
    return NULL;
}

static void *bind_alloc(uint64_t bytes, int node) {
    void *p = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
    if (p == MAP_FAILED) return NULL;
    struct bitmask *nm = numa_allocate_nodemask();
    numa_bitmask_setbit(nm, node);
    if (mbind(p, bytes, MPOL_BIND, nm->maskp, nm->size + 1, 0) < 0) {
        perror("mbind index array");
        munmap(p, bytes);
        numa_free_nodemask(nm);
        return NULL;
    }
    numa_free_nodemask(nm);
    return p;
}

int main(int argc, char *argv[]) {
    int num_threads = 16, mode = MODE_READ, repeats = 40, node = 0, idx_node = -1;
    uint64_t gib = 1, clamp_mask = 0, norm_mask = 0, per_bank = 0;
    int flush_dist = 0, want_banks = 0;
    double duration = 0;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-t") && i + 1 < argc) num_threads = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-r") && i + 1 < argc) repeats = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-n") && i + 1 < argc) node = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-g") && i + 1 < argc) gib = strtoull(argv[++i], NULL, 0);
        else if (!strcmp(argv[i], "-i") && i + 1 < argc) idx_node = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-f") && i + 1 < argc) flush_dist = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-b") && i + 1 < argc) want_banks = atoi(argv[++i]);
        else if (!strcmp(argv[i], "-d") && i + 1 < argc) duration = atof(argv[++i]);
        else if (!strcmp(argv[i], "-M") && i + 1 < argc)
            per_bank = strtoull(argv[++i], NULL, 0);
        else if (!strcmp(argv[i], "-c") && i + 1 < argc)
            clamp_mask = strtoull(argv[++i], NULL, 0);
        else if (!strcmp(argv[i], "-C") && i + 1 < argc)
            norm_mask = strtoull(argv[++i], NULL, 0);
        else if (!strcmp(argv[i], "-m") && i + 1 < argc) {
            const char *v = argv[++i];
            mode = !strcmp(v, "rw") ? MODE_RW : !strcmp(v, "nt") ? MODE_NT : MODE_READ;
        }
        else {
            fprintf(stderr,
                    "Usage: %s [-t threads] [-m r|rw|nt] [-r repeats|0=auto] [-n node]\n"
                    "          [-g gib] [-c phys_mask] [-C norm_mask] [-i index_node]\n"
                    "          [-f dist] [-b banks] [-M lines_per_bank] [-d seconds]\n"
                    "  -g  mapping size in 1 GiB hugepages (default 1)\n"
                    "  -c  hex mask on the physical byte address; keeps lines with\n"
                    "      (phys & mask) == 0. Scrambled by the 12-way interleave, so\n"
                    "      this is a footprint/stride knob, not a bank knob.\n"
                    "  -C  hex mask on the NORMALIZED address (the r-th line this\n"
                    "      controller owns sits at r*64). Each clamped bank or\n"
                    "      bank-group bit halves the banks the stream can reach --\n"
                    "      this is the bank-parallelism knob.\n"
                    "  -i  node for the index array (default: node+1, off the node\n"
                    "      under test so its stream misses the controller measured)\n"
                    "  -d  run the loop for this many seconds instead of a fixed\n"
                    "      repeat count -- the only way one perf window fits both a\n"
                    "      1 GB/s point and a 30 GB/s one.\n"
                    "  -b  restrict the stream to N banks, found by row-conflict\n"
                    "      timing rather than by address bits (the UMC hashes the bank\n"
                    "      index, so no address mask can do this). -b 0 = off. Implies\n"
                    "      -f: the per-bank working sets are small.\n"
                    "  -M  lines per bank for -b. Default holds the total near\n"
                    "      constant across N (8192 lines) so the sweep varies banks and\n"
                    "      not footprint.\n"
                    "  -f  clflushopt the line accessed `dist` iterations ago, so every\n"
                    "      access misses to DRAM however small the clamped working set\n"
                    "      is. 0 = off. Validate it against -f 0 at clamp 0, where the\n"
                    "      set is already 5x L3 and the two must agree.\n",
                    argv[0]);
            return EXIT_FAILURE;
        }
    }
    if (num_threads <= 0) return fprintf(stderr, "threads must be >= 1\n"), EXIT_FAILURE;
    if (gib < 1 || gib > MAX_PAGES)
        return fprintf(stderr, "-g must be 1..%d\n", MAX_PAGES), EXIT_FAILURE;

    if (numa_available() < 0) return fprintf(stderr, "no numa\n"), EXIT_FAILURE;
    if (idx_node < 0) idx_node = (node + 1) % (numa_max_node() + 1);

    // cpus of the node that will own the page, in ascending order (physical cores
    // before their SMT siblings on this machine's enumeration).
    struct bitmask *cpus = numa_allocate_cpumask();
    if (numa_node_to_cpus(node, cpus) != 0) return perror("numa_node_to_cpus"), EXIT_FAILURE;
    int cpu_list[512], ncpus = 0;
    for (int c = 0; c < numa_num_configured_cpus() && ncpus < 512; c++)
        if (numa_bitmask_isbitset(cpus, c)) cpu_list[ncpus++] = c;
    numa_free_cpumask(cpus);
    if (ncpus == 0) return fprintf(stderr, "node %d has no cpus\n", node), EXIT_FAILURE;

    uint64_t total_bytes = gib * ONE_GB;
    uint64_t total_lines = total_bytes / CACHE_LINE_SIZE;
    void *ptr = mmap(NULL, total_bytes, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT), -1, 0);
    if (ptr == MAP_FAILED) return perror("mmap 1GB hugepages"), EXIT_FAILURE;

    struct bitmask *nodemask = numa_allocate_nodemask();
    numa_bitmask_setbit(nodemask, node);
    if (mbind(ptr, total_bytes, MPOL_BIND, nodemask->maskp, nodemask->size + 1, 0) < 0)
        return perror("mbind"), EXIT_FAILURE;
    numa_free_nodemask(nodemask);

    cacheline_t *mem_space = (cacheline_t *)ptr;
    memset(ptr, 1, total_bytes);
    for (uint64_t i = 0; i < total_lines; i++) _mm_clflush(&mem_space[i][0]);
    _mm_sfence();

    // Each 1 GiB page has its own physical base, so its own position in the 12 MB
    // interleave cycle. The predicate takes that offset, so the same physical
    // controller is selected in every page regardless of where the page landed.
    uint64_t phys[MAX_PAGES], shift[MAX_PAGES];
    for (uint64_t p = 0; p < gib; p++) {
        phys[p] = page_phys_base((char *)ptr + p * ONE_GB);
        shift[p] = (phys[p] / (1024 * 1024)) % 12;
    }
    printf("[*] %lu x 1 GiB hugepage(s) on node %d; phys base 0x%lx, 12MB cycle region %lu"
           " (last: 0x%lx / %lu)\n",
           gib, node, phys[0], shift[0], phys[gib - 1], shift[gib - 1]);

    // Pass 1: count the lines this controller owns that survive the clamp, so the
    // index array is allocated at exactly its size (it can be hundreds of MB).
    // Rank r counts this controller's lines in ascending physical order, so r * 64 is
    // the normalized address that -C clamps. The physical clamp does not renumber
    // ranks, so the two masks stay independent.
    uint64_t owned = 0, kept = 0;
    for (uint64_t i = 0; i < total_lines; i++) {
        uint64_t p = i / LINES_PER_GB;
        if (!is_block0_owner_cacheline(i % LINES_PER_GB, shift[p])) continue;
        uint64_t rank = owned++;
        if ((phys[p] + (i % LINES_PER_GB) * CACHE_LINE_SIZE) & clamp_mask) continue;
        if ((rank * CACHE_LINE_SIZE) & norm_mask) continue;
        kept++;
    }
    if (kept < (uint64_t)num_threads * LOOKAHEAD * 4)
        return fprintf(stderr, "clamps 0x%lx/0x%lx leave only %lu lines -- too few\n",
                       clamp_mask, norm_mask, kept), EXIT_FAILURE;

    uint32_t *master = bind_alloc(kept * sizeof(uint32_t), idx_node);
    if (!master) return fprintf(stderr, "index array alloc failed\n"), EXIT_FAILURE;
    uint64_t found = 0, rank = 0;
    for (uint64_t i = 0; i < total_lines; i++) {
        uint64_t p = i / LINES_PER_GB;
        if (!is_block0_owner_cacheline(i % LINES_PER_GB, shift[p])) continue;
        uint64_t r = rank++;
        if ((phys[p] + (i % LINES_PER_GB) * CACHE_LINE_SIZE) & clamp_mask) continue;
        if ((r * CACHE_LINE_SIZE) & norm_mask) continue;
        master[found++] = (uint32_t)i;
    }

    int banks_seen = 0;
    if (want_banks > 0) {
        if (want_banks > MAX_BANKS)
            return fprintf(stderr, "-b at most %d\n", MAX_BANKS), EXIT_FAILURE;
        // Total lines held near constant across N so the sweep varies banks, not
        // footprint: N banks x (BANK_TARGET_LINES / N) lines each.
        if (per_bank == 0) {
            per_bank = BANK_TARGET_LINES / want_banks;
            if (per_bank < 64) per_bank = 64;
        }
        uint32_t *bank_ws = bind_alloc((uint64_t)want_banks * per_bank * sizeof(uint32_t),
                                       idx_node);
        if (!bank_ws) return fprintf(stderr, "bank workload alloc failed\n"), EXIT_FAILURE;
        uint64_t nb = build_bank_workload(mem_space, master, kept, want_banks, per_bank,
                                          bank_ws, &banks_seen);
        if (!nb) return EXIT_FAILURE;
        munmap(master, kept * sizeof(uint32_t));
        master = bank_ws;
        kept = nb;
        if (!flush_dist && mode != MODE_NT) {
            flush_dist = 64;   // a few MB at most; without this it is an L3 measurement
            printf("[*] -b implies flush-behind; turned it on at 64\n");
        }
    }

    uint64_t workset = kept * CACHE_LINE_SIZE;
    uint64_t deadline_tsc = 0;
    if (duration > 0) {
        repeats = 1 << 30;
        deadline_tsc = __rdtsc() + (uint64_t)(duration * PROCESSOR_FREQ_GHZ * 1e9);
    } else if (repeats <= 0) {
        repeats = (int)(AUTO_TARGET_BYTES / workset + 1);
    }
    printf("[*] node %d, %d threads, mode %s, phys clamp 0x%lx norm clamp 0x%lx -> %lu of"
           " %lu owned lines kept (%.2f%% of mapping)\n",
           node, num_threads, mode == MODE_RW ? "rw (1r1w)" : mode == MODE_NT ? "nt (full-line NT store)" : "r",
           clamp_mask, norm_mask,
           kept, owned, 100.0 * kept / total_lines);
    printf("[*] working set %.1f MB = %.1fx the node's %llu MB L3; index array %.1f MB"
           " on node %d; %d repeats\n",
           workset / 1e6, (double)workset / NODE_L3_BYTES, NODE_L3_BYTES / (1024 * 1024),
           kept * 4 / 1e6, idx_node, repeats);
    if (flush_dist)
        printf("[*] flush-behind on: clflushopt %d accesses back, so every access is a"
               " DRAM miss\n", flush_dist);
    if (workset < 4 * NODE_L3_BYTES && !flush_dist)
        printf("[!] working set is under 4x L3 -- part of the stream may be served by"
               " cache, so read the DRAM rate off the counters, not the CPU-side number\n");

    pthread_barrier_init(&sync_barrier, NULL, num_threads);
    pthread_t threads[512];
    thread_args_t args[512];
    uint64_t per = kept / num_threads;
    for (int i = 0; i < num_threads; i++) {
        args[i] = (thread_args_t){.thread_id = i, .cpu = cpu_list[i % ncpus], .mode = mode,
                                  .repeats = repeats, .deadline_tsc = deadline_tsc,
                                  .flush_dist = flush_dist,
                                  .my_workload = &master[i * per],
                                  .workload_len = (i == num_threads - 1) ? kept - i * per : per,
                                  .mem_space = mem_space};
        pthread_create(&threads[i], NULL, memory_worker, &args[i]);
    }

    printf("Start perf collection\n");
    fflush(stdout);
    uint64_t maxc = 0, lines = 0;
    for (int i = 0; i < num_threads; i++) pthread_join(threads[i], NULL);
    printf("End perf collection\n");

    // Under -d the threads stop at a deadline and so finish different numbers of
    // passes; summing each thread's own bytes is the only figure that stays right.
    double touched = 0;
    for (int i = 0; i < num_threads; i++) {
        if (args[i].elapsed_cycles > maxc) maxc = args[i].elapsed_cycles;
        lines += args[i].workload_len;
        touched += (double)args[i].workload_len * args[i].reps_done;
    }
    double secs = (double)maxc / (PROCESSOR_FREQ_GHZ * 1e9);
    int reps_done = 0;
    for (int i = 0; i < num_threads; i++)
        if (args[i].reps_done > reps_done) reps_done = args[i].reps_done;
    double bytes = touched * CACHE_LINE_SIZE;
    printf("Lines/pass        : %lu  (%d passes)\n", lines, reps_done);
    printf("Elapsed           : %.4f s\n", secs);
    printf("CPU-side bandwidth: %.2f GB/s   (bytes the loop asked for; the controller\n"
           "                     also carries the writeback in rw mode, so DRAM traffic\n"
           "                     is ~2x this -- read it off the umc counters)\n",
           bytes / secs / 1e9);
    munmap(master, kept * sizeof(uint32_t));
    munmap(ptr, total_bytes);
    return EXIT_SUCCESS;
}
