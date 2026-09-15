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

cd "$(git -C "$(dirname "$(readlink -f "$0")")" rev-parse --show-toplevel)"

BUILD_DIR="${BUILD_DIR:-build}"
JOBS="${JOBS:-$(nproc)}"

# ---------------------------------------------------------------------------
# CPUFREQ_MHZ detection
#
# CPUFREQ_MHZ is not a tuning knob: dramhit divides rdtsc deltas by it to turn
# cycles into Mops, so a value that disagrees with the frequency the cores are
# actually running at scales every reported number by exactly that ratio. It
# used to be hardcoded to 2700 here, which silently skewed Mops by 8% on a box
# that scripts/setup.sh had pinned to 2.5GHz.
#
# scripts/constant_freq.sh pins scaling_min_freq == scaling_max_freq, so on a
# prepared machine scaling_max_freq *is* the run frequency. Fall back through
# the less trustworthy sources only when cpufreq is unavailable.
# ---------------------------------------------------------------------------
detect_cpufreq_mhz() {
  local khz

  # 1. what constant_freq.sh pinned -- authoritative when min == max
  if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq ]]; then
    khz=$(</sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
    echo $(( khz / 1000 ))
    return 0
  fi

  # 2. hardware ceiling, if the governor is not exposed
  if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]]; then
    khz=$(</sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
    echo $(( khz / 1000 ))
    return 0
  fi

  # 3. lscpu, which reports MHz directly
  local mhz
  mhz=$(lscpu 2>/dev/null | awk -F: '/CPU max MHz/ {gsub(/ /,"",$2); print int($2); exit}')
  if [[ -n "${mhz}" && "${mhz}" != "0" ]]; then
    echo "${mhz}"
    return 0
  fi

  # 4. the rated frequency in the model name (e.g. "... CPU @ 2.70GHz")
  mhz=$(awk -F'@' '/model name/ {gsub(/[ GHz]/,"",$2); printf "%d", $2*1000; exit}' /proc/cpuinfo 2>/dev/null)
  if [[ -n "${mhz}" && "${mhz}" != "0" ]]; then
    echo "${mhz}"
    return 0
  fi

  return 1
}

# An explicit CPUFREQ_MHZ=... in the environment always wins over detection.
if [[ -z "${CPUFREQ_MHZ:-}" ]]; then
  if ! CPUFREQ_MHZ=$(detect_cpufreq_mhz); then
    echo "ERROR: could not detect CPU frequency; pass it explicitly, e.g." >&2
    echo "         CPUFREQ_MHZ=2500 $0" >&2
    exit 1
  fi
  echo "Detected CPUFREQ_MHZ=${CPUFREQ_MHZ}"
else
  echo "Using CPUFREQ_MHZ=${CPUFREQ_MHZ} from the environment"
fi

# Warn when the cores are not actually pinned there -- the Mops math assumes a
# fixed frequency, so turbo or a live governor makes the number approximate.
if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq ]]; then
  _min=$(</sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  _max=$(</sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
  if [[ "${_min}" != "${_max}" ]]; then
    echo "WARNING: scaling_min_freq (${_min}) != scaling_max_freq (${_max});" >&2
    echo "         frequency is not pinned. Run scripts/setup.sh first." >&2
  fi
fi
if [[ -r /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
  if [[ "$(</sys/devices/system/cpu/intel_pstate/no_turbo)" != "1" ]]; then
    echo "WARNING: turbo is enabled; cores may clock above CPUFREQ_MHZ." >&2
  fi
fi

if [[ "${CLEAN:-0}" == "1" ]]; then
  rm -rf "$BUILD_DIR"
fi

cmake -S . -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCPUFREQ_MHZ="${CPUFREQ_MHZ}" \
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
  -DCAS_PREFETCH_INSERTION=DOUBLE \
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
  CPUFREQ_MHZ         Mandatory (configure fails without it). Only used to turn
                      cycle counts into Mops in the stats output -- which means
                      a wrong value scales every reported number by exactly the
                      ratio it is wrong by. Auto-detected from
                      scaling_max_freq (what scripts/constant_freq.sh pinned),
                      falling back to cpuinfo_max_freq, lscpu, then the rated
                      frequency in the model name. Override with
                      CPUFREQ_MHZ=2500 ./build_dramhit.sh.

  CAS_PREFETCH_INSERTION=DOUBLE
                      Insert path issues two prefetches per entry: a read
                      prefetch to L2 when the kmer is queued (prefetch_insert)
                      and a prefetchw when it is dequeued
                      (flush_if_needed / pop_insert_queue / insert_batch).
                      This is what "dramblast with double prefetch on
                      insertion" means, and it is pinned here rather than left
                      to AUTO so the build does not silently change if PREFETCH
                      is overridden on the command line. Alternatives:
                      PREFETCHW (single prefetchw at queue time), NONE.
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
