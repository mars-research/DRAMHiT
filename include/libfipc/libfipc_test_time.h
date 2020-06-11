/**
 * @File     : libfipc_test_time.h
 * @Author   : Charles Jacobsen
 * @Author   : Abdullah Younis
 * @Copyright: University of Utah
 *
 * This library contains timing helper functions for the several fipc tests.
 *
 * NOTE: This library assumes an x86 architecture.
 */

#ifndef LIBFIPC_TEST_TIME_LIBRARY_LOCK
#define LIBFIPC_TEST_TIME_LIBRARY_LOCK

static inline
uint64_t RDTSC_START ( void )
{

	unsigned cycles_low, cycles_high;

	asm volatile ( "CPUID\n\t"
				   "RDTSC\n\t"
				   "mov %%edx, %0\n\t"
				   "mov %%eax, %1\n\t"
				   : "=r" (cycles_high), "=r" (cycles_low)::
				   "%rax", "%rbx", "%rcx", "%rdx");

	return ((uint64_t) cycles_high << 32) | cycles_low;
}

/**
 * CITE: http://www.intel.com/content/www/us/en/embedded/training/ia-32-ia-64-benchmark-code-execution-paper.html
 */
static inline
uint64_t RDTSCP ( void )
{
	unsigned cycles_low, cycles_high;

	asm volatile( "RDTSCP\n\t"
				  "mov %%edx, %0\n\t"
				  "mov %%eax, %1\n\t"
				  "CPUID\n\t": "=r" (cycles_high), "=r" (cycles_low)::
				  "%rax", "%rbx", "%rcx", "%rdx");
	
	return ((uint64_t) cycles_high << 32) | cycles_low;
}

/**
 * This function returns the average time spent collecting timestamps.
 */
static inline
uint64_t fipc_test_time_get_correction ( void )
{
	register CACHE_ALIGNED uint64_t start;
	register CACHE_ALIGNED uint64_t end;
	register CACHE_ALIGNED uint64_t sum;
	register CACHE_ALIGNED uint64_t i;

	for ( sum = 0, i = 0; i < 100000; ++i )
	{
		start = RDTSC_START();
		end   = RDTSCP();
		sum  += end - start;
	}

	return sum / i;
}

/**
 * This function returns a time stamp with no preceding fence instruction.
 */
static inline
uint64_t fipc_test_time_get_timestamp ( void )
{
	unsigned int low, high;

	asm volatile("rdtsc" : "=a" (low), "=d" (high));

	return low | ((uint64_t)high) << 32;	
}

/**
 * This function returns a time stamp with a preceding load fence instruction.
 */
static inline
uint64_t fipc_test_time_get_timestamp_lf ( void )
{
	
	fipc_test_lfence();
	return fipc_test_time_get_timestamp();
}

/**
 * This function returns a time stamp with a preceding store fence instruction.
 */
static inline
uint64_t fipc_test_time_get_timestamp_sf ( void )
{
	fipc_test_sfence();
	
	return fipc_test_time_get_timestamp();
}

/**
 * This function returns a time stamp a preceding memory fence instruction.
 */
static inline
uint64_t fipc_test_time_get_timestamp_mf ( void )
{
	fipc_test_mfence();
	return fipc_test_time_get_timestamp();
}

/**
 * This function waits for atleast ticks clock cycles.
 */
static inline
void fipc_test_time_wait_ticks ( uint64_t ticks )
{
		uint64_t current_time;
		uint64_t time = fipc_test_time_get_timestamp();
		time += ticks;
		do
		{
			current_time = fipc_test_time_get_timestamp();
		}
		while ( current_time < time );
}

#endif
