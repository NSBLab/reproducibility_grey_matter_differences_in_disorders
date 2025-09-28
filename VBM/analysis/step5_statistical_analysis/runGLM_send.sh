#!/bin/bash

# Load configuration
if [ -f "../../config.json" ]; then
    echo "Loading configuration from config.json"
    # Extract values from config.json (basic extraction)
    DATA_ROOT=$(grep -o '"dataset_root"[[:space:]]*:[[:space:]]*"[^"]*"' ../../config.json | cut -d'"' -f4)
    SCRIPT_DIR=$(pwd)
else
    echo "Using default configuration"
    DATA_ROOT="/home/trangc/kg98/trangc/VBM/data"
    SCRIPT_DIR="/home/trangc/kg98/trangc/VBM/code/voxelwise"
fi

# Set default parameters
export isses=0 # 1 or 0
export smoothKernel=6
export maskDiag=psy
export harmonize=1  #1 or 0

# Export environment variables
export DATA_ROOT
export SCRIPT_DIR

# Check if required environment variables are set
if [ -z "$DATA_ROOT" ] || [ -z "$smoothKernel" ] || [ -z "$SCRIPT_DIR" ]; then
    echo "Error: Required environment variables not set"
    echo "DATA_ROOT: $DATA_ROOT"
    echo "smoothKernel: $smoothKernel"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    exit 1
fi

# Dataset list file
SUBJLIST="$DATA_ROOT/dataset_list_VBM_psy_noses.txt"  #dataset_list_VBM_psy_noses.txt or dataset_list_AD.txt or dataset_list_VBM_psy_ses.txt

if [ ! -f "$SUBJLIST" ]; then
    echo "Error: Dataset list file not found: $SUBJLIST"
    exit 1
fi

echo "=== STEP5: STATISTICAL ANALYSIS SUBMISSION ==="
echo "Dataset list: $SUBJLIST"
echo "Sessions: $isses"
echo "Smoothing kernel: $smoothKernel"
echo "Mask diagnostic group: $maskDiag"
echo "Harmonization: $harmonize"
echo "Data root: $DATA_ROOT"
echo "Script directory: $SCRIPT_DIR"

for dataset in `cat ${SUBJLIST}`
do
    export dataset=$dataset
    echo "Submitting job for dataset: $dataset"
    sbatch --job-name=GLM_VBM_${dataset} runGLM_batch.sh
done

echo "All jobs submitted successfully"


