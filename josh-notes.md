
u1399218@node-0:/opt/DRAMHiT$ ./u.sh large single-local 64

/opt/DRAMHiT/build/dramhit --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv --find_queue 64 --ht-fill 70 --ht-type 3 --insert-factor 1 --read-factor 500 --read-snapshot 1 --num-threads 64 --numa-split 4 --no-prefetch 0 --mode 11 --ht-size 536870912 --skew 0.01 --hw-pref 0 --batch-len 16

sudo /usr/bin/perf stat -I 1000 -e "L1D_PEND_MISS.FB_FULL, CYCLE_ACTIVITY.STALLS_L1D_MISS, CYCLE_ACTIVITY.STALLS_L2_MISS, CYCLE_ACTIVITY.STALLS_L3_MISS" -- /opt/DRAMHiT/build/dramhit --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv --find_queue 64 --ht-fill 70 --ht-type 3 --insert-factor 1 --read-factor 500 --read-snapshot 1 --num-threads 64 --numa-split 4 --no-prefetch 0 --mode 11 --ht-size 536870912 --skew 0.01 --hw-pref 0 --batch-len 16

# Duble pref
    60.059974859     63,726,011,260      L1D_PEND_MISS.FB_FULL                                                 
    60.059974859      2,383,513,622      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    60.059974859         18,141,864      MEM_LOAD_RETIRED.FB_HIT                                               
    61.060974401     61,069,415,782      L1D_PEND_MISS.FB_FULL                                                 
    61.060974401      2,307,701,466      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    61.060974401         18,240,126      MEM_LOAD_RETIRED.FB_HIT                                               
    62.061971599     64,247,230,679      L1D_PEND_MISS.FB_FULL                                                 
    62.061971599      2,407,650,858      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    62.061971599         18,508,935      MEM_LOAD_RETIRED.FB_HIT  


# pure l2                              
    61.061972924     47,129,142,266      L1D_PEND_MISS.FB_FULL                                                 
    61.061972924      1,846,884,670      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    61.061972924         33,172,079      MEM_LOAD_RETIRED.FB_HIT                                               
    62.062970748     47,854,167,191      L1D_PEND_MISS.FB_FULL                                                 
    62.062970748      1,860,546,434      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    62.062970748         32,837,064      MEM_LOAD_RETIRED.FB_HIT                                               
    63.063970896     47,124,542,220      L1D_PEND_MISS.FB_FULL                                                 
    63.063970896      1,848,048,482      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    63.063970896         31,665,149      MEM_LOAD_RETIRED.FB_HIT                                               
    64.064970411     47,313,128,980      L1D_PEND_MISS.FB_FULL                                                 
    64.064970411      1,851,307,665      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    64.064970411         31,912,958      MEM_LOAD_RETIRED.FB_HIT                                               
    65.065978604     47,422,642,450      L1D_PEND_MISS.FB_FULL                                                 
    65.065978604      1,851,715,017      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    65.065978604         30,127,527      MEM_LOAD_RETIRED.FB_HIT                                               
    66.066970222     48,125,960,942      L1D_PEND_MISS.FB_FULL                                                 
    66.066970222      1,875,693,443      L1D_PEND_MISS.

# L1 only
74.080961591     76,560,157,067      L1D_PEND_MISS.FB_FULL                                                 
    74.080961591      1,920,677,202      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    74.080961591         84,267,209      MEM_LOAD_RETIRED.FB_HIT                                               
    75.081961134     76,939,435,021      L1D_PEND_MISS.FB_FULL                                                 
    75.081961134      1,911,650,803      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    75.081961134         85,264,129      MEM_LOAD_RETIRED.FB_HIT                                               
    76.082963599     75,338,114,226      L1D_PEND_MISS.FB_FULL                                                 
    76.082963599      1,887,185,072      L1D_PEND_MISS.FB_FULL_PERIODS                                         
    76.082963599         81,859,476      MEM_LOAD_RETIRED.FB_HIT           


# checking stalls

# L1 only:
    42.041962116     74,617,214,692      L1D_PEND_MISS.FB_FULL                                                 
    42.041962116      2,070,518,129       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    42.041962116        695,256,817       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    43.042961115     73,795,565,561      L1D_PEND_MISS.FB_FULL                                                 
    43.042961115      2,059,923,229       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    43.042961115        681,283,926       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    44.043958795     74,408,309,193      L1D_PEND_MISS.FB_FULL                                                 
    44.043958795      2,131,128,153       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    44.043958795        735,481,618       CYCLE_ACTIVITY.STALLS_L2_MISS  

# double
    53.052965415     63,484,297,443      L1D_PEND_MISS.FB_FULL                                                 
    53.052965415      1,889,901,815       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    53.052965415        657,838,666       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    54.053961206     62,847,157,986      L1D_PEND_MISS.FB_FULL                                                 
    54.053961206      1,861,252,529       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    54.053961206        630,387,262       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    55.054963610     62,651,045,683      L1D_PEND_MISS.FB_FULL                                                 
    55.054963610      1,816,418,641       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    55.054963610        603,212,885       CYCLE_ACTIVITY.STALLS_L2_MIS

# L2 only

 63.062959656     46,315,443,359      L1D_PEND_MISS.FB_FULL                                                 
    63.062959656      7,544,957,515       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    63.062959656      1,925,004,230       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    64.063960167     46,930,953,167      L1D_PEND_MISS.FB_FULL                                                 
    64.063960167      7,563,594,842       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    64.063960167      1,910,085,905       CYCLE_ACTIVITY.STALLS_L2_MISS                                        
    65.064959892     46,644,256,675      L1D_PEND_MISS.FB_FULL                                                 
    65.064959892      7,534,230,993       CYCLE_ACTIVITY.STALLS_L1D_MISS                                       
    65.064959892      1,892,950,673       CYCLE_ACTIVITY.STALLS_L2_MISS 