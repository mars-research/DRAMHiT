




- deep vectorizartion 
- cpu emulation
- hyperthreading investigation on dramhit. 

## Debugging

- under report-unocre and report-throttling, it claims the power limit throttle cpu freq not the temperature.
Then why throttle at all, what is the reason behind this freq throttle. Why package power limit set so low if 
it does not even affect temperature of the chip. 



# mathematical relationship


- energy / line
- throughput: cycle / line
- time = 1 / core_freq

From a fix power 350W, energy/time, so that means, for a fix time slice,
we only have limit of energy to spend, if we have more instruction to execute
over that time slice (and if those instruction equates to more energy), 
we must have issued less lines, thus decrease throughput. 

This however, does not explain why core freq drops. 

# compounding effect why achieve 280 gb/s rather than 391 gb/s on dramhit


26 cycle per line 
32 cycle per 1.25 line 

From fb_full report:
391 / 275 = 1.42 = 1.18 (core clock 2.51 / 2.13) × 1.21 (cycles per line 31.8 / 26.3).
This suggests bw degradation are two things, 

1. freq degradation due to hitting power limit

dymaic power = a * C * v^2 * f.
Since power is constant at 350W, seems to be reasonable to assume more capacitance 
(more transistor) are being activated on dramblast.

- how is alpha and instruction/s related ?

alpha probably directly (linearly) relates to IPC.

2. higher cycle budget due to more complex dramblast logic

We have concrete ideas of those logic accounts for added cycle
- Store returning keys accounts for ~2 cycles.
- Read request keys accounts for ~3 cycles.
They seems to be reasonable performance that can not be avoid,
and the latency is the same as accessing l1.


Hard stats

51 inst/line vs 14 inst/line


## Open research

- [x] Investigate uncore mesh frequency drop condition. (report-throttling.md)
- [x] More instruction trimming
  
- [] Mitigate fb_full, the idea here is to explore, is it possible 
to write the code in such a way that prefetch instruction never 
result in fb_full. Meaning, assume we have a way knowing lfb 
status at all time (and it cost nothing performance wise), can we 
write the code to be effecient ? 

Even if we knows, lfb status at all time, we would also need to 
know what lines are cached in l1, so we can issue associated compute 
instructions. There might be a limit here, for example 
if l1 has capacity of 64 cachelines, that means we can really only issue
compute instructions related to 64 find opeartions. 
Is this enough for lfb to drain ? There are a lot more theoretical things 
to think about here. PLus, all assumption are not correct, because 
we don't have any meaningful way to know lfb status, nor what 
cache line is being held in zero performance cost way. 

Prefetch engine seems to be the closet things ....

- [] possibel instruction swap base on energy per op. 

If we have a way to know what each instruction cost in term energy,
and if two instruction does the same things, or a sequence of small 
cost energy instruction can do same thing as a high enegy cost instruction.
We might be able to just use the less energy cost instruction to do the same things. 
We can build a benchmark like a loop of issue the same operation, and measure
energy cost per op. Note, this is different than instruction trimming, 
as reduce number of instruction is obviously a direct way to be energy 
efficient. 


# This is used for human to write down his/her thoughts on the subject


## WHat we know

Processor gets hot -> Frequency drops -> Memory bandwidth drops -> Performance drops.

## Why processor gets hot

There are multiple sources, leakage (static) and capacitance (dynamic).
Dynamic power relates to prcessor freq. (comp arch 101) 
Chip gets too hot, processor freq must drop to protect itself.

### The idea

Dramblast as a workload roughly does 2 things

compute (hashtable logic) + memory (read/load cachelines)

All of those instructions consumes energy as it 
needs to activate different electronic component.

Energy efficiency concept, nJ/op. We want to 
reduce this because that means each operation 
waste less energy, processor can run cooler, thus 
frequency can stay.

However, we must do it without sacraficing performance.

### Application metric

We need a way to monitor 

cpu stalls due to memory operation
This should be kept low, almost to 0, per find op.

Prefetch engine has one job

---> To ensure the compute instruction (like compare instruciton
that check if key matches) hit cache.

The implementation uses
- prefetches
- async + batching property to mitigate high level reprobe.
aka. if a request reprobes a lot, cpu can always start processing other requests.
