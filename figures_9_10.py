#!/bin/python3

import os
import typing
import pathlib


def get_home() -> pathlib.Path:
    return pathlib.Path(os.path.dirname(os.path.realpath(__file__)))


class FatalError(BaseException):
    pass


def run_synchronous(cwd: str, command: str, args: typing.List[str], log: int = os.open('log.log', os.O_RDWR | os.O_CREAT)):
    cmake_pid = os.fork()
    if cmake_pid == 0:
        if log > 2:
            os.dup2(log, 1)
        os.chdir(cwd)
        os.execvp(command, [command] + args)
    else:
        _, state = os.wait()
        if state != 0:
            raise FatalError()

def run_cmake(cwd: str, source: str, args: typing.List[str]):
    run_synchronous(cwd, 'cmake', [source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DHASHER=crc'] + args)
    run_synchronous(cwd, 'cmake', ['--build', '.'])


if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/figures_9_10')
    if tests_home.exists():
        print('Please remove build tree first')
        exit()

    tests_home.mkdir(parents=True)
    casht_home = tests_home.joinpath('casht', 'build')
    cashtpp_home = tests_home.joinpath('casht++', 'build')
    bq_home = tests_home.joinpath('bq', 'build')

    print('Building casht++', flush=True)
    cashtpp_home.mkdir(parents=True)
    run_cmake(cashtpp_home, source, ['-DPREFETCH=ON'])    

    print('Building casht', flush=True)
    casht_home.mkdir(parents=True)
    run_cmake(casht_home, source, ['-DPREFETCH=OFF'])

    print('Building bq', flush=True)
    bq_home.mkdir(parents=True)
    run_cmake(bq_home, source, ['-DPREFETCH=ON', '-DBRANCH=simd', '-DBQUEUE=ON', '-DBQ_ZIPFIAN=ON'])

    points = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99]
    for n in points:
        print(f'Running cashtpp{n}', flush=True)
        run_synchronous(cashtpp_home, './kvstore', ['--mode=11', '--ht-fill=75',
                        f'--num-threads=64', '--ht-type=3', f'--skew={n}'], os.open(cashtpp_home.parent.joinpath(f'{n}.log'), os.O_RDWR | os.O_CREAT))

        print(f'Running casht{n}', flush=True)
        run_synchronous(casht_home, './kvstore', ['--mode=11', '--ht-fill=75',
                        '--num-threads=64', '--ht-type=3', f'--skew={n}'], os.open(casht_home.parent.joinpath(f'{n}.log'), os.O_RDWR | os.O_CREAT))

        print(f'Running bq{n}', flush=True)
        run_synchronous(bq_home, './kvstore', ['--mode=8', '--ht-fill=75',
                        '--ncons=32', '--nprod=32', '--ht-type=1', f'--skew={n}'], os.open(bq_home.parent.joinpath(f'{n}.log'), os.O_RDWR | os.O_CREAT))
