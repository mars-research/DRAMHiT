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
    tests_home = source.joinpath('tests/rw-ratios')
    if not tests_home.exists():
        exit()

    cashtpp_home = tests_home.joinpath('casht++')
    part_home = tests_home.joinpath('part')
    bq_home = tests_home.joinpath('bq')

    part_times = []
    cashtpp_times = []
    bq_times = []
    ratios = [p / (1 - p) for p in (n * 0.1 for n in range(int(1 / 0.1)))]

    for r in ratios:
        cashtpp_times.append(get_times(cashtpp_home.joinpath(f'{r}.log'))[0])
        part_times.append(get_times(part_home.joinpath(f'{r}.log'))[0])
        tmp_list = []
        for c_count in range(8, 57, 4):
            tmp_list.append(get_times(bq_home.joinpath(f'{r}-{c_count}.log'))[0])

        bq_times.append(max(tmp_list))

    print(list(zip(ratios, cashtpp_times, part_times, bq_times)))
    # print(f'Casht++: {cashtpp_times}')
    # print(f'Casht: {casht_times}')
    # print(f'Bqueue: {bq_times}')
