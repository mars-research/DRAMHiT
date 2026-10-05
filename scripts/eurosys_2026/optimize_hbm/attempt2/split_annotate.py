#!/usr/bin/env python3
"""Split `perf annotate --stdio` output into one file per (event, function).

    split_annotate.py <perf annotate output> <out dir>

Writes annotate_<fn>_<event>.txt for fn in find/insert and event in
cycles/misp, with the long CASHashTable<...> symbol names shortened.
"""
import re, sys
from pathlib import Path

src, out = Path(sys.argv[1]), Path(sys.argv[2])
blocks, cur = [], []
for line in src.read_text().splitlines():
    if line.lstrip().startswith("Percent |") and cur:
        blocks.append(cur); cur = []
    cur.append(line)
if cur:
    blocks.append(cur)

LONG = "kmercounter::CASHashTable<kmercounter::Item, kmercounter::ItemQueue>::"
for b in blocks:
    head = "\n".join(b[:12])
    ev = "cycles" if "cycles/" in b[0] else "misp" if "br_misp" in b[0] else None
    fn = next((f for f in ("find_batch", "insert_batch") if LONG + f + "(" in head), None)
    if not ev or not fn:
        continue
    text = "\n".join(b)
    text = re.sub(re.escape(LONG) + r"(\w+)\([^<>]*?(<[^<>]*>[^<>]*?)*\)", r"\1", text)
    (out / f"annotate_{fn.split('_')[0]}_{ev}.txt").write_text(text + "\n")
    print(out / f"annotate_{fn.split('_')[0]}_{ev}.txt")
