#!/usr/bin/env bash
# Thin wrapper so the mock run can be invoked as a shell script.
# All arguments are forwarded verbatim to test_and_run_kmer.py.
#
#   ./test_and_ran_kmer.sh --mode partition --out-file kmer_out/ht --k 8
#   ./test_and_ran_kmer.sh --mode global    --out-file kmer_out/ht --k 12
#   ./test_and_ran_kmer.sh --help
set -euo pipefail
exec python3 "$(dirname "$(readlink -f "$0")")/test_and_run_kmer.py" "$@"
