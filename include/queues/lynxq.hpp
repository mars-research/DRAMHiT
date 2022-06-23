/*Lynx is a lock-free single-producer/single-consumer software
queue for fine-grained communictaion. Copyright (C) 2016  
Konstantina Mitropoulou, Vasileios Porpodas, Xiaochun Zhang and 
Timothy M. Jones.

Lynx is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Lynx is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
02110-1301, USA. 
 
More information about Lynx can be found at 
https://www.repository.cam.ac.uk/handle/1810/255384
*/

#pragma once

#define OPERATOR_NEW

#include <execinfo.h>
#include <unistd.h>		/* sysconf() */
#include <sys/mman.h>		/* mprotect() */
#include <signal.h>
#include <assert.h>
#include <string.h>
#include <capstone/capstone.h>
#include <stdint.h>
#include <limits.h>
#include <time.h>		/* clock_t */
#include <pthread.h>
#include <set>
#include <map>
#include "queue.hpp"

#define COMPILER_BARRIER asm volatile("" ::: "memory")

namespace kmercounter {

struct lynxQ;
typedef struct lynxQ *lynxQ_t;
typedef std::set<lynxQ_t> qset_t;
qset_t all_queues_created;

struct lynxQ;
typedef struct lynxQ queue_t;

static void lynxQ_handler(int, siginfo_t *, void *);
static void lynxQ_nomprotect_handler(int, siginfo_t *, void *);

enum section_state {
  /* Boiler plate */
  __STATE_UNINIT = 0,
  /* Section is free for push() to enter. Pop() has read all its values. */
  POP_READY = 1 << 0,
  /* Section is busy. Push() is writing values into it. */
  PUSH_WRITES = 1 << 1,
  /* Section is ready for the pop() to step in. Push() has written values into it. */
  PUSH_READY = 1 << 2,
  /* Section is read by the pop() thread */
  POP_READS = 1 << 3,
  /* Push thread has finished pushing values into the queue and has exited */
  PUSH_EXITED = 1 << 4,
  /* Boiler plate */
  __STATE_MAX,
};
typedef enum section_state section_state_t;


enum Redzone_state {
  __REDZONE_STATE_UNINIT = 0,
  FREE = 1 << 0,
  PUSH_OWNS = 1 << 1,
  POP_OWNS = 1 << 2,
  __REDZONE_STATE_MAX,
};
typedef enum Redzone_state redzone_state_t;

typedef struct Queue_state
{
  //long int fsbuf0[8];
  CACHE_ALIGNED section_state_t sstate0;
  CACHE_ALIGNED section_state_t sstate1;
  CACHE_ALIGNED char *last_pop_r15;
  CACHE_ALIGNED int push_done;
  int last_red_zone;
  void *label;
  CACHE_ALIGNED redzone_state_t redzone1_state;
  CACHE_ALIGNED redzone_state_t redzone2_state;
  CACHE_ALIGNED uint64_t num_push;
  CACHE_ALIGNED uint64_t num_pop;
} queue_state_t;


#define DEFINE_PUSH_OVERLOADED_NEW(TYPE, MOV)				\
  inline void push(TYPE data)						\
  {									\
    char *push_index_tmp = push_index;					\
    asm(MOV" %0, (%1, %2)"						\
    	:	/* no outputs */					\
    	: "r" (data), "r" (free_push_reg), "r" ((TYPE*)push_index_tmp) /* inputs */ \
    	: "1" );							\
    push_index_tmp = (char *)((uint64_t)push_index_tmp + sizeof(TYPE));		\
    push_index = push_index_tmp;					\
  }

#define DEFINE_PUSH_OVERLOADED_1OP(TYPE, MOV)				\
  inline void push(TYPE data)						\
  {									\
    char *push_index_tmp = push_index;					\
    asm(MOV" %0, (%1)"						\
    	:	/* no outputs */					\
    	: "r" (data),  "r" ((TYPE*)push_index_tmp) /* inputs */ \
    	: "1" );							\
    push_index = (char *)((uint64_t)push_index + sizeof(TYPE));		\
  }


#define DEFINE_POP_1OP(TYPE, MOV)						\
  inline TYPE pop_##TYPE (void)						\
  {									\
    TYPE data;								\
    char *pop_index_tmp = pop_index;					\
    asm(MOV" (%1), %0"						\
    	: "=&r" (data)							\
    	: "r" ((TYPE *)pop_index_tmp) 	/* inputs */ \
    	: "1" );							\
    pop_index_tmp += sizeof(TYPE);						\
    pop_index = pop_index_tmp;                \
    return data;							\
  }


#define DEFINE_POP_NEW(TYPE, MOV)						\
  inline TYPE pop_##TYPE (void)						\
  {									\
    TYPE data;								\
    char *pop_index_tmp = pop_index;					\
    asm(MOV" (%1, %2), %0"						\
    	: "=&r" (data)							\
    	: "r" (free_pop_reg), "r" ((TYPE *)pop_index_tmp) 	/* inputs */ \
    	: "1" );							\
    pop_index_tmp += sizeof(TYPE);					\
    pop_index = pop_index_tmp;						\
    return data;							\
  }


#define DEFINE_PUSH_OVERLOADED(TYPE, MOV)				\
  inline void push(TYPE data, struct prod_queue *pq)						\
  {									\
    char *push_index_tmp = pq->push_index;					\
    asm(MOV" %0, (%1, %2)"						\
    	:	/* no outputs */					\
    	: "r" (data), "r" (pq->free_push_reg), "r" ((TYPE*)push_index_tmp) /* inputs */ \
    	: "1" );							\
    push_index_tmp = (char *)((uint64_t)push_index_tmp + sizeof(TYPE));		\
    pq->push_index = push_index_tmp;					\
  }

#define DEFINE_POP(TYPE, MOV)						\
  inline TYPE pop_##TYPE (struct cons_queue *cq)						\
  {									\
    TYPE data;								\
    char *pop_index_tmp = cq->pop_index;					\
    asm(MOV" (%1, %2), %0"						\
    	: "=&r" (data)							\
    	: "r" (cq->free_pop_reg), "r" ((TYPE *)pop_index_tmp) 	/* inputs */ \
    	: "1" );							\
    pop_index_tmp += sizeof(TYPE);					\
    cq->pop_index = pop_index_tmp;						\
    return data;							\
  }

enum on_or_off_enum {
  OFF = 0,
  ON = 1,
};

typedef enum on_or_off_enum on_or_off_t;

struct prod_queue {
  char *QUEUE;
  char *push_index;
  uint64_t free_push_reg;

