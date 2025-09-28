#!/bin/bash

# STEP4D: Submit COMBAT harmonization batch jobs
# This script submits batch jobs for COMBAT harmonization for each combat group

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Check if environment variables are set
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set"
    exit 1
fi

if [ -z "$smoothKernel" ]; then
    echo "Error: smoothKernel environment variable not set"
    exit 1
fi

# Export environment variables for batch jobs
export DATA_ROOT
export smoothKernel
export SCRIPT_DIR
export conda_env

echo "=== STEP4D: COMBAT HARMONIZATION BATCH SUBMISSION ==="
echo "Data root: $DATA_ROOT"
echo "Smoothing kernel: $smoothKernel"

# Get combat groups from metadata files
COMBAT_GROUPS=()
if [ -f "$DATA_ROOT/metadataVBM_psy.csv" ]; then
    COMBAT_GROUPS+=("psy")
fi
if [ -f "$DATA_ROOT/metadataVBM_AD.csv" ]; then
    COMBAT_GROUPS+=("AD")
fi

if [ ${#COMBAT_GROUPS[@]} -eq 0 ]; then
    echo "Error: No combat group metadata files found"
    exit 1
fi

echo "Found combat groups: ${COMBAT_GROUPS[*]}"

# Submit batch job for each combat group
for group in "${COMBAT_GROUPS[@]}"; do
    echo "Submitting batch job for combat group: $group"
    
    # Submit the batch job
    sbatch --job-name="combat_${group}" \
           "${SCRIPT_DIR}/COMBAT_run_sbatch.sh" "$group"
    
    if [ $? -eq 0 ]; then
        echo "  Batch job submitted successfully for group: $group"
    else
        echo "  Error: Failed to submit batch job for group: $group"
    fi
done

echo "=== BATCH SUBMISSION COMPLETED ==="

