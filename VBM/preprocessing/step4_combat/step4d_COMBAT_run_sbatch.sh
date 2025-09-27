#!/bin/bash

# STEP4D: Run COMBAT harmonization batch job
# This script runs the Python COMBAT harmonization for a specific combat group

# Check if group name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <group_name>"
    echo "Example: $0 psy"
    exit 1
fi

GROUP_NAME="$1"

# Check if environment variables are set
if [ -z "$DATA_ROOT" ] || [ -z "$SMOOTH_KERNEL" ] || [ -z "$SCRIPT_DIR" ]; then
    echo "Error: Required environment variables not set"
    echo "DATA_ROOT: $DATA_ROOT"
    echo "SMOOTH_KERNEL: $SMOOTH_KERNEL"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    exit 1
fi

echo "=== STEP4D: COMBAT HARMONIZATION BATCH JOB ==="
echo "Group: $GROUP_NAME"
echo "Data root: $DATA_ROOT"
echo "Smoothing kernel: $SMOOTH_KERNEL"
echo "Script directory: $SCRIPT_DIR"

# Set up directories
OUT_DIR="$DATA_ROOT/derivatives/s${SMOOTH_KERNEL}COMBAT"
MASK_DIR="$OUT_DIR/mask_$GROUP_NAME"

# Check if input files exist
METADATA_FILE="$DATA_ROOT/metadataVBM_${GROUP_NAME}.csv"
ANAT_FILE="$MASK_DIR/anat_s${SMOOTH_KERNEL}mwp1_T1w_masked.txt"
MASK_FILE="$MASK_DIR/mask.nii"

echo "Checking input files..."
if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: Metadata file not found: $METADATA_FILE"
    exit 1
fi
if [ ! -f "$ANAT_FILE" ]; then
    echo "Error: Anatomical data file not found: $ANAT_FILE"
    exit 1
fi
if [ ! -f "$MASK_FILE" ]; then
    echo "Error: Mask file not found: $MASK_FILE"
    exit 1
fi

echo "Input files verified for group $GROUP_NAME"

# Check if Python COMBAT script exists
PYTHON_SCRIPT="$SCRIPT_DIR/COMBAT_run.py"
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Python COMBAT script not found: $PYTHON_SCRIPT"
    exit 1
fi

# Load required modules (adjust as needed for your HPC system)
echo "Loading required modules..."
module load python/3.8
module load spm12

# Run COMBAT using Python
echo "Running COMBAT harmonization for group $GROUP_NAME..."
echo "Python script: $PYTHON_SCRIPT"
echo "Smoothing kernel: $SMOOTH_KERNEL"
echo "Group: $GROUP_NAME"

# Change to the script directory and run
cd "$SCRIPT_DIR"

# Run the Python script
python "$PYTHON_SCRIPT" "$SMOOTH_KERNEL" "$GROUP_NAME"

# Check exit status
if [ $? -eq 0 ]; then
    echo "COMBAT harmonization completed successfully for group $GROUP_NAME"
    
    # Check if output file was created
    OUTPUT_FILE="$MASK_DIR/anat_s${SMOOTH_KERNEL}mwp1_T1w_masked_combat.txt"
    if [ -f "$OUTPUT_FILE" ]; then
        echo "COMBAT output file created: $OUTPUT_FILE"
    else
        echo "Warning: COMBAT output file not found: $OUTPUT_FILE"
    fi
else
    echo "Error: COMBAT harmonization failed for group $GROUP_NAME"
    exit 1
fi

echo "=== BATCH JOB COMPLETED ==="
