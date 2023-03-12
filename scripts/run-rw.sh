#!/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$SCRIPT_DIR/generate-rw-runs.py $1 | sh -x
