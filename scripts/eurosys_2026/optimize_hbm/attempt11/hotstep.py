"""Extract the all-hit deep step of find_batch (attempt11/<build>/find_batch.s): from the block the setup jumps
over to (A) up to the loop head's 'jne A'. Prints it as an llvm-mca input on stdout, stats on stderr."""
import re, sys
L = []
for l in open(sys.argv[1]):
    m = re.match(r"\s*([0-9a-f]+):\s*(.*)", l)
    if m:
        L.append((int(m.group(1), 16), re.sub(r"\s*<[^>]*>", "", m.group(2)).strip()))
i = next(k for k, (_, t) in enumerate(L) if t.startswith("jmp "))
a = i + 1
while L[a][1].startswith(("nop", "xchg", "data16", "cs nop")):
    a += 1
A = L[a][0]
b = next(k for k in range(a, len(L)) if L[k][1] == f"jne    {A:x}" or re.fullmatch(rf"jne\s+{A:x}", L[k][1]))
body = [t for _, t in L[a:b + 1] if not re.match(r"(j[a-z]+|nop)\b", t)]
rsp = [t for t in body if "rsp" in t]
print(".intel_syntax noprefix"); print("\n".join(body))
print(f"{sys.argv[1]}: {len(body)} instr in the 4-find step, stack accesses: {len(rsp)}", file=sys.stderr)
for t in rsp: print("   ", t, file=sys.stderr)
