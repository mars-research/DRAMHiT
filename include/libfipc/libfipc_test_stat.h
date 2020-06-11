/**
 * @File     : libfipc_test_stat.h
 * @Author   : Abdullah Younis
 * @Copyright: University of Utah
 *
 * This library contains statistical helper functions for the several fipc tests.
 *
 * NOTE: This library assumes an x86 architecture.
 */

#ifndef LIBFIPC_TEST_STAT_LIBRARY_LOCK
#define LIBFIPC_TEST_STAT_LIBRARY_LOCK

#define ABSOLUTE(x) ((x) > 0 ? (x) : -(x))
#define INF  9223372036854775807
#define NINF -9223372036854775807

#define DTOC(x)     ((char)('0' + (x)))

#include <math.h>

typedef struct stats_t
{
	uint64_t N;			// The size of the sample set

	double mean;		// The mean of the data
	double stdev;		// The standard deviation
	double abdev;		// The mean absolute deviation
	int64_t min;		// The minimum value
	int64_t max;		// The maximum value

	int64_t tolerance;	// The tolerance level used in classifying outliers
	uint64_t outliers;	// The number of data points classified as outliers

	double norm_mean;	// The mean of the data without the outliers
	double norm_stdev;	// The standard deviation without the outliers
	double norm_abdev;	// The mean absolute deviation without the outliers
	int64_t norm_min;	// The minimum value without the outliers
	int64_t norm_max;	// The maximum value without the outliers

} stats_t;

/**
 * This function returns the mean of the sample set.
 */
static inline
double fipc_test_stat_get_mean ( int64_t* sample_set, uint64_t sample_size )
{
	register double sum;
	register uint64_t i;

	for ( sum = 0, i = 0; i < sample_size; ++i )
	{
		sum += sample_set[i];
	}

	return sum / (double) sample_size;
}

/**
 * This function returns a tolerance level, the suggested max deviation
 * from the mean before being classified as an outlier.
 */
static inline
int64_t fipc_test_stat_get_tolerance ( int64_t* sample_set, uint64_t sample_size )
{
	register float sum;
	register float mean;
	register uint64_t i;

	// For a quick sketch idea of the data, only go through 1/16 of it.
	if ( sample_size > 16 )
		sample_size >>= 4;

	for ( sum = 0, i = 0; i < sample_size; ++i )
	{
		sum += sample_set[i];
	}

	mean = sum / (float) sample_size;

	for ( sum = 0, i = 0; i < sample_size; ++i )
	{
		sum += ABSOLUTE( sample_set[i] - mean );
	}

	float sketch_abdev = sum / (float) sample_size;

	if ( sketch_abdev > INF / 32 )
		return INF;

	return 5 * sketch_abdev;
}

/**
 * This function populates the stat data structure with statistics.
 */
static inline
int fipc_test_stat_calculate_stats ( int64_t* sample_set, uint64_t sample_size, stats_t* stat )
{
	// Error Checking
	if ( stat == NULL || sample_size == 0 )
		return -1;

	stat->N    = sample_size;
	stat->mean = fipc_test_stat_get_mean ( sample_set, sample_size );
	stat->tolerance = fipc_test_stat_get_tolerance ( sample_set, sample_size );

	int64_t upper_thresh = stat->tolerance == INF ? INF : stat->mean + stat->tolerance;
	int64_t lower_thresh = stat->tolerance == INF ? NINF : stat->mean - stat->tolerance;

	// Temporary Values
	stat->min = INF;
	stat->max = NINF;
	stat->norm_min = INF;
	stat->norm_max = NINF;
	stat->outliers = 0;

	register double stdevSum = 0;
	register double abdevSum = 0;
	register double normSum = 0;
	register double normStdevSum = 0;
	register double normAbdevSum = 0;
	register uint64_t i;

	for ( i = 0; i < sample_size; ++i )
	{
		double dev = ABSOLUTE( sample_set[i] - stat->mean );
		abdevSum += dev;
		stdevSum += dev*dev;

		if ( sample_set[i] < stat->min )
			stat->min = sample_set[i];

		if ( sample_set[i] > stat->max )
			stat->max = sample_set[i];

		if ( sample_set[i] > upper_thresh || sample_set[i] < lower_thresh )
		{
			stat->outliers++;
		}
		else
		{
			normSum += sample_set[i];

			if ( sample_set[i] > stat->norm_max )
				stat->norm_max = sample_set[i];

			if ( sample_set[i] < stat->norm_min )
				stat->norm_min = sample_set[i];
		}
	}

	stat->stdev     = sqrt( stdevSum / (double) sample_size );
	stat->abdev     = abdevSum / (double) sample_size;
	stat->norm_mean = normSum / (double) ( sample_size - stat->outliers );

	for ( i = 0; i < sample_size; ++i )
	{
		if ( sample_set[i] <= upper_thresh && sample_set[i] >= lower_thresh )
		{
			double dev = ABSOLUTE( sample_set[i] - stat->norm_mean );
			normAbdevSum += dev;
			normStdevSum += dev*dev;
		}
	}

	stat->norm_stdev = sqrt( normStdevSum / (double) ( sample_size - stat->outliers ) );
	stat->norm_abdev = normAbdevSum / (double) ( sample_size - stat->outliers );

	return 0;
}

