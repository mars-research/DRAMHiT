#!/usr/bin/env python3

from collections import defaultdict
from matplotlib import pyplot as plt
# import matplotlib as mpl
# import numpy as np
import pandas as pd
import re
import os

drange = range(6, 17)
filename = "dramhit_{}.log"
p = re.compile(r'.*IDX: (\d+), radix: (\d+) partition_time: (.*), partition_cycles: (\d+), total_kmer_partition: (\d+), cycles_per_partition: (\d+), first_barrier: (\d+), insertion time: (.*), insertion_cycles: (\d+), time_per_insertion: (.*), cycles_per_insertion: (\d+), total_kmer_insertion: (\d+), second_barrier: (\d+)')


load = re.compile(r'IDX: (\d+), cap: (\d+), fill: (\d+)');
MOPS_KEY = "MOPS"
D_KEY = "radix"
IDX_KEY = "idx"
LOADF_KEY = "_load_factor"
P_CYCLES_KEY = "_p_cycles"
P_CYCLES_PER_KEY = "_p_cycles_per"
I_CYCLES_KEY = "_i_cycles"
I_CYCLES_PER_KEY = "_i_cycles_per"
TOTAL_KMER_PART_KEY = "_total_kmer_partition"
TOTAL_KMER_INSERTION_KEY = "_total_kmer_insertion"
FB_KEY = "_first_barrier"
SB_KEY = "_second_barrier"
result = []
idx_range = range(0, 64)

for i in drange:
    # print("D = {}".format(i))
    data = {}
    data[D_KEY] = i

    logfile = filename.format(i)
    with open(logfile, 'rb') as myfile:
        if os.path.getsize(logfile) > 200:
            myfile.seek(-200, 2)
        line = myfile.readlines()[-1].decode("utf-8").strip()
    MOPS = float(line)

    # print(MOPS)

    data[MOPS_KEY] = MOPS
    f = open(logfile, 'r')
    # lines = f.readlines()
    data[IDX_KEY] = defaultdict()

    for l in f: 
        m = p.search(l)
        if m:
            idx = m.group(1)
            assert (int(idx) >= 0 and int(idx) < 64)
            data.setdefault(idx, defaultdict())

            radix = int(m.group(2))
            assert radix == i

            p_cycles = int(m.group(4))
            data[idx + P_CYCLES_KEY] = p_cycles

            total_kmer_partition = int(m.group(5))
            data[idx + TOTAL_KMER_PART_KEY] = total_kmer_partition

            cycles_per_partition = m.group(6)
            data[idx+P_CYCLES_PER_KEY] = int(cycles_per_partition)

            first_barrier = int(m.group(7))
            data[idx+FB_KEY] = first_barrier

            insertion_cycles = int(m.group(9))
            data[idx+I_CYCLES_KEY] = insertion_cycles

            cycles_per_insertion = int(m.group(11))
            data[idx+I_CYCLES_PER_KEY] = cycles_per_insertion

            total_kmer_insertion = int(m.group(12))
            data[idx+TOTAL_KMER_INSERTION_KEY] = total_kmer_insertion

            second_barrier = int(m.group(13))
            data[idx + SB_KEY] = second_barrier
        else:
            m = load.search(l)
            if m:
                idx = m.group(1)
                cap = float(m.group(2))
                fill = float(m.group(3))
                # data.setdefault(idx, defaultdict())
                data.setdefault(idx + LOADF_KEY, [])
                data[idx + LOADF_KEY].append(fill / cap) 
                # print("idx: {}, load factor: {}".format(idx, fill/cap))
    result.append(data)
df = pd.DataFrame(result)
df[[D_KEY, MOPS_KEY]].to_csv("MOPS.csv")

currentPlotting = I_CYCLES_PER_KEY
currentPlotting = SB_KEY
currentPlotting = TOTAL_KMER_PART_KEY
currentPlotting = TOTAL_KMER_INSERTION_KEY
currentPlotting = P_CYCLES_KEY
currentPlotting = I_CYCLES_KEY
currentPlotting = I_CYCLES_PER_KEY
# currentPlotting = FB_KEY

li = []
for i in idx_range:
    name = str(i) + currentPlotting
    d = df.rename(columns={name: currentPlotting})[[D_KEY,  currentPlotting]]
    # d.rename(columns={name: p_cycles_per_key})
    li.append(d)
# df[[D_KEY, FB_KEY]].plot()
df_con = pd.concat(li, axis=0)
print(df_con)
i8 = df_con.loc[df_con[D_KEY] == 8][currentPlotting].sum()
i16 = df_con.loc[df_con[D_KEY] == 16][currentPlotting].sum()
print("i8  " , i8)
print("i16 " , i16)
#
#
# currentPlotting = P_CYCLES_KEY
# li = []
# for i in idx_range:
#     name = str(i) + currentPlotting
#     d = df.rename(columns={name: currentPlotting})[[D_KEY,  currentPlotting]]
#     # d.rename(columns={name: p_cycles_per_key})
#     li.append(d)
# # df[[D_KEY, FB_KEY]].plot()
# df_con = pd.concat(li, axis=0)
#
# p8 = df_con.loc[df_con[D_KEY] == 8][currentPlotting].sum()
# p16 = df_con.loc[df_con[D_KEY] == 16][currentPlotting].sum()
# print("p8  ", p8)
# print("p16 ", p16)
# print("2 * p8 + i16 = ", 2 * p8 + i16)
# print(" p8 + i8 =     ",  p8 + i8)

boxplot = df_con.boxplot(column=[currentPlotting], by=[D_KEY])
plt.savefig('foo.png')

# df.set_index(D_KEY, inplace=True)
# plt.show()
# df = df.transpose()
df.to_csv("res.csv")
# print(df_con)


