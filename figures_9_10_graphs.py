#!/bin/python3

import pathlib
import os
import shutil
import re


def get_home() -> pathlib.Path:
    return pathlib.Path(os.path.dirname(os.path.realpath(__file__)))


def get_times(logfile: str):
    file = open(logfile)
    text = ''.join(file.readlines())
    file.close()
    insert = float(re.match(r'Number of insertions per sec \(Mops/s\): (?P<mops>[0-9]*\.[0-9]*\)', text)['mops'])
    find = float(re.match(r'Number of finds per sec (Mops/s): (?P<mops>[0-9]*\.[0-9]*\)', text)['mops'])
    return insert, find

if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/figures_9_10')
    if not tests_home.exists():
        exit()

    tests_home.mkdir(parents=True)
    casht_home = tests_home.joinpath('casht')
    cashtpp_home = tests_home.joinpath('casht++')
    partitioned_home = tests_home.joinpath('partitioned')

    for i in [1, 2, 4, 8, 16, 32, 64]:
        if i != 1:
            print(get_times(partitioned_home.joinpath(f'{i}.log')))

        print(get_times(cashtpp_home.joinpath(f'{i}.log')))
        print(get_times(casht_home.joinpath(f'{i}.log')))

