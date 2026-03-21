# AMD bw collection
perf stat -a -M umc_mem_bandwidth -I 1000 -- 0 \
/opt/DRAMHiT/build/dramhit --find_queue 64 --ht-fill 70 \
--ht-type 3 --insert-factor 100 --read-factor 100 --num-threads 64 \
--numa-split 4 --no-prefetch 0 --mode 11 --ht-size 536870912 \
--skew 0.01 --hw-pref 0 --batch-len 16