  DEFINE_PUSH_OVERLOADED_1OP(long, "movq")
  //DEFINE_PUSH_OVERLOADED_NEW(long, "movq")
};

struct cons_queue {
  char *QUEUE;
  char *pop_index;
  uint64_t free_pop_reg;
  bool in_redzone;
  DEFINE_POP_1OP(long, "movq")
  //DEFINE_POP_NEW(long, "movq")
};

struct alignas(4096) lynxQ {
  CACHE_ALIGNED char *QUEUE;
  CACHE_ALIGNED char *redzone1;
  CACHE_ALIGNED char *redzone2;
  CACHE_ALIGNED char *redzone_end;
  CACHE_ALIGNED bool allow_rotate;
  clock_t time_begin;
  clock_t time_end;
  double queue_time;
  CACHE_ALIGNED struct prod_queue *pq_state;
  struct cons_queue *cq_state;
  long _PAGE_SIZE;
  size_t queue_size;
  size_t REDZONE_SIZE;
  size_t QUEUE_SECTION_SIZE;
  size_t QUEUE_ALIGN;
  size_t QUEUE_ALIGN_MASK;
  size_t QUEUE_CIRCULAR_MASK;
  qset_t *all_queues_set;
  CACHE_ALIGNED volatile queue_state_t qstate;
  CACHE_ALIGNED char *push_expected_rz;
  char *pop_expected_rz;
  CACHE_ALIGNED char *push_last_rz;		/* The last redzone created by push */
  char *pop_last_rz;		/* The last redzone created by pop */
  volatile section_state_t *last_push_state;
  volatile section_state_t *last_pop_state;

  void dump(void);
  inline void push_done(void);
  void pop_done(void);

  DEFINE_PUSH_OVERLOADED(char, "movb")
  DEFINE_PUSH_OVERLOADED(uint8_t, "movb")
  DEFINE_PUSH_OVERLOADED(short, "movw")
  DEFINE_PUSH_OVERLOADED(uint16_t, "movw")
  DEFINE_PUSH_OVERLOADED(int, "movl")
  DEFINE_PUSH_OVERLOADED(uint32_t, "movl")
  DEFINE_PUSH_OVERLOADED(long, "movq")
  DEFINE_PUSH_OVERLOADED(uint64_t, "movq")

  DEFINE_POP(char, "movb")
  DEFINE_POP(uint8_t, "movb")
  DEFINE_POP(short, "movw")
  DEFINE_POP(uint16_t, "movw")
  DEFINE_POP(int, "movl")
  DEFINE_POP(uint32_t, "movl")
  DEFINE_POP(long, "movq")
  DEFINE_POP(uint64_t, "movq")

  lynxQ(size_t qsize, struct prod_queue *pq, struct cons_queue *cq);
  double get_time(void);
  void finalize(void);

  void *operator new(std::size_t size,
     // std::align_val_t align,
      size_t qsize
      //,struct prod_queue *pq, struct cons_queue *cq
      ) {
    auto queue_align = (1 << 21);
    auto ptr = aligned_alloc(static_cast<std::size_t>(queue_align), size + qsize + (1 << 12));

    //printf("size %zu | align %zu | qsize %zu\n", size, align, qsize);
    printf("size %zu | qsize %zu | ptr %p | sz %zu\n", size, qsize, ptr, sizeof(lynxQ));

    if (!ptr) throw std::bad_alloc{};

    //PLOGI << "Allocating " << size
    //      << ", align: " << static_cast<std::size_t>(align) << ", ptr: " << ptr;
    return ptr;
  }

  void operator delete(void *ptr, std::size_t size,
                       std::size_t qsize) noexcept {
    PLOGI << "deleting " << size
          << ", ptr : " << ptr;
    free(ptr);
  }


  const char *config_red_zone(on_or_off_t cond, void *addr);
  inline char *get_new_redzone_left (char *curr_redzone);
  //void setup_signal_handler(void);

  ~lynxQ() {
  }

};


/* Print error message and exit */
#define fatal_error(...) 			\
  {						\
  fprintf (stderr, "queue: Fatal Error: ");	\
  fprintf (stderr, __VA_ARGS__);		\
  exit(EXIT_FAILURE);				\
  }						\


#define handle_error(msg) \
do { perror(msg); exit(EXIT_FAILURE); } while (0)

void lynxQ::dump(void) {
  fprintf (stderr, "QUEUE:          %p\n", QUEUE);
  fprintf (stderr, "redzone1:       %p\n", redzone1);
  fprintf (stderr, "redzone2:       %p\n", redzone2);
  fprintf (stderr, "redzone_end:    %p\n", redzone_end);
  fprintf (stderr, "queue_end:      %p\n", QUEUE + queue_size);
  fprintf (stderr, "PAGE_SIZE:      0x%x\n", PAGE_SIZE);
  fprintf (stderr, "queue_size:     0x%lx\n", queue_size);
  fprintf (stderr, "REDZONE_SIZE:   0x%lx\n", REDZONE_SIZE);
  fprintf (stderr, "QUEUE_SECTION_SIZE:  0x%lx\n", QUEUE_SECTION_SIZE);
  fprintf (stderr, "QUEUE_ALIGN:         0x%lx\n", QUEUE_ALIGN);
  fprintf (stderr, "QUEUE_ALIGN_MASK:    0x%lx\n", QUEUE_ALIGN_MASK);
  fprintf (stderr, "QUEUE_CIRCULAR_MASK: 0x%lx\n", QUEUE_CIRCULAR_MASK);
  fprintf (stderr, "push_expected_rz: %p\n", push_expected_rz);
  fprintf (stderr, "pop_expected_rz:  %p\n", pop_expected_rz);

  fprintf (stderr, "push_last_rz: %p\n", push_last_rz);
  fprintf (stderr, "pop_last_rz:  %p\n", pop_last_rz);

  fprintf (stderr, "num_push:     %ld\n", qstate.num_push);
  fprintf (stderr, "num_pop:      %ld\n", qstate.num_pop);

  fprintf (stderr, "push_index:   %p\n", pq_state->push_index);
  fprintf (stderr, "pop_index:    %p\n", cq_state->pop_index);
}

/* Set or Unset redzone REDZONE at ADDR depending on boolean ON_OFF */
const char *lynxQ::config_red_zone (on_or_off_t cond, void *addr) {
  assert ((cond == ON) || (cond == OFF) && "Bad COND");
  int prot = (cond == ON) ? PROT_NONE : (PROT_READ| PROT_WRITE | PROT_EXEC);
  size_t size = _PAGE_SIZE;

  if (!addr) {
    void *array[10];
    size_t size;

    // get void*'s for all entries on the stack
    size = backtrace(array, 10);

    // print out all the frames to stderr
    char **strings = backtrace_symbols(array, size);
    if (strings != NULL)
    {

      printf ("Obtained %zu stack frames.\n", size);
      for (auto i = 0u; i < size; i++)
        printf ("%s\n", strings[i]);
    }
  }

  if (mprotect(addr, size, prot) == -1) {
    dump();
    fatal_error("mprotect error: addr:%p, size:0x%lx, prot:%d\n", 
        addr, size, prot);
  }
  return (char *)addr;
}


inline void lynxQ::push_done (void)
{
  /* Notify pop() that we are done */
  //push((uint64_t) 0xDEADBEEF, pq_state);
  //push((uint64_t) 0xFEEBDAED, pq_state);

  /* Clear the last redzone */
  //config_red_zone (OFF, push_last_rz);
  /* Make sure that a segfault does not belong to a push */
  //printf("-------------------PUSH DONE!-----------------\n");
  //printf("push_expected_rz %p | pop_expected_rz %p | push_last_rz %p\n",
  //      push_expected_rz, pop_expected_rz, push_last_rz);
  push_expected_rz = NULL;

  /* Set the special state */
  *last_push_state = PUSH_READY;
  //config_red_zone (OFF, pop_last_rz);
  //pop_expected_rz = NULL;
  allow_rotate = true;
  //dump();
}


void lynxQ::pop_done(void) {
  return;
}


static inline uint8_t * get_err_ip(const ucontext_t * uc){
    return (uint8_t *)(uc->uc_mcontext.gregs[REG_RIP]);
}

static inline uint64_t get_reg_value(const ucontext_t * uc, int regid){
    switch (regid) {
        case X86_REG_RAX:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RAX]);
        case X86_REG_RBX:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RBX]);
        case X86_REG_RCX:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RCX]);
        case X86_REG_RDX:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RDX]);
        case X86_REG_RDI:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RDI]);
        case X86_REG_RSI:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RSI]);
        case X86_REG_RBP:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RBP]);
        case X86_REG_RSP:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RSP]);
        case X86_REG_R8:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R8 ]);
        case X86_REG_R9:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R9 ]);
        case X86_REG_R10:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R10]);
        case X86_REG_R11:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R11]);
        case X86_REG_R12:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R12]);
        case X86_REG_R13:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R13]);
        case X86_REG_R14:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R14]);
        case X86_REG_R15:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_R15]);
        case X86_REG_RIP:
            return (uint64_t)(uc->uc_mcontext.gregs[REG_RIP]);
        default:
            handle_error("get_reg_value unsupported reg");
            return 0;
    }
}

