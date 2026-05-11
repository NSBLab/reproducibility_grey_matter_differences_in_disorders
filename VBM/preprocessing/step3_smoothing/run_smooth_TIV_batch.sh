#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --account=kg98
#SBATCH --job-name=smooth
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
#SBATCH --export=ALL

# Worker: smooths GM images and estimates TIV for one dataset (invoked by run_smooth_TIV_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATASET="${DATASET:?Set DATASET}"

if [ "${HPC_ENABLED:-0}" = "1" ] || [ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    module unload matlab
    module load spm12/matlab2021a.r7771-v1
fi

matlab -nodisplay -r "addpath('$SCRIPT_DIR'); run_smooth_TIV_func('$CONFIG_FILE', '$DATASET')"
