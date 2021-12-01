#!/usr/bin/env bash
set -euo pipefail

echo 0 > /proc/sys/kernel/perf_event_paranoid
echo 0 > /proc/sys/kernel/kptr_restrict
echo 0 > /proc/sys/kernel/yama/ptrace_scope