static inline void set_reg_value(ucontext_t * uc, int regid, uint64_t value, csh handle){
    switch (regid) {
        case X86_REG_RAX:
            uc->uc_mcontext.gregs[REG_RAX] = value;
            break;
        case X86_REG_RBX:
            uc->uc_mcontext.gregs[REG_RBX] = value;
            break;
        case X86_REG_RCX:
            uc->uc_mcontext.gregs[REG_RCX] = value;
            break;
        case X86_REG_RDX:
            uc->uc_mcontext.gregs[REG_RDX] = value;
            break;
        case X86_REG_RDI:
            uc->uc_mcontext.gregs[REG_RDI] = value;
            break;
        case X86_REG_RSI:
            uc->uc_mcontext.gregs[REG_RSI] = value;
            break;
        case X86_REG_RBP:
            uc->uc_mcontext.gregs[REG_RBP] = value;
            break;
        case X86_REG_RSP:
            uc->uc_mcontext.gregs[REG_RSP] = value;
            break;
        case X86_REG_R8:
            uc->uc_mcontext.gregs[REG_R8 ] = value;
            break;
        case X86_REG_R9:
            uc->uc_mcontext.gregs[REG_R9 ] = value;
            break;
        case X86_REG_R10:
            uc->uc_mcontext.gregs[REG_R10] = value;
            break;
        case X86_REG_R11:
            uc->uc_mcontext.gregs[REG_R11] = value;
            break;
        case X86_REG_R12:
            uc->uc_mcontext.gregs[REG_R12] = value;
            break;
        case X86_REG_R13:
            uc->uc_mcontext.gregs[REG_R13] = value;
            break;
        case X86_REG_R14:
            uc->uc_mcontext.gregs[REG_R14] = value;
            break;
        case X86_REG_R15:
            uc->uc_mcontext.gregs[REG_R15] = value;
            break;
        case X86_REG_RIP:
            uc->uc_mcontext.gregs[REG_RIP] = value;
            break;
        default:
            handle_error("set_reg_value unsupported reg");
            break;
    }
}

enum mem_type_t {
  MEM_TYPE_UNINIT,
  STORE_TYPE,
  LOAD_TYPE,
  MEM_TYPE_MAX,
};

static inline cs_x86_op *get_mem_op (cs_insn *insn, csh handle,
				     mem_type_t *mem_type) {
  cs_detail *detail = insn->detail;
  if(!detail)handle_error("capstone detail failed.");
  assert (detail->x86.op_count == 2 && "Why more than one operand?");
  cs_x86_op *mem_op = NULL;
  uint8_t op_i;
  for (op_i = 0; op_i < detail->x86.op_count; ++op_i)
    {
      cs_x86_op *op = &(detail->x86.operands[op_i]);
      if (op->type == X86_OP_MEM) {
	assert (mem_op == NULL && "More than 1 mem operands?");
	mem_op = op;
	*mem_type = (op_i == 0) ? STORE_TYPE : LOAD_TYPE;
      }
    }
  assert (mem_op && "No memory operand?");
  //printf("Instruction: %s\t%s\n", insn[0].mnemonic, insn[0].op_str);
  unsigned mem_op_membase = mem_op->mem.base;
  if (mem_op_membase == X86_REG_INVALID){
    printf("Instruction: %s\t%s\n", insn[0].mnemonic, insn[0].op_str);
    handle_error("unrecognized register");
  }
  return mem_op;
}

/* The registers and their values */
struct Regs {
  unsigned int reg_base;
  unsigned int reg_index;
  unsigned int reg_segment;
  int scale;
  int64_t mem_disp;
  /* reg values */
  uint64_t reg_base_value;
  uint64_t reg_index_value;
  uint64_t reg_segment_value;
};
typedef struct Regs Regs;

