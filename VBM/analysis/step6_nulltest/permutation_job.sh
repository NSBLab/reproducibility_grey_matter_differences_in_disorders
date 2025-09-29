#!/bin/bash
#SBATCH --job-name=permutation_job
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "=== PERMUTATION JOB ==="
echo "Permutation ID: $PERM_ID"
echo "Dataset: $DATASET"
echo "Script directory: $SCRIPT_DIR"

# Load modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading required modules (HPC mode enabled)..."
    module unload matlab 
    module load spm12/matlab2021a.r7771-v1
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

# Create permutation output directory
PERM_OUT_DIR="$DATA_ROOT/derivatives/s${smoothKernel}COMBAT_perm${PERM_ID}"
mkdir -p "$PERM_OUT_DIR"

echo "Permutation output directory: $PERM_OUT_DIR"

# Run MATLAB script to create permuted metadata and run statistical analysis
matlab -nodisplay -r "
    addpath('$SCRIPT_DIR');
    addpath('$DATA_ROOT/../VBM/analysis/step5_statistical_analysis');
    
    % Create permuted metadata for this dataset
    permuted_metadata_file = create_permuted_metadata('$DATA_ROOT', '$DATASET', $PERM_ID, $harmonize, $smoothKernel);
    
    % Run statistical analysis with permuted labels
    step5a_statistical_analysis('$DATA_ROOT', '$DATASET', $isses, $smoothKernel, '$maskDiag', $harmonize, $PERM_ID);
    
    fprintf('Permutation %d completed for dataset %s\n', $PERM_ID, '$DATASET');
    quit;
"

# Check exit status
if [ $? -eq 0 ]; then
    echo "Permutation $PERM_ID completed successfully for dataset $DATASET"
else
    echo "Error: Permutation $PERM_ID failed for dataset $DATASET"
    exit 1
fi
