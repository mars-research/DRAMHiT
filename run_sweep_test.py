#!/bin/python3

import argparse
import os
import pathlib
import re
import shutil
import sys
import typing

TEST_BUILD_DIR='test/sweep_test';

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
            print(f'exit status: {state}, Signal? {state & 0xff}')
            raise FatalError()

def setup_system(src_dir: str):
    scripts = source.joinpath('scripts')
    hugepages = scripts.joinpath('enable_hugepages.sh')
    constant_freq = scripts.joinpath('constant_freq.sh')
    hyperthreading = scripts.joinpath('toggle_hyperthreading.sh')
    prefetch = scripts.joinpath('prefetch_control.sh')
    run_synchronous(source, 'sudo', [hugepages])
    run_synchronous(source, 'sudo', [constant_freq])
    run_synchronous(source, 'sudo', [hyperthreading, 'on'])
    run_synchronous(source, 'sudo', [prefetch, 'off'])

def get_additional_args(n: int, args: argparse.Namespace):
    extra_cmdline_args = []
    if args.small_ht == True:
        ht_size = 2 * (1 << 20)
        extra_cmdline_args += [f'--ht-size={ht_size}'] #, f'--insert-factor={n}']
    if args.skew:
        extra_cmdline_args += [f'--skew={args.skew}']
        if args.ht_type != 1:
            extra_cmdline_args += [ '--mode=11']
    return extra_cmdline_args

def get_insert_find_mops(logfile: pathlib.Path):
    file = open(logfile)
    text = ''.join(file.readlines())
    file.close()
    insert = float(re.search(
        r'Number of insertions per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
    find = float(re.search(
        r'Number of finds per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
    return insert, find

def dumplog(log_dir: str):
    with open(log_dir.parent.joinpath('summary.csv'), 'w') as csv:
        csv.write(f'num threads, set mops/s, get mops/s\n')
        num_threads = 64 + 1
        if log_dir == part_home:
            num_threads = 32 + 1
        for n in range(1, num_threads):
            if log_dir == part_home:
                logfile = log_dir.parent.joinpath(f'p{n}-n{n}.log')
            else:
                logfile = log_dir.parent.joinpath(f'{n}.log')
            set, get = get_insert_find_mops(logfile)
            if log_dir == part_home:
                format_str = f'{n}-{n}, {set}, {get}'
            else:
                format_str = f'{n}, {set}, {get}'
            print(format_str)
            csv.write(format_str + '\n')


def run_partitioned(build_dir: str, args: argparse.Namespace):
    print('Running partitioned', flush=True)
    for n in range(1, 33):
        partitioned_args = ['--mode=8', f'--nprod={n}', f'--ncons={n}', '--ht-type=1']
        partitioned_args += get_additional_args(n, args)
        logfile = build_dir.parent.joinpath(f'p{n}-n{n}.log')
        print(f'Running bq{n} with {partitioned_args}', flush=True)
        run_synchronous(build_dir, './kvstore', partitioned_args, os.open(logfile, os.O_RDWR | os.O_CREAT))
    dumplog(build_dir)

def run_cashtpp(build_dir: str, args: argparse.Namespace):
    print(f'Running cashtpp', flush=True)
    for n in range(1, 64 + 1):
        cashtpp_args = [f'--num-threads={n}', '--ht-type=3', '--numa-split=1']
        if not args.skew:
            cashtpp_args += [ '--mode=6' ]
        cashtpp_args += get_additional_args(n, args)
        print(f'Running cashtpp{n} with {cashtpp_args}', flush=True)
        logfile = cashtpp_home.parent.joinpath(f'{n}.log')
        run_synchronous(build_dir, './kvstore', cashtpp_args, os.open(logfile, os.O_RDWR | os.O_CREAT))

    dumplog(cashtpp_home)

def run_casht(build_dir: str, args: argparse.Namespace):
    print(f'Running casht', flush=True)
    for n in range(1, 64 + 1):
        casht_args = [f'--num-threads={n}', '--ht-type=3', '--numa-split=1']
        #if args.skew:
        #    casht_args += ['--mode=6']
        casht_args += get_additional_args(n, args)
        logfile = casht_home.parent.joinpath(f'{n}.log')
        print(f'Running casht{n} with {casht_args}', flush=True)
        run_synchronous(build_dir, './kvstore', casht_args, os.open(logfile, os.O_RDWR | os.O_CREAT))
    dumplog(casht_home)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run sweep test')
    parser.add_argument('--small_ht', action='store_true', help='Run tests on small-sized hashtable (32 MiB)')
    parser.add_argument('--clean', action='store_true', help='Perform a clean build if dir is present')
    parser.add_argument('--ht_type', nargs='?', type=int, choices=range(1, 4), help='1 - Partitioned, 2 - Casht, 3 - Casht++', required=True)
    parser.add_argument('--xorwow', action='store_true', help='Insert random keys (generated using xorwow)')
    parser.add_argument('--dumplog', action='store_true', help='Dump the log without running')
    parser.add_argument('--skew', nargs='?', type=float, help='Skew for zipfian')

    args = parser.parse_args()

    source = get_home()
    tests_home = source.joinpath(TEST_BUILD_DIR)

    if tests_home.exists():
        if args.clean == True:
            shutil.rmtree(tests_home)
        else:
            print('Please remove build tree first')
            #exit()

    tests_home.mkdir(parents=True, exist_ok=True)
    casht_home = tests_home.joinpath('casht', 'build')
    cashtpp_home = tests_home.joinpath('casht++', 'build')
    part_home = tests_home.joinpath('partitioned', 'build')

    setup_system(source)

    additional_build_args = []
    if args.xorwow:
        additional_build_args += [ '-DXORWOW=ON' ]
    if args.skew and args.ht_type == 1:
        additional_build_args += [ '-DBQ_ZIPFIAN=ON' ]

    if args.dumplog:
        logdir = ''

        match args.ht_type:
            case 1:
                logdir = part_home
            case 2:
                logdir = casht_home
            case 3:
                logdir = cashtpp_home
        dumplog(logdir)
        sys.exit(1)

    match args.ht_type:
        case 1:
            print('Building partitioned', flush=True)
            part_home.mkdir(parents=True, exist_ok=True)
            run_synchronous(part_home, 'cmake', [
                            source, '-GNinja', '-DPREFETCH=ON', '-DBRANCH=branched', '-DBQUEUE=ON'] + additional_build_args)
            run_synchronous(part_home, 'cmake', ['--build', '.'])
            run_partitioned(part_home, args)

        case 2:
            print('Building casht', flush=True)
            casht_home.mkdir(parents=True, exist_ok=True)
            run_synchronous(casht_home, 'cmake', [
                            source, '-GNinja', '-DPREFETCH=OFF'] + additional_build_args)
            run_synchronous(casht_home, 'cmake', ['--build', '.'])
            run_casht(casht_home, args)

        case 3:
            print('Building casht++', flush=True)
            cashtpp_home.mkdir(parents=True, exist_ok=True)
            run_synchronous(cashtpp_home, 'cmake', [
                            source, '-GNinja', '-DPREFETCH=ON'] + additional_build_args)
            run_synchronous(cashtpp_home, 'cmake', ['--build', '.'])

            run_cashtpp(cashtpp_home, args)
