#!/bin/env python

if __name__ == '__main__':
    for p in range(0, 33, 4):
        num_lines = p * 16
        print(f'./dramhit --ht-type=3 --mode=11 --ht-fill=75 --num-threads=64 --skew=0.01 --numa-split=1 --pollute-ratio={p} > pollute-chtpp-{num_lines}')
        print(f'./dramhit --ht-type=3 --mode=11 --ht-fill=75 --num-threads=64 --skew=0.01 --numa-split=1 --pollute-ratio={p} --no-prefetch=1 > pollute-cht-{num_lines}')

        nc = 48
        np = 64 - nc
        print(f'./dramhit --ht-type=1 --mode=8 --ht-fill=75 --ncons={nc} --nprod={np} --skew=0.01 --p-read=0.0 --numa-split=3 --pollute-ratio={p} > pollute-queues{nc}-{num_lines}')
