#!/usr/bin/env bash
# E21: DEEP_VECTORIZATION find-queue length x batch length sweep (attempt10), fill 10, keys in HBM
set -e
cd "$(dirname "$0")"
python3 run_stream.py --reps 3 --interval-ms 100 --read-factor 400 --workloads a10_dv_q32_b16 a10_dv_q32_b32 a10_dv_q32_b64 a10_dv_q64_b16 a10_dv_q64_b32 a10_dv_q64_b64 a10_dv_q128_b16 a10_dv_q128_b32 a10_dv_q128_b64 a10_dv_q256_b16 a10_dv_q256_b32 a10_dv_q256_b64 a10_q16_q64_b16 --out E21_qb
