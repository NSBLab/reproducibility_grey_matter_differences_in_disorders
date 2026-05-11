#!/bin/env bash
#SBATCH --job-name=MRIQC_group
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000

# Worker: runs MRIQC group for one dataset (invoked by step2b.mriqc_group.sh)
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

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
