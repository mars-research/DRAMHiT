#!/usr/bin/env bash

# Ensure script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run as root (e.g., sudo $0)"
  exit 1
fi

RDMSR=$(which rdmsr)
WRMSR=$(which wrmsr)

echo "[*] Disabling AMD Core Performance Boost (CPB/Turbo)..."
# Read bit mask from Core 0
HWCR_VAL=$($RDMSR -p 0 0xc0010015)

# Flip bit 25 (CpbDis - Core Performance Boost Disable) to 1
HWCR_NEW=$(printf "0x%x" $(( 0x$HWCR_VAL | (1 << 25) )))

# Write modified mask across all cores (-a)
$WRMSR -a 0xc0010015 "$HWCR_NEW"

echo "[*] Forcing all CPU cores into P-State 0 (P0)..."
$WRMSR -a 0xc0010063 0x0

# Read back active state on CPU 0
ACTIVE_PSTATE=$($RDMSR -p 0 0xc0010062)
echo "[+] Target applied! Active P-State MSR returned: P${ACTIVE_PSTATE}"
echo "[*] Launching real-time frequency monitoring (Press Ctrl+C to exit)..."
echo ""

sleep 1.5

# Monitor core frequencies in real-time
watch -n 0.5 "grep 'cpu MHz' /proc/cpuinfo"
