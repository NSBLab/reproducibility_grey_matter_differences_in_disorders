#!/bin/bash
# Dispatcher: submit label-shuffle GLM permutations for enabled datasets.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/permutation_job.sh"

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
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: missing worker $SUB_SCRIPT"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
smoothKernel=$(jq -r '.analysis_settings.vbm_smoothing_kernel // 6' "$CONFIG_FILE")
harmonize=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")
maskDiag=$(jq -r '.analysis_settings.mask_diagnostic_group // "psy"' "$CONFIG_FILE")
NUM_PERMUTATIONS=$(jq -r '.analysis_settings.num_permutations // 10' "$CONFIG_FILE")

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

echo "=== STEP6C: PERMUTATION ANALYSIS ==="
echo "CONFIG_FILE:       $CONFIG_FILE"
echo "DATA_ROOT:         $DATA_ROOT"
echo "smoothKernel:      $smoothKernel"
echo "harmonize:         $harmonize"
echo "maskDiag:          $maskDiag"
echo "NUM_PERMUTATIONS:  $NUM_PERMUTATIONS"
echo "HPC_ENABLED:       $HPC_ENABLED"

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED smoothKernel harmonize maskDiag

pids=()
while IFS= read -r DATASET; do
    [[ -z "$DATASET" ]] && continue
    export DATASET

    for perm in $(seq 1 "$NUM_PERMUTATIONS"); do
        export PERM_ID=$perm
        echo "Submitting perm=${perm} dataset=${DATASET}"

        if [[ "$HPC_ENABLED" == "1" ]]; then
            sbatch --job-name="perm${perm}_${DATASET}" "$SUB_SCRIPT"
        else
            bash "$SUB_SCRIPT" &
            pids+=($!)
            if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                wait "${pids[0]}"
                pids=("${pids[@]:1}")
            fi
        fi
    done
done <<< "$ENABLED_DATASETS"

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP6C SUBMISSION DONE ==="
