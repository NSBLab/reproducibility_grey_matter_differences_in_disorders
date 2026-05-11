#!/bin/bash
# Dispatcher: submits step2d_sub.mriqc_PCA.sh once per enabled dataset
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step2d_sub.mriqc_PCA.sh"
PCA_PY="${PCA_PY:-python3}"

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

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // empty' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

ENABLED=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED" ]] && { echo "No enabled datasets."; exit 1; }

for DATASET in $ENABLED; do
    BASE="${DATA_ROOT}/${DATASET}"
    QC_TSV="${BASE}/derivatives/MRIQC/group_T1w.tsv"
    if [[ ! -f "$QC_TSV" ]]; then
        echo "Skip $DATASET: missing $QC_TSV (run MRIQC group first)."
        continue
    fi
    echo "$DATASET: submitting PCA QC -> $(dirname "$QC_TSV")"
    export CONFIG_FILE DATA_ROOT DATASET PCA_PY HPC_ENABLED

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT"
    fi
done
