#!/bin/bash
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

# ---------- LOGIN: sbatch once per enabled dataset ----------
if [[ -z "${SLURM_JOB_ID:-}" ]] && [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then

    if [[ -z "${CONFIG_FILE:-}" ]]; then
        REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
        if [[ -f "$REPO_ROOT/config_hpc.json" ]]; then CONFIG_FILE="$REPO_ROOT/config_hpc.json"
        elif [[ -f "$REPO_ROOT/config.json" ]]; then CONFIG_FILE="$REPO_ROOT/config.json"
        elif [[ -f "config_hpc.json" ]]; then CONFIG_FILE="config_hpc.json"
        elif [[ -f "config.json" ]]; then CONFIG_FILE="config.json"
        else echo "Error: set CONFIG_FILE or place config_hpc.json in repo root."; exit 1; fi
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
        echo "$DATASET: sbatch PCA QC → $(dirname "$QC_TSV")"
        export CONFIG_FILE DATA_ROOT DATASET PCA_PY HPC_ENABLED
        sbatch "$STEP_SCRIPT"
    done
    exit 0
fi

# ---------- WORKER ----------
[[ -z "${SLURM_JOB_ID:-}" ]] && { echo "Run from login node without SLURM to submit jobs, or use sbatch."; exit 1; }

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
