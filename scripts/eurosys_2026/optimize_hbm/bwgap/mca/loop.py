import sys, re
w, dis = sys.argv[1], sys.argv[2]
c = [(int(l.split()[0]), int(l.split()[1], 16)) for l in open(f'{w}.ips')]
c = [(n, ip) for n, ip in c if ip < 0x500000]
tot = sum(n for n, _ in c); acc = 0; hot = []
for n, ip in c:
    acc += n; hot.append(ip)
    if acc > 0.97 * tot: break
lo, hi = min(hot), max(hot)
ins = []
for l in open(dis):
    m = re.match(r'\s+([0-9a-f]+):\s+(.*)', l)
    if m: ins.append((int(m.group(1), 16), m.group(2).strip()))
# smallest backward-jump loop covering [lo, hi]
best = None
for a, t in ins:
    m = re.match(r'j\w+\s+([0-9a-f]+)', t)
    if m:
        tgt = int(m.group(1), 16)
        if tgt <= lo and a >= hi - 8 and tgt < a:
            if best is None or a - tgt < best[1] - best[0]: best = (tgt, a)
s, e = best
body = [(a, t) for a, t in ins if s <= a <= e]
samples = dict((ip, n) for n, ip in c)
with open(f'{w}.loop', 'w') as f:
    for a, t in body: f.write(f'{a:x}\t{samples.get(a,0)/tot*100:5.1f}%\t{t}\n')
# mca input: drop jumps / branches, strip comments and symbols
with open(f'{w}.s', 'w') as f:
    for a, t in body:
        t = re.sub(r'\s*<.*', '', re.sub(r'\s*#.*', '', t))
        if t.startswith('j') or t.startswith('nop') or t.startswith('cs ') or t.startswith('data16'): continue
        f.write(t + '\n')
print(w, hex(s), hex(e), len(body), 'instr in loop;', f'{acc/tot*100:.0f}% of user samples in hot set')
