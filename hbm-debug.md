Hashtable Core algorithm


# Interface

`insert_batch` and `find_batch` 

Dramblast has a async batching interfaces,
where all requests to hashtable will be submit 
and returned in batches where each item in the
batch will have a ID. This interface allows 
prefetch engine to interleave compute instructions 
such as hashing and memory access instruction (prefetch)
at ALL fills.  

# Fill factor

As fill factor increases, reprobe factor of given 
request goes up. A given request can reprobe,
we treat reprobe request as another cache line access
thus Async allows us to repeatively access memory 
(thus lower efficacy of the cpu parallel pipeline). 

Imagine a given item can reprobe many times, 
if we use synchronous interface, we must keep 
access new cachelines, and all other requests 
has already been fullfilled, now the amount of 
compute instruciton left are very few.

# HBM challenges

We have a lot of bandwidth, latency is the same
aorund 130ns to 160ns per request. 
So we need to leverage this, hbm machine can achieve 
420 gb/s read, but hashtable find can only achieve
maybe half of this

# Cycle budget base on memory bandwidth

Cycle_Budget = Num_CPU * Freq_Ghz * 64 / Memory_BW 
HBM with 64 threads (from 1 package).
26 cycle per cacheline.

Currently we are only achieve memory bandwidth of 250gb/s 
which 44 cycle per cacheline.

# Some ideas

- Let us use the cpu from the second socket. 
The problem here, I have observed degradtion from using 
microbenchmark (no prefetch engine or anything, just randomly access).
But maybe it is not a problem here because we are not fully saturating.

- optimize the code further (remain single socket).














