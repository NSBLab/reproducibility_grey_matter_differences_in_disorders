#!/bin/bash

# STEP4D: Submit COMBAT harmonization batch jobs
# This script submits batch jobs for COMBAT harmonization for each combat group

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "=== STEP4D: COMBAT HARMONIZATION BATCH SUBMISSION ==="

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
           --output="${SCRIPT_DIR}/combat_${group}_%j.out" \
           --error="${SCRIPT_DIR}/combat_${group}_%j.err" \
           --time=02:00:00 \
           --mem=8G \
           --cpus-per-task=4 \
           "${SCRIPT_DIR}/step4d_COMBAT_run_sbatch.sh" "$group"
    
    if [ $? -eq 0 ]; then
        echo "  Batch job submitted successfully for group: $group"
    else
        echo "  Error: Failed to submit batch job for group: $group"
    fi
done

echo "=== BATCH SUBMISSION COMPLETED ==="
