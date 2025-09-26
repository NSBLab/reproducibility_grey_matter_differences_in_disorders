#!/bin/bash

# Get DATA_ROOT from environment variable (set by pipeline)
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set. Please run from pipeline."
    exit 1
fi

# Get smoothing kernel from environment variable or use default
if [ -z "$smoothKernel" ]; then
    export smoothKernel=6
fi

# Get session flag from environment variable or use default
if [ -z "$isses" ]; then
    export isses=0
fi

# Create dataset list file path
SUBJLIST="${DATA_ROOT}/dataset_list_VBM.txt"

# Check if dataset list exists
if [ ! -f "$SUBJLIST" ]; then
    echo "Error: Dataset list not found at $SUBJLIST"
    echo "Please run step1a first to create the dataset list."
    exit 1
fi

echo "Running smoothing for datasets in: $SUBJLIST"
echo "Smoothing kernel: $smoothKernel"
echo "Sessions enabled: $isses"

for dataset in `cat ${SUBJLIST}`
do
    export dataset=$dataset
    echo "Submitting smoothing job for dataset: $dataset"
    sbatch --job-name=smooth_${dataset} $SCRIPT_DIR/run_smooth_TIV_batch.sh
done

echo "All smoothing jobs submitted successfully."


