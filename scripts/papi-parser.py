import json
import sys
import collections

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: papi-parser.py <log file>')

    log = json.load(open(sys.argv[1], 'r'))
    results = collections.defaultdict(lambda : collections.defaultdict(lambda : 0))
    for thread in log['threads']:
        for region in thread['regions']:
            for name in region.keys():
                for event in region[name]:
                    results[name][event] += int(region[name][event])

    for region in results:
        print(region)
        for event in results[region]:
            print(f"\t{event}: {results[region][event]}")
