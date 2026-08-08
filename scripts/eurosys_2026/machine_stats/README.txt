
If we abandon latency measurement, simply use memory bandwidth as measurement
to infer latency.


If we trust lfb model, and lfb number as 16 on intel, and trust memory bandwidth (we collect use counters).
Then we should be able to infer latency of different prefetch instructions.

64 * freq * lfb_sz * processor / bandwidth

1 cpu, prefetch test, we get latency. (This is not loaded)
>>> 64 * 2.5 * 16 / 14
182.85714285714286

All 32 cpu, system are loaded, we get latency
>>> 64 * 2.5 * 16 * 32 / 250
327.68


In this case, the data would suggest on intel, different prefetch instructions
have different latencies ....


collect over 100 ms,

t1, idle:
     3.512279900         25,704,145      unc_m_cas_count.all
t1, idle, ht:
     3.616278176         30,170,840      unc_m_cas_count.all

t0, idle:
     3.616803843         22,022,179      unc_m_cas_count.all
t0, idle, ht:
     3.718389818         23,919,081      unc_m_cas_count.all

The above suggest, prefetchT1 has better latency from cpu persepective.
t0 improve likely just some other cpu resources, not from lack of issuing power into lfb.

Prefetcht1 though, the improve are significant enough, there might be a suggestion that a single thread
might not issue fast enough to fully utilize the lfb, as prefetchT1 drops latency. Thus the
queue drains faster...

245gb/s is the memory bandwidth limit for a single socket machine.

t0, loaded:
     1.323520668        390,796,256      unc_m_cas_count.all
t0, loaded, ht:
     2.240268601        392,030,807      unc_m_cas_count.all
t1, loaded:
     1.223006190        389,923,312      unc_m_cas_count.all
t1, loaded, ht:
     2.445917612        391,277,683      unc_m_cas_count.all

Saturate memory bandwidth.
