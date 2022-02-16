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
    print(text)
    times = eval(text)
    file.close()    
    return times['any']


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
        cashtpp_times.append(get_times(cashtpp_home.joinpath(f'{r}.log')))
        part_times.append(get_times(part_home.joinpath(f'{r}.log')))
        tmp_list = []
        for c_count in range(8, 57, 4):
            tmp_list.append(get_times(bq_home.joinpath(f'{r}-{c_count}.log')))

        bq_times.append(max(tmp_list))

    print(list(zip(ratios, cashtpp_times, part_times, bq_times)))
    # print(f'Casht++: {cashtpp_times}')
    # print(f'Casht: {casht_times}')
    # print(f'Bqueue: {bq_times}')
