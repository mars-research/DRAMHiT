#!/bin/python

import os
from utilities import get_home, run_synchronous

if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/rw-ratios')
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
                    '-DHASHER=crc', '-DBRANCH=simd', '-DBQ_RW=ON', '-DBQUEUE=ON'])

    run_synchronous(bq_home, 'cmake', ['--build', '.'])

    scripts = source.joinpath('scripts')
    hugepages = scripts.joinpath('enable_hugepages.sh')
    constant_freq = scripts.joinpath('constant_freq.sh')
    hyperthreading = scripts.joinpath('toggle_hyperthreading.sh')
    prefetch = scripts.joinpath('prefetch_control.sh')
    run_synchronous(source, 'sudo', [hugepages])
    run_synchronous(source, 'sudo', [constant_freq])
    run_synchronous(source, 'sudo', [hyperthreading, 'on'])
    run_synchronous(source, 'sudo', [prefetch, 'off'])

    ratios = [p / (1 - p) for p in (n * 0.1 for n in range(int(1 / 0.1)))]
    for n in ratios:
        # print(f'Running cashtpp{n}', flush=True)
        # chtpp_log = os.open(cashtpp_home.parent.joinpath(
        #     f'{n}.log'), os.O_RDWR | os.O_CREAT)

        # run_synchronous(cashtpp_home, './kvstore', ['--mode=12', '--ht-fill=75',
        #                 f'--num-threads=64', '--ht-type=3', f'--rw-ratio={n}'], chtpp_log)

        print(f'Running bq{n}', flush=True)
        bq_log = os.open(bq_home.parent.joinpath(
            f'{n}.log'), os.O_RDWR | os.O_CREAT)

        run_synchronous(bq_home, './kvstore', ['--mode=8', '--ht-fill=75',
                        '--ncons=32', '--nprod=32', '--ht-type=1', f'--rw-ratio={n}'], bq_log)
