#!/bin/bash
# Build BrainSMASH volume distance matrix using pipeline config.

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

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
CONDA_ENV=$(jq -r '.data_directories.conda_env // empty' "$CONFIG_FILE")
HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

echo "=== STEP6A: VOLUME DISTANCE MATRIX ==="
echo "CONFIG_FILE: $CONFIG_FILE"
echo "DATA_ROOT:   $DATA_ROOT"

if [[ "$HPC_ENABLED" == "1" ]] && [[ -n "$CONDA_ENV" ]]; then
    # shellcheck disable=SC1090
    source "$CONDA_ENV"
fi

python "$SCRIPT_DIR/step6a_matrix_volume.py" --config "$CONFIG_FILE"
echo "=== STEP6A DONE ==="
