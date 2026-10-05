// Register-only load generator: pinned threads, no memory traffic, fixed duration.
//
//   spin <scalar|zmmlight|zmmheavy> <seconds> <cpu,cpu,...>
//
// Used by uncore_sweep.py to separate "core power" from "HBM traffic" when looking at
// what lowers the mesh clock. Each thread runs an independent-chains loop in inline asm,
// so the instruction mix is fixed and the compiler cannot fold or remove it:
//   scalar     8 independent 64-bit imul chains + 4 add chains   (integer ALU, ~4 IPC)
//   zmmlight   8 independent 512-bit vpaddq/vpxorq chains          (light AVX-512)
//   zmmheavy   8 independent 512-bit vpmullq chains                (heavy AVX-512 multiply)
// Prints "Start perf collection" / "End perf collection" around the timed window, the
// same markers bandwidth_rand prints, so the sweep's parser treats both alike.
#define _GNU_SOURCE
#include <immintrin.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

enum { SCALAR, ZMMLIGHT, ZMMHEAVY, CLASS_BASE };
// Instruction classes (see classes[]): each loop is 8 independent op chains unrolled 8x
// (64 instructions per iteration of a 4096-iteration inner loop), so the loop overhead is
// ~4% of the instructions and the op, not its dependency chain, sets the pace.
static const char *classes[] = {"add", "imul", "crc", "load", "store", "zload", "vcmp",
                                "compress", "pack", "pf0", "bcast", "nop", "ymmadd", NULL};
static char l1buf[8192] __attribute__((aligned(64)));

static atomic_int stop_flag;
static pthread_barrier_t barrier;

struct targ { int cpu, mode; uint64_t sink; };

