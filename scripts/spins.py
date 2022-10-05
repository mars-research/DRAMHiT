#!/usr/bin/env python

import sys
import re

def main():
    if len(sys.argv) != 2:
        return

    enq = 0
    deq = 0
    for line in open(sys.argv[1]).readlines():
        m = re.search(r"enq spins (\d+) \| numdequeue spins (\d+)", line)
        if m != None:
            enq += int(m[1])
            deq += int(m[2])

    print(f'Enqueue: {enq}, Dequeue: {deq}')

if __name__ == '__main__':
    main()
