#!/usr/bin/env python3
"""
Count k-mer frequencies in a FASTQ file and write them as a TSV.

Output format matches gen_fastq.py / verify.py:
    <encoded_uint64>\t<count>

Encoding matches kmercounter::DNAKMer (include/utils/circular_buffer.hpp):
  * A=0, C=1, G=2, T=3 (case insensitive)
  * buffer = ((buffer << 2) & KMER_MASK) | code   -- first base is most significant
  * any other character (N, IUPAC codes, ...) is invalid and RESETS the window,
    so K new valid bases are required before the next kmer is emitted

Sequence lines are FASTQ record line 2 of every 4. K-mers never span a read.
"""

import argparse
import gzip
import sys
import time

import numpy as np

INVALID = 255
READ_CHUNK = 64 << 20  # bytes pulled from the file at a time
# Above this many distinct possible kmers, use the sparse counter instead of a
# dense bincount table (4**k * 8 bytes would get unreasonable).
DENSE_LIMIT = 1 << 24


def build_lut():
    lut = np.full(256, INVALID, dtype=np.uint8)
    for ch, code in (("A", 0), ("C", 1), ("G", 2), ("T", 3)):
        lut[ord(ch)] = code
        lut[ord(ch.lower())] = code
    return lut


LUT = build_lut()


def sequence_codes(block, line_offset):
    """Map a block of raw FASTQ bytes to 2-bit codes.

    Everything that is not part of a sequence line is forced to INVALID, which
    both removes header/quality text and acts as a separator so that no kmer
    window can span two reads.

    Returns (codes, lines_consumed).
    """
    arr = np.frombuffer(block, dtype=np.uint8)
    nl = np.flatnonzero(arr == 0x0A)
    if nl.size == 0:
        return None, 0

    starts = np.empty(nl.size, dtype=np.int64)
    starts[0] = 0
    starts[1:] = nl[:-1] + 1

    # FASTQ record = @header / sequence / + / quality
    is_seq = ((line_offset + np.arange(nl.size)) & 3) == 1

    codes = LUT[arr]
    # Interval-marking: +1 at each sequence-line start, -1 at its end, prefix-sum
    # gives a keep-mask without touching Python per line.
    delta = np.zeros(arr.size + 1, dtype=np.int8)
    delta[starts[is_seq]] += 1
    delta[nl[is_seq]] -= 1
    keep = np.cumsum(delta[:-1]) > 0
    codes[~keep] = INVALID
    return codes, nl.size


def block_kmers(codes, k, vdtype):
    """Rolling-encode every valid kmer window in `codes`."""
    n = codes.size
    m = n - k + 1
    if m <= 0:
        return None

    bad = codes > 3
    vals = codes.astype(vdtype)
    np.putmask(vals, bad, 0)

    acc = np.zeros(m, dtype=vdtype)
    badw = np.zeros(m, dtype=bool)
    for j in range(k):
        acc <<= 2
        acc |= vals[j:j + m]
        badw |= bad[j:j + m]  # window is only valid if every base in it is valid

    return acc[~badw]


def main():
    ap = argparse.ArgumentParser(description="Count kmer frequencies in a FASTQ file")
    ap.add_argument("fastq", help="input FASTQ (plain or .gz)")
    ap.add_argument("-k", type=int, required=True, help="kmer length (1-32)")
    ap.add_argument("-o", "--out", required=True, help="output TSV path")
    ap.add_argument("--max-bytes", type=int, default=0,
                    help="stop after roughly this many input bytes (for testing)")
    args = ap.parse_args()

    k = args.k
    if not 1 <= k <= 32:
        sys.exit(f"k must be in [1, 32], got {k}")

    vdtype = np.uint32 if 2 * k <= 32 else np.uint64
    space = 1 << (2 * k)
    dense = space <= DENSE_LIMIT
    counts = np.zeros(space, dtype=np.int64) if dense else {}

    opener = gzip.open if args.fastq.endswith(".gz") else open
    pending = b""
    line_offset = 0
    consumed = 0
    t0 = time.time()

    with opener(args.fastq, "rb") as fh:
        while True:
            chunk = fh.read(READ_CHUNK)
            if not chunk:
                break
            consumed += len(chunk)
            pending += chunk

            # Only process up to the last complete line; a kmer can never span a
            # line boundary, so cutting here loses nothing.
            cut = pending.rfind(b"\n")
            if cut < 0:
                continue
            block, pending = pending[:cut + 1], pending[cut + 1:]

            codes, nlines = sequence_codes(block, line_offset)
            line_offset += nlines
            if codes is None:
                continue

            v = block_kmers(codes, k, vdtype)
            if v is None or v.size == 0:
                continue

            if dense:
                counts += np.bincount(v, minlength=space)
            else:
                u, c = np.unique(v, return_counts=True)
                for key, cnt in zip(u.tolist(), c.tolist()):
                    counts[key] = counts.get(key, 0) + cnt

            el = time.time() - t0
            print(f"\r  {consumed / 1e9:.2f} GB  ({consumed / 1e6 / max(el, 1e-9):.0f} MB/s)",
                  end="", file=sys.stderr, flush=True)

            if args.max_bytes and consumed >= args.max_bytes:
                break

    # Trailing partial line (file not ending in a newline)
    if pending:
        codes, _ = sequence_codes(pending + b"\n", line_offset)
        if codes is not None:
            v = block_kmers(codes, k, vdtype)
            if v is not None and v.size:
                if dense:
                    counts += np.bincount(v, minlength=space)
                else:
                    u, c = np.unique(v, return_counts=True)
                    for key, cnt in zip(u.tolist(), c.tolist()):
                        counts[key] = counts.get(key, 0) + cnt

    print(file=sys.stderr)

    if dense:
        keys = np.flatnonzero(counts)
        vals = counts[keys]
        pairs = zip(keys.tolist(), vals.tolist())
        n_unique, n_total = keys.size, int(vals.sum())
    else:
        items = sorted(counts.items())
        pairs = iter(items)
        n_unique, n_total = len(items), sum(counts.values())

    with open(args.out, "w") as f:
        for key, cnt in pairs:
            f.write(f"{key}\t{cnt}\n")

    el = time.time() - t0
    print(f"read      : {args.fastq} ({consumed / 1e9:.2f} GB in {el:.1f}s)")
    print(f"k         : {k}")
    print(f"unique    : {n_unique} of {space} possible")
    print(f"total     : {n_total} kmer occurrences")
    print(f"wrote     : {args.out}")


if __name__ == "__main__":
    main()
