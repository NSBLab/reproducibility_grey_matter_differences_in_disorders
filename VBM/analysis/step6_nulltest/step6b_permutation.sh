#!/bin/bash

# Get script directory (same directory as this script file)
export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Use environment variables passed from MATLAB
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set"
    echo "Please ensure the pipeline sets the DATA_ROOT environment variable."
    exit 1
fi

if [ -z "$smoothKernel" ]; then
    echo "Error: smoothKernel environment variable not set"
    echo "Please ensure the pipeline sets the smoothKernel environment variable."
    exit 1
fi

if [ -z "$HPC_ENABLED" ]; then
    echo "Error: HPC_ENABLED environment variable not set"
    echo "Please ensure the pipeline sets the HPC_ENABLED environment variable."
    exit 1
fi

if [ -z "$harmonize" ]; then
    echo "Error: harmonize environment variable not set"
    echo "Please ensure the pipeline sets the harmonize environment variable."
    exit 1
fi

if [ -z "$maskDiag" ]; then
    echo "Error: maskDiag environment variable not set"
    echo "Please ensure the pipeline sets the maskDiag environment variable."
    exit 1
fi

if [ -z "$isses" ]; then
    echo "Error: isses environment variable not set"
    echo "Please ensure the pipeline sets the isses environment variable."
    exit 1
fi

echo "=== STEP6B: PERMUTATION ANALYSIS ==="
echo "Using DATA_ROOT from environment: $DATA_ROOT"
echo "Using smoothKernel from environment: ${smoothKernel}mm"
echo "Using HPC_ENABLED from environment: $HPC_ENABLED"
echo "Using harmonize from environment: $harmonize"
echo "Using maskDiag from environment: $maskDiag"
echo "Using isses from environment: $isses"



# Get enabled datasets from environment
if [ -z "$ENABLED_DATASETS" ]; then
    echo "Error: ENABLED_DATASETS environment variable not set"
    echo "Please ensure the pipeline sets the ENABLED_DATASETS environment variable."
    exit 1
fi

echo "Processing enabled datasets: $ENABLED_DATASETS"

# Create logs directory
mkdir -p "$SCRIPT_DIR/logs"

# Parse enabled datasets (comma-separated)
IFS=',' read -ra DATASETS <<< "$ENABLED_DATASETS"

# Number of permutations
NUM_PERMUTATIONS=2

echo "Submitting $NUM_PERMUTATIONS permutations for each dataset..."

# Loop through each dataset
for dataset in "${DATASETS[@]}"; do
    echo "Processing dataset: $dataset"
    
    # Loop through permutations
    for perm in $(seq 1 $NUM_PERMUTATIONS); do
        echo "  Submitting permutation $perm for dataset $dataset"
        
        # Set environment variables for this permutation
        export PERM_ID=$perm
        export DATASET=$dataset
        
        # Submit permutation job
        sbatch --job-name=perm${perm}_${dataset} "$SCRIPT_DIR/permutation_job.sh"
    done
done

echo "=== STEP6B: PERMUTATION SUBMISSION COMPLETED ==="
echo "Submitted $NUM_PERMUTATIONS permutations for each of ${#DATASETS[@]} datasets"
echo "Total jobs submitted: $(($NUM_PERMUTATIONS * ${#DATASETS[@]}))"
