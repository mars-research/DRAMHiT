/**
 * @File     : libfipc_types.h
 * @Author   : Anton Burtsev
 * @Author   : Scotty Bauer
 * @Author   : Charles Jacobsen
 * @Author   : Abdullah Younis
 * @Copyright: University of Utah
 *
 * This library contains data structure definitions for types used in libfipc.
 */

#ifndef LIBFIPC_TYPES_H
#define LIBFIPC_TYPES_H

#include "libfipc_platform_types.h"

// Assumed cache line size, in bytes
#ifndef FIPC_CACHE_LINE_SIZE
	#define FIPC_CACHE_LINE_SIZE 64
#endif

// Type modifier that aligns the variable to the cache line
#ifndef CACHE_ALIGNED
	#define CACHE_ALIGNED __attribute__((aligned(FIPC_CACHE_LINE_SIZE)))
#endif

// The number of 64 bit registers in a single message.
#define FIPC_NR_REGS ((FIPC_CACHE_LINE_SIZE-8)/8)

// The amount of padding need for the buffers
#define FIPC_RING_BUF_PADDING (FIPC_CACHE_LINE_SIZE-24)

/**
 * This is the smallest unit in the libfipc system, and is in every slot of an
 * FIPC ring buffer. The fast IPC library gets is efficiency from the size of
 * this object. This data structure is exactly the same size as the cache line,
 * which allows us to minimize the amount of cache traffic required to
 * pass messages.
 *
 * NOTE: Fields: msg_status and msg_length are reserved for internal use.
 */
typedef struct CACHE_ALIGNED fipc_message
{
	volatile uint32_t msg_status;	// The status of the message
	uint32_t flags;					// Not touched by libfipc
	uint64_t regs[FIPC_NR_REGS];	// Not touched by libfipc

} message_t;

/**
 * This is the header for an IPC ring buffer, which is a circular buffer by
 * design. To accomplish this, a order two mask is applied to the slot index,
 * which creates a modular or loop-around effect. This mask is quickly computed
 * at ring buffer initialization time. The mask is given by:
 *
 *     [2^buf_order / sizeof(struct fipc_message)] - 1
 *
 * NOTE: Since we require that the message_t is a power of 2, the mask will equal
 * 2^x-1 for some x.
 */
typedef struct CACHE_ALIGNED fipc_ring_buf
{
	uint64_t   slot;	// The current slot in the buffer.
	uint64_t   mask;	// Used to quickly calculate modular message slot index
	message_t* buffer;	// Pointer to IPC circular buffer data

	// Extra padding to ensure alignment to the cache line
	uint8_t padding[FIPC_RING_BUF_PADDING];

} buffer_t;

/**
 * A full duplex IPC channel is made up of two, one-way IPC ring buffers,
 * @tx and @rx.
 *
 * NOTE: It may seem redundant to store two equal mask values in both ring
 * buffers rather than putting a common value here; however, we put redundant
 * values so that different cores can communicate with sharing a cache line.
 */
typedef struct CACHE_ALIGNED fipc_ring_channel
{
	buffer_t tx;	// Pointer to our sending ring buffer.
	buffer_t rx;	// Pointer to our receiving ring buffer.

} header_t;

#endif
