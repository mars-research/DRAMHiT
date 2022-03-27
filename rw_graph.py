#!/bin/python

import os
import sys
from utilities import get_home, run_synchronous

if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/p-reads')
    if tests_home.exists():
        print('Please remove build tree first')
        exit()

    tests_home.mkdir(parents=True)
    cashtpp_home = tests_home.joinpath('casht++', 'build')
    part_home = tests_home.joinpath('part', 'build')
    bq_home = tests_home.joinpath('bq', 'build')

    print('Building casht++', flush=True)
    cashtpp_home.mkdir(parents=True)
    run_synchronous(cashtpp_home, 'cmake', [
                    source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DHASHER=crc'])

    run_synchronous(cashtpp_home, 'cmake', ['--build', '.'])

    print('Building part', flush=True)
    part_home.mkdir(parents=True)
    run_synchronous(part_home, 'cmake', [
                    source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DHASHER=crc'])

    run_synchronous(part_home, 'cmake', ['--build', '.'])

    print('Building bq', flush=True)
    bq_home.mkdir(parents=True)
    run_synchronous(bq_home, 'cmake', [source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release',
                    '-DHASHER=crc', '-DBRANCH=branched', '-DBQ_RW=ON', '-DBQUEUE=ON'])

    run_synchronous(bq_home, 'cmake', ['--build', '.'])

    probs = [0.0, 0.25, 0.5, 0.75, 1.0]
    skews = [0.0, 0.5, 0.95]
    for s in skews:
        for r in probs:
            print(f'Running cashtpp-{r}-{s}', flush=True)
            run_synchronous(cashtpp_home, './kvstore', ['--mode=12', '--ht-fill=75', f'--num-threads=64', '--ht-type=3', f'--p-read={r}', f'--skew={s}', f'--stats={r}-{s}.log'])

            for c_count in range(2, 58, 4):
                print(f'Running bq-{r}-{s}-{c_count}', flush=True)
                run_synchronous(bq_home, './kvstore', ['--mode=8', '--ht-fill=75', f'--ncons={c_count}', f'--nprod={64 - c_count}', '--ht-type=1', f'--p-read={r}', f'--skew={s}', f'--stats={r}-{s}-{c_count}.log'])
