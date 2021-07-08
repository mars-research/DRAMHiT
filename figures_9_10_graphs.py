#!/bin/python3

import pathlib
import os
import shutil
import re


def get_home() -> pathlib.Path:
    return pathlib.Path(os.path.dirname(os.path.realpath(__file__)))


def get_times(logfile: pathlib.Path):
    file = open(logfile)
    text = ''.join(file.readlines())
    file.close()
    insert = float(re.search(
        r'Number of insertions per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
    find = float(re.search(
        r'Number of finds per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
    return insert, find


if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/figures_9_10')
    if not tests_home.exists():
        exit()

    casht_home = tests_home.joinpath('casht')
    cashtpp_home = tests_home.joinpath('casht++')
    partitioned_home = tests_home.joinpath('partitioned')

    casht_times = []
    cashtpp_times = []
    partitioned_times = []
    threads = [1, 2, 4, 8, 16, 32, 64]

    for i in threads:
        if i != 1:
            partitioned_times.append(
                get_times(partitioned_home.joinpath(f'{i}.log')))

        cashtpp_times.append(get_times(cashtpp_home.joinpath(f'{i}.log')))
        casht_times.append(get_times(casht_home.joinpath(f'{i}.log')))

    print('Partitioned:')
    for i in range(len(threads) - 1):
        print(f'\t{threads[i + 1]} threads:')
        insert, find = partitioned_times[i]
        print(f'\t\tInsertion: {insert} Mops/s')
        print(f'\t\tLookup: {find} Mops/s')

    print('Casht++:')
    for i in range(len(threads)):
        print(f'\t{threads[i]} threads:')
        insert, find = cashtpp_times[i]
        print(f'\t\tInsertion: {insert} Mops/s')
        print(f'\t\tLookup: {find} Mops/s')

    print('Casht++:')
    for i in range(len(threads)):
        print(f'\t{threads[i]} threads:')
        insert, find = casht_times[i]
        print(f'\t\tInsertion: {insert} Mops/s')
        print(f'\t\tLookup: {find} Mops/s')
