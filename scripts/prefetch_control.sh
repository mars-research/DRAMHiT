#!/usr/bin/env bash
# Toggle the Intel hardware prefetchers via MSR 0x1a4 on every cpu.
#   0x0 = all four prefetchers enabled
#   0xf = all four disabled
#
# Needs root, and does NOT call sudo itself. sudo's secure_path drops msr-tools
# from PATH, so carry PATH across explicitly:
#
#   sudo env PATH="$PATH" scripts/prefetch_control.sh off
#
# The previous version ran `sudo ${WRMSR} ...` internally, with WRMSR resolved
# by $(which wrmsr) at the top. Invoked under sudo that resolution came back
# empty and the command became `sudo 0x1a4 -a 0x0` -> "0x1a4: command not
# found": the script printed "Turning off all prefetchers" and changed nothing.
# It now fails loudly, and reads the MSR back to confirm the write landed.

set -euo pipefail

usage() {
  echo "usage: prefetch_control.sh <on|off>" >&2
  echo "  on  -> MSR 0x1a4 = 0x0 (all prefetchers enabled)" >&2
  echo "  off -> MSR 0x1a4 = 0xf (all prefetchers disabled)" >&2
}

case "${1:-}" in
  on)  want=0x0; label="Turning on all prefetchers" ;;
  off) want=0xf; label="Turning off all prefetchers" ;;
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
"${WRMSR}" -a 0x1a4 "${want}"

got=$("${RDMSR}" -a 0x1a4 | sort -u)
if [ "$(printf '%s\n' "${got}" | wc -l)" -ne 1 ] || \
   [ "$((16#${got}))" -ne "$((want))" ]; then
  echo "error: MSR 0x1a4 reads back as [$(printf '%s ' ${got})], expected ${want}" >&2
  exit 1
fi
echo "verified: MSR 0x1a4 = 0x${got} on all cpus"
