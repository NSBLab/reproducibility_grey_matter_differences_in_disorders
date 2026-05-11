#!/bin/bash
#SBATCH --job-name=MRIQC_individual
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=0-1:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000

# Worker: runs MRIQC for a single subject (invoked by step2a.mriqc_individual.sh)

if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
    echo "Error: SLURM_ARRAY_TASK_ID not set. Run via step2a.mriqc_individual.sh."
    exit 1
fi

DATASET="${DATASET:?Set DATASET}"
SUBJECT_LIST="${SUBJECT_LIST:?Set SUBJECT_LIST}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
LONG="${LONG:-0}"

line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SUBJECT_LIST" | xargs)
[[ -z "$line" ]] && { echo "Empty line ${SLURM_ARRAY_TASK_ID}"; exit 1; }

BIDS_DIR="${DATA_ROOT}/${DATASET}"
OUT_DIR="${BIDS_DIR}/derivatives/MRIQC"
WORK_DIR="${OUT_DIR}/work"

echo "---------------------------"
echo "----- ${SLURM_ARRAY_TASK_ID} ${line} (${DATASET}) -----"
echo "---------------------------"

mkdir -p "$OUT_DIR" "$WORK_DIR"

if [[ "${HPC_ENABLED:-0}" == "1" ]] || [[ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    module purge
    module load mriqc/24.0.2-1
fi

if [[ "$LONG" -eq 1 ]]; then
    read -r plabel sess <<<"$line"
    mriqc "$BIDS_DIR" "$OUT_DIR" participant --participant_label "$plabel" --session-id "$sess" \
        --n_procs 12 --n_cpus 6 --mem_gb 12 -m T1w --work-dir "$WORK_DIR" --bids-filter-file "$BIDS_DIR"
else
    mriqc "$BIDS_DIR" "$OUT_DIR" participant --participant_label "$line" \
        --n_procs 12 --n_cpus 6 --mem_gb 12 -m T1w --work-dir "$WORK_DIR" --bids-filter-file "$BIDS_DIR"
fi

echo "----- DONE -----"
