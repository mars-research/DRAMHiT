#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>


// =======================
// XORWOW state
// =======================
typedef struct {
    uint32_t a, b, c, d;
    uint32_t counter;
} xorwow_state;

uint32_t xorwow(xorwow_state *state) {
    /* Algorithm "xorwow" from p. 5 of Marsaglia, "Xorshift RNGs" */
    uint32_t t = state->d;
    uint32_t const s = state->a;
    state->d = state->c;
    state->c = state->b;
    state->b = s;

    t ^= t >> 2;
    t ^= t << 1;
    t ^= s ^ (s << 4);
    state->a = t;

    state->counter += 362437;
    return t + state->counter;
}

static inline void xorwow_init(xorwow_state *s) {
    // Simple deterministic seeding from input integer
    s->a = rand();
    s->b = rand();
    s->c = rand();
    s->d = rand();
    s->counter = rand();
}

xorwow_state st;

// Wrapper to treat XORWOW as a "hash function"
uint32_t hash_xorwow(uint32_t x) {
    return xorwow(&st);
}

// =======================
// Other hash functions
// =======================
static inline uint32_t hash_knuth(uint32_t x) {
    return x * 2654435761u;
}

static inline uint32_t hash_wang(uint32_t x) {
    x = (x ^ 61) ^ (x >> 16);
    x = x + (x << 3);
    x = x ^ (x >> 4);
    x = x * 0x27d4eb2d;
    x = x ^ (x >> 15);
    return x;
}

static inline uint32_t hash_xorshift(uint32_t x) {
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return x;
}

static inline uint32_t hash_jenkins(uint32_t x) {
    x += (x << 12);
    x ^= (x >> 22);
    x += (x << 4);
    x ^= (x >> 9);
    x += (x << 10);
    x ^= (x >> 2);
    x += (x << 7);
    x ^= (x >> 12);
    return x;
}

// =======================
// Collision test utility
// =======================
typedef uint32_t (*hash_func_t)(uint32_t);

static int cmp_double(const void *a, const void *b) {
    double da = *(const double *)a;
    double db = *(const double *)b;
    return (da > db) - (da < db); // returns +1, 0, or -1
}

double ks_test_uniform(uint32_t (*h)(uint32_t), size_t n) {
    double *vals = malloc(n * sizeof(double));
    if (!vals) {
        perror("malloc");
        exit(1);
    }

    for (size_t i = 0; i < n; i++) {
        uint32_t hv = h((uint32_t)i);
        vals[i] = (double)hv / (double)UINT32_MAX; // normalize to [0,1)
    }

    qsort(vals, n, sizeof(double), cmp_double);

    double D = 0.0;
    for (size_t i = 0; i < n; i++) {
        double F_emp = (double)(i + 1) / (double)n;
        double diff1 = fabs(F_emp - vals[i]);
        double diff2 = fabs(vals[i] - (double)i / (double)n);
        if (diff1 > D) D = diff1;
        if (diff2 > D) D = diff2;
    }

    free(vals);
    return D;
}



// =======================
// Main
// =======================
int main(int argc, char **argv) {
    size_t N = 1000000; // default: 1 million
    if (argc > 1) N = strtoull(argv[1], NULL, 10);

    printf("Testing with N = %zu sequential integers\n", N);

    struct {
        const char *name;
        hash_func_t func;
    } hashes[] = {
        { "Knuth multiplicative", hash_knuth },
        { "Thomas Wang mix",      hash_wang },
        { "Xorshift",             hash_xorshift },
        { "Jenkins mix",          hash_jenkins },
        { "XORWOW",               hash_xorwow },
    };

    xorwow_init(&st);


    for (size_t i = 0; i < sizeof(hashes)/sizeof(hashes[0]); i++) {
        printf("%-12s:\n", hashes[i].name);
        clock_t start = clock();
        double D = ks_test_uniform(hashes[i].func, N);
        clock_t end = clock();
        printf("  Time: %.2f sec D %f\n", (double)(end - start) / CLOCKS_PER_SEC, D);
    }


    return 0;
}