/**
 * This function returns the value with the specified zScore.
 */
static inline
int64_t fipc_test_stat_zrange_value ( stats_t* stat, double zScore )
{
	return stat->norm_mean + zScore*stat->norm_stdev;
}

/**
 * This function returns the zScore with the specified value.
 */
static inline
double fipc_test_stat_zscore_value ( stats_t* stat, int64_t value )
{
	if ( stat->norm_stdev == 0 )
		return 0;

	return (double)(value - stat->norm_mean) / stat->norm_stdev;
}

/**
 * This function counts the number of data points in the zScore range (inclusive).
 */
static inline
uint64_t fipc_test_stat_count_in_range ( int64_t* sample_set, uint64_t sample_size, int64_t min, int64_t max )
{
	register uint64_t i;
	register uint64_t count;

	for ( count = 0, i = 0; i < sample_size; ++i )
		if ( sample_set[i] >= min && sample_set[i] <= max )
			++count;

	return count;
}

/**
 * This function truncates (or pads) the given int64_t into a string with given width
 */
static inline
int fipc_test_stat_truncate ( int64_t value, char* buf, uint64_t width )
{
	// Error Checking
	if ( width == 0 )
		return -1;

	// Negative Symbol
	if ( value < 0 )
	{
		buf[0] = '-';
		return fipc_test_stat_truncate ( value <= NINF ? INF : -value, ++buf, --width );
	}

	uint64_t buf_index   = 0;
	uint64_t digit_index = 0;

	char digits[21];
	memset( digits, 0, 21 );

	// Turn value into char array
	while ( value > 0 && digit_index < 20 )
	{
		int64_t digit = value % 10;
		value = value / 10;
		digits[digit_index++] = DTOC(digit);
	}

	// Reverse it into buf
	while ( width > 0 && digit_index >= 1 )
	{
		buf[buf_index++] = digits[--digit_index];
		--width;
	}

	// Append suffix, if needed
	if ( digit_index >= 1 )
	{
		int chars_deleted = 3 - (digit_index % 3);

		buf_index   -= chars_deleted;
		width       += chars_deleted;
		digit_index += chars_deleted;

		if ( buf_index < 0 )
			return -1;

		char suffix = ' ';

		if ( digit_index >= 18 )
			suffix = 'E';
		else if ( digit_index >= 15 )
			suffix = 'P';
		else if ( digit_index >= 12 )
			suffix = 'T';
		else if ( digit_index >= 9 )
			suffix = 'G';
		else if ( digit_index >= 6 )
			suffix = 'M';
		else if ( digit_index >= 3 )
			suffix = 'K';

		buf[buf_index++] = suffix;
		width--;
	}

	// Pad with spaces
	while ( width > 0 )
	{
		buf[buf_index++] = ' ';
		--width;
	}

	return 0;
}

/**
 * This function prints one bar in a histogram corresponding to the range given by zScoreMin and zScoreMax.
 */
static inline
int fipc_test_stat_print_zrange_bar ( int64_t* sample_set, uint64_t sample_size, stats_t* stat, double zScoreMin, double zScoreMax )
{
	char bar[33];
	char count_str[13];
	char value_below_str[14];
	char value_above_str[14];

	bar[32]             = '\0';
	count_str[12]       = '\0';
	value_below_str[13] = '\0';
	value_above_str[13] = '\0';

	int64_t value_below = fipc_test_stat_zrange_value( stat, zScoreMin );
	int64_t value_above = fipc_test_stat_zrange_value( stat, zScoreMax );

	// Calculate the number of 'X's
	uint64_t count   = fipc_test_stat_count_in_range( sample_set, sample_size, value_below, value_above );
	uint64_t X_value = sample_size >> 5 == 0 ? 1 : sample_size >> 5;
	uint64_t X_count = count / X_value;

	// Construct the bar string
	memset( bar, 'X', X_count );
	memset( bar + X_count, ' ', 32 - X_count );

	fipc_test_stat_truncate( count, count_str, 12 );
	fipc_test_stat_truncate( value_below, value_below_str, 13 );
	fipc_test_stat_truncate( value_above, value_above_str, 13 );


	printf ( "%s -> %s : %s : %s\n", value_below_str, value_above_str, bar, count_str );
	return 0;
}

