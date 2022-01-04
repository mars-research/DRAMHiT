/*
 *  B-Queue -- An efficient and practical queueing for fast core-to-core
 *             communication
 *
 *  Copyright (C) 2011 Junchang Wang <junchang.wang@gmail.com>
 *
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * CITE: https://github.com/olibre/B-Queue/blob/master/
 *
 */

#include "bqueue.h"

static data_t ELEMENT_ZERO = 0x0UL;

int init_queue(cons_queue_t *q) {
#if defined(CONS_BATCH)
  Q_BATCH_HISTORY = CONS_BATCH_SIZE;
#endif
  return 0;
}

int free_queue(cons_queue_t *q) { return 0; }

#if defined(PROD_BATCH) || defined(CONS_BATCH)
inline int leqthan(volatile data_t point, volatile data_t batch_point) {
  return (point == batch_point);
}
#endif

#if defined(PROD_BATCH)
int enqueue(prod_queue_t *q, data_t value) {
  uint32_t tmp_head;
  if (Q_HEAD == Q_BATCH_HEAD) {
    tmp_head = Q_HEAD + PROD_BATCH_SIZE;
    if (tmp_head >= QUEUE_SIZE) tmp_head = 0;

    if (q->data[tmp_head]) {
      fipc_test_time_wait_ticks(CONGESTION_PENALTY);
      return BUFFER_FULL;
    }

    Q_BATCH_HEAD = tmp_head;
  }
  q->data[Q_HEAD] = value;
  Q_HEAD++;
  if (Q_HEAD >= QUEUE_SIZE) {
    Q_HEAD = 0;
  }

  return SUCCESS;
}
#else  /* PROD_BATCH */
int enqueue(queue_t *q, data_t value) {
  if (q->data[Q_HEAD]) return BUFFER_FULL;
  q->data[Q_HEAD] = value;
  Q_HEAD++;
  if (Q_HEAD >= QUEUE_SIZE) {
    Q_HEAD = 0;
  }

  return SUCCESS;
}
#endif /* PROD_BATCH */

#if defined(CONS_BATCH)

static inline int backtracking(cons_queue_t *q) {
  uint32_t tmp_tail;
  tmp_tail = Q_TAIL + CONS_BATCH_SIZE - 1;
  if (tmp_tail >= QUEUE_SIZE) {
    tmp_tail = 0;
  }

#if defined(ADAPTIVE)
  if (Q_BATCH_HISTORY < CONS_BATCH_SIZE) {
    Q_BATCH_HISTORY = (CONS_BATCH_SIZE < (Q_BATCH_HISTORY + BATCH_INCREMENT))
                           ? CONS_BATCH_SIZE
                           : (Q_BATCH_HISTORY + BATCH_INCREMENT);
  }
#endif

#if defined(BACKTRACKING)
  unsigned long batch_size = Q_BATCH_HISTORY;
#if defined(OPTIMIZE_BACKTRACKING2)
  if ((!q->data[tmp_tail]) && !Q_BACKTRACK_FLAG) {
    return -1;
  }
#endif

#if defined(OPTIMIZE_BACKTRACKING)
  if ((!q->data[tmp_tail]) && (q->backtrack_count++ & 255)) {
    return -1;
  }
#endif

  while (!(q->data[tmp_tail])) {
    // fipc_test_time_wait_ticks(CONGESTION_PENALTY);

    if (batch_size > 1) {
      batch_size = batch_size >> 1;
      tmp_tail = Q_TAIL + batch_size - 1;
      if (tmp_tail >= QUEUE_SIZE) tmp_tail = 0;
    } else
      return -1;
  }
#if defined(ADAPTIVE)
  Q_BATCH_HISTORY = batch_size;
#endif

#else
  if (!q->data[tmp_tail]) {
    wait_ticks(CONGESTION_PENALTY);
    return -1;
  }
#endif /* end BACKTRACKING */

  if (tmp_tail == Q_TAIL) {
    tmp_tail = (tmp_tail + 1) >= QUEUE_SIZE ? 0 : tmp_tail + 1;
  }
  Q_BATCH_TAIL = tmp_tail;

  return 0;
}

int dequeue(cons_queue_t *q, data_t *value) {
  if (Q_TAIL == Q_BATCH_TAIL) {
    if (backtracking(q) != 0) return BUFFER_EMPTY;
  }
  *value = q->data[Q_TAIL];
  q->data[Q_TAIL] = ELEMENT_ZERO;
  Q_TAIL++;
  if (Q_TAIL >= QUEUE_SIZE) Q_TAIL = 0;

  return SUCCESS;
}

#else /* CONS_BATCH */

int dequeue(struct queue_t *q, data_t *value) {
  if (!q->data[Q_TAIL]) return BUFFER_EMPTY;
  *value = q->data[Q_TAIL];
  q->data[Q_TAIL] = ELEMENT_ZERO;
  Q_TAIL++;
  if (Q_TAIL >= QUEUE_SIZE) Q_TAIL = 0;

  return SUCCESS;
}

#endif
