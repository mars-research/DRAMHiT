/*
 * libfipc.h
 *
 * Fast, asynchronous IPC library using shared
 * memory.
 *
 * The main object here is a duplex, ring channel, used by two
 * threads, or processes, etc., shown below:
 *
 *                   |                                  |
 *                   |          Shared Memory           |
 *      Thread 1     |                                  |     Thread 2
 *      --------     |                                  |     --------
 *                   |                                  |
 *  header           |                                  |      header
 *  +----+           |    +--------------------------+  |      +-----+
 *  | rx ---------------->|      memory buffer 1     |  |      |     |
 *  |    |           | +---------------------------+ |<--------- tx  |
 *  | tx ------------->|       memory buffer 2     |-+  |      |     |
 *  |    |           | |                           |<----------- rx  |
 *  +----+           | +---------------------------+    |      +-----+
 *                   |                                  |
 *                   |                                  |
 *
 * There are a couple things to note here.
 *
 *    1 - The ring channel consists of two buffers in shared memory, and
 *        two distinct headers on each side. These headers *need not be* in
 *        a region of memory shared by the two threads.
 *
 *    2 - Memory buffer 1 is used by Thread 2 to send messages to Thread 1
 *        (Thread 2's tx points to memory buffer 1, and Thread 1's rx points
 *        to memory buffer 1.) Similarly, for memory buffer 2. So, data
 *        can flow both directions.
 *
 * Each header is a header_t. header_t
 * consists of two struct fipc_ring_buf's -- one for each direction (tx/rx).
 *
 * The memory buffers are treated as circular buffers, whose slots are
 * message_t's.
 *
 *                           memory buffer layout
 *    +--------------+--------------+--------------+--------------+---- ...
 *    | struct       | struct       | struct       | struct       |
 *    | fipc_message | fipc_message | fipc_message | fipc_message |
 *    +--------------+--------------+--------------+--------------+---- ...
 *
 * Ring Channel Initialization
 * ---------------------------
 *
 * There are few steps:
 *
 *         1 - Allocate and initialize the shared memory buffers
 *
 *         2 - Allocate the headers (header_t's). These
 *             can be statically allocated (e.g. global variables).
 *
 *         3 - Initialize the headers
 *
 * In a typical scenario, Thread 1 will allocate both memory buffers and
 * share them with Thread 2 (how this is done depends on the environment).
 * Thread 1 and Thread 2 will allocate their private headers, and initialize
 * them to point to the allocated memory buffers. Here is how this looks
 * for Thread 1 using the libfipc interface (return values ignored):
 *
 *     --------
 *     Thread 1
 *     --------
 *
 *     header_t t1_chnl_header;
 *
 *     // Allocate shared memory buffers
 *     unsigned int buf_order = .. buffers are 2^buf_order bytes ..
 *     char *buffer_1 = ... alloc memory buffer 1 ...
 *     char *buffer_2 = ... alloc memory buffer 1 ...
 *
 *     // Initialize the shared buffers (*required*)
 *     fipc_prep_buffers(buf_order, buffer_1, buffer_2);
 *
 *     .... share buffers with Thread 2 ...
 *
 *     // Initialize my header_t header
 *     fipc_ring_channel_init(&t1_chnl_header, buf_order,
 *                            buffer_1,
 *                            buffer_2);
 *
 * Send/Receive
 * ------------
 *
 * IMPORTANT: If you plan to share the same tx or rx header on one
 * side of the channel amongst multiple threads, fipc_send_msg_start and
 * fipc_recv_msg_start/if are NOT thread safe. (Some libfipc users may
 * not require it, so we don't do any synchronization internally.) So,
 * you should wrap calls to these functions in locks as necessary. See
 * their documentation for more comments.
 *
 * (Of course, communication across the channel itself to the other side
 * does not require explicit synchronization of threads on opposite sides.)
 *
 * A typical send/receive sequence is as follows, assuming the headers
 * have been initialized already:
 *
 *     --------
 *     Thread 1
 *     --------
 *
 *     message_t *msg;
 *     int ret;
 *
 *     do {
 *
 *        // Allocate a slot to put message in
 *        ret = fipc_send_msg_start(t1_chnl_header, &msg);
 *
 *     } while (ret == -EWOULDBLOCK);
 *
 *     msg->regs[0] = 1;
 *     msg->regs[1] = 2;
 *     ...
 *
 *     // Mark message as sent (receiver will see status change)
 *     fipc_send_msg_end(t1_chnl_header, msg);
 *
 *     --------
 *     Thread 2
 *     --------
 *
 *     message_t *msg;
 *     int ret;
 *
 *     do {
 *
 *        // Wait for message to receive
 *        ret = fipc_recv_msg_start(t2_chnl_header, &msg);
 *
 *     } while (ret == -EWOULDBLOCK);
 *
 *     ... do something with msg ...
 *
 *     // Mark message as received (sender will see slot as available)
 *     fipc_recv_msg_end(t2_chnl_header, msg);
 *
 * Ring Channel Tear down
 * ----------------------
 *
 * When you're done using the ring channel (you should probably wait until
 * both threads are done -- using some other mechanism), there is no tear
 * down required. (You are the one responsible for allocating the headers
 * and shared memory buffers, so you need to tear them down.)
 *
 *
 * Authors: Anton Burtsev Scotty Bauer
 * Date:    October 2011 Feburary 2015
 *
 * Copyright: University of Utah
 */
