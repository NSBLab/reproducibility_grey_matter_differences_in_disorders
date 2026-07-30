#!/bin/bash
#SBATCH --time=2-12:00:00
#SBATCH --job-name=parcellate
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000

# Worker: parcellate maps for one dataset (submitted by step7c_parcellate_maps_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATASET="${DATASET:?Set DATASET}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module unload matlab 2>/dev/null || true
    module load spm12/matlab2021a.r7771-v1
fi

echo "=== PARCELLATE MAPS: $DATASET ==="
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); parcellate_maps('$CONFIG_FILE', '$DATASET'); quit;"

if [ $? -ne 0 ]; then
    echo "Error: parcellate_maps failed for $DATASET"
    exit 1
fi
echo "=== PARCELLATE MAPS DONE: $DATASET ==="
