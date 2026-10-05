#!/usr/bin/env python3
"""Split the instructions of a hot loop into MEMORY-DEPENDENT and MEMORY-INDEPENDENT.

    instr_mix.py dis  <binary> <symbol-substring> [--out file]     # objdump -d -l of one function
    instr_mix.py taint <dis-file> --loop <first-addr> <last-addr> --source '<regex>' [--entry-until addr]

Definition (the one used in report-bwgap.md)
  A memory-DEPENDENT instruction consumes, directly or through registers, mask registers or
  flags, data that was loaded from the cache line the prefetch engine is bringing in (the
  hash-table bucket for dramhit, the random line for bandwidth_rand). The load of that line is
  the taint SOURCE (selected with --source, a regex on the instruction text, first match in the
  loop). Everything else is memory-INDEPENDENT. An instruction that merely executes because a
  branch on the loaded data went one way (control dependence) is reported as independent but
  flagged `ctl`: with a correctly predicted branch it can issue without waiting for the data.

Method: forward taint propagation over the loop body in program order, twice (the second pass
starts with the registers still tainted at the end of the first, to catch loop-carried
dependence). Operand semantics are a small table covering exactly the mnemonics that occur in
these loops; an unknown mnemonic aborts, so a silent mis-classification cannot happen.
"""
import argparse
import re
import subprocess
import sys

# ------------------------------------------------------------------ disassembly
def disassemble(binary, sym, out=None):
    nm = subprocess.run(["nm", "-S", "-C", "--defined-only", binary], capture_output=True, text=True).stdout
    best = None
    for line in nm.splitlines():
        m = re.match(r"^([0-9a-f]+) ([0-9a-f]+) ([tTwW]) (.*)$", line)
        if m and sym in m.group(4) and ".cold" not in m.group(4):
            best = (int(m.group(1), 16), int(m.group(2), 16), m.group(4))
            break
    assert best, f"no function whose demangled name contains {sym!r}"
    lo, size, dm = best
    txt = subprocess.run(["objdump", "-d", "-l", "-C", "--no-show-raw-insn", f"--start-address={lo:#x}",
                          f"--stop-address={lo + size:#x}", binary], capture_output=True, text=True).stdout
    if out:
        open(out, "w").write(txt)
    return txt


def parse_dis(text):
    """-> list of {addr:int, asm:str, src:str} in address order."""
    ins, src = [], ""
    for line in text.splitlines():
        m = re.match(r"^\s+([0-9a-f]+):\s+(.*?)\s*$", line)
        if m:
            asm = re.sub(r"\s+<.*$", "", m.group(2))              # drop the trailing <symbol+off> annotation
            asm = re.sub(r"\s*#.*$", "", asm)
            ins.append({"addr": int(m.group(1), 16), "asm": asm.strip(), "src": src})
            continue
        m = re.match(r"^(/[^\s:]+|[A-Za-z_][^\s:]*\.[a-z]+):(\d+)", line)
        if m:
            src = f"{m.group(1).split('/')[-1]}:{m.group(2)}"
    return ins


# ------------------------------------------------------------------ operand semantics
REG = re.compile(r"%([a-z0-9]+)")
GPR_ALIAS = {}
for base in ("a", "b", "c", "d"):
    for n in (f"r{base}x", f"e{base}x", f"{base}x", f"{base}l", f"{base}h"):
        GPR_ALIAS[n] = f"r{base}x"
for r_ in ("si", "di", "bp", "sp"):
    for n in (f"r{r_}", f"e{r_}", r_, f"{r_}l"):
        GPR_ALIAS[n] = f"r{r_}"
for k in range(8, 16):
    for suf in ("", "d", "w", "b"):
        GPR_ALIAS[f"r{k}{suf}"] = f"r{k}"


def canon(reg):
    if reg in GPR_ALIAS:
        return GPR_ALIAS[reg]
    m = re.match(r"^[xyz]mm(\d+)$", reg)
    if m:
        return f"v{m.group(1)}"
    return reg                      # k0..k7, rip, ...


def split_ops(s):
    ops, depth, cur = [], 0, ""
    for ch in s:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            ops.append(cur.strip()); cur = ""
        else:
            cur += ch
    if cur.strip():
        ops.append(cur.strip())
    return ops


def regs_of(op):
    return {canon(r) for r in REG.findall(op)}


