




hbm machine support. 

for non partition approach, 
- we need to make sure kmer loaded are in hugeapges.
also need to ensure kmer output is correct.

need to make sure ht_helper.h calloc_ht distribute memory 
correctly base on policy. Need to think about this one, 
what is the correct behavior.