/* Collect the register ids and their values into REGS */
static inline void collect_regs (Regs *regs, cs_x86_op *mem_op, csh handle, 
				 const ucontext_t *context) {
  regs->reg_base = mem_op->mem.base;
  regs->reg_index = mem_op->mem.index;
  regs->reg_segment = mem_op->mem.segment;
  regs->scale = mem_op->mem.scale;
  regs->mem_disp = mem_op->mem.disp;

  regs->reg_base_value = get_reg_value (context, regs->reg_base);
  regs->reg_index_value = 0;
  regs->reg_segment_value = 0;
  if (regs->reg_index != X86_REG_INVALID)
    regs->reg_index_value = get_reg_value (context, regs->reg_index);
  if (regs->reg_segment != X86_REG_INVALID)
    regs->reg_segment_value = get_reg_value (context, regs->reg_segment);
  assert (regs->reg_base != INT_MIN && regs->mem_disp != UINT_MAX && "not initialized"); 
}

inline char *lynxQ::get_new_redzone_left (char *curr_redzone) {
  /* This is a circular operation. */
  char *new_redzone = curr_redzone - REDZONE_SIZE;
  if (new_redzone < QUEUE)
    new_redzone = QUEUE + queue_size - REDZONE_SIZE;
  return new_redzone;
}

static inline bool index_is_in_redzone (char *index, char *redzone) {
  return (index == redzone);
}

static inline bool is_expected_redzone (char *index, char *redzone) {
  return (index == redzone); 
}

void setup_signal_handler() {
  /* Set up signal handler */
  struct sigaction act;
  sigset_t sa_mask;
  sigemptyset (&sa_mask);
  act.sa_handler = NULL;
  //act.sa_sigaction = lynxQ_handler;
  act.sa_sigaction = lynxQ_nomprotect_handler;
  act.sa_mask = sa_mask;
  act.sa_flags = SA_SIGINFO;
  act.sa_restorer = NULL;
  sigaction(SIGSEGV, &act, NULL);
}

#ifdef OPERATOR_NEW
lynxQ::lynxQ(size_t qsize, struct prod_queue *pq, struct cons_queue *cq) {
  printf("Creating LynxQ of size %zu | this %p\n", qsize, this);
  /* Add queue into the set of all the queues created so far */
  all_queues_created.insert(this);
  all_queues_set = &all_queues_created;

  /* Get the system's page size */
  _PAGE_SIZE = sysconf (_SC_PAGE_SIZE);
  if (_PAGE_SIZE == -1) fatal_error("sysconf: Error getting page size\n");

  /* The size of the queue must be a power of the page size*/
  queue_size = qsize;

  /* We need the addresses to be aligned with a larger alignment than queue_size.
   This is to allow for the circular address optimization:
   Example: Assuming a queue of size 4, QUEUE_ALIGN is 8.
            Therefore the addresses always have a '0' just before the index part
            to allow for overflow without modifying the rest of the bits.
                              v
            For example addr= 1011 0 01
                             |----|-|--|
                             Address|Index
                                    |
            The         mask= 1111 0 11
            In this way, when the Index part overflows (e.g. 1011 1 00)
            masking resets it to the beginning:              1011 0 00
   This is the computation: ADDR = (ADDR + 1) & QUEUE_CIRCULAR_MASK */
  //QUEUE_ALIGN = queue_size << 1;
  QUEUE_ALIGN = (1 << 12);

  /* We use the minimum redzone possible */
  REDZONE_SIZE = _PAGE_SIZE;

  /* Allocate QUEUE */
  char *Q;
  Q = (char*) this + _PAGE_SIZE;

  QUEUE = Q;

  printf("q %p | q->QUEUE %p\n", this, Q);
  /* Sanity checks */
  if (! (queue_size >= 4 * REDZONE_SIZE)) {
    fatal_error ("Queue (=0x%lx) too small compared to redzone (=0x%lx)\n"
		 "Must be at least 4 * REDZONE_SIZE (=0x%lx)\n",
		 queue_size, REDZONE_SIZE, 4 * REDZONE_SIZE);
  }

  /* Each section is a redzone smaller than half the queue */
  QUEUE_SECTION_SIZE = queue_size / 2 - REDZONE_SIZE;
  QUEUE_ALIGN_MASK = QUEUE_ALIGN - 1;
  QUEUE_CIRCULAR_MASK = (~queue_size);

  //setup_signal_handler();

  /* Set up red zones */
  redzone1 = (char *) config_red_zone (ON, QUEUE + QUEUE_SECTION_SIZE);
  redzone2 = (char *) config_red_zone (ON, QUEUE + 2 * QUEUE_SECTION_SIZE + REDZONE_SIZE);
  redzone_end = (char *) config_red_zone (ON, QUEUE + queue_size);

  /* Initialize queue state */
  qstate.sstate0 = PUSH_WRITES;
  qstate.redzone1_state = FREE;
  qstate.redzone2_state = FREE;
  qstate.num_push = 0;
  qstate.num_pop = 0;

  this->pq_state = pq;
  this->cq_state = cq;
  pq->QUEUE = cq->QUEUE = QUEUE;
  pq->push_index = QUEUE;
  allow_rotate = false;
  cq->pop_index = QUEUE + queue_size;;
  pq->free_push_reg = 0;
  cq->free_pop_reg = 0;

  qstate.sstate0 = POP_READY;
  qstate.sstate1 = POP_READY;

  push_expected_rz = redzone1;
  pop_expected_rz = redzone1 - REDZONE_SIZE;

  /* Initialize timer */
  time_begin = clock();

  push_last_rz = NULL;
  pop_last_rz = NULL;
}
#else
lynxQ::lynxQ(size_t qsize, struct prod_queue *pq, struct cons_queue *cq) {
  printf("Creating LynxQ of size %zu | this %p\n", qsize, this);
  /* Add queue into the set of all the queues created so far */
  all_queues_created.insert(this);
  all_queues_set = &all_queues_created;

  /* Get the system's page size */
  _PAGE_SIZE = sysconf (_SC_PAGE_SIZE);
  if (_PAGE_SIZE == -1) fatal_error("sysconf: Error getting page size\n");

  /* The size of the queue must be a power of the page size*/
  queue_size = qsize;

  /* We need the addresses to be aligned with a larger alignment than queue_size.
   This is to allow for the circular address optimization:
   Example: Assuming a queue of size 4, QUEUE_ALIGN is 8.
            Therefore the addresses always have a '0' just before the index part
            to allow for overflow without modifying the rest of the bits.
                              v
            For example addr= 1011 0 01
                             |----|-|--|
                             Address|Index
                                    |
            The         mask= 1111 0 11
            In this way, when the Index part overflows (e.g. 1011 1 00)
            masking resets it to the beginning:              1011 0 00
   This is the computation: ADDR = (ADDR + 1) & QUEUE_CIRCULAR_MASK */
  //QUEUE_ALIGN = queue_size << 1;
  QUEUE_ALIGN = (1 << 21);

  /* We use the minimum redzone possible */
  REDZONE_SIZE = _PAGE_SIZE;

  /* Allocate QUEUE */
  char *Q;
  int ok = posix_memalign ((void **)&Q, QUEUE_ALIGN, queue_size + REDZONE_SIZE);
  if (ok != 0) {
    fprintf (stderr, "posix_memalign() failed!\n");
    exit(1);
  }
  QUEUE = Q;

  /* Sanity checks */
  if (! (queue_size >= 4 * REDZONE_SIZE)) {
    fatal_error ("Queue (=0x%lx) too small compared to redzone (=0x%lx)\n"
		 "Must be at least 4 * REDZONE_SIZE (=0x%lx)\n",
		 queue_size, REDZONE_SIZE, 4 * REDZONE_SIZE);
  }

  /* Each section is a redzone smaller than half the queue */
  QUEUE_SECTION_SIZE = queue_size / 2 - REDZONE_SIZE;
  QUEUE_ALIGN_MASK = QUEUE_ALIGN - 1;
  QUEUE_CIRCULAR_MASK = (~queue_size);

  /* Set up signal handler */
  struct sigaction act;
  sigset_t sa_mask;
  sigemptyset (&sa_mask);
  act.sa_handler = NULL;
  //act.sa_sigaction = lynxQ_handler;
  act.sa_sigaction = lynxQ_nomprotect_handler;
  act.sa_mask = sa_mask;
  act.sa_flags = SA_SIGINFO;
  act.sa_restorer = NULL;
  sigaction(SIGSEGV, &act, NULL);

  /* Set up red zones */
  redzone1 = (char *) config_red_zone (ON, QUEUE + QUEUE_SECTION_SIZE);
  redzone2 = (char *) config_red_zone (ON, QUEUE + 2 * QUEUE_SECTION_SIZE + REDZONE_SIZE);
  redzone_end = (char *) config_red_zone (ON, QUEUE + queue_size);

  /* Initialize queue state */
  qstate.sstate0 = PUSH_WRITES;
  qstate.redzone1_state = FREE;
  qstate.redzone2_state = FREE;
  qstate.num_push = qstate.num_pop = 0;

  this->pq_state = pq;
  this->cq_state = cq;
  pq->QUEUE = cq->QUEUE = QUEUE;
  pq->push_index = QUEUE;
  allow_rotate = false;
  cq->pop_index = QUEUE + queue_size;;
  pq->free_push_reg = 0;
  cq->free_pop_reg = 0;

  qstate.sstate0 = POP_READY;
  qstate.sstate1 = POP_READY;

  push_expected_rz = redzone1;
  pop_expected_rz = redzone1 - REDZONE_SIZE;

  /* Initialize timer */
  time_begin = clock();

  push_last_rz = NULL;
  pop_last_rz = NULL;
}
#endif