def is_mem(op):
    return "(" in op and not op.startswith("$")


def mem_addr_regs(op):
    m = re.search(r"\(([^)]*)\)", op)
    return {canon(r) for r in REG.findall(m.group(1))} if m else set()


RMW = {"add", "addq", "addl", "sub", "subl", "subq", "and", "andl", "andq", "or", "orl", "xor", "xorl", "shl", "shll", "shlq",
       "shr", "shrl", "inc", "incl", "dec", "decl", "imul", "neg", "not", "crc32", "crc32q", "crc32l", "sar", "sarl", "lea_rmw"}
MOVLIKE = {"mov", "movl", "movq", "movb", "movw", "movzbl", "movzwl", "movslq", "movsbl", "movabs", "vmovq", "vmovd", "vmovdqa64",
           "vmovdqu64", "vmovdqa", "vmovdqu", "vpbroadcastq", "vpbroadcastd", "tzcnt", "popcnt", "lzcnt", "kmovb", "kmovw", "kmovd",
           "kmovq", "lea", "vpmovqd", "movzbl"}
CMP = {"cmp", "cmpl", "cmpq", "cmpb", "test", "testb", "testl", "testq"}
FLAGSRC = {"je", "jne", "jb", "jae", "ja", "jbe", "jg", "jge", "jl", "jle", "js", "jns", "jz", "jnz", "cmove", "cmovne", "sete", "setne"}
NOOPS = {"jmp", "nop", "nopw", "nopl", "xchg", "vzeroupper", "ret", "leave", "cs", "data16", "pause"}
STACK = {"push", "pop", "call"}
PREFETCH = {"prefetcht0", "prefetcht1", "prefetcht2", "prefetchnta", "prefetchw"}


def semantics(asm):
    """-> (mnemonic, dest_regs, src_regs, reads_mem, writes_mem, mem_addr_regs, sets_flags, reads_flags, dest_also_read)"""
    parts = asm.split(None, 1)
    mn = parts[0]
    ops = split_ops(parts[1]) if len(parts) > 1 else []
    # k-mask predicates {%k1}{z} on an operand are READ
    pred = set()
    ops2 = []
    for o in ops:
        for m in re.finditer(r"\{%(k\d)\}", o):
            pred.add(m.group(1))
        ops2.append(re.sub(r"\{[^}]*\}", "", o))
    ops = ops2
    if mn in NOOPS or mn in STACK:
        return mn, set(), set(), False, False, set(), False, False, False
    if mn in PREFETCH:
        return mn, set(), set(), False, False, mem_addr_regs(ops[0]), False, False, False
    if mn.startswith("j") or mn in FLAGSRC:
        return mn, set(), set(), False, False, set(), False, True, False
    if mn in CMP or mn == "kortestb":
        src = set()
        for o in ops:
            src |= regs_of(o)
        mem = any(is_mem(o) for o in ops)
        return mn, set(), src - set(), mem, False, set().union(*[mem_addr_regs(o) for o in ops if is_mem(o)]) if mem else set(), True, False, False
    if mn in ("vpcmpequq", "vpcmpeqq", "vpcmpuq"):
        # vpcmpequq src2, src1, dst_k   (AT&T: last is dest)
        dst = regs_of(ops[-1]); src = set()
        for o in ops[:-1]:
            src |= regs_of(o)
        return mn, dst, src | pred, False, False, set(), False, False, False
    if mn in ("kshiftlb", "kshiftlw", "kshiftrb"):
        return mn, regs_of(ops[-1]), regs_of(ops[-2]), False, False, set(), False, False, False
    if mn in ("vpcompressq", "vpcompressd"):
        return mn, regs_of(ops[-1]), regs_of(ops[0]) | pred, False, False, set(), False, False, False
    if mn in ("vpinsrd", "vpinsrq"):
        # vpinsrd $imm, src(reg/mem), xmm_in, xmm_out
        srcs = [o for o in ops[1:-1]]
        src = set(); mem = False; ar = set()
        for o in srcs:
            src |= regs_of(o)
            if is_mem(o):
                mem = True; ar |= mem_addr_regs(o)
        return mn, regs_of(ops[-1]), src, mem, False, ar, False, False, False
    if mn in ("vpxor", "vpxorq", "pxor") and len(ops) == 3 and ops[0] == ops[1] == ops[2]:
        return mn, regs_of(ops[-1]), set(), False, False, set(), False, False, False      # zeroing idiom
    if mn in ("vpxor", "vpxorq", "vpaddq", "vpandq"):
        return mn, regs_of(ops[-1]), set().union(*[regs_of(o) for o in ops[:-1]]), False, False, set(), False, False, False
    if mn in MOVLIKE:
        d, s = ops[-1], ops[:-1]
        dst_is_mem = is_mem(d)
        src = set(); mem_r = False; ar = set()
        for o in s:
            src |= regs_of(o)
            if is_mem(o):
                mem_r = True; ar |= mem_addr_regs(o)
        if mn == "lea":                         # address arithmetic only: no memory access
            return mn, regs_of(d), src, False, False, set(), False, False, False
        if dst_is_mem:                          # a store: the data operand(s) are sources; address regs too
            return mn, set(), src, False, True, mem_addr_regs(d), False, False, False
        return mn, regs_of(d), src, mem_r, False, ar, False, False, False
    if mn in RMW or mn.startswith("add") or mn.startswith("sub"):
        d, s = ops[-1], ops[:-1]
        src = set(); mem_r = False; ar = set()
        for o in s:
            src |= regs_of(o)
            if is_mem(o):
                mem_r = True; ar |= mem_addr_regs(o)
        if is_mem(d):                           # read-modify-write of memory (e.g. incl -0x10(%rsp))
            return mn, set(), src, True, True, mem_addr_regs(d), True, False, False
        return mn, regs_of(d), src, mem_r, False, ar, True, False, True
    raise SystemExit(f"unknown mnemonic {mn!r} in {asm!r}: add it to semantics()")


