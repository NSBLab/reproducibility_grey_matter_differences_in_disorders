#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=GLM_parc
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000

# Worker: ROI GLM for one dataset x nParc (submitted by step7d_runGLM_parc_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATASET="${DATASET:?Set DATASET}"
nParc="${nParc:?Set nParc}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module unload matlab 2>/dev/null || true
    module load spm12/matlab2021a.r7771-v1
fi

echo "=== ROI GLM: $DATASET nParc=$nParc ==="
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); runGLM_parc_func('$CONFIG_FILE', '$DATASET', $nParc); quit;"

if [ $? -ne 0 ]; then
    echo "Error: runGLM_parc_func failed for $DATASET nParc=$nParc"
    exit 1
fi
echo "=== ROI GLM DONE: $DATASET nParc=$nParc ==="