/**
 * This function prints a histogram of the data.
 */
static inline
int fipc_test_stat_print_zhistogram ( int64_t* sample_set, uint64_t sample_size, stats_t* stat )
{
	double zNINF = fipc_test_stat_zscore_value( stat, NINF );
	double zINF  = fipc_test_stat_zscore_value( stat, INF  );

	double i = fipc_test_stat_zscore_value( stat, stat->min );
	i = i < -3 ? -3 : i; // i = max(-3, min)
	i = i < zNINF ? zNINF : i; // i = max(i, z(NINF))

	double maxZ = fipc_test_stat_zscore_value( stat, stat->max );
	maxZ = maxZ > 3 ? 3 : maxZ; // maxZ = min(3, max)
	maxZ = maxZ > zINF ? zINF : maxZ; // maxZ = min(maxZ, z(INF))

	if ( i >= maxZ )
		fipc_test_stat_print_zrange_bar( sample_set, sample_size, stat, -0.5, 0.5 );

	for ( ; i < maxZ; i += 0.5 )
		fipc_test_stat_print_zrange_bar( sample_set, sample_size, stat, i, ( i+0.5 <= maxZ ? i+0.5 : maxZ ) );

	return 0;
}

/**
 * This function prints statistics of the sample set to stdout.
 */
static inline
int fipc_test_stat_print_stats ( int64_t* sample_set, uint64_t sample_size, stats_t* stat )
{
	printf ( "-------------------------------------------------------------------------------\n" );
	printf ( "Sample Size            : %lu\n", stat->N );
	printf ( "Average value          : %.0f\n", stat->mean );
	printf ( "Minimum value          : %ld\n", stat->min );
	printf ( "Maximum value          : %ld\n", stat->max );
	printf ( "Standard Deviation     : %.0f\n", stat->stdev );
	printf ( "Mean Absolute Deviation: %.0f\n", stat->abdev );
	printf ( "\n" );

	printf ( "Outlier Count   : %lu\n", stat->outliers );
	if ( stat->outliers > 0 )
	{
		printf ( "Without Outliers:\n");
		printf ( "\tAverage value          : %.0f\n", stat->norm_mean );
		printf ( "\tMinimum value          : %ld\n", stat->norm_min );
		printf ( "\tMaximum value          : %ld\n", stat->norm_max );
		printf ( "\tStandard Deviation     : %.0f\n", stat->norm_stdev );
		printf ( "\tMean Absolute Deviation: %.0f\n", stat->norm_abdev );
	}
	printf ( "\n" );

	fipc_test_stat_print_zhistogram( sample_set, sample_size, stat );
	printf ( "\n" );

	printf ( "Summary:\n");

	char min[15];
	char max[15];
	char mean[15];

	memset( min, 0, 15 );
	memset( max, 0, 15 );
	memset( mean, 0, 15 );

	fipc_test_stat_truncate( stat->min, min, 14 );
	fipc_test_stat_truncate( stat->max, max, 14 );
	fipc_test_stat_truncate( stat->mean, mean, 14 );

	printf ( "min : %s || max : %s || mean : %s\n", min, max, mean );

	if ( stat->outliers > 0 )
	{
		memset( min, 0, 15 );
		memset( max, 0, 15 );
		memset( mean, 0, 15 );

		fipc_test_stat_truncate( stat->norm_min, min, 14 );
		fipc_test_stat_truncate( stat->norm_max, max, 14 );
		fipc_test_stat_truncate( stat->norm_mean, mean, 14 );

		printf ( "Nmin: %s || Nmax: %s || Nmean: %s\n", min, max, mean );
	}
	printf ( "-------------------------------------------------------------------------------\n" );

	return 0;
}

/**
 * This function prints a specified amount of raw data.
 */
static inline
int fipc_test_stat_print_raw ( int64_t* sample_set, uint64_t sample_size, uint64_t print_count )
{
	if ( print_count > sample_size )
		print_count = sample_size;

	int i;
	for ( i = 0; i < print_count; ++i )
		printf ( "%d.\t %ld\n", i, sample_set[i] );

	return 0;
}

/**
 * This function calculates and prints statistics of the given sample set.
 */
static inline
int fipc_test_stat_get_and_print_stats ( int64_t* sample_set, uint64_t sample_size )
{
	int error_code = 0;

	stats_t stats;
	error_code = fipc_test_stat_calculate_stats ( sample_set, sample_size, &stats );

	if ( error_code != 0 )
		return error_code;

	return fipc_test_stat_print_stats ( sample_set, sample_size, &stats );
}

#endif
