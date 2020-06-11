/**
 * @File     : libfipc_test_shm.h
 * @Author   : Abdullah Younis
 * @Copyright: University of Utah
 *
 * This library contains shared memory helper functions.
 *
 * NOTE: This library assumes an x86 architecture.
 */

#ifndef LIBFIPC_TEST_SHM_LIBRARY_LOCK
#define LIBFIPC_TEST_SHM_LIBRARY_LOCK

#include <sys/mman.h>
#include <pthread.h>
#include <fcntl.h>

#define FIPC_TEST_TRANSMIT 1
#define FIPC_TEST_RECEIVE  0

typedef struct shared_mutex
{
  int count;
  pthread_mutex_t mutex;

} shared_mutex_t;


/**
 * This function gets/creates a region of shared memory and places a ptr to it in shm.
 */
static inline
int fipc_test_shm_get ( const char* key, size_t size, void** shm )
{
	int error_code = 0;
	int created    = 0; // true if this function call created the shared memory

	int ssmpfd = shm_open( key, O_CREAT | O_EXCL | O_RDWR, S_IRWXU | S_IRWXG );

	if ( ssmpfd >= 0 )
	{
		created = 1;
	}
	else
	{
		if ( errno != EEXIST )
		{
			error_code = -EEXIST;
			goto fail1;
		}

	  	ssmpfd = shm_open( key, O_CREAT | O_RDWR, S_IRWXU | S_IRWXG );

	  	if ( ssmpfd < 0 )
	  	{
	  		error_code = -errno;
	  		goto fail1;
	  	}
	}
  
	error_code = ftruncate( ssmpfd, size );

	if ( error_code )
	{
		goto fail2;
	}

	*shm = mmap( NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, ssmpfd, 0 );

	if ( *shm == NULL )
	{
		error_code = -ENOMEM;
		goto fail3;
	}

	goto success;

fail3:
fail2:
	close( ssmpfd );
fail1:
	return error_code;
success:
	return created;
}

/**
 * This function unlinks a region of shared memory.
 */
static inline
int fipc_test_shm_unlink ( const char* key )
{
	return shm_unlink( key );
}

static inline
int fipc_test_shm_get_shared_mutex ( shared_mutex_t** shared_mutex, const char* key )
{
	int error_code = fipc_test_shm_get( key, sizeof(shared_mutex_t), (void**)shared_mutex );

	if ( error_code < 0 )
	{
		return error_code;
	}

	(*shared_mutex)->count = 0;
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&(*shared_mutex)->mutex, &attr);
    
    return 0;
}

static inline
int fipc_test_shm_barrier ( shared_mutex_t* shared_mutex, uint64_t num_process, uint64_t rank )
{
	pthread_mutex_lock(&(shared_mutex->mutex));
	shared_mutex->count++;
	pthread_mutex_unlock(&(shared_mutex->mutex));

	while ( shared_mutex->count < num_process )
		fipc_test_pause();

	if ( rank == 0 )
		shared_mutex->count = 0;

	return 0;
}

/**
 * This function creates half of a channel, either the rx or tx end.
 */
static inline
int fipc_test_shm_create_half_channel ( size_t buffer_order, header_t** header, const char* key, int tx )
{
	int   error_code = 0;
	int   created    = 0;
	int   alcHeader  = *header == NULL;
	void* buffer     = NULL;

	// (1) Allocate Buffer Pages
	error_code = fipc_test_shm_get( key, PAGES_NEEDED(buffer_order)*PAGE_SIZE, &buffer );

	if ( error_code < 0 )
	{
		goto fail1;
	}
	else if ( error_code == 1 )
	{
		error_code = 0;
		created    = 1;
	}

	// (2) Initialize Buffer
	// This is only done when creating the tx half channel to not double prep the buffer.
	if ( tx )
	{
		error_code = fipc_prep_buffer( buffer_order, buffer );

		if ( error_code )
		{
			goto fail2;
		}
	}

	// (3) Allocate Header, if necessary
	if ( alcHeader )
	{
		*header = (header_t*) malloc( sizeof( header_t ) );

		if ( *header == NULL )
		{
			error_code = -ENOMEM;
			goto fail3;
		}
	}

	// (4) Initialize Header
	if ( tx )
		error_code = fipc_tx_channel_init( *header, buffer_order, buffer );
	else
		error_code = fipc_rx_channel_init( *header, buffer_order, buffer );

	if ( error_code )
	{
		goto fail4;
	}

	goto success;

fail4:
	if ( alcHeader )
		free ( *header );
fail3:
fail2:
	if ( created )
		fipc_test_shm_unlink( key );
fail1:
success:
	return error_code;
}

/**
 * This function 
 */
static inline
void fipc_test_shm_free_half_channel ( header_t* header )
{
	free( header );
}

#endif
