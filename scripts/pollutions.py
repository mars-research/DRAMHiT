#!/bin/env python

if __name__ == '__main__':
    for i in range(40):
        p = i * 2
        print(f'./kvstore --ht-type=3 --mode=11 --ht-fill=75 --num-threads=64 --skew=0.01 --numa-split=1 --pollute-ratio={p} > pollute-chtpp-{p}')
        print(f'./kvstore --ht-type=3 --mode=11 --ht-fill=75 --num-threads=64 --skew=0.01 --numa-split=1 --pollute-ratio={p} --no-prefetch=1 > pollute-cht-{p}')
        
        for j in range(1, 8):
            nc = j * 8
            np = 64 - nc
            print(f'./kvstore --ht-type=1 --mode=8 --ht-fill=75 --ncons={nc} --nprod={np} --skew=0.01 --p-read=0.0 --numa-split=3 --pollute-ratio={p} > pollute-queues{nc}-{p}')