void lynxQ::finalize(void) {
  /* Timer */
  time_end = clock();
  /* Timer for the second thread */
  queue_time = (double)(time_end - time_begin) / (2 * CLOCKS_PER_SEC);
}

double lynxQ::get_time(void) {
  return queue_time;
}

/* ************** HANDLER *************** */

/* Search through all the queues created so far to figure out where the pointer
   belongs to. */
static lynxQ_t get_beginning_of_queue(char *ptr_in_queue) {
  lynxQ_t found_queue = NULL;
  for (qset_t::iterator it = all_queues_created.begin(), ite = all_queues_created.end();
       it != ite; ++it) {
    lynxQ_t queue = *it;
    char *min = queue->QUEUE;
    char *max = min + queue->queue_size + queue->REDZONE_SIZE;
    if (ptr_in_queue >= min && ptr_in_queue < max) {
      assert (! found_queue && "Queues overlap???");
      found_queue = queue;
    }
  }
  return found_queue;
}

static void redzone_do_push(const char *redzone_str,
			    char *index,
			    volatile section_state_t *sstate_prev,
			    volatile section_state_t *sstate_next,
			    char **redzone, char *QUEUE, lynxQ_t queue) {
  queue->last_push_state = sstate_next;
  COMPILER_BARRIER;
  char *new_redzone = queue->get_new_redzone_left(index);
  COMPILER_BARRIER;
  queue->config_red_zone (ON, new_redzone);
  COMPILER_BARRIER;
  queue->push_last_rz = new_redzone;
  COMPILER_BARRIER;
  *redzone = new_redzone;
  COMPILER_BARRIER;
  bool expect_rz1 = (new_redzone == queue->redzone1);
  COMPILER_BARRIER;

  /* Relase previous section */
  *sstate_prev = PUSH_READY;
  COMPILER_BARRIER;
  /* Wait until we can enter the next section */
  while (! (*sstate_next == POP_READY)) {
    ;
  }
  COMPILER_BARRIER;
  /* We now know that the other thread's redzone is set. 
     Set our next expected redzone. */
  queue->push_expected_rz = (expect_rz1) ? queue->redzone2 : queue->redzone1;
  COMPILER_BARRIER;
  /* Release pop() from its trap when we are in redzone1 */
  if (! queue->allow_rotate) {
    queue->allow_rotate = true;
  }
  COMPILER_BARRIER;
  queue->config_red_zone (OFF, index);
  COMPILER_BARRIER;
  *sstate_next = PUSH_WRITES;
  printf("Passing RZ %s | push_expected_rz %p\n", redzone_str, queue->push_expected_rz);
}

static void redzone_do_pop(const char *redzone_str,
			   char *index,
			   volatile section_state_t *sstate_prev,
			   volatile section_state_t *sstate_next,
			   char **redzone, char *QUEUE, lynxQ_t queue) {
  queue->last_pop_state = sstate_next;
  COMPILER_BARRIER;
  char *new_redzone = queue->get_new_redzone_left(index);
  COMPILER_BARRIER;
  queue->config_red_zone (ON, new_redzone);
  COMPILER_BARRIER;
  queue->pop_last_rz = new_redzone;
  COMPILER_BARRIER;
  *redzone = new_redzone;
  COMPILER_BARRIER;
  bool expect_rz1 = (new_redzone == queue->redzone1);
  COMPILER_BARRIER;

  /* Release the section */
  *sstate_prev = POP_READY;
  COMPILER_BARRIER;
  /* Wait until we can enter the next section */
  while (! (*sstate_next & (PUSH_READY | PUSH_EXITED))) {
    ;
  }
  /* We now know that the other thread's redzone is set.
     Set our next expected redzone. */
  COMPILER_BARRIER;
  queue->pop_expected_rz = (expect_rz1) ? queue->redzone2 : queue->redzone1;
  COMPILER_BARRIER;
  queue->config_red_zone (OFF, index);
  COMPILER_BARRIER;
  *sstate_next = POP_READS;
  printf("Passing RZ %s | pop_expected_rz %p\n", redzone_str, queue->pop_expected_rz);
}

