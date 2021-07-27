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
    skews = [0.0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.99]

    for i in skews:
        cashtpp_times.append(get_times(cashtpp_home.joinpath(f'{i}.log'))[0])
        casht_times.append(get_times(casht_home.joinpath(f'{i}.log'))[0])

    print(f'Casht++: {cashtpp_times}')
    print(f'Casht: {casht_times}')
