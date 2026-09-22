#!/usr/bin/env bash
# Toggle the AMD hardware prefetchers via MSR 0xC0000108 on every cpu.
# For the AMD EPYC 9354P (Zen 4).
#
#   0x00 = reset state, all prefetchers enabled
#   0x2F = bits 0,1,2,3,5 set -> L1/L2 prefetchers disabled
#
# Run it as your normal user; it calls sudo itself for the two privileged
# commands:
#
#   scripts/prefetch_control_amd.sh off
#
# Running the whole SCRIPT under sudo used to break it silently. `which rdmsr`
# then resolves against sudo's secure_path, which does not include the nix
# store where msr-tools actually lives, so RDMSR/WRMSR came back empty and
# `sudo ${WRMSR} -a $MSR $VAL` became `sudo -a 0xC0000108 0x2F`. sudo printed a
# usage error, the script printed "Done. Prefetchers disabled." anyway, and the
# MSR was never touched -- the same failure mode prefetch_control.sh documents
# for Intel. It now resolves the tools before any privilege change, refuses to
# run if it cannot find them, and reads the MSR back to prove the write landed.

set -uo pipefail

MSR_REG="0xC0000108"
DISABLE_MASK="0x2F"
ENABLE_MASK="0x00"

# Resolve msr-tools up front. Under sudo, PATH is secure_path and the nix store
# is not on it, so fall back to the invoking user's PATH before giving up.
find_tool() {
    local name="$1" p
    p=$(command -v "$name" 2>/dev/null) && [[ -n "$p" ]] && { echo "$p"; return 0; }
    # Under sudo, PATH is secure_path. Recover the caller's own resolution first,
    # then fall back to the nix store, which is where msr-tools lives here and is
    # exactly what secure_path drops.
    if [[ -n "${SUDO_USER:-}" ]]; then
        p=$(sudo -u "$SUDO_USER" -i command -v "$name" 2>/dev/null) \
            && [[ -n "$p" ]] && { echo "$p"; return 0; }
    fi
    for p in /nix/store/*msr-tools*/bin/"$name" /usr/sbin/"$name" /usr/bin/"$name"; do
        [[ -x "$p" ]] && { echo "$p"; return 0; }
    done
    return 1
}

RDMSR=$(find_tool rdmsr) || {
    echo "Error: 'rdmsr' not found. Install msr-tools, or run this script as your" >&2
    echo "       normal user rather than under sudo (sudo's secure_path hides it)." >&2
    exit 1
}
WRMSR=$(find_tool wrmsr) || {
    echo "Error: 'wrmsr' not found. Install msr-tools, or run this script as your" >&2
    echo "       normal user rather than under sudo (sudo's secure_path hides it)." >&2
    exit 1
}

# Already root (script run under sudo) -> do not re-invoke sudo.
if [[ $EUID -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi

if ! "${SUDO[@]}" test -r /dev/cpu/0/msr; then
    echo "Error: /dev/cpu/0/msr not readable. Try: sudo modprobe msr" >&2
    exit 1
fi

read_msr() { "${SUDO[@]}" "$RDMSR" -p "${1:-0}" -0 "$MSR_REG"; }

# Writes to every cpu, then proves it landed. -a is silent on failure for cpus
# that reject the write, so the read-back is the only real confirmation.
apply() {
    local want="$1" label="$2" want_padded got bad=0
    echo "${label} hardware prefetchers (writing ${want} to MSR ${MSR_REG} on all cpus)..."
    if ! "${SUDO[@]}" "$WRMSR" -a "$MSR_REG" "$want"; then
        echo "Error: wrmsr failed." >&2
        exit 1
    fi
    want_padded=$(printf '%016x' "$want")
    for cpu in 0 $(( $(nproc) - 1 )); do
        got=$(read_msr "$cpu")
        if [[ "$got" != "$want_padded" ]]; then
            echo "Error: cpu ${cpu} reads 0x${got}, expected 0x${want_padded}." >&2
            bad=1
        fi
    done
    [[ $bad -eq 0 ]] || exit 1
    echo "Verified: MSR ${MSR_REG} = 0x${want_padded} on all cpus."
}

case "${1:-}" in
    off) apply "$DISABLE_MASK" "Disabling" ;;
    on)  apply "$ENABLE_MASK"  "Restoring" ;;
    status)
        CURRENT_VAL=$(read_msr 0)
        echo "Current MSR ${MSR_REG} state (cpu 0): 0x${CURRENT_VAL}"
        case "$CURRENT_VAL" in
            000000000000002f) echo "Status: Prefetchers are currently DISABLED." ;;
            0000000000000000) echo "Status: Prefetchers are currently ENABLED." ;;
            *)                echo "Status: Custom configuration detected." ;;
        esac
        ;;
    *)
        echo "Usage: $0 {on|off|status}"
        echo "  off    - Disables L1/L2 prefetchers (writes ${DISABLE_MASK})"
        echo "  on     - Enables L1/L2 prefetchers (writes ${ENABLE_MASK})"
        echo "  status - Reads the current state from cpu 0"
        exit 1
        ;;
esac