struct Memoize_mem_op {
  const uint8_t *ip;
  cs_x86_op *mem_op;
  mem_type_t mem_type;
};

typedef struct Memoize_mem_op Memoize_mem_op_t;

#include <execinfo.h>
void
print_trace (void)
{
  void *array[10];
  char **strings;
  int size, i;

  size = backtrace (array, 10);
  strings = backtrace_symbols (array, size);
  if (strings != NULL)
  {

    printf ("Obtained %d stack frames.\n", size);
    for (i = 0; i < size; i++)
      printf ("%s\n", strings[i]);
  }

  free (strings);
}

/* Raise segmentation fualt signal */
static void segfault (const char *msg, char *index) {

  print_trace();
  fprintf (stderr, msg, index);
  struct sigaction act;
  act.sa_handler = SIG_DFL;
  sigaction (SIGSEGV, &act, 0);
}

std::tuple<csh, cs_x86_op*> decode_insn(const ucontext_t *context, Memoize_mem_op_t *memo) {
  cs_x86_op *mem_op = NULL;
  csh handle;

  const uint8_t *ip = get_err_ip(context);

  if (ip != memo->ip) {
    if (cs_open(CS_ARCH_X86, CS_MODE_64, &handle) != CS_ERR_OK)
      handle_error("capstone cs_open failed");
    cs_option(handle, CS_OPT_DETAIL, CS_OPT_ON);
    cs_insn instobj, * insn = &instobj;
    int count = cs_disasm(handle, ip, 8/*code_size*/, 0x0/*addr*/, 1/*num to disasm*/, &insn);
    if (count == 0)
      handle_error("cs_disasm failed.");

    /* Find the memory operand */
    mem_op = get_mem_op (insn, handle, &memo->mem_type);
    /* Memoize */
    memo->ip = ip;
    memo->mem_op = mem_op;
  }
  else {
    mem_op = memo->mem_op;
  }
  return std::make_pair(handle, mem_op);
}

std::tuple<uint64_t, uint64_t> get_mem_base(
    const ucontext_t *context,
    Memoize_mem_op_t *memo,
    char *base_addr,
    csh handle,
    cs_x86_op *mem_op) {
  Regs regs;
  collect_regs(&regs, mem_op, handle, context);

  unsigned int reg_base_to_update = regs.reg_base;
  assert (reg_base_to_update != X86_REG_INVALID && "ASM supposed to force this");

  uint64_t new_base_value = (uint64_t) base_addr - regs.reg_segment_value -
    regs.mem_disp - regs.reg_index_value * regs.scale;

  uint64_t sum = regs.mem_disp + new_base_value + regs.reg_index_value *
    regs.scale + regs.reg_segment_value;
  assert (sum == (uint64_t) base_addr);

  return std::make_tuple(new_base_value, reg_base_to_update);
}

static void lynxQ_nomprotect_handler(int signal, siginfo_t *info, void *cxt)
{
  static __thread Memoize_mem_op_t memo;
  ucontext_t *context = (ucontext_t *)cxt;

  /* The address that caused the fault. */
  char *index = (char *)info->si_addr;

#if 0
  lynxQ_t queue = get_beginning_of_queue (index);
#else
  lynxQ_t queue = (lynxQ_t)((uint64_t)index & ~((1 << 21) - 1));
  //printf("index %p | queue %p\n", index, queue);
#endif

  if (! queue) {
    //queue->dump();
    segfault ("Index: %p is not in any queue!. "
	      "Probably a segmentation fault of program\n", index);
  }

  auto [handle, mem_op] = decode_insn(context, &memo);

  /* If we are at the end of the QUEUE, rewind the index to the begining. */
  /* NOTE: this has to run first because in the beginning pop() is trapped
           inside redzone_end and therefore the index does not match the 
           pop expected redzone. */
  if (index >= queue->QUEUE + queue->queue_size) {
    auto [new_base_value, reg_base_to_update] =
              get_mem_base(context, &memo, queue->QUEUE, handle, mem_op);
    /* Initially the pop thread is trapped at the end of the queue, until
       the push thread has reached the first redzone. */
    if (queue->allow_rotate) {
      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      if (memo.mem_type == STORE_TYPE) {
        //printf("PUSH queue wrap around\n");
	queue->pq_state->push_index = queue->QUEUE;
      }
      else if (memo.mem_type == LOAD_TYPE) {
        //printf("POP queue wrap around\n");
	queue->cq_state->pop_index = queue->QUEUE;
      }
      else {
	fprintf (stderr, "ERROR: Can't determine which thread it is\n");
      }
    }
  } else if (memo.mem_type == STORE_TYPE) {
    if (index_is_in_redzone(index, queue->redzone1)) {
      //printf("Push RZ1\n");
      // - Check if we can progress to the next section
      // - If so, move and announce that we are in the next section
      // - If not, return RETRY?

      // release previous section
      queue->qstate.sstate0 = PUSH_READY;

      // wait for the next section to be ready
      while (queue->qstate.sstate1 != POP_READY) ;
      // claim next section
      queue->qstate.sstate1 = PUSH_WRITES;
      queue->last_push_state = &queue->qstate.sstate1;
      // move the index pointer past the redzone
      char *new_index = queue->redzone1 + queue->REDZONE_SIZE;

      auto [new_base_value, reg_base_to_update] = get_mem_base(context, &memo,
                new_index, handle, mem_op);

      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      queue->pq_state->push_index = new_index;

      if (! queue->allow_rotate) {
        queue->allow_rotate = true;
      }
    }
    else if (index_is_in_redzone(index, queue->redzone2)) {
      //printf("Push RZ2\n");

      queue->qstate.sstate1 = PUSH_READY;

      while (queue->qstate.sstate0 != POP_READY) ;

      queue->qstate.sstate0 = PUSH_WRITES;

      queue->last_push_state = &queue->qstate.sstate0;

      char *new_index = queue->redzone2 + queue->REDZONE_SIZE;

      auto [new_base_value, reg_base_to_update] = get_mem_base(context, &memo,
                new_index, handle, mem_op);

      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      queue->pq_state->push_index = new_index;

      if (! queue->allow_rotate) {
        queue->allow_rotate = true;
      }
    }
    else {
      fprintf(stderr, "\n\n");
      queue->dump();
      segfault("*** PUSH: Index %p not in red-zone. This is a program bug ***\n", index);
    }
  } else if (memo.mem_type == LOAD_TYPE) {
    if (index_is_in_redzone(index, queue->redzone1)) {
      //printf("Pop RZ1\n");
      queue->qstate.sstate0 = POP_READY;

      while (! (queue->qstate.sstate1 & (PUSH_READY | PUSH_EXITED))) ;

      queue->qstate.sstate1 = POP_READS;

      char *new_index = queue->redzone1 + queue->REDZONE_SIZE;

      auto [new_base_value, reg_base_to_update] = get_mem_base(
          context, &memo, new_index, handle, mem_op);

      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      queue->cq_state->pop_index = new_index;
    }
    else if (index_is_in_redzone(index, queue->redzone2)) {
      //printf("Pop RZ2\n");
      queue->qstate.sstate1 = POP_READY;

      while (! (queue->qstate.sstate0 & (PUSH_READY | PUSH_EXITED))) ;

      queue->qstate.sstate0 = POP_READS;
      char *new_index = queue->redzone2 + queue->REDZONE_SIZE;

      auto [new_base_value, reg_base_to_update] = get_mem_base(
          context, &memo, new_index, handle, mem_op);

      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      queue->cq_state->pop_index = new_index;
    }
    /* The index is not in the queue's red zone. This is a program bug. */
    else {
      fprintf(stderr, "\n\n");
      queue->dump();
      segfault ("*** POP: Index %p not in red-zone. This is a program bug. ***\n", index);
    }
  } else {
    fprintf (stderr, "Not push() or pop()!!!\n");
    queue->dump();
    segfault("*** Cannot detemine if %p is in push_expected_rz or pop_expected_rz. ***\n", index);
  }
}

