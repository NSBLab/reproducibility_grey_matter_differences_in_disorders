#!/bin/bash

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Use environment variables passed from MATLAB
if [ -z "$HPC_ENABLED" ]; then
    echo "Error: HPC_ENABLED environment variable not set"
    echo "Please ensure the pipeline sets the HPC_ENABLED environment variable."
    exit 1
fi

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

echo "Using HPC_ENABLED from environment: $HPC_ENABLED"
echo "Using DATA_ROOT from environment: $DATA_ROOT"
echo "Using smoothKernel from environment: ${smoothKernel}mm"

# Load MATLAB modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading MATLAB modules (HPC mode enabled)..."
    module unload matlab
    module load spm12/matlab2021a.r7771-v1
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

# Run the MATLAB script
echo "Running step4b_make_mask MATLAB function..."
matlab -nodisplay -r "cd ('$SCRIPT_DIR'); step4b_make_mask('$DATA_ROOT', $smoothKernel); quit;"

# Check exit status
if [ $? -eq 0 ]; then
    echo "step4b_make_mask completed successfully"
else
    echo "Error: step4b_make_mask failed"
    exit 1
fi
