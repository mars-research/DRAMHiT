#!/bin/env python

for p in [n / 10 for n in range(9)]:
    for c in [8 * (n + 1) for n in range(7)]:
        print(f'./kvstore --ht-type=1 --mode=8 --ht-fill=75 --ncons={c} --nprod={64 - c} --skew=0.01 --p-read={p} --numa-split=3 > queues-{p}-{c}.log')
