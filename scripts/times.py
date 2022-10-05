from statistics import *
import re

values = []
for line in open('log.log').readlines():
    match = re.search(r"\[TIME\](\d*)", line)
    if match != None:
        values.append(int(match[1]))

print(mean(values), median(values), min(values), max(values))
