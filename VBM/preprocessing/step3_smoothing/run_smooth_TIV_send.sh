#!/bin/bash

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

echo "Using DATA_ROOT from environment: $DATA_ROOT"
echo "Using smoothKernel from environment: ${smoothKernel}mm"

# Get session flag from environment variable
if [ -z "$isses" ]; then
    echo "Error: isses environment variable not set"
    exit 1
fi
export isses=$isses
echo "Sessions setting: $isses"

# Create dataset list file path
SUBJLIST="${DATA_ROOT}/dataset_list_VBM.txt"

# Check if dataset list exists
if [ ! -f "$SUBJLIST" ]; then
    echo "Error: Dataset list not found at $SUBJLIST"
    echo "Please run step1a first to create the dataset list."
    exit 1
fi

echo "Data root: $DATA_ROOT"
echo "Running smoothing for datasets in: $SUBJLIST"
echo "Smoothing kernel: $smoothKernel"
echo "Sessions enabled: $isses"

# Export DATA_ROOT so batch jobs can see it
export DATA_ROOT

for dataset in `cat ${SUBJLIST}`
do
    export dataset=$dataset
    echo "Submitting smoothing job for dataset: $dataset"
	echo $SCRIPT_DIR
	export SCRIPT_DIR=$SCRIPT_DIR
    sbatch --job-name=smooth_${dataset} $SCRIPT_DIR/run_smooth_TIV_batch.sh
	#sh $SCRIPT_DIR/run_smooth_TIV_batch.sh
done

echo "All smoothing jobs submitted successfully."
