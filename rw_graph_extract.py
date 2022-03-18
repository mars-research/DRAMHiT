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
    times = eval(text)
    file.close()    
    return times['any']


if __name__ == '__main__':
    source = get_home()
    tests_home = source.joinpath('tests/p-reads')
    if not tests_home.exists():
        exit()

    cashtpp_home = tests_home.joinpath('casht++/build')
    part_home = tests_home.joinpath('part/build')
    bq_home = tests_home.joinpath('bq/build')

    part_times = []
    cashtpp_times = []
    bq_times = []
    ratios = [0.0, 0.25, 0.5, 0.75, 1.0]

    for r in ratios:
        cashtpp_times.append(get_times(cashtpp_home.joinpath(f'{r}.log')))
        part_times.append(get_times(part_home.joinpath(f'{r}.log')))
        tmp_list = []
        for c_count in range(2, 58, 4):
            tmp_list.append((get_times(bq_home.joinpath(f'{r}-{c_count}.log')), c_count))

        best = max(tmp_list, key=lambda t : t[0])
        print(f'{r}: {best[1]}')
        bq_times.append(best[0])

    print(list(zip(ratios, cashtpp_times, part_times, bq_times)))
    # print(f'Casht++: {cashtpp_times}')
    # print(f'Casht: {casht_times}')
    # print(f'Bqueue: {bq_times}')