static void lynxQ_handler(int signal, siginfo_t *info, void *cxt)
{
  static __thread Memoize_mem_op_t memo;
  ucontext_t *context = (ucontext_t *)cxt;

  /* Find which register is the index register */
  const uint8_t *ip = get_err_ip(context);

  /* The address that caused the fault. */
  char *index = (char *)info->si_addr;

  lynxQ_t queue = get_beginning_of_queue (index);

  if (! queue) {
    //queue->dump();
    segfault ("Index: %p is not in any queue!. "
	      "Probably a segmentation fault of program\n", index);
  }


  /* If we are at the end of the QUEUE, rewind the index to the begining. */
  /* NOTE: this has to run first because in the beginning pop() is trapped
           inside redzone_end and therefore the index does not match the 
           pop expected redzone. */
  if (index >= queue->QUEUE + queue->queue_size) {
    auto [handle, mem_op] = decode_insn(context, &memo);
    auto [new_base_value, reg_base_to_update] =
              get_mem_base(context, &memo, queue->QUEUE, handle, mem_op);
    /* Initially the pop thread is trapped at the end of the queue, until
       the push thread has reached the first redzone. */
    if (queue->allow_rotate) {
      set_reg_value (context, reg_base_to_update, new_base_value, handle);

      if (memo.mem_type == STORE_TYPE) {
        //auto old_push_reg = queue->pq_state->free_push_reg;
//        printf("free_push_reg old: %lx | new %lx push_index 0x%p\n",
 //             old_push_reg, queue->pq_state->free_push_reg, queue->pq_state->push_index);
	queue->pq_state->push_index = queue->QUEUE;
	queue->pq_state->free_push_reg -= queue->queue_size;
      }
      else if (memo.mem_type == LOAD_TYPE) {
        //auto old_pop_reg = queue->cq_state->free_pop_reg;
	queue->cq_state->free_pop_reg -= queue->queue_size;
        //printf("free_pop_reg old: %lx | new %lx pop_index 0x%p\n",
        //      old_pop_reg, queue->cq_state->free_pop_reg, queue->cq_state->pop_index);
	queue->cq_state->pop_index = queue->QUEUE;
      }
      else {
	fprintf (stderr, "ERROR: Can't determine which thread it is\n");
      }
    }
  }
  else if (is_expected_redzone (index, queue->push_expected_rz)) {
      if (index_is_in_redzone(index, queue->redzone1)) {
	redzone_do_push("REDZONE 1", index,
			&queue->qstate.sstate0, &queue->qstate.sstate1,
			&queue->redzone1, queue->QUEUE, queue);
      }
      else if (index_is_in_redzone(index, queue->redzone2)) {
	redzone_do_push("REDZONE 2", index,
			&queue->qstate.sstate1, &queue->qstate.sstate0,
			&queue->redzone2, queue->QUEUE, queue);
      }
      else {
	fprintf(stderr, "\n\n");
	queue->dump();
	segfault("*** PUSH: Index %p not in red-zone. This is a program bug ***\n", index);
      }
    }
  else if (is_expected_redzone (index, queue->pop_expected_rz)) {
      if (queue->allow_rotate) {
	if (index_is_in_redzone(index, queue->redzone1)) {
#if 0
          if (! (queue->qstate.sstate1 & (PUSH_READY | PUSH_EXITED))) {
            queue->cq_state->in_redzone = true;
            return;
          }
#endif
	  redzone_do_pop("REDZONE 1", index,
			 &queue->qstate.sstate0, &queue->qstate.sstate1,
			 &queue->redzone1, queue->QUEUE, queue);
	}
	else if (index_is_in_redzone(index, queue->redzone2)) {
#if 0
          if (! (queue->qstate.sstate0 & (PUSH_READY | PUSH_EXITED))) {
            queue->cq_state->in_redzone = true;
            return;
          }
#endif
	  redzone_do_pop("REDZONE 2", index,
			 &queue->qstate.sstate1, &queue->qstate.sstate0,
			 &queue->redzone2, queue->QUEUE, queue);
	}
	/* The index is not in the queue's red zone. This is a program bug. */
	else {
	  fprintf(stderr, "\n\n");
	  queue->dump();
	  segfault ("*** POP: Index %p not in red-zone. This is a program bug. ***\n", index);
	}
      }
    }
  else {
    fprintf (stderr, "Not push() or pop()!!!\n");
    queue->dump();
    segfault("*** Cannot detemine if %p is in push_expected_rz or pop_expected_rz. ***\n", index);
  }
}

class LynxQueue {
  public:
    typedef struct prod_queue prod_queue_t;
    typedef struct cons_queue cons_queue_t;

  private:
    size_t queue_size;
    uint32_t nprod;
    uint32_t ncons;

