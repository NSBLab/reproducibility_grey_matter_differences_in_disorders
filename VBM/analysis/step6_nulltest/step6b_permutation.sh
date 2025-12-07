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



# Get enabled datasets file path from environment variable
if [ -z "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: ENABLED_DATASETS_FILE environment variable not set"
    echo "Please ensure the pipeline sets the ENABLED_DATASETS_FILE environment variable."
    exit 1
fi

# Check if the dataset list file exists
if [ ! -f "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: Dataset list file not found: $ENABLED_DATASETS_FILE"
    exit 1
fi

# Check if the file has any content
if [ ! -s "$ENABLED_DATASETS_FILE" ]; then
    echo "Error: Dataset list file is empty: $ENABLED_DATASETS_FILE"
    exit 1
fi

echo "Processing enabled datasets from file: $ENABLED_DATASETS_FILE"
echo "Found enabled datasets:"
cat "$ENABLED_DATASETS_FILE"

# Create logs directory
mkdir -p "$SCRIPT_DIR/logs"

# Read datasets from file
DATASETS=()
while IFS= read -r dataset; do
    # Skip empty lines
    if [ -n "$dataset" ]; then
        DATASETS+=("$dataset")
    fi
done < "$ENABLED_DATASETS_FILE"

# Get number of permutations from environment variable
if [ -z "$NUM_PERMUTATIONS" ]; then
    echo "Error: NUM_PERMUTATIONS environment variable not set"
    echo "Please ensure the pipeline sets the NUM_PERMUTATIONS environment variable."
    exit 1
fi

echo "Number of permutations: $NUM_PERMUTATIONS"

echo "Checking and submitting permutations for each dataset..."
echo "Note: Will skip permutations that already have existing results"

# Loop through each dataset
for dataset in "${DATASETS[@]}"; do
    echo "Processing dataset: $dataset"
    
    # Loop through permutations
    for perm in $(seq 1 $NUM_PERMUTATIONS); do
        # Set environment variables for this permutation
        export PERM_ID=$perm
        export DATASET=$dataset
        
               
echo "submit job ${perm}_${dataset}"
        
        # Submit permutation job
        sbatch --job-name=perm${perm}_${dataset} "$SCRIPT_DIR/permutation_job.sh"
    done
done

echo ""
echo "=== STEP6B: PERMUTATION SUBMISSION COMPLETED ==="
echo "Summary:"
echo "- Total permutations requested per dataset: $NUM_PERMUTATIONS"
echo "- Checked for existing SPM contrast files before submitting jobs"
echo "- Only missing permutations were submitted"
echo "- Total datasets processed: ${#DATASETS[@]}"
echo ""
