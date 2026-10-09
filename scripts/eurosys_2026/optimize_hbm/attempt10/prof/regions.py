import re, sys
L=[]
for l in open(sys.argv[1]):
    m=re.match(r'\s*([\d.]+)\s*:\s*([0-9a-f]+):\s*(.*)', l)
    if m: L.append([float(m.group(1)), int(m.group(2),16), m.group(3).strip()])
tot=sum(x[0] for x in L)
res=[i for i,x in enumerate(L) if re.match(r'vmovdqu64 %zmm\d+,\(%r\w+\)$', x[2])]
push=[i for i,x in enumerate(L) if re.match(r'vmovdqu64 %zmm\d+,\(%r\w+,%r\w+,1\)', x[2])]
r0=res[0]; p0=push[0]
# loop start: first vpbroadcastq (mem) minus the prefetch/pop setup ~ go back to the instruction after the previous backward jump target... use the first 'lea' before the first broadcast
b0=next(i for i,x in enumerate(L) if 'vpbroadcastq (' in x[2] or 'vpbroadcastq 0x' in x[2])
s0=b0
while s0>0 and not re.match(r'(j\w+|ret)\b', L[s0-1][2]): s0-=1
reg={"deep pop (4 completions, hit path + reprobe code)":sum(x[0] for x in L[s0:r0]),
     "result store (64 B)":L[r0][0],
     "deep push (4 crc32 + prefetch + block build + 64 B store) and loop":sum(x[0] for x in L[r0+1:p0+8]),
     "rest (setup, leftover/slow path, ...)":0}
reg["rest (setup, leftover/slow path, ...)"]=tot-sum(v for k,v in reg.items() if not k.startswith("rest"))
for k,v in reg.items(): print(f"{v:5.1f}%  {k}")
print("top 12 instructions:")
for p,a,t in sorted(L,reverse=True)[:12]:
    i=[k for k,x in enumerate(L) if x[1]==a][0]
    zone="pop" if s0<=i<r0 else ("push" if r0<i<=p0+7 else "other")
    print(f"  {p:5.2f}% {zone:5s} {t[:70]}")
