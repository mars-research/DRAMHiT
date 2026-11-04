# Deep vectorization HBM optimization plan


TODO;
we need to confirm and investigate the truth value of following 
hypothesis, and what condition that they hold true, remember
those are uniform distributions.


we need a table of each incremental technique and measure 
instruciton count on hotpath, and break down asm inst types.

 -> Restore the table


# concrete, rajeev assginemtn. 

schedule model is probably would be better than gem5.

collect info.
emulate this specific cpu. 
--- create a faith scheudle ->  reason about scheule -?> binary rewrite



- clarify vec_ld and ld.
|version|inst count| LD | ST | REGISTER | VEC | etc ...


- using negative mask, andn because andn is not destructive in the sense that override
the resgiter value original register value. 

bmi1

idx = hash & bmask
 
      // bucket index = hash & bmask, written as andn(~bmask, hash): BMI1 andn has 3
      // operands, so the mask register is not copied before every AND
      const uint32_t nbmask = ~bmask;
      // byte offset of a hash's bucket: andn(~bmask) then << 4 (sizeof(KV)) in one asm, so bmask is never
      // needed (only nbmask is live) and the 32-bit index is not copied to another register before the shift
      static_assert(sizeof(KV) == 16, "bucket byte offset = index << 4");
      const auto hoff = [nbmask](uint32_t h) -> uint64_t {
        uint64_t r;
        __asm__("andnl %2, %1, %k0\n\tshlq $4, %0" : "=&r"(r) : "r"(nbmask), "rm"(h));
        return r;
      };

save a resgiter transfer. 
but this seems like becuase we used a outdated compiler.
we need to upgrade our compiler.

- using direct memory address calculation rather than storing idx. 

description: we used to keep track of tail and head for queue logic.
But it is easier to directly keep track of address rather than idices
this saves some shifting logic. let us you keep index in your register, 
then when you need to access the mmeory location for the quue, yo would 
need to shift this register. but if we directly store the address into 
the register, we can save this shift operation.

queue[tial] tail = 10. queue_base + tail << sizeof(elemtn)).


- using kadd rather than kshift for shifting operation on hit register.

description: hit is a 8 bit register indicated matched key for a cacheline. we do a shift by 1 bit 
to get the location of value.

hypothesis: using kadd reduce port 5 pressure which is shown through static and dynamic data collection
using perf. 

- using avx instruction that directly cmpare memory against another register rather than do a load into register then compare two axv register. 

#ifdef CAS_FIND_EMBCAST
        // compare straight against the entry ({1to8} memory broadcast); the
        // key is reloaded from q only on the retry path
        key_cmp = cmp_key_bcast(cacheline, &q->key);
#else
        key = q->key;
        key_vector = _mm512_set1_epi64(key);
        key_cmp = _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
#endif


you need at least 2 instruction to compare 2 cacheline in avx.
1 instruction load the cacheline into a zmm register, then a vpcmp to compare 
this register against a memory location with a custom selection vector. 

Notes on avx512 broadcast:

In AVX-512, you often do not need a separate broadcast instruction or set1 at all.
AVX-512 allows arithmetic and logic instructions to embed a 32-bit or 64-bit scalar broadcast directly inside the memory operand using EVEX bit manipulation ({1to16} for 32-bit floats/ints, {1to8} for 64-bit floats/ints):


This can relieve register pressure, assume key vector is in the l1 cache and no reprobe, 
then not loading into a register can save instructions and relieve avx512 register pressure.


## Research ideas

Register pressure
scalar vs deep vec

- one technique failed is using a 128bit store for results on scalar but suceed on deep vec. 
The explanation was essentially deep vec and scalar code has different register pressure
scalar code used more register thus using 128bit store didn't save end up saving store instruction. 
but succeed in deep vec.

- make find queue store address directly rather than hash or idx to reduce shifting 
oepration and arthmatic.

- use a new compiler, maybe most of the performnace optimization will be just from an outdated compiler.

LLM have much better grasp over assembly, the general instruction that might just work on any binary is just. 

1. find hot functions under a workload.
2. analysis of the hot assembly path using perf and static tool to understand cpu port pressure
3. General strategies  with concrete goals such as

- find alternative instructions to reduce instruction count (sometimes compiler fails)
- find alternative isntructions to relieve register pressure 

essentially LLM as a compiler optimizaton pass.








