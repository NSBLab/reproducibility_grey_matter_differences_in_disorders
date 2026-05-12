#!/bin/bash
# Dispatcher: submits step6_sub_make_input_run_mri_glmfit.sh per enabled dataset

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step6_sub_make_input_run_mri_glmfit.sh"

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
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: Missing $SUB_SCRIPT"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac
HARMONIZE=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "No enabled datasets found in config."; exit 1; }

# --- Analysis settings ---
smoothKernel=10
measure=thickness
measureShort=thick
hemis="lh rh"
control=1
covariance1=sex
covariance2=age

echo "Using CONFIG_FILE: $CONFIG_FILE"
echo "DATA_ROOT:         $DATA_ROOT"
echo "HPC_ENABLED:       $HPC_ENABLED"
echo "harmonize:         $HARMONIZE"
echo "smoothKernel:      $smoothKernel"
echo "Enabled datasets:  $ENABLED_DATASETS"

for DATASET in $ENABLED_DATASETS; do
    DATASET_DIR="${DATA_ROOT}/${DATASET}"
    if [ ! -d "$DATASET_DIR" ]; then
        echo "Warning: $DATASET_DIR not found, skipping..."
        continue
    fi
    if [ ! -d "${DATASET_DIR}/derivatives/freesurfer" ]; then
        echo "Warning: No freesurfer derivatives for $DATASET, skipping..."
        continue
    fi

    echo "=== Submitting step6 for dataset: $DATASET ==="
    export CONFIG_FILE DATA_ROOT DATASET HPC_ENABLED HARMONIZE
    export smoothKernel measure measureShort hemis control covariance1 covariance2

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch --job-name="step6_${DATASET}" "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT"
    fi
done
