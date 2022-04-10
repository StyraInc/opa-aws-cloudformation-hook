#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

current=$(cat "$SCRIPT_DIR/../hooks/styra-opa-hook.json")

new=$(echo "$current" \
| opa eval --stdin-input \
           --format pretty \
           --data "$SCRIPT_DIR/resourcetypes.rego" \
           data.aws.cloudformation.output)

if [[ "$current" != "$new" ]]; then
    echo "Resource types have been updated. Please run:"
    echo
    echo "cat hooks/styra-opa-hook.json | opa eval -I -f pretty -d build/resourcetypes.rego data.aws.cloudformation.output > hooks/styra-opa-hook-new.json"
    echo
    echo "mv hooks/styra-opa-hook-new.json hooks/styra-opa-hook.json"
    echo
    echo "And commit the result"
    exit 1
fi
