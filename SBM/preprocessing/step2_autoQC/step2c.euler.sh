#!/usr/bin/env bash
# Dispatcher: submits step2c_sub.euler.sh once per enabled dataset
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step2c_sub.euler.sh"

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

submitted=0
for DATASET in $ENABLED; do
    BASE="${DATA_ROOT}/${DATASET}"
    LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
    [[ "$LONG" == "true" ]] && LONG=1 || LONG=0

    if [[ "$LONG" -eq 1 ]]; then
        RECON_LIST="${BASE}/ses_sub_with_recon_output.txt"
    else
        RECON_LIST="${BASE}/sub_with_recon_output.txt"
    fi

    if [[ ! -f "$RECON_LIST" ]]; then
        echo "Skip $DATASET: missing $RECON_LIST"
        continue
    fi

    echo "$DATASET: submitting Euler"
    export CONFIG_FILE DATA_ROOT DATASET HPC_ENABLED

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT"
    fi
    submitted=$((submitted + 1))
done

if [[ "$submitted" -eq 0 ]]; then
    echo "Nothing to run (no recon lists found for enabled datasets)."
fi
