

Quick todo
-[] (development task) rewrite syn_test (uniform data test), copy zipfian remove zipfian logic.
-[] (development task) intel tbb, 4GB runs out of memory, trouble shoot
-[] (data collection) macro zipfian data 
-[] (data collection) kmer data  
-[] (data collection) recollect dual socket data for optimization experiment: inline, prefetches, reduce branch, prefetch engine
-[] (data collection) collect insertion for optimization experiment: inline, prefetches, reduce branch

'''
    import sys

    if len(sys.argv) < 2:
        print("Usage: python script.py <output.json>")
        sys.exit(1)

    out_file = sys.argv[1]
'''

# COLLECT data on SNOOP MODE, don't forget to chande 'mode' to 14, also Add to run_all script
[X] collect_inline, jerry did it
[X] collect_prefetch_engine, done
[O] collect_reprobes, prolly dont need it
[ ] macro_kmer, xiangdong on it
[X] collect_insertion
[X] collect_prefetches
[X] collect_rpq
[ ] macro_uniform
[ ] collect_lfb
[ ] collect_reduce_branch
[X] macro_hashjoin
[ ] macro_zipfian



# meeting notes

    
finalize reprobe experiments

- drop clht
- benchmark insert
- modify growt, then run larger hashtable.