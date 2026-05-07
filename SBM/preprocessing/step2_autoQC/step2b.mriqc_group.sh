#!/usr/bin/env bash
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
        OUT_DIR="${BASE}/derivatives/MRIQC"
        if [[ ! -d "$OUT_DIR" ]]; then
            echo "Skip $DATASET: missing MRIQC derivatives dir $OUT_DIR"
            continue
        fi
        echo "$DATASET: sbatch MRIQC group → $OUT_DIR"
        export CONFIG_FILE DATA_ROOT DATASET HPC_ENABLED
        sbatch "$STEP_SCRIPT"
    done
    exit 0
fi

# ---------- WORKER (single-task job) ----------
[[ -z "${SLURM_JOB_ID:-}" ]] && { echo "Run from login node without SLURM to submit jobs, or use sbatch."; exit 1; }

DATASET="${DATASET:?Set DATASET}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"

BIDS_DIR="${DATA_ROOT}/${DATASET}"
OUT_DIR="${BIDS_DIR}/derivatives/MRIQC"
GROUP_DIR="${OUT_DIR}/group"
WORK_DIR="${SCRIPT_DIR}/work/${DATASET}.group"

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
