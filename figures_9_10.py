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


if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/figures_9_10')
    if tests_home.exists():
        print('Please remove build tree first')
        exit()

    tests_home.mkdir(parents=True)
    casht_home = tests_home.joinpath('casht', 'build')
    cashtpp_home = tests_home.joinpath('casht++', 'build')

    print('Building casht++', flush=True)
    cashtpp_home.mkdir(parents=True)
    run_synchronous(cashtpp_home, 'cmake', [
                    source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DVTUNE=ON'])
    run_synchronous(cashtpp_home, 'cmake', ['--build', '.'])

    print('Building casht', flush=True)
    casht_home.mkdir(parents=True)
    run_synchronous(casht_home, 'cmake', [
                    source, '-GNinja', '-DCMAKE_BUILD_TYPE=Release', '-DPREFETCH=OFF', '-DVTUNE=ON'])
    run_synchronous(casht_home, 'cmake', ['--build', '.'])

    scripts = source.joinpath('scripts')
    hugepages = scripts.joinpath('enable_hugepages.sh')
    constant_freq = scripts.joinpath('constant_freq.sh')
    hyperthreading = scripts.joinpath('toggle_hyperthreading.sh')
    prefetch = scripts.joinpath('prefetch_control.sh')
    run_synchronous(source, 'sudo', [hugepages])
    run_synchronous(source, 'sudo', [constant_freq])
    run_synchronous(source, 'sudo', [hyperthreading, 'on'])
    run_synchronous(source, 'sudo', [prefetch, 'off'])

    for n in [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99]:
        print(f'Running cashtpp{n}', flush=True)
        run_synchronous(cashtpp_home, './kmercounter', ['--mode=11', '--ht-fill=75',
                        f'--num-threads=64', '--ht-type=3', f'--skew={n}'], os.open(cashtpp_home.parent.joinpath(f'{n}.log'), os.O_RDWR | os.O_CREAT))

        print(f'Running casht{n}', flush=True)
        run_synchronous(casht_home, './kmercounter', ['--mode=11', '--ht-fill=75',
                        '--num-threads=64', '--ht-type=3', f'--skew={n}'], os.open(casht_home.parent.joinpath(f'{n}.log'), os.O_RDWR | os.O_CREAT))