# ------------------------------------------------------------------ taint
def taint_loop(ins, source_regex, first, last):
    """Classify ins[first..last] (indices). Returns list of (instr, class, reason)."""
    src_re = re.compile(source_regex)
    tainted, tflags = set(), False
    result = {}
    src_idx = next(i for i in range(first, last + 1) if src_re.search(ins[i]["asm"]))
    for passno in (1, 2):
        for i in range(first, last + 1):
            a = ins[i]["asm"]
            mn, dst, src, mem_r, mem_w, addr, sets_flags, reads_flags, dst_read = semantics(a)
            why = []
            dep = False
            if i == src_idx:
                dep = True; why.append("LOADS the line")
                # the loaded register(s) become tainted
                tainted |= dst
            else:
                for r in (src | addr):
                    if r in tainted:
                        dep = True; why.append(f"reads tainted {r}")
                if reads_flags and tflags:
                    dep = True; why.append("branches on tainted flags")
                if dst_read:
                    for r in dst:
                        if r in tainted:
                            dep = True; why.append(f"read-modify-write of tainted {r}")
                if dep:
                    tainted |= dst
                else:
                    tainted -= dst                       # overwritten by an untainted value
            if sets_flags:
                tflags = dep
            if passno == 2 or i not in result:
                result[i] = (dep, "; ".join(why))
    return [(ins[i], "D" if result[i][0] else "I", result[i][1]) for i in range(first, last + 1)]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    d = sub.add_parser("dis"); d.add_argument("binary"); d.add_argument("symbol"); d.add_argument("--out")
    t = sub.add_parser("taint"); t.add_argument("disfile")
    t.add_argument("--loop", nargs=2, required=True, help="first and last instruction address (hex)")
    t.add_argument("--source", required=True)
    a = ap.parse_args()
    if a.cmd == "dis":
        txt = disassemble(a.binary, a.symbol, a.out)
        print(txt if not a.out else f"wrote {a.out} ({len(txt.splitlines())} lines)")
        return
    ins = parse_dis(open(a.disfile).read())
    lo, hi = int(a.loop[0], 16), int(a.loop[1], 16)
    first = next(i for i, x in enumerate(ins) if x["addr"] == lo)
    last = next(i for i, x in enumerate(ins) if x["addr"] == hi)
    rows = taint_loop(ins, a.source, first, last)
    nd = sum(1 for _, c, _ in rows if c == "D")
    for x, c, why in rows:
        print(f"{x['addr']:x}  {c}  {x['asm']:<46} {x['src']:<26} {why}")
    print(f"\n{len(rows)} instructions in [{lo:x}, {hi:x}]: {nd} memory-dependent, {len(rows) - nd} independent")


if __name__ == "__main__":
    main()
