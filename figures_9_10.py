#!/bin/python3

import os
import sys
from utilities import get_home, run_synchronous

if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/figures_9_10')
    if tests_home.exists():
        print('Please remove build tree first')
        exit()

    tests_home.mkdir(parents=True)
    cashtpp_home = tests_home.joinpath('casht++', 'build')
    bq_home = tests_home.joinpath('bq', 'build')

    print('Building casht++', flush=True)
    cashtpp_home.mkdir(parents=True)
    run_synchronous(cashtpp_home, 'cmake', [
                    source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DHASHER=crc'])

    run_synchronous(cashtpp_home, 'cmake', ['--build', '.'])

    print('Building bq', flush=True)
    bq_home.mkdir(parents=True)
    run_synchronous(bq_home, 'cmake', [source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release',
                    '-DHASHER=crc', '-DBRANCH=branched', '-DBQ_ZIPFIAN=ON', '-DBQUEUE=ON'])

    run_synchronous(bq_home, 'cmake', ['--build', '.'])

    skews = [0.0, 0.25, 0.5, 0.75, 1.0]
    for s in skews:
        print(f'Running cashtpp-{s}', flush=True)
        run_synchronous(cashtpp_home, './kvstore', ['--mode=11', '--ht-fill=75', f'--num-threads=64', '--ht-type=3', f'--skew={s}', f'--stats={s}.log'])

        for c_count in range(2, 58, 4):
            print(f'Running bq-{s}-{c_count}', flush=True)
            run_synchronous(bq_home, './kvstore', ['--mode=8', '--ht-fill=75', f'--ncons={c_count}', f'--nprod={64 - c_count}', '--ht-type=1', f'--skew={s}', f'--stats={s}-{c_count}.log'])

    print(list(zip(skews, cashtpp_times, bq_times)))