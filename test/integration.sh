#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

opa run --server "$SCRIPT_DIR/../policy/" &>/dev/null &

pid=$(echo $!)

# Provide some time for OPA to start
sleep 1

"$SCRIPT_DIR"/test-templates.py

status=$(echo $?)

kill "$pid"

exit "$status"
