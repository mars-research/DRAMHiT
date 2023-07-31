#!/usr/bin/env python3

from matplotlib import pyplot as plt
import matplotlib as mpl
import numpy as np
import pandas as pd
import re
import sys

args = sys.argv[1:]
print(args)

# create valid markers from mpl.markers
valid_markers = ([item[0] for item in mpl.markers.MarkerStyle.markers.items() if 
item[1] is not 'nothing' and not item[1].startswith('tick') 
and not item[1].startswith('caret')])


p = re.compile(r'(\w+[\s\w+]*): ([\d]+)')
IDX_key = 'IDX'
HIST_key = 'building hist'
SWB_key = 'SWB'
Timestamp_key = 'Timestamp'
Partition_alloc = 'Partition_alloc'

lines = [ line for line in open('dramhit.log') if (all(arg in line for arg in args))]
ds = []
for line in lines:
    d = {}
    for (key, val) in re.findall(p, line):
        d[key] = int(val)
    ds.append(d)
ds.sort(key=lambda d:d[IDX_key])
ds = pd.DataFrame(ds)
print("Columns: " + ds.columns)
# ds.set_index(IDX_key)

# use fillable markers
# valid_markers = mpl.markers.MarkerStyle.filled_markers

markers = np.random.choice(valid_markers, ds.shape[1], replace=False)

y_set = args 
for y_key in y_set:
    ds[y_key] = ds[y_key] - ds[y_key].mean()
ax = ds.plot(x=IDX_key, y=y_set)
ax.set_xticks(list(ds[IDX_key]))
for i, line in enumerate(ax.get_lines()):
    line.set_marker(markers[i])
ax.legend(ax.get_lines(), y_set, loc='best')
plt.show()
print(ds)
# fig, ax = plt.subplots()
# ax.plot(x, y)
# plt.show()
