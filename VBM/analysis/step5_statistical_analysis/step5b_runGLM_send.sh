#!/bin/bash
# Dispatcher: submits one GLM job per enabled dataset.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/runGLM_batch.sh"

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

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

echo "=== STEP5: VBM GLM SUBMISSION ==="
echo "CONFIG_FILE: $CONFIG_FILE"
echo "HPC_ENABLED: $HPC_ENABLED"

export CONFIG_FILE HPC_ENABLED

if [[ "$HPC_ENABLED" == "1" ]]; then
    while IFS= read -r DATASET; do
        [[ -z "$DATASET" ]] && continue
        echo "Submitting: $DATASET"
        export DATASET
        sbatch --job-name="GLM_VBM_${DATASET}" "$SUB_SCRIPT"
    done <<< "$ENABLED_DATASETS"
else
    pids=()
    while IFS= read -r DATASET; do
        [[ -z "$DATASET" ]] && continue
        echo "Running locally: $DATASET"
        export DATASET
        bash "$SUB_SCRIPT" &
        pids+=($!)
        if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    done <<< "$ENABLED_DATASETS"
    wait
fi

echo "=== STEP5 SUBMISSION DONE ==="
