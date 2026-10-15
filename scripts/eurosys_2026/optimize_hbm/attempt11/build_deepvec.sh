#!/usr/bin/env bash
# attempt11: build the best deep-vectorization configuration from report-bwgap.md §30-§33
# (= attempt10/dc24s: DEEP_VECTORIZATION, crc32 hash, L1 find prefetch distance 24, 16 B split
# arguments, no key_id in the insert queue) and verify that every -D actually took effect.
#
#   ./build_deepvec.sh [name] [extra cmake -D...]     default name: dvs
#
# Checks, in order (any failure aborts):
#   1. fresh build dir (no stale CMakeCache: a cached option from an earlier configure would
#      silently override a missing -D)
#   2. CMakeCache.txt holds every requested value
#   3. the compile command of zipfian_test.cpp (the TU that instantiates CASHashTable::find_batch)
#      carries every expected -D
#   4. the preprocessor, run with that exact command, sees every expected macro, including the ones
#      the headers derive (CAS_FIND_QUEUE16) and none of the forbidden ones
#   5. the binary: find_batch(span<FindArgument>) exists, has the deep-path signature (64 B zmm block
#      loads/stores, crc32, kortest) and the L1 prefetch is 24 x 16 B = 0x180 slots ahead
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="${SRC:-$(cd "$HERE/../../../.." && pwd)}"   # /opt/DRAMHiT; SRC=<tree> builds another source tree
NAME="${1:-dvs}"; shift || true
OUT="$HERE/$NAME"; BUILD="$OUT/build"
PF_DIST=24

# ---- the configuration (one flag per line so it is easy to diff against the report)
CMAKE_ARGS=(
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DDRAMHiT_VARIANT=2025_INLINE
  -DBRANCH=simd
  -DHASHER=crc
  -DKEY_LEN=8
  -DKMER_LEN=8
  -DBENCHMARK_BACKEND=NONE
  -DCPUFREQ_MHZ=2700
  -DBUCKETIZATION=ON
  -DUNIFORM_PROBING=ON
  -DREAD_BEFORE_CAS=ON
  -DCAS_FAST_PATH=ON
  -DPREFETCH=DOUBLE
  -DCAS_PREFETCH_INSERTION=DOUBLE
  -DCAS_FIND_RING_OFFSETS=ON
  -DCAS_FIND_COMPRESS_VALUE=ON
  -DCAS_FIND_KSHIFT=ON
  -DCAS_FIND_EMBCAST=OFF
  -DCALC_STATS=OFF
  -DLATENCY_COLLECTION=OFF
  -DDEEP_VECTORIZATION=ON
  -DFIND_PF_DIST=$PF_DIST
  -DSPLIT_ARGS=ON
  "$@"
)
# macros the compiler must see in zipfian_test.cpp (name or name=value)
MUST_DEFINE=(
  DEEP_VECTORIZATION SPLIT_ARGS "FIND_PF_DIST=$PF_DIST"
  CAS_FIND_RING_OFFSETS CAS_FIND_COMPRESS_VALUE CAS_FIND_KSHIFT
  CAS_FIND_QUEUE16                                   # derived in cas_kht.hpp; deep path needs it
  DOUBLE_PREFETCH CAS_INSERT_PREFETCH_DOUBLE
  FAST_PATH BUCKETIZATION BRANCHLESS_SIMD UNIFORM_HT_SUPPORT READ_BEFORE_CAS
  "KEY_LEN=8" "CPUFREQ_MHZ=2700" CRC_HASH
)
# macros that must NOT be visible (would change the find path or add overhead)
MUST_NOT=(CAS_FIND_EMBCAST LATENCY_COLLECTION CAS_FIND_BANDWIDTH_TEST CALC_STATS CAS_FIND_SCALAR_PACK)

die() { echo "FAIL: $*" >&2; exit 1; }
ok()  { echo "  ok  $*"; }

echo "== [1] fresh configure: $BUILD"
rm -rf "$BUILD"; mkdir -p "$BUILD"
cmake -S "$SRC" -B "$BUILD" "${CMAKE_ARGS[@]}" > "$BUILD/cmake.log" 2>&1 || { tail -20 "$BUILD/cmake.log"; die "cmake"; }
grep -q "cas insert-path prefetch: DOUBLE" "$BUILD/cmake.log" || die "insert prefetch is not DOUBLE"

echo "== [2] CMakeCache values"
for a in "${CMAKE_ARGS[@]}"; do
  [[ $a == -D* ]] || continue
  kv="${a#-D}"; k="${kv%%=*}"; v="${kv#*=}"
  got=$(grep -E "^${k}:[A-Z]+=" "$BUILD/CMakeCache.txt" | head -1 | cut -d= -f2-) || true
  [[ "$got" == "$v" ]] || die "cache $k = '$got', wanted '$v'"
done
ok "${#CMAKE_ARGS[@]} cache entries match"

echo "== [3] build"
make -C "$BUILD" -j"$(nproc)" dramhit > "$BUILD/make.log" 2>&1 || { grep -m5 -B2 -A8 -E "error|#error" "$BUILD/make.log"; die "make"; }
grep -E "warning: .*(DEEP_VECTORIZATION|batch_len)" "$BUILD/make.log" && die "deep-path warning in make.log" || true

