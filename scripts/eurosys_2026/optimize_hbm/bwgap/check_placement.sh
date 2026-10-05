#!/usr/bin/env bash
# Where do the program's pages live while it runs? Samples /proc/<pid>/numa_maps and sums pages per NUMA node.
#   check_placement.sh <label> <delay_s> <command...>
# (4 KiB pages counted as pages, hugetlb mappings by their own page size: the script prints bytes per node.)
label=$1; delay=$2; shift 2
"$@" > /dev/null 2>&1 &
pid=$!
sleep "$delay"
sudo python3 - "$pid" "$label" <<'PY'
import re, sys, collections
pid, label = sys.argv[1], sys.argv[2]
tot = collections.defaultdict(lambda: collections.defaultdict(int))
for blk in open(f"/proc/{pid}/numa_maps"):
    kind = "hugetlb" if "huge" in blk else ("stack" if "stack" in blk else ("heap" if "heap" in blk else ("file" if "file=" in blk else "anon4k")))
    m = re.search(r"kernelpagesize_kB=(\d+)", blk); ps = int(m.group(1)) * 1024 if m else 4096
    for n, c in re.findall(r"\bN(\d+)=(\d+)", blk):
        tot[kind][int(n)] += int(c) * ps
print(f"== {label} (pid {pid}) bytes per node, by mapping kind")
for kind, d in sorted(tot.items()):
    print(f"  {kind:8s}", {n: f"{b/2**20:.1f} MiB" for n, b in sorted(d.items())})
PY
wait $pid 2>/dev/null
