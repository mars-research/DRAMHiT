#!/usr/bin/env bash

RDMSR=$(which rdmsr)
WRMSR=$(which wrmsr)

if [ $# -lt 1 ]; then
  echo "usage: prefetch_control.sh <on|off>";
  echo " on -> you should see 0x0";
  echo " off -> you should see 0xf";
fi

if [ "$1" == "on" ]; then
  echo "Turning on all prefetchers";
  sudo ${WRMSR} 0x1a4 -a 0x0
  sudo ${RDMSR} 0x1a4
elif [ "$1" == "off" ]; then
  echo "Turning off all prefetchers";
  sudo ${WRMSR} 0x1a4 -a 0xf
  sudo ${RDMSR} 0x1a4
fi