echo "== [4] compile command + preprocessor macros of zipfian_test.cpp"
CMD=$(python3 - "$BUILD/compile_commands.json" <<'EOF'
import json, sys
for e in json.load(open(sys.argv[1])):
    if e["file"].endswith("/zipfian_test.cpp"):
        print(e["command"]); break
else:
    sys.exit("zipfian_test.cpp not in compile_commands.json")
EOF
)
echo "$CMD" > "$OUT/compile_cmd.txt"
for m in DEEP_VECTORIZATION SPLIT_ARGS "FIND_PF_DIST=$PF_DIST" CAS_FIND_RING_OFFSETS CAS_FIND_COMPRESS_VALUE CAS_FIND_KSHIFT; do
  grep -qE -- "-D$m( |$)" <<<"$CMD" || die "-D$m missing from compile command"
done
ok "compile command carries the deep-path -D flags"
SRCFILE=$(grep -oE '[^ ]+/zipfian_test\.cpp' <<<"$CMD" | tail -1)
PP=$(sed -E 's/ -o [^ ]+//; s/ -c [^ ]+//; s/ -MD|-MT [^ ]+|-MF [^ ]+//g' <<<"$CMD")
(cd "$BUILD" && eval "$PP -dM -E $SRCFILE") > "$OUT/macros.txt" 2>"$OUT/macros.err" || { cat "$OUT/macros.err"; die "preprocess"; }
for m in "${MUST_DEFINE[@]}"; do
  n="${m%%=*}"; line=$(grep -E "^#define $n( |$)" "$OUT/macros.txt" || true)
  [[ -n $line ]] || die "macro $n not defined"
  if [[ $m == *=* ]]; then [[ "$line" == "#define $n ${m#*=}" ]] || die "$line, wanted ${m#*=}"; fi
done
for m in "${MUST_NOT[@]}"; do grep -qE "^#define $m( |$)" "$OUT/macros.txt" && die "macro $m must not be defined"; done
ok "${#MUST_DEFINE[@]} required macros present, ${#MUST_NOT[@]} forbidden absent"

echo "== [5] binary: find_batch(span<FindArgument>) signature"
cp "$BUILD/dramhit" "$OUT/dramhit"
nm -S "$OUT/dramhit" > "$OUT/syms.txt"            # file, not a pipe: no SIGPIPE under pipefail
SYM=$(c++filt < "$OUT/syms.txt" | grep -E "CASHashTable<.*>::find_batch\(std::span<kmercounter::FindArgument" | grep -v "\.cold" | awk 'NR==1 {print $1}')
[[ -n $SYM ]] || die "no CASHashTable::find_batch(span<FindArgument>) -- SPLIT_ARGS not in effect"
START=$((16#$SYM)); SIZE=$(awk -v a="$SYM" '$1==a && !n++ {print $2}' "$OUT/syms.txt")
objdump -d --no-show-raw-insn -M intel --start-address=$START --stop-address=$((START + 16#$SIZE)) "$OUT/dramhit" \
  | sed -n '/>:$/,$p' > "$OUT/find_batch.s"
objdump -dl --no-show-raw-insn --start-address=$START --stop-address=$((START + 16#$SIZE)) "$OUT/dramhit" > "$OUT/find_batch.lines.s"
cnt() { grep -cE "$1" "$OUT/find_batch.s" || true; }
NI=$(grep -cE '^ +[0-9a-f]+:' "$OUT/find_batch.s")
printf "  find_batch: %s instructions, %s crc32, %s kortest, %s zmm loads/stores, %s prefetcht0, %s vpcompress\n" \
  "$NI" "$(cnt crc32)" "$(cnt kortest)" "$(cnt 'vmovdq[au]64 +(zmm|ZMMWORD)|ZMMWORD PTR')" "$(cnt prefetcht0)" "$(cnt vpcompress)"
(( $(cnt crc32) >= 4 ))    || die "fewer than 4 crc32 in find_batch: deep push not inlined"
(( $(cnt kortest) >= 4 ))  || die "fewer than 4 kortest: deep pop not inlined"
grep -qE 'ZMMWORD PTR' "$OUT/find_batch.s" || die "no 64 B zmm memory access: deep block load/store missing"
# the ring is addressed by byte offset: next-slot offset = head + 24 x 16 B, then prefetcht0 [ring + off]
PFOFF=$(printf '0x%x' $((PF_DIST * 16)))
(( $(cnt "lea +[a-z0-9]+,\\[[a-z0-9]+\\+$PFOFF\\]") >= 4 )) || die "no 4x 'lea r,[r+$PFOFF]' (FIND_PF_DIST=$PF_DIST x 16 B)"
ok "deep-path signature present, L1 prefetch $PFOFF bytes ahead"

md5sum "$OUT/dramhit" | tee "$OUT/md5.txt"
REF="$HERE/../attempt10/dc24s/dramhit"
[[ -f $REF ]] && { cmp -s "$REF" "$OUT/dramhit" && echo "  identical to attempt10/dc24s" || echo "  note: differs from attempt10/dc24s (expected if sources changed after E33)"; }
echo "OK $OUT/dramhit"
