#!/bin/bash
#SBATCH --time=0-4:00:00
#SBATCH --account=kg98
#SBATCH --job-name=CAT12_Preprocessing
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000
#SBATCH --mail-user=trang.cao@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END

# Worker: runs CAT12 preprocessing for one subject (invoked by step1a_CAT12_preprocessing_send.sh)

if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo "Error: SLURM_ARRAY_TASK_ID not set. Run via step1a_CAT12_preprocessing_send.sh."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
DATASET="${DATASET:?Set DATASET}"
SUBJECT_LIST="${SUBJECT_LIST:?Set SUBJECT_LIST}"

i=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SUBJECT_LIST" | xargs)
[[ -z "$i" ]] && { echo "Empty line ${SLURM_ARRAY_TASK_ID}"; exit 1; }

DATASET_DIR="${DATA_ROOT}/${DATASET}"

# Resolve session
shopt -s nullglob
ses_dirs=("${DATASET_DIR}/${i}"/ses-*)
shopt -u nullglob
if [[ ${#ses_dirs[@]} -gt 0 ]] && [[ -d "${ses_dirs[0]}" ]]; then
    ses="$(basename "${ses_dirs[0]}")"
    T1_name="${DATASET_DIR}/${i}/${ses}/anat/${i}_${ses}_T1w.nii"
else
    ses=""
    T1_name="${DATASET_DIR}/${i}/anat/${i}_T1w.nii"
fi

echo "---------------------------"
echo "----- $i (${DATASET}) -----"
echo "---------------------------"

if [ "${HPC_ENABLED:-0}" = "1" ] || [ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    module unload matlab
    module load spm12/matlab2021a.r7771-v1
fi

matlab -nodisplay -r "cd ('$SCRIPT_DIR'); CAT12_preprocessing_job('$T1_name')"
