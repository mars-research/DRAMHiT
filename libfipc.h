/**
 * @File     : libfipc_test_time.h
 * @Author   : Charles Jacobsen
 * @Author   : Abdullah Younis
 * @Copyright: University of Utah
 *
 * This library contains timing and other helper functions for the several fipc
 * tests.
 *
 * NOTE: This library assumes an x86 architecture.
 */

#ifndef LIBFIPC
#define LIBFIPC

#define fipc_test_FAI(X) __sync_fetch_and_add(&X, 1)
#define fipc_test_FAD(X) __sync_fetch_and_add(&X, -1)
#define fipc_test_mfence() asm volatile("mfence" : :)
#define fipc_test_pause() asm volatile("pause\n" : : : "memory");
#define fipc_test_CAS(a, b, c) __sync_bool_compare_and_swap(a, b, c);

static inline uint64_t RDTSC_START(void)
{
  unsigned cycles_low, cycles_high;

  asm volatile(
      "CPUID\n\t"
      "RDTSC\n\t"
      "mov %%edx, %0\n\t"
      "mov %%eax, %1\n\t"
      : "=r"(cycles_high), "=r"(cycles_low)::"%rax", "%rbx", "%rcx", "%rdx");

  return ((uint64_t)cycles_high << 32) | cycles_low;
}

/**
 * CITE:
 * http://www.intel.com/content/www/us/en/embedded/training/ia-32-ia-64-benchmark-code-execution-paper.html
 */
static inline uint64_t RDTSCP(void)
{
  unsigned cycles_low, cycles_high;

  asm volatile(
      "RDTSCP\n\t"
      "mov %%edx, %0\n\t"
      "mov %%eax, %1\n\t"
      "CPUID\n\t"
      : "=r"(cycles_high), "=r"(cycles_low)::"%rax", "%rbx", "%rcx", "%rdx");

  return ((uint64_t)cycles_high << 32) | cycles_low;
}

#endif
