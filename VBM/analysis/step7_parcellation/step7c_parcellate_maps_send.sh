#!/bin/bash
# Dispatcher: parcellate subject GM maps for each enabled dataset.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step7c_sub_parcellate_maps.sh"

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
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: missing worker script $SUB_SCRIPT"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

echo "=== STEP7C: PARCELLATE MAPS ==="
echo "CONFIG_FILE: $CONFIG_FILE"
echo "DATA_ROOT:   $DATA_ROOT"
echo "HPC_ENABLED: $HPC_ENABLED"

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED

pids=()
while IFS= read -r DATASET; do
    [[ -z "$DATASET" ]] && continue
    LONGITUDINAL_RAW=$(jq -r --arg d "$DATASET" '.datasets[$d].longitudinal // false' "$CONFIG_FILE")
    case "$(echo "$LONGITUDINAL_RAW" | tr '[:upper:]' '[:lower:]')" in
        1|true) LONGITUDINAL="1" ;;
        *) LONGITUDINAL="0" ;;
    esac
    export DATASET LONGITUDINAL
    echo "Dataset: $DATASET  longitudinal=$LONGITUDINAL"

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch --job-name="parc_${DATASET}" "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT" &
        pids+=($!)
        if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    fi
done <<< "$ENABLED_DATASETS"

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP7C SUBMISSION DONE ==="
