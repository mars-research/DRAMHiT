#!/bin/env python3

import sys

skew = float(sys.argv[1])
for p in [n / 10 for n in range(9)]:
    print(f'./kvstore --ht-type=3 --mode=12 --ht-fill=75 --num-threads=64 --skew={skew} --p-read={p} --numa-split=1 > chtpp-{p}')
    print(f'./kvstore --ht-type=3 --mode=12 --ht-fill=75 --num-threads=64 --skew={skew} --p-read={p} --numa-split=1 --no-prefetch=1 > cht-{p}')

    for c in [8 * (n + 1) for n in range(7)]:
        for n in range(3):
            print(f'./kvstore --ht-type=1 --mode=8 --ht-fill=75 --ncons={c} --nprod={64 - c} --skew={skew} --p-read={p} --numa-split=3 > queues-{p}-{c}-{n}')
