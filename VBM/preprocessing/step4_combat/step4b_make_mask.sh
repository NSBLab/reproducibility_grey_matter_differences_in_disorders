#!/bin/bash
# Runs step4b_make_mask for all combat groups (invoked directly — not an array job)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found."
        echo "Checked: $REPO_ROOT/config_hpc.json"
        exit 1
    fi
fi
command -v jq >/dev/null || { echo "Need jq"; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

echo "Using CONFIG_FILE: $CONFIG_FILE"

if [ "$HPC_ENABLED" = "1" ]; then
    module unload matlab
    module load spm12/matlab2021a.r7771-v1
fi

matlab -nodisplay -r "addpath('$SCRIPT_DIR'); step4b_sub_make_mask('$CONFIG_FILE'); quit;"
