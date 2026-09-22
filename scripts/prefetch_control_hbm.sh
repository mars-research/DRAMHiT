#!/usr/bin/env bash
# Toggle the hardware prefetchers via MSR 0x1a4 on the Xeon Max 9462 (HBM box).
#   on  -> 0x00  all prefetchers enabled
#   off -> 0x2f  all prefetchers this cpu lets us disable
#
# Why this exists instead of prefetch_control.sh
# ----------------------------------------------
# prefetch_control.sh writes 0xf, the four classic bits (L2 stream, L2 adjacent
# line, DCU, DCU IP). On this part that is NOT "all prefetchers off": bit 5
# controls a further prefetcher that keeps running, and it is not a small
# effect on a sequential access pattern. Measured on folklore's linear-probe
# lookup (uniform, 8 GiB table, fill 50, 64 threads, table in hbm):
#
#   mask   offcore data reads/op   L2 fills/op   demand misses/op   get Mops
#   0x00           4.80               5.43            1.21             980
#   0x0f           3.32               3.39            1.05            1282
#   0x2f           1.48               1.51            1.34            1160
#   0x3f           1.47               1.50            1.33            1144
#
# The algorithm itself touches 1.125 cache lines per lookup at that fill (that
# is linear probing at 50% load, confirmed by simulating the exact key stream
# and hash). Only at 0x2f does the measured traffic match it -- under 0xf the
# machine was fetching 2.2 extra lines per lookup that nothing asked for, which
# is enough to make a memory-traffic number meaningless.
#
# 0x3f behaves the same as 0x2f here (bit 4 changes nothing measurable), and
# 0xff is rejected by the cpu, so 0x2f is what "off" means on this machine.
# A random-access table barely notices the difference (cas23: 1.50 -> 1.28
# lines/op, throughput unchanged); a sequential one does.
#
# Needs root, and does NOT call sudo itself -- sudo's secure_path drops
# msr-tools from PATH, so carry PATH across explicitly:
#
#   sudo env PATH="$PATH" scripts/prefetch_control_hbm.sh off

set -euo pipefail

ON_MASK=0x0
OFF_MASK=0x2f

usage() {
  echo "usage: prefetch_control_hbm.sh <on|off|0xNN>" >&2
  echo "  on   -> MSR 0x1a4 = ${ON_MASK} (all prefetchers enabled)" >&2
  echo "  off  -> MSR 0x1a4 = ${OFF_MASK} (all four classic bits + bit 5)" >&2
  echo "  0xNN -> that mask, for isolating one bit" >&2
}

case "${1:-}" in
  on)  want=${ON_MASK};  label="Turning on all prefetchers" ;;
  off) want=${OFF_MASK}; label="Turning off all prefetchers" ;;
  0x*) want="$1";        label="Setting prefetch control to $1" ;;
  *)   usage; exit 1 ;;
esac

RDMSR=$(command -v rdmsr || true)
WRMSR=$(command -v wrmsr || true)
if [ -z "${WRMSR}" ] || [ -z "${RDMSR}" ]; then
  echo "error: rdmsr/wrmsr not found on PATH (install msr-tools)" >&2
  echo "  PATH=${PATH}" >&2
  echo "  under sudo, run: sudo env PATH=\"\$PATH\" $0 $1" >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "error: must be root to write MSR 0x1a4; run:" >&2
  echo "  sudo env PATH=\"\$PATH\" $0 $1" >&2
  exit 1
fi

echo "${label} (MSR 0x1a4 = ${want} on all cpus)"
# A mask with a bit this cpu does not implement is rejected per-cpu, which
# would otherwise leave the machine in a mixed state.
if ! "${WRMSR}" -a 0x1a4 "${want}"; then
  echo "error: cpu rejected MSR 0x1a4 = ${want}; prefetcher state is now" \
       "UNKNOWN -- re-run with a supported mask (0x0, 0xf, 0x2f, 0x3f)" >&2
  exit 1
fi

got=$("${RDMSR}" -a 0x1a4 | sort -u)
if [ "$(printf '%s\n' "${got}" | wc -l)" -ne 1 ] || \
   [ "$((16#${got}))" -ne "$((want))" ]; then
  echo "error: MSR 0x1a4 reads back as [$(printf '%s ' ${got})], expected ${want}" >&2
  exit 1
fi
echo "verified: MSR 0x1a4 = 0x${got} on all cpus"
