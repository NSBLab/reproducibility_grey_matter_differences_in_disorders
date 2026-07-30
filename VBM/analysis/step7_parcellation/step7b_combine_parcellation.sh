#!/bin/bash
# Step7b: combine projected atlases into ROI NIfTIs under dataset_root/derivatives/roi.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found at $REPO_ROOT"
        exit 1
    fi
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

echo "=== STEP7B: COMBINE PARCELLATION ==="
echo "CONFIG_FILE: $CONFIG_FILE"

if [ "$HPC_ENABLED" = "1" ]; then
    module load matlab/r2023b
fi

matlab -nodisplay -r "addpath('$SCRIPT_DIR'); step7b_sub_combine_parcellation('$CONFIG_FILE'); quit;"
if [ $? -ne 0 ]; then
    echo "Error: step7b_combine_parcellation failed"
    exit 1
fi

echo "=== STEP7B DONE ==="
