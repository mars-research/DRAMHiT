#!/usr/bin/env python3
"""E3: per-line instruction counts and the memory-dependent / independent split, from the
instructions:ppp sample histograms (hist/*.ip.txt, made by `perf script -F ip,sym | sort | uniq -c`)
and the taint classification of instr_mix.py.  Writes tables/instr_mix.md.

Per-line instructions of a code region = (samples in the region) * PERIOD / lines, where lines
= find_ops (dramhit, from the program output) or, for bandwidth_rand, 64 threads' lines =
alloc_MB*2^20/64 * iterations."""
import re, sys
import instr_mix as m
PERIOD = 2000003
def hist(name):
    h = {}
    for l in open(f"hist/{name}.ip.txt"):
        p = l.split(None, 2); h[int(p[1], 16)] = int(p[0])
    return h
out = []
# ---------------- dramhit (rck), find_batch + harness find fill loop
h = hist("dramhit_f10")
txt = open("logs/E3_sampling/dramhit_f10.out").read()
lines = int(re.search(r"find_ops : (\d+)", txt).group(1))
ins = m.parse_dis(open("dis/dramhit_rck_find_batch.txt").read())
FB_LO, FB_HI = 0x43daa0, 0x43df4f
LOOP_LO, LOOP_HI = 0x43dbae, 0x43dc5f
fb = {a: n for a, n in h.items() if FB_LO <= a < FB_HI}
s_fb = sum(fb.values())
idx = {x["addr"]: i for i, x in enumerate(ins)}
rows = m.taint_loop(ins, r"^vmovdqa64 \(%r10,%rdi,1\),%zmm7", idx[LOOP_LO], idx[LOOP_HI])
cls = {x["addr"]: (c, why) for x, c, why in rows}
load = {x["addr"] for x, c, why in rows if "LOADS" in why}
cnt = {"L": 0, "D": 0, "I": 0}
for a, n in fb.items():
    if a in load: cnt["L"] += n
    elif a in cls and cls[a][0] == "D": cnt["D"] += n
    elif a in cls: cnt["I"] += n
loop_total = sum(cnt.values()); outside = s_fb - loop_total
per = lambda s: s * PERIOD / lines
HL, HH = 0x46ae80, 0x46b090
s_h = sum(n for a, n in h.items() if HL <= a < HH)
iters = fb[LOOP_LO]
out.append("## rck dramblast, find phase (fill 10), from logs/E3_sampling/dramhit_f10")
out.append(f"find_ops = {lines}; samples: find_batch {s_fb}, harness find-fill loop {s_h}; loop-body entry executed ~{iters} times ({iters*PERIOD/lines:.3f}x per find)\n")
out.append("| region | instr/find | share of region | note |\n|---|---|---|---|")
out.append(f"| find_batch loop body 0x{LOOP_LO:x}-0x{LOOP_HI:x}: LOAD of the bucket | {per(cnt['L']):.2f} | | vmovdqa64 (%r10,%rdi,1),%zmm7 |")
out.append(f"| find_batch loop: memory-DEPENDENT | {per(cnt['D']):.2f} | | " + ", ".join(sorted({x['asm'].split()[0] for x, c, w in rows if c=='D' and 'LOADS' not in w})) + " |")
out.append(f"| find_batch loop: independent | {per(cnt['I']):.2f} | | |")
out.append(f"| find_batch outside loop (call entry/exit, per 16 finds) | {per(outside):.2f} | | |")
out.append(f"| harness find fill loop 0x{HL:x}-0x{HH:x} | {per(s_h):.2f} | | all independent of the table line (loads the key stream instead) |")
tot = per(s_fb + s_h)
out.append(f"| **total accounted** | **{tot:.2f}** | | measured (E2) 55.3-55.8 |")
D = per(cnt['D']); L = per(cnt['L'])
out.append(f"\nSplit: load {L:.2f}, memory-dependent {D:.2f} ({100*D/tot:.1f}%), independent {tot-D-L:.2f} ({100*(tot-D-L)/tot:.1f}%)\n")
out.append("Loop body classification (static, taint):\n\n```")
for x, c, w in rows:
    out.append(f"{x['addr']:x} {h.get(x['addr'],0):6d} {'L' if 'LOADS' in w else c}  {x['asm']:<40} {w}")
out.append("```\n")
# ---------------- bandwidth_rand
bins = m.parse_dis(open("dis/bw_it100_mem_worker.txt").read())
for name, lo, hi, src, iters_lines in (("bw_t1", 0x4047d0, 0x404802, r"^add\s+\(%rdi,%rax,1\),%r14", None),
                                        ("bw_double24", 0x405ed8, 0x405faa, r"^add\s+\(%rbx,%r9,1\),%r15", None)):
    hh = hist(name)
    i0 = next(i for i, x in enumerate(bins) if x["addr"] == lo); i1 = next(i for i, x in enumerate(bins) if x["addr"] == hi)
    r = m.taint_loop(bins, src, i0, i1)
    nL = sum(1 for x, c, w in r if "LOADS" in w); nD = sum(1 for x, c, w in r if c == "D" and "LOADS" not in w)
    s_loop = sum(n for a, n in hh.items() if lo <= a <= hi)
    s_tot = sum(n for a, n in hh.items() if bins[0]["addr"] <= a <= bins[-1]["addr"])
    out.append(f"## bandwidth_rand {name}: loop 0x{lo:x}-0x{hi:x}\n")
    out.append(f"static loop length {len(r)} instructions (cmp+jne are counted as two instructions by the counter; sampling attributes both to the jne); load {nL}, dependent {nD}, independent {len(r)-nL-nD}; loop samples {s_loop} of {s_tot} in mem_worker ({100*s_loop/s_tot:.1f}%)\n")
    out.append("```")
    for x, c, w in r:
        out.append(f"{x['addr']:x} {hh.get(x['addr'],0):6d} {'L' if 'LOADS' in w else c}  {x['asm']:<40} {w}")
    out.append("```\n")
open("tables/instr_mix.md", "w").write("\n".join(out))
print("\n".join(out))
