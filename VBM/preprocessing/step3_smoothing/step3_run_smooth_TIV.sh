#!/bin/bash
# Dispatcher: reads config, loops enabled datasets, submits run_smooth_TIV_batch.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATCH_SCRIPT="${SCRIPT_DIR}/run_smooth_TIV_batch.sh"

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
[[ -f "$BATCH_SCRIPT" ]] || { echo "Error: Missing $BATCH_SCRIPT"; exit 1; }

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac
MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED=$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED" ]] && { echo "No enabled datasets in $CONFIG_FILE"; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"

pids=()
for DATASET in $ENABLED; do
    echo "=== $DATASET ==="
    export CONFIG_FILE DATASET HPC_ENABLED

    if [[ "$HPC_ENABLED" == "1" ]]; then
        echo "$DATASET: submitting smoothing job via SLURM"
        sbatch --job-name="smooth_${DATASET}" "$BATCH_SCRIPT"
    else
        echo "$DATASET: running smoothing locally"
        bash "$BATCH_SCRIPT" &
        pids+=($!)
        if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    fi
done
[[ "$HPC_ENABLED" != "1" ]] && wait
