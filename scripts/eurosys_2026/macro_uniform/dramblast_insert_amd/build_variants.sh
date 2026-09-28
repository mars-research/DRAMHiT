#!/usr/bin/env bash
# Build the three insert-prefetch variants used by variants.py / pfdrop.py next
# to this script, without touching /opt/DRAMHiT/build (the baseline).
#   build_pw   CAS_PREFETCH_INSERTION=PREFETCHW  (one prefetchw at enqueue)
#   build_d16  DOUBLE, PREFETCH_INSERT_NEXT_DISTANCE 8 -> 16
#   build_d32  DOUBLE, PREFETCH_INSERT_NEXT_DISTANCE 8 -> 32
#   build_t1only  CAS_PREFETCH_INSERTION=PREFETCHT1_ONLY: DOUBLE without the
#                 dequeue-time prefetchw, i.e. one prefetcht1 at enqueue
#   build_t0only  as t1only with the enqueue hint T1 -> T0 (patched source copy)
#   build_none    CAS_PREFETCH_INSERTION=NONE: no insert-path prefetch at all
#   build_nostore DOUBLE, but the upsert skips the bucket store when the value is
#                 already there (it always is after the first pass: value == key)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=/opt/DRAMHiT
FLAGS="-DCPUFREQ_MHZ=3250 -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd
       -DAVX_SUPPORT=ON -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON
       -DCAS_NO_ABSTRACT=OFF -DGROWT=OFF -DCALC_STATS=OFF"

cmake -S "$SRC" -B "$HERE/build_pw" $FLAGS -DCAS_PREFETCH_INSERTION=PREFETCHW
cmake --build "$HERE/build_pw" -j 32 --target dramhit

cmake -S "$SRC" -B "$HERE/build_t1only" $FLAGS -DCAS_PREFETCH_INSERTION=PREFETCHT1_ONLY
cmake --build "$HERE/build_t1only" -j 32 --target dramhit

cmake -S "$SRC" -B "$HERE/build_none" $FLAGS -DCAS_PREFETCH_INSERTION=NONE
cmake --build "$HERE/build_none" -j 32 --target dramhit

# copy_src <name>: a pristine copy of the tracked tree (plus submodules) at src_<name>
copy_src() {
  local copy="$HERE/src_$1"
  rm -rf "$copy" && mkdir -p "$copy"
  (cd "$SRC" && git ls-files -z | xargs -0 -I{} cp --parents {} "$copy/")
  for sub in $(cd "$SRC" && git submodule --quiet foreach 'echo $sm_path'); do
    cp -r "$SRC/$sub/." "$copy/$sub/"
  done
  echo "$copy"
}
build_copy() {  # build_copy <name>
  cmake -S "$HERE/src_$1" -B "$HERE/build_$1" $FLAGS -DCAS_PREFETCH_INSERTION=DOUBLE
  cmake --build "$HERE/build_$1" -j 32 --target dramhit
}

for d in 16 32; do
  hdr="$(copy_src d$d)/include/hashtables/cas_kht.hpp"
  sed -i "s/#define PREFETCH_INSERT_NEXT_DISTANCE 8/#define PREFETCH_INSERT_NEXT_DISTANCE $d/" "$hdr"
  grep -q "PREFETCH_INSERT_NEXT_DISTANCE $d" "$hdr"
  build_copy d$d
done

# t0only: PREFETCHT1_ONLY with the hint changed, as a patched copy. The
# dequeue-time prefetchw appears at three sites (flush_if_needed,
# pop_insert_queue, the insert_batch fast path); all are the same line.
for v in t0only; do
  hdr="$(copy_src $v)/include/hashtables/cas_kht.hpp"
  test "$(grep -c '__builtin_prefetch(next_tail_addr, true, 3);' "$hdr")" -eq 3
  sed -i '/__builtin_prefetch(next_tail_addr, true, 3);/d' "$hdr"
  if true; then
    sed -i 's|__builtin_prefetch(&this->hashtable\[idx\], false, 2); // L2 prefetch first|__builtin_prefetch(\&this->hashtable[idx], false, 3);|' "$hdr"
    grep -q '__builtin_prefetch(&this->hashtable\[idx\], false, 3);' "$hdr"
  fi
  build_copy $v
done

# nostore: silent-store elimination on the upsert, both sites (insert_batch fast
# path and __insert_branched). Diagnostic only -- it changes the DRAM write stream.
hdr="$(copy_src nostore)/include/hashtables/cas_kht.hpp"
test "$(grep -c 'bucket\[(offset + 1)\] = q->value;' "$hdr")" -eq 2
sed -i 's|bucket\[(offset + 1)\] = q->value;|if (bucket[(offset + 1)] != q->value) bucket[(offset + 1)] = q->value;|' "$hdr"
test "$(grep -c 'if (bucket\[(offset + 1)\] != q->value)' "$hdr")" -eq 2
build_copy nostore
