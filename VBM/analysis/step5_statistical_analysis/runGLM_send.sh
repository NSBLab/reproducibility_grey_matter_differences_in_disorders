#!/bin/bash

# Simple script to submit GLM jobs
# All parameters are passed via environment variables from run_pipeline.m
# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Check if required environment variables are set
if [ -z "$DATA_ROOT" ] || [ -z "$smoothKernel" ] || [ -z "$SCRIPT_DIR" ]; then
    echo "Error: Required environment variables not set"
    echo "DATA_ROOT: $DATA_ROOT"
    echo "smoothKernel: $smoothKernel"
    echo "SCRIPT_DIR: $SCRIPT_DIR"
    exit 1
fi

echo "=== STEP5: STATISTICAL ANALYSIS SUBMISSION ==="
echo "Smoothing kernel: $smoothKernel"
echo "Harmonization: $harmonize"
echo "Data root: $DATA_ROOT"
echo "Script directory: $SCRIPT_DIR"

# Use a simple dataset list file instead of parsing config
dataset_list_file="$DATA_ROOT/dataset_list_VBM.txt"

if [ ! -f "$dataset_list_file" ]; then
    echo "Error: Dataset list file not found: $dataset_list_file"
    exit 1
fi

echo "Using dataset list file: $dataset_list_file"

# Read datasets from file
while IFS= read -r dataset; do
    # Skip empty lines
    if [ -z "$dataset" ]; then
        continue
    fi
    
    # For now, use default values (these should be set by MATLAB)
    export dataset=$dataset
    export isses=$isses
    export maskDiag=$maskDiag
    
    echo "Submitting job for dataset: $dataset (sessions: $isses, group: $maskDiag)"
    sbatch --job-name=GLM_VBM_${dataset} "$SCRIPT_DIR/runGLM_batch.sh"
	#sh $SCRIPT_DIR/runGLM_batch.sh
done < "$dataset_list_file"

echo "All jobs submitted successfully"
