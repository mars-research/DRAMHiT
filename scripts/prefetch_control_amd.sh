#!/bin/bash

# This is for  AMD EPYC 9354P
#
# Target MSR and values
MSR_REG="0xC0000108"
DISABLE_MASK="0x2F" # Bits 0, 1, 2, 3, and 5 set to 1
ENABLE_MASK="0x00"  # Reset state (all enabled)
RDMSR=$(which rdmsr)
WRMSR=$(which wrmsr)

# 2. Ensure msr-tools is installed
if ! command -v ${WRMSR} &> /dev/null; then
    echo "Error: 'wrmsr' command not found."
    echo "Please install msr-tools (e.g., sudo apt install msr-tools)."
    exit 1
fi

# 4. Handle the command line arguments
case "$1" in
    off)
        echo "Disabling hardware prefetchers (writing $DISABLE_MASK to MSR $MSR_REG on all cores)..."
        sudo ${WRMSR} -a $MSR_REG $DISABLE_MASK
        echo "Done. Prefetchers disabled."
        ;;
    on)
        echo "Restoring hardware prefetchers (writing $ENABLE_MASK to MSR $MSR_REG on all cores)..."
        sudo ${WRMSR} -a $MSR_REG $ENABLE_MASK
        echo "Done. Prefetchers enabled."
        ;;
    status)
        echo "Current MSR $MSR_REG state (Core 0):"
        # Read the MSR value from core 0 padded with zeros
        CURRENT_VAL=$(sudo $RDMSR -p 0 -0 $MSR_REG)
        echo "0x$CURRENT_VAL"

        if [ "$CURRENT_VAL" == "000000000000002f" ]; then
            echo "Status: Prefetchers are currently DISABLED."
        elif [ "$CURRENT_VAL" == "0000000000000000" ]; then
            echo "Status: Prefetchers are currently ENABLED."
        else
            echo "Status: Custom configuration detected."
        fi
        ;;
    *)
        echo "Usage: $0 {on|off|status}"
        echo "  off    - Disables L1/L2 prefetchers (writes 0x2F)"
        echo "  on     - Enables L1/L2 prefetchers (writes 0x00)"
        echo "  status - Reads the current state from Core 0"
        exit 1
        ;;
esac