#ifndef LIBFIPC_H
#define LIBFIPC_H

#include "libfipc_types.h"
#include "libfipc_platform.h"

#ifndef LIBFIPC_FUNC_ATTR
#define LIBFIPC_FUNC_ATTR
#endif

/* MAIN INTERFACE -------------------------------------------------- */

/**
 * fipc_init -- Initialize libfipc.
 *
 * This should be invoked before any use of libfipc functions.
 *
 * Returns non-zero on initialization failure.
 *
 * Note: This is a no-op for now, but gives us a chance later to have
 * some init code if necessary (internal caches, whatever).
 */
int fipc_init(void);
/**
 * fipc_fini -- Tear down libfipc.
 *
 * This should be invoked when finished using libfipc functions.
 */
void fipc_fini(void);
/**
 * fipc_prep_buffers -- Initialize the shared memory buffers for ipc
 * @buf_order: both buffers are 2^buf_order bytes
 * @buffer_1, @buffer_2: buffers used for channel
 *
 * This *must* be called by exactly one of the sides of the channel
 * before using the channel (probably the same thread that allocated the
 * buffers themselves should call this). It initializes the slots in
 * the shared buffers.
 *
 * @buffer_1 and @buffer_2 *must* be exactly 2^buf_order bytes (if not,
 * your memory will be corrupted), and the buffers must be big enough
 * to fit at least one message_t.
 */

int fipc_prep_buffer  ( uint32_t buf_order, void* buffer );
int fipc_prep_buffers ( uint32_t buf_order, void *buffer_1, void *buffer_2 );
/**
 * fipc_ring_channel_init -- Initialize ring channel header with buffers
 * @chnl: the header_t to initialize
 * @buf_order: buffers are 2^buf_order bytes
 * @buffer_tx: buffer to use for tx (send) direction
 * @buffer_rx: buffer to use for rx (receive) direction
 *
 * This function must be called before trying to do a send or receive
 * on the channel.
 *
 * The buffers are required to be at least sizeof(message_t)
 * bytes (at least one message should fit). (Note that because they are
 * a power of 2 number of bytes, they will automatically be a multiple
 * of sizeof(message_t).)
 */
int fipc_ring_channel_init ( header_t* chnl, uint32_t buf_order, void* buffer_tx, void* buffer_rx );
int fipc_tx_channel_init ( header_t* chnl, uint32_t buf_order, void* buffer_tx );
int fipc_rx_channel_init ( header_t* chnl, uint32_t buf_order, void* buffer_rx );

/**
 * fipc_send_msg_start -- Allocate a slot from tx buffer for sending
 * @chnl: the ring channel, whose tx we should allocate from
 * @msg: out param, the allocated slot
 *
 * If there are no free slots, returns -EWOULDBLOCK.
 *
 * IMPORTANT: If the sender fails to invoke fipc_send_msg_end, this could
 * introduce some delay and re-ordering of messages. (The slot will not
 * be marked as ready to receive, for the receiver to pick up.) So, make
 * sure the code in between start and end cannot fail.
 *
 * IMPORTANT: This function is NOT thread safe. To make this code fast,
 * we do not do any internal synchronization. If you plan to share the
 * tx buffer amongst several threads, you should wrap a call to this
 * function with a tx-specific lock, for example. Once this call has
 * returned, however, a subsequent call will not return the same message.
 */
int fipc_send_msg_start      ( header_t* chnl, message_t** msg );
int fipc_send_long_msg_start ( header_t* chnl, message_t** msg, uint16_t len );
/**
 * fipc_send_msg_end -- Mark a message as ready for receipt from receiver
 * @chnl: the ring channel containing @msg in tx
 * @msg: the message we are sending
 *
 * Returns non-zero on failure. (For now, this never fails, but in case
 * failure is possible in the future, we provide for this possibility.)
 *
 * This function is thread safe.
 */