static void *worker(void *p) {
    struct targ *t = p;
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(t->cpu, &set);
    if (pthread_setaffinity_np(pthread_self(), sizeof set, &set)) perror("affinity");
    pthread_barrier_wait(&barrier);

    uint64_t s = 0;
    if (t->mode >= CLASS_BASE) {
        const char *cl = classes[t->mode - CLASS_BASE];
        char own[8192] __attribute__((aligned(64)));   // per-thread: a shared buffer makes the
        memset(own, 1, sizeof own);                    // store classes ping-pong cache lines
        char *b = own;
        uint64_t r0 = 1, r1 = 3, r2 = 5, r3 = 7, r4 = 9, r5 = 11, r6 = 13, r7 = 15, k = 0x9e3779b97f4a7c15ULL;
        __m512i z0 = _mm512_set1_epi64(1), z1 = _mm512_set1_epi64(3), z2 = _mm512_set1_epi64(5),
                z3 = _mm512_set1_epi64(7), z4 = _mm512_set1_epi64(9), z5 = _mm512_set1_epi64(11),
                z6 = _mm512_set1_epi64(13), z7 = _mm512_set1_epi64(15), zk = _mm512_set1_epi64(0x55);
        __mmask8 m0;
#define EIGHT(X) X X X X X X X X
#define R8 "+r"(r0), "+r"(r1), "+r"(r2), "+r"(r3), "+r"(r4), "+r"(r5), "+r"(r6), "+r"(r7)
#define R8IN "r"(r0), "r"(r1), "r"(r2), "r"(r3), "r"(r4), "r"(r5), "r"(r6), "r"(r7)
#define Z8 "+v"(z0), "+v"(z1), "+v"(z2), "+v"(z3), "+v"(z4), "+v"(z5), "+v"(z6), "+v"(z7)
        while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
            for (int i = 0; i < 4096; i++) {
                if (!strcmp(cl, "add"))
                    __asm__ volatile(EIGHT("add %[k],%0\n add %[k],%1\n add %[k],%2\n add %[k],%3\n add %[k],%4\n add %[k],%5\n add %[k],%6\n add %[k],%7\n")
                                     : R8 : [k] "r"(k));
                else if (!strcmp(cl, "imul"))
                    __asm__ volatile(EIGHT("imul %[k],%0\n imul %[k],%1\n imul %[k],%2\n imul %[k],%3\n imul %[k],%4\n imul %[k],%5\n imul %[k],%6\n imul %[k],%7\n")
                                     : R8 : [k] "r"(k));
                else if (!strcmp(cl, "crc"))
                    __asm__ volatile(EIGHT("crc32q %[k],%0\n crc32q %[k],%1\n crc32q %[k],%2\n crc32q %[k],%3\n crc32q %[k],%4\n crc32q %[k],%5\n crc32q %[k],%6\n crc32q %[k],%7\n")
                                     : R8 : [k] "r"(k));
                else if (!strcmp(cl, "load"))
                    __asm__ volatile(EIGHT("mov 0(%[b]),%0\n mov 64(%[b]),%1\n mov 128(%[b]),%2\n mov 192(%[b]),%3\n mov 256(%[b]),%4\n mov 320(%[b]),%5\n mov 384(%[b]),%6\n mov 448(%[b]),%7\n")
                                     : "=&r"(r0), "=&r"(r1), "=&r"(r2), "=&r"(r3), "=&r"(r4), "=&r"(r5), "=&r"(r6), "=&r"(r7) : [b] "r"(b) : "memory");
                else if (!strcmp(cl, "store"))
                    __asm__ volatile(EIGHT("mov %0,0(%[b])\n mov %1,64(%[b])\n mov %2,128(%[b])\n mov %3,192(%[b])\n mov %4,256(%[b])\n mov %5,320(%[b])\n mov %6,384(%[b])\n mov %7,448(%[b])\n")
                                     : : R8IN, [b] "r"(b) : "memory");
                else if (!strcmp(cl, "zload"))
                    __asm__ volatile(EIGHT("vmovdqa64 0(%[b]),%0\n vmovdqa64 64(%[b]),%1\n vmovdqa64 128(%[b]),%2\n vmovdqa64 192(%[b]),%3\n vmovdqa64 256(%[b]),%4\n vmovdqa64 320(%[b]),%5\n vmovdqa64 384(%[b]),%6\n vmovdqa64 448(%[b]),%7\n")
                                     : "=&v"(z0), "=&v"(z1), "=&v"(z2), "=&v"(z3), "=&v"(z4), "=&v"(z5), "=&v"(z6), "=&v"(z7) : [b] "r"(b) : "memory");
                else if (!strcmp(cl, "vcmp"))
                    __asm__ volatile(EIGHT("vpcmpeqq %[z],%0,%%k1\n vpcmpeqq %[z],%1,%%k2\n vpcmpeqq %[z],%2,%%k3\n vpcmpeqq %[z],%3,%%k4\n vpcmpeqq %[z],%4,%%k5\n vpcmpeqq %[z],%5,%%k6\n vpcmpeqq %[z],%6,%%k1\n vpcmpeqq %[z],%7,%%k2\n")
                                     : : "v"(z0), "v"(z1), "v"(z2), "v"(z3), "v"(z4), "v"(z5), "v"(z6), "v"(z7), [z] "v"(zk) : "k1", "k2", "k3", "k4", "k5", "k6");
                else if (!strcmp(cl, "compress"))
                    __asm__ volatile("kmovb %[m],%%k1\n" EIGHT("vpcompressq %0,%%zmm9%{%%k1%}%{z%}\n vpcompressq %1,%%zmm10%{%%k1%}%{z%}\n vpcompressq %2,%%zmm11%{%%k1%}%{z%}\n vpcompressq %3,%%zmm12%{%%k1%}%{z%}\n vpcompressq %4,%%zmm13%{%%k1%}%{z%}\n vpcompressq %5,%%zmm14%{%%k1%}%{z%}\n vpcompressq %6,%%zmm15%{%%k1%}%{z%}\n vpcompressq %7,%%zmm16%{%%k1%}%{z%}\n")
                                     : : "v"(z0), "v"(z1), "v"(z2), "v"(z3), "v"(z4), "v"(z5), "v"(z6), "v"(z7), [m] "r"(0x2aU)
                                     : "k1", "zmm9", "zmm10", "zmm11", "zmm12", "zmm13", "zmm14", "zmm15", "zmm16");
                else if (!strcmp(cl, "pack"))
                    __asm__ volatile(EIGHT("vmovd %%r8d,%%xmm17\n vpinsrd $1,0(%[b]),%%xmm17,%%xmm18\n vmovq %%xmm18,64(%[b])\n vmovd %%r9d,%%xmm19\n vpinsrd $1,128(%[b]),%%xmm19,%%xmm20\n vmovq %%xmm20,192(%[b])\n vmovd %%r10d,%%xmm21\n vpinsrd $1,256(%[b]),%%xmm21,%%xmm22\n")
                                     : : [b] "r"(b) : "memory", "xmm17", "xmm18", "xmm19", "xmm20", "xmm21", "xmm22", "r8", "r9", "r10");
                else if (!strcmp(cl, "pf0"))
                    __asm__ volatile(EIGHT("prefetcht0 0(%[b])\n prefetcht0 64(%[b])\n prefetcht0 128(%[b])\n prefetcht0 192(%[b])\n prefetcht0 256(%[b])\n prefetcht0 320(%[b])\n prefetcht0 384(%[b])\n prefetcht0 448(%[b])\n")
                                     : : [b] "r"(b) : "memory");
                else if (!strcmp(cl, "bcast"))
                    __asm__ volatile(EIGHT("vpbroadcastq %[k],%0\n vpbroadcastq %[k],%1\n vpbroadcastq %[k],%2\n vpbroadcastq %[k],%3\n vpbroadcastq %[k],%4\n vpbroadcastq %[k],%5\n vpbroadcastq %[k],%6\n vpbroadcastq %[k],%7\n")
                                     : "=&v"(z0), "=&v"(z1), "=&v"(z2), "=&v"(z3), "=&v"(z4), "=&v"(z5), "=&v"(z6), "=&v"(z7) : [k] "r"(k));
                else if (!strcmp(cl, "ymmadd"))
                    __asm__ volatile(EIGHT("vpaddq %%ymm0,%%ymm1,%%ymm1\n vpaddq %%ymm0,%%ymm2,%%ymm2\n vpaddq %%ymm0,%%ymm3,%%ymm3\n vpaddq %%ymm0,%%ymm4,%%ymm4\n vpaddq %%ymm0,%%ymm5,%%ymm5\n vpaddq %%ymm0,%%ymm6,%%ymm6\n vpaddq %%ymm0,%%ymm7,%%ymm7\n vpaddq %%ymm0,%%ymm8,%%ymm8\n")
                                     : : : "ymm0", "ymm1", "ymm2", "ymm3", "ymm4", "ymm5", "ymm6", "ymm7", "ymm8");
                else  /* nop */
                    __asm__ volatile(EIGHT("nop\n nop\n nop\n nop\n nop\n nop\n nop\n nop\n"));
            }
        }
        (void)m0;
        s = r0 ^ r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ r7 ^ (uint64_t)_mm_cvtsi128_si64(_mm512_castsi512_si128(
              _mm512_xor_si512(_mm512_xor_si512(z0, z1), _mm512_xor_si512(z2, z3))));
    } else if (t->mode == SCALAR) {
        uint64_t a0 = 1, a1 = 3, a2 = 5, a3 = 7, a4 = 9, a5 = 11, a6 = 13, a7 = 15;
        uint64_t b0 = 1, b1 = 2, b2 = 3, b3 = 4;
        while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
            for (int i = 0; i < 4096; i++)
                __asm__ volatile(
                    "imul %[k], %[a0]\n imul %[k], %[a1]\n imul %[k], %[a2]\n imul %[k], %[a3]\n"
                    "imul %[k], %[a4]\n imul %[k], %[a5]\n imul %[k], %[a6]\n imul %[k], %[a7]\n"
                    "add %[k], %[b0]\n add %[k], %[b1]\n add %[k], %[b2]\n add %[k], %[b3]\n"
                    : [a0] "+r"(a0), [a1] "+r"(a1), [a2] "+r"(a2), [a3] "+r"(a3),
                      [a4] "+r"(a4), [a5] "+r"(a5), [a6] "+r"(a6), [a7] "+r"(a7),
                      [b0] "+r"(b0), [b1] "+r"(b1), [b2] "+r"(b2), [b3] "+r"(b3)
                    : [k] "r"((uint64_t)0x9e3779b97f4a7c15ULL));
        }
        s = a0 ^ a1 ^ a2 ^ a3 ^ a4 ^ a5 ^ a6 ^ a7 ^ b0 ^ b1 ^ b2 ^ b3;
    } else {
        __m512i v0 = _mm512_set1_epi64(1), v1 = _mm512_set1_epi64(3), v2 = _mm512_set1_epi64(5),
                v3 = _mm512_set1_epi64(7), v4 = _mm512_set1_epi64(9), v5 = _mm512_set1_epi64(11),
                v6 = _mm512_set1_epi64(13), v7 = _mm512_set1_epi64(15);
        const __m512i k = _mm512_set1_epi64(0x100000001b3LL);
        if (t->mode == ZMMHEAVY) {
            while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
                for (int i = 0; i < 4096; i++)
                    __asm__ volatile(
                        "vpmullq %[k], %[v0], %[v0]\n vpmullq %[k], %[v1], %[v1]\n"
                        "vpmullq %[k], %[v2], %[v2]\n vpmullq %[k], %[v3], %[v3]\n"
                        "vpmullq %[k], %[v4], %[v4]\n vpmullq %[k], %[v5], %[v5]\n"
                        "vpmullq %[k], %[v6], %[v6]\n vpmullq %[k], %[v7], %[v7]\n"
                        : [v0] "+v"(v0), [v1] "+v"(v1), [v2] "+v"(v2), [v3] "+v"(v3),
                          [v4] "+v"(v4), [v5] "+v"(v5), [v6] "+v"(v6), [v7] "+v"(v7)
                        : [k] "v"(k));
            }
        } else {
            while (!atomic_load_explicit(&stop_flag, memory_order_relaxed)) {
                for (int i = 0; i < 4096; i++)
                    __asm__ volatile(
                        "vpaddq %[k], %[v0], %[v0]\n vpxorq %[k], %[v1], %[v1]\n"
                        "vpaddq %[k], %[v2], %[v2]\n vpxorq %[k], %[v3], %[v3]\n"
                        "vpaddq %[k], %[v4], %[v4]\n vpxorq %[k], %[v5], %[v5]\n"
                        "vpaddq %[k], %[v6], %[v6]\n vpxorq %[k], %[v7], %[v7]\n"
                        : [v0] "+v"(v0), [v1] "+v"(v1), [v2] "+v"(v2), [v3] "+v"(v3),
                          [v4] "+v"(v4), [v5] "+v"(v5), [v6] "+v"(v6), [v7] "+v"(v7)
                        : [k] "v"(k));
            }
        }
        __m512i x = _mm512_xor_si512(_mm512_xor_si512(_mm512_xor_si512(v0, v1), _mm512_xor_si512(v2, v3)),
                                     _mm512_xor_si512(_mm512_xor_si512(v4, v5), _mm512_xor_si512(v6, v7)));
        s = (uint64_t)_mm_cvtsi128_si64(_mm512_castsi512_si128(x));
    }
    t->sink = s;
    return NULL;
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s <scalar|zmmlight|zmmheavy> <seconds> <cpu,cpu,...>\n", argv[0]);
        return 1;
    }
    int mode = !strcmp(argv[1], "scalar") ? SCALAR : !strcmp(argv[1], "zmmlight") ? ZMMLIGHT
             : !strcmp(argv[1], "zmmheavy") ? ZMMHEAVY : -1;
    for (int k = 0; classes[k] && mode < 0; k++)
        if (!strcmp(argv[1], classes[k])) mode = CLASS_BASE + k;
    if (mode < 0) { fprintf(stderr, "unknown mode %s\n", argv[1]); return 1; }
    double secs = atof(argv[2]);

    int cpus[1024], n = 0;
    for (char *tok = strtok(argv[3], ","); tok && n < 1024; tok = strtok(NULL, ","))
        cpus[n++] = atoi(tok);

    pthread_t th[1024];
    struct targ ta[1024];
    pthread_barrier_init(&barrier, NULL, n + 1);
    for (int i = 0; i < n; i++) {
        ta[i] = (struct targ){.cpu = cpus[i], .mode = mode};
        pthread_create(&th[i], NULL, worker, &ta[i]);
    }
    pthread_barrier_wait(&barrier);
    printf("Start perf collection\n");
    fflush(stdout);
    usleep((useconds_t)(secs * 1e6));
    atomic_store(&stop_flag, 1);
    printf("End perf collection\n");
    fflush(stdout);
    uint64_t sink = 0;
    for (int i = 0; i < n; i++) {
        pthread_join(th[i], NULL);
        sink ^= ta[i].sink;
    }
    printf("threads %d mode %s seconds %.1f sink %llx\n", n, argv[1], secs, (unsigned long long)sink);
    return 0;
}
