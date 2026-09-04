#!/usr/bin/env bash
#
# Reproduce the DRAMHiT build configuration used for k-mer counting on the
# Xeon Max (HBM) box.
#
# Usage:
#   ./build.sh                    # configure + build into ./build
#   BUILD_DIR=build-x ./build.sh  # build somewhere else
#   CLEAN=1 ./build.sh            # wipe the build dir first
#   ./build.sh -DCALC_STATS=ON    # extra/override cmake args are passed through
#
# Run this inside the nix dev shell (./nix-dev-shell.sh) so the toolchain
# matches; the exact nix store hashes will differ between machines, but none of
# the flags below depend on them.
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

BUILD_DIR="${BUILD_DIR:-build}"
JOBS="${JOBS:-$(nproc)}"

if [[ "${CLEAN:-0}" == "1" ]]; then
  rm -rf "$BUILD_DIR"
fi

cmake -S . -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCPUFREQ_MHZ=2700 \
  -DAGGR=ON \
  -DBQ_KMER_TEST=ON \
  -DPART_ID=ON \
  -DBUCKETIZATION=ON \
  -DBRANCH=simd \
  -DDRAMHiT_VARIANT=2025_INLINE \
  -DKEY_LEN=8 \
  -DKMER_LEN=8 \
  -DHASHER=crc \
  -DPREFETCH=DOUBLE \
  -DAVX_SUPPORT=ON \
  "$@"

cmake --build "$BUILD_DIR" -j "$JOBS"

cat <<'EOF'

Build complete. Flags that actually change behaviour (the rest are CMakeLists
defaults, pinned above only so the config is explicit):

  AGGR=ON             KVType = Aggr_KV (8B key + 8B count) instead of Item, i.e.
                      the table aggregates counts. Required for kmer counting.
                      Note Aggr_KV's empty sentinel is key == 0, so the all-A
                      kmer is unrepresentable and never shows up in get_fill()
                      or the --out-file dump.

  BQ_KMER_TEST=ON     Defines BQUEUE_KMER_TEST. Two effects, both essential for
                      --mode 4 with --ht-type 1/12 (the producer/consumer path):
                        1. compiles the FASTQ reader into producer_thread;
                        2. switches data_t from KeyValuePair (16B) to Key (8B).
                      With it OFF the producers never read --in-file and, because
                      run_test hardcodes is_join=true, enqueue key 0 for every
                      message -- the run "succeeds" with an empty hashtable.

  PART_ID=ON          Compiles PARTITIONED_HT (--ht-type 1) and MULTI_HT (5)
                      into init_ht(). With it OFF, --ht-type 1 exits with
                      "HT type not implemented".

  BUCKETIZATION=ON    Probe 4 KV pairs per 64B cacheline.
  BRANCH=simd         Selects __insert_branchless_simd (AVX-512). Alternatives:
                      branched, cmov.
  DRAMHiT_VARIANT     2025_INLINE -> -DDRAMHiT_2025_INLINED.
  CPUFREQ_MHZ=2700    Mandatory (configure fails without it). Only used to turn
                      cycle counts into Mops in the stats output.
  KEY_LEN=8           key_type = uint64_t.
  KMER_LEN=8          Defined but referenced nowhere in the tree -- k is chosen
                      at runtime with --k, so changing this rebuilds nothing.

Verify functional correctness:
  python3 kmer_freq.py synthetic.fastq -k 4 -o truth_kmers.tsv
  ./BUILD_DIR/dramhit --find_queue 64 --mode 4 --ht-size 1048576 --hw-pref 0 \
      --in-file ./synthetic.fastq --ht-type 1 --numa-split 4 --nprod 64 \
      --ncons 64 --k 4 --insert-factor 1 --out-file kmer_out/ht
  python3 verify.py --truth truth_kmers.tsv --ht-output kmer_out/ht \
      --n-cons 64 --n-prod 64
  # expect: 255 correct, 0 mismatches, key 0 missing (the empty sentinel)
EOF