int fipc_send_msg_end ( header_t* chnl, message_t* msg );

/**
 * fipc_recv_msg_start -- Receive the next message from rx, if available
 * @chnl: the ring channel, whose rx we should receive from
 * @msg: out param, the received message
 *
 * Messages are received in increasing slot order (wrapping around when
 * we reach the end of the memory buffer). Internally, we maintain a
 * cursor to the next slot where we expect a message, and wait until the
 * sender puts one there. When the sender puts a message there, and a
 * thread on the receiving side receives the message (by invoking this
 * function), we increment the cursor by 1.
 *
 * XXX: This implies that if the sender screws up and doesn't send messages
 * in increasing slot order, the receiver will be stuck waiting. (This
 * can happen if a thread on the sending side allocates a slot to send
 * a message in, but doesn't mark the message as ready to be
 * received -- i.e., failing to call fipc_send_msg_end.)
 *
 * If there are no messages to be received, returns -EWOULDBLOCK. (More
 * precisely, if the current slot under the cursor does not contain a
 * ready message, returns -EWOULDBLOCK.)
 *
 * IMPORTANT: If the caller fails to invoke fipc_recv_msg_end, the sender
 * will potentially block waiting for the slot to become free. So, make sure
 * your code cannot fail between start/end.
 *
 * IMPORTANT: This function is NOT thread safe. To make this code fast,
 * we do not do any internal synchronization. If you plan to share the
 * rx buffer amongst several threads, you should wrap a call to this
 * function with a rx-specific lock, for example. Once this call has
 * returned, however, a subsequent call will not return the same message.
 */
int fipc_recv_msg_start(header_t *chnl,
			message_t **msg);
/**
 * fipc_recv_msg_if -- Like fipc_recv_msg_start, but conditioned on a predicate
 * @chnl: the ring channel, whose rx we should receive from
 * @pred: the condition under which we should receive a message
 * @data: context data to pass to @pred
 * @msg: out param, the received message
 *
 * This is like fipc_recv_msg_start, but if there is a message to be
 * received, libfipc will allow @pred to peek at the message to see if the
 * caller wants to receive it (by looking at values in the message).
 * libfipc will pass along @data to @pred, providing context.
 *
 * @pred should return non-zero to indicate the caller should receive the
 * message, and zero if no.
 *
 * IMPORTANT: This function is NOT thread safe. To make this code fast,
 * we do not do any internal synchronization. If you plan to share the
 * rx buffer amongst several threads, you should wrap a call to this
 * function with an rx-specific lock, for example. In that case, you
 * should ensure @pred is simple, as it is would be executed inside of a
 * critical section.
 */
int fipc_recv_msg_if(header_t *chnl,
		int (*pred)(message_t *, void *),
		void *data,
		message_t **msg);
/**
 * fipc_recv_msg_end -- Mark a message as received, so sender can re-use slot
 * @chnl: the ring channel containing @msg in rx
 * @msg: the message to mark as received
 * @return: non-zero on failure.
 *
 * NOTE: Currently, this function does not fail.
 *
 * NOTE: This function is thread safe.
 */
int fipc_recv_msg_end(header_t *chnl,
		message_t *msg);

// =============================================================
// ------------------ MESSAGE ACCESSORS ------------------------
// =============================================================
// The use of these functions makes your code independent of the
// structure of our code, however, they are not required.

#define FIPC_MK_REG_ACCESS(idx)						\
static inline							        \
uint64_t fipc_get_reg##idx(message_t *msg)		\
{									\
	FIPC_BUILD_BUG_ON(idx >= FIPC_NR_REGS);				\
	return msg->regs[idx];						\
}									\
static inline								\
void fipc_set_reg##idx(message_t *msg, uint64_t val)	\
{									\
	msg->regs[idx] = val;						\
}

FIPC_MK_REG_ACCESS(0)
FIPC_MK_REG_ACCESS(1)
FIPC_MK_REG_ACCESS(2)
FIPC_MK_REG_ACCESS(3)
FIPC_MK_REG_ACCESS(4)
FIPC_MK_REG_ACCESS(5)
FIPC_MK_REG_ACCESS(6)

static inline
uint32_t fipc_get_flags(message_t *msg)
{
	return msg->flags;
}

static inline
void fipc_set_flags(message_t *msg, uint32_t flags)
{
	msg->flags = flags;
}

#endif
