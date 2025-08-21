


# L1 
    103,058,982,866      L1D_PEND_MISS.FB_FULL                                                 
    157,206,660,913       cycles
# L2
    65,420,730,016      L1D_PEND_MISS.FB_FULL                                                 
    157,895,761,565       cycles
# double L2+L1
    72,760,820,736      L1D_PEND_MISS.FB_FULL                                                 
    157,525,348,520       cycles    
# double L1+L1
    102,364,280,820      L1D_PEND_MISS.FB_FULL                                                 
    157,748,918,781       cycles

Seems we missed an important detail:
https://www.felixcloutier.com/x86/prefetchh

L1 prefetch: T0 (temporal data)—prefetch data into all levels of the cache hierarchy.
*ALL DATA HIERCHY* ie L1,L2,L3
L2 prefetch: prefetch data into level 2 cache and higher.
*Level 2 AND HIGHER* ie L1,L2

https://www.intel.com/content/www/us/en/content-details/671488/intel-64-and-ia-32-architectures-optimization-reference-manual-volume-1.html

"NOTE
At the time of PREFETCH, if data is already found in a cache level that is closer to the
processor than the cache level specified by the instruction, no data movement occurs"

We see less more L1 misses during double prefetch...

Seems we see most hits with double prefetch.
However this doesnt seem to be only imporant thing, since we also see higher hits with double L1
and we dont see improvement, must be a mix of too much lfb stalls which lead to bad pipelining and more L1 hits.


