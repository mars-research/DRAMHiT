#!/usr/bin/env python3
"""
Render a LaTeX table file (a fragment like tbl-upi-hbm-read.tex, or a full
document) to a cropped PNG.

Uses pdflatex + ghostscript, both of which are already on PATH here.

Examples:
    python3 tex2png.py tbl-upi-hbm-read.tex
    python3 tex2png.py tbl-upi-hbm-read.tex -o /tmp/tbl.png -r 600
    python3 tex2png.py tbl-upi-read.tex tbl-upi-write.tex --no-caption
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

# Packages a table fragment is likely to lean on.
PREAMBLE = r"""\documentclass[border=10pt,varwidth=100cm]{standalone}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb}
\usepackage{array,booktabs,multirow,tabularx}
\usepackage{caption}
\usepackage{graphicx}
\usepackage[table]{xcolor}
\usepackage{siunitx}
\begin{document}
"""


def strip_braced(src, macro):
    """Remove every `\\macro{...}` from src, matching braces properly."""
    out = []
    i = 0
    needle = "\\" + macro + "{"
    while True:
        j = src.find(needle, i)
        if j < 0:
            out.append(src[i:])
            return "".join(out)
        out.append(src[i:j])
        depth = 0
        k = j + len(needle) - 1
        while k < len(src):
            if src[k] == "{":
                depth += 1
            elif src[k] == "}":
                depth -= 1
                if depth == 0:
                    break
            k += 1
        i = k + 1


def build_document(src, keep_caption=True):
    """Wrap a table fragment in a standalone document, or pass a full doc through."""
    if "\\documentclass" in src:
        return src

    body = src
    # standalone has no float mechanism: unwrap table/table* and figure/figure*.
    body = re.sub(r"\\begin\{(table|figure)\*?\}\s*(\[[^\]]*\])?", "", body)
    body = re.sub(r"\\end\{(table|figure)\*?\}", "", body)

    if keep_caption:
        # \caption only lives inside a float; \captionof works anywhere.
        body = body.replace("\\caption{", "\\captionof{table}{")
    else:
        body = strip_braced(body, "caption")
        body = strip_braced(body, "label")

    return PREAMBLE + body.strip() + "\n\\end{document}\n"


def render(tex_path, out_path, dpi, keep_caption, transparent, keep_tmp):
    with open(tex_path) as f:
        src = f.read()
    doc = build_document(src, keep_caption)

    tmpdir = tempfile.mkdtemp(prefix="tex2png-")
    try:
        job = "table"
        tex_tmp = os.path.join(tmpdir, job + ".tex")
        with open(tex_tmp, "w") as f:
            f.write(doc)

        # Two passes so \label/\ref and caption numbering settle.
        for _ in range(2):
            proc = subprocess.run(
                ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
                 "-file-line-error", job + ".tex"],
                cwd=tmpdir, capture_output=True, text=True,
            )
        pdf = os.path.join(tmpdir, job + ".pdf")
        if proc.returncode != 0 or not os.path.exists(pdf):
            sys.stderr.write("pdflatex failed on %s\n" % tex_path)
            # The interesting lines are the file:line:error ones.
            for line in proc.stdout.splitlines():
                if re.match(r".*:\d+:", line) or line.startswith("!"):
                    sys.stderr.write("  " + line + "\n")
            sys.stderr.write("  (generated source kept at %s)\n" % tex_tmp)
            keep_tmp = True
            return False

        device = "pngalpha" if transparent else "png16m"
        proc = subprocess.run(
            ["gs", "-q", "-dSAFER", "-dBATCH", "-dNOPAUSE",
             "-sDEVICE=" + device, "-r%d" % dpi,
             "-dTextAlphaBits=4", "-dGraphicsAlphaBits=4",
             "-sOutputFile=" + os.path.abspath(out_path), pdf],
            capture_output=True, text=True,
        )
        if proc.returncode != 0:
            sys.stderr.write("ghostscript failed: %s\n" % proc.stderr.strip())
            return False

        print("%s -> %s (%d dpi, %.1f KiB)"
              % (tex_path, out_path, dpi, os.path.getsize(out_path) / 1024.0))
        return True
    finally:
        if keep_tmp:
            print("  temp dir kept: %s" % tmpdir)
        else:
            shutil.rmtree(tmpdir, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("tex", nargs="+", help=".tex table file(s) to render")
    ap.add_argument("-o", "--output",
                    help="output PNG path (only with a single input; "
                         "default: alongside the input, .png extension)")
    ap.add_argument("-r", "--dpi", type=int, default=300, help="resolution (default: 300)")
    ap.add_argument("--no-caption", action="store_true",
                    help="drop \\caption/\\label, render the bare table")
    ap.add_argument("--transparent", action="store_true",
                    help="transparent background instead of white")
    ap.add_argument("--keep-tmp", action="store_true",
                    help="keep the temp build dir (for debugging LaTeX errors)")
    args = ap.parse_args()

    if args.output and len(args.tex) > 1:
        ap.error("-o/--output takes a single input file")

    ok = True
    for tex in args.tex:
        if not os.path.exists(tex):
            sys.stderr.write("no such file: %s\n" % tex)
            ok = False
            continue
        out = args.output or os.path.splitext(tex)[0] + ".png"
        ok &= render(tex, out, args.dpi, not args.no_caption,
                     args.transparent, args.keep_tmp)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