    std::map<std::tuple<int, int>, prod_queue_t*> pqueue_map;
    std::map<std::tuple<int, int>, cons_queue_t*> cqueue_map;
    std::map<std::tuple<int, int>, queue_t*> queue_map;
    queue_t ***queues;

  public:
    prod_queue_t **all_pqueues;
    cons_queue_t **all_cqueues;

    static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;

    void init_prod_queues() {
      // map queues and producer_metadata
      for (auto p = 0u; p < nprod; p++) {
        // Queue Allocation
        //auto pqueues = (prod_queue_t *)utils::zero_aligned_alloc(
        //    FIPC_CACHE_LINE_SIZE, ncons * sizeof(prod_queue_t));
        auto pqueues = (prod_queue_t *)calloc(
            1, ncons * sizeof(prod_queue_t));
        all_pqueues[p] = pqueues;
        for (auto c = 0u; c < ncons; c++) {
          prod_queue_t *pq = &pqueues[c];
          pqueue_map.insert({std::make_tuple(p, c), pq});
        }
      }
    }

    void init_cons_queues() {
      // map queues and consumer_metadata
      for (auto c = 0u; c < ncons; c++) {
        //auto cqueues = (cons_queue_t *)utils::zero_aligned_alloc(
        //    FIPC_CACHE_LINE_SIZE, nprod * sizeof(cons_queue_t));
        auto cqueues = (cons_queue_t *)calloc(
            1, nprod * sizeof(cons_queue_t));
        all_cqueues[c] = cqueues;
        for (auto p = 0u; p < nprod; p++) {
          cons_queue_t *cq = &cqueues[p];
          cqueue_map.insert({std::make_tuple(p, c), cq});
        }
      }
    }


    explicit LynxQueue(uint32_t nprod, uint32_t ncons, size_t queue_size) {

      printf("%s, lynx queue init | queue_sz %zu\n", __func__, queue_size);

      this->queue_size = queue_size;
      this->nprod = nprod;
      this->ncons = ncons;
      //this->all_pqueues = (prod_queue_t **)utils::zero_aligned_alloc(
      //  FIPC_CACHE_LINE_SIZE, nprod * sizeof(prod_queue_t*));

      this->all_pqueues = (prod_queue_t **)calloc(
        1, nprod * sizeof(prod_queue_t*));

      //this->all_cqueues = (cons_queue_t **)utils::zero_aligned_alloc(
      //  FIPC_CACHE_LINE_SIZE, ncons * sizeof(cons_queue_t*));

      this->all_cqueues = (cons_queue_t **)calloc(
        1, ncons * sizeof(cons_queue_t*));

      this->init_prod_queues();
      this->init_cons_queues();

      this->queues = (queue_t ***)calloc(1, nprod * sizeof(queue_t*));

      for (auto p = 0u; p < nprod; p++) {
        //this->queues[p] = (queue_t **)aligned_alloc(
        //    FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t*));
        this->queues[p] = (queue_t **)calloc(1, ncons * sizeof(queue_t*));
        printf("allocating %zu bytes %p\n", ncons * sizeof(queue_t*), this->queues[p]);
        for (auto c = 0u; c < ncons; c++) {
          printf("%s, &queues[%d][%d] %p\n", __func__, p, c, &queues[p][c]);
          auto pq = pqueue_map.at(std::make_tuple(p, c));
          auto cq = cqueue_map.at(std::make_tuple(p, c));
         // queues[p][c] = new queue_t(queue_size, pq, cq);

          queues[p][c] = new(queue_size) queue_t(queue_size, pq, cq);
          //queue_map.insert({std::make_tuple(p, c), q});
        }
      }
      queues[0][0]->dump();
    }

    inline void prefetch(uint32_t p, uint32_t c, bool is_prod)  {
      auto q = queues[p][c];
      if (is_prod) {
        auto pq = &all_pqueues[p][c];
        if (((uint64_t)pq->push_index & 0x3f) == 0) {
          __builtin_prefetch(pq->push_index + 64, 1, 3);
        }
        auto nc = ((c + 1) >= ncons) ? 0: (c + 1);
        auto npq = queues[p][nc];
        __builtin_prefetch(npq->pq_state, 0, 3);
      } else {
        // auto cq = q->cq_state;
        //auto np = ((p + 1) >= nprod) ? 0: (p + 1);
        //auto ncq = queues[np][c];
        //__builtin_prefetch(ncq->cq_state, 0, 3);
        auto cq = &all_cqueues[c][p];
        if (cq->pop_index != q->redzone_end) {
        __builtin_prefetch(cq->pop_index + 0, 1, 3);
        __builtin_prefetch(cq->pop_index + 64, 1, 3);
        __builtin_prefetch(cq->pop_index + 128, 1, 3);
        }
      }
    }

    inline int enqueue(uint32_t p, uint32_t c, data_t value)  {
      auto pq = &all_pqueues[p][c];
      auto q = queues[p][c];

#if 0
      if (!((uint64_t)pq->push_index & ((1 << 13) - 1)))
      printf("pq->push_index 0x%lx | push_reg 0x%lx | value %" PRIu64 "\n",
            pq->push_index, pq->free_push_reg, value);
#endif
      pq->push(value);

      return SUCCESS;
    }

    inline int dequeue(uint32_t p, uint32_t c, data_t *value) {
      int ret = SUCCESS;
      auto cq = &all_cqueues[c][p];
      auto q = queues[p][c];

      *value = cq->pop_long();
#if 0
      if (!((uint64_t)cq->pop_index & ((1 << 12) - 1)))
        printf("cq->pop_index 0x%lx | pop_reg 0x%lx | ea 0x%lx | value %" PRIu64 "\n",
                cq->pop_index, cq->free_pop_reg,
                (uint64_t)cq->pop_index + cq->free_pop_reg,
                *value);
#endif
#if 0
      if (cq->in_redzone) {
        ret = RETRY;
        cq->in_redzone = false;
      }
#endif
      return ret;
    }

    inline void push_done(uint32_t p, uint32_t c) {
      auto q = queues[p][c];

      enqueue(p, c, BQ_MAGIC_64BIT);
      //q->push(BQ_MAGIC_64BIT, q->pq_state);
      q->push_done();
    }

    void pop_done(uint32_t p, uint32_t c) {
      auto q = queues[p][c];
      q->pop_done();
    }

    void finalize(uint32_t p, uint32_t c) {
      auto q = queues[p][c];
      q->finalize();
    }

    double get_time(uint32_t p, uint32_t c) {
      auto q = queues[p][c];
      return q->get_time();
    }

    void dump_stats(uint32_t p, uint32_t c) {
    }
};
} // namespace
