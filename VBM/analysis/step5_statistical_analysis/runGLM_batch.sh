#!/bin/bash
#SBATCH --time=0-2:00:00
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=80000

# Worker: runs VBM GLM for one dataset (submitted by runGLM_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATASET="${DATASET:?Set DATASET}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module unload matlab
    module load spm12/matlab2021a.r7771-v1
fi

echo "=== GLM: $DATASET ==="
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); step5_sub_statistical_analysis('$CONFIG_FILE', '$DATASET'); quit;"

if [ $? -ne 0 ]; then
    echo "Error: GLM failed for $DATASET"
    exit 1
fi
echo "=== GLM DONE: $DATASET ==="
