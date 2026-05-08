#!/bin/bash
# This script requires Bash; users may invoke it with `sh`.
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=0-3:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
# One job per dataset with group_T1w.tsv; submit from login. Optional: export PCA_PY=/path/to/python

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"
PCA_PY="${PCA_PY:-python3}"

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
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then

    resolve_config_file || exit 1
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
        echo "$DATASET: sbatch PCA QC → $(dirname "$QC_TSV")"
        export CONFIG_FILE DATA_ROOT DATASET PCA_PY HPC_ENABLED
        sbatch "$STEP_SCRIPT"
    done
    exit 0
fi

# ---------- WORKER ----------
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo "Error: missing SLURM_ARRAY_TASK_ID"
    exit 1
fi
DATASET="${DATASET:?Set DATASET}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"

BIDS_DIR="${DATA_ROOT}/${DATASET}"
MRIQC_DIR="${BIDS_DIR}/derivatives/MRIQC"
QC_TSV="${MRIQC_DIR}/group_T1w.tsv"
PCA_SCRIPT="${SCRIPT_DIR}/step2d_sub.mriqc_PCA.py"

echo "---------------------------"
echo "----- MRIQC PCA ${DATASET} -----"
echo "---------------------------"

PY_ENV_ACTIVATE=$(jq -r '.data_directories.conda_env // empty' "${CONFIG_FILE:-}")
if [[ -n "$PY_ENV_ACTIVATE" ]]; then
    if [[ "$PY_ENV_ACTIVATE" == "~/"* ]]; then
        PY_ENV_ACTIVATE="${HOME}/${PY_ENV_ACTIVATE#~/}"
    fi
    if [[ -f "$PY_ENV_ACTIVATE" ]]; then
        # shellcheck source=/dev/null
        source "$PY_ENV_ACTIVATE"
    else
        echo "Warning: conda_env activate script not found: $PY_ENV_ACTIVATE"
        echo "Continuing with ${PCA_PY} from PATH."
    fi
fi

"${PCA_PY}" "${PCA_SCRIPT}" "${QC_TSV}" "${MRIQC_DIR}"

# required python packages: numpy pandas scipy sklearn matplotlib argparse

# NOTE: this will return a list of subjects that failed the mriqc PCA check, but you'll still need to check the euler numbers for each subject/each hemisphere to get your list of subjects that failed euler checks
