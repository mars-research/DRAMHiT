"""Bin perf-script samples (ip sym) of find_batch(span<FindArgument>) in attempt11/dvs by code region.
Address ranges are read off attempt11/dvs/find_batch.s (valid only for that binary: md5 in dvs/md5.txt)."""
import collections, re, sys
R = [("pop, hit path (4 completions: probe + compare + result lane)", [(0x468f10, 0x4690b3), (0x4691a2, 0x4691f8)]),
     ("miss: empty check + reprobe push-back", [(0x4691f8, 0x469250), (0x469588, 0x469690), (0x469a0a, 0x469a30)]),
     ("result store + deep push + loop", [(0x4690b3, 0x4691a2), (0x469690, 0x469752)]),
     ("setup / leftover / slow path", [(0x468e00, 0x468f10), (0x469250, 0x469588), (0x469752, 0x469a0a)])]
tot, fb, reg, ins = 0, 0, collections.Counter(), collections.Counter()
for line in sys.stdin:
    p = line.split(None, 1)
    if len(p) < 2:
        continue
    tot += 1
    if "find_batch" not in p[1] or "FindArgument" not in p[1]:
        continue
    fb += 1
    ip = int(p[0], 16)
    ins[ip] += 1
    for name, rr in R:
        if any(a <= ip < b for a, b in rr):
            reg[name] += 1
            break
    else:
        reg["outside"] += 1
dis = {}
for l in open(sys.argv[1].replace("dramhit", "find_batch.s")):
    m = re.match(r"\s*([0-9a-f]+):\s*(.*)", l)
    if m:
        dis[int(m.group(1), 16)] = re.sub(r"<[^>]*>", "", m.group(2)).strip()
print(f"samples: {tot}; find_batch: {fb} ({100 * fb / tot:.1f} %)")
for k, v in reg.most_common():
    print(f"  {100 * v / fb:5.1f} %  {k}")
print("top 15 instructions (% of find_batch; PEBS cycles land on the instruction after the one waiting):")
for ip, v in ins.most_common(15):
    print(f"  {100 * v / fb:5.1f} %  {ip:x}  {dis.get(ip, '?')}")
