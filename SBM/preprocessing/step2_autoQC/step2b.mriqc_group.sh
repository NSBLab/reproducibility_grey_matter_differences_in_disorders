#!/bin/env bash
# This script requires Bash; users may invoke it with `sh`.
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

#SBATCH --job-name=MRIQC_group
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
# One job per dataset; submit from login builds jobs from config — override via: sbatch --partition=X ...

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

resolve_config_file() {
    if [[ -n "${CONFIG_FILE:-}" ]]; then
        [[ -f "$CONFIG_FILE" ]] && return 0
        echo "Error: CONFIG_FILE is set but file not found: $CONFIG_FILE"
        return 1
    fi

    local dir="$SCRIPT_DIR"
    while [[ -n "$dir" ]]; do
        if [[ -f "$dir/config_hpc.json" ]]; then
            CONFIG_FILE="$dir/config_hpc.json"
            return 0
        fi
        if [[ -f "$dir/config.json" ]]; then
            CONFIG_FILE="$dir/config.json"
            return 0
        fi
        local parent
        parent="$(dirname "$dir")"
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done

    if [[ -f "config_hpc.json" ]]; then
        CONFIG_FILE="config_hpc.json"
        return 0
    fi
    if [[ -f "config.json" ]]; then
        CONFIG_FILE="config.json"
        return 0
    fi

    echo "Error: set CONFIG_FILE or place config_hpc.json/config.json in repo path."
    return 1
}

# ---------- LOGIN: sbatch once per enabled dataset ----------

    resolve_config_file || exit 1
    command -v jq >/dev/null || { echo "Need jq"; exit 1; }

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // empty' "$CONFIG_FILE")
    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

    ENABLED=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
    [[ -z "$ENABLED" ]] && { echo "No enabled datasets."; exit 1; }

    for DATASET in $ENABLED; do
        BASE="${DATA_ROOT}/${DATASET}"
        OUT_DIR="${BASE}/derivatives/MRIQC"
        if [[ ! -d "$OUT_DIR" ]]; then
            echo "Skip $DATASET: missing MRIQC derivatives dir $OUT_DIR"
            continue
        fi
        echo "$DATASET: sbatch MRIQC group → $OUT_DIR"
        export CONFIG_FILE DATA_ROOT DATASET HPC_ENABLED
        sbatch "$STEP_SCRIPT"
        #sh "$STEP_SCRIPT"
    done
    exit 0


# ---------- WORKER (single-task job) ----------


DATASET="${DATASET:?Set DATASET}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"

BIDS_DIR="${DATA_ROOT}/${DATASET}"
OUT_DIR="${BIDS_DIR}/derivatives/MRIQC"
GROUP_DIR="${OUT_DIR}/group"
WORK_DIR="${OUT_DIR}/work"

mkdir -p "$OUT_DIR" "$GROUP_DIR" "$WORK_DIR"

echo "---------------------------"
echo "----- MRIQC group ${DATASET} -----"
echo "---------------------------"

if [[ "${HPC_ENABLED:-0}" == "1" ]] || [[ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    module purge
    module load mriqc/24.0.2-1
fi

mriqc -v "$BIDS_DIR" "$OUT_DIR" group --work-dir "$WORK_DIR"

echo "----- DONE -----"
