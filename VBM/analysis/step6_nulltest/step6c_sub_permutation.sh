#!/bin/bash
#SBATCH --time=0-2:00:00
#SBATCH --job-name=permutation_VBM
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=80000

# Worker: create permuted demographics and re-run VBM GLM (step5).

CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
DATASET="${DATASET:?Set DATASET}"
PERM_ID="${PERM_ID:?Set PERM_ID}"
smoothKernel="${smoothKernel:?Set smoothKernel}"
harmonize="${harmonize:?Set harmonize}"

TARGET_DIR=$(cd "$SCRIPT_DIR/../step5_statistical_analysis" && pwd)

echo "=== PERMUTATION JOB ==="
echo "Permutation ID: $PERM_ID"
echo "Dataset:        $DATASET"
echo "CONFIG_FILE:    $CONFIG_FILE"
echo "Script dir:     $SCRIPT_DIR"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module unload matlab 2>/dev/null || true
    module load spm12/matlab2021a.r7771-v1
fi

if [ "$harmonize" -eq 1 ]; then
    PERM_OUT_DIR="$DATA_ROOT/derivatives/s${smoothKernel}COMBAT_perm${PERM_ID}"
else
    PERM_OUT_DIR="$DATA_ROOT/derivatives/s${smoothKernel}_perm${PERM_ID}"
fi
mkdir -p "$PERM_OUT_DIR"
echo "Permutation output directory: $PERM_OUT_DIR"

matlab -nodisplay -r "\
addpath('$SCRIPT_DIR'); addpath('$TARGET_DIR'); \
step6c_sub_create_permuted_metadata('$DATA_ROOT', '$DATASET', $PERM_ID, $harmonize, $smoothKernel); \
step5_sub_statistical_analysis('$CONFIG_FILE', '$DATASET', $PERM_ID); \
fprintf('Permutation %d completed for dataset %s\n', $PERM_ID, '$DATASET'); \
quit;"

if [ $? -ne 0 ]; then
    echo "Error: Permutation $PERM_ID failed for dataset $DATASET"
    exit 1
fi
echo "Permutation $PERM_ID completed successfully for dataset $DATASET"
