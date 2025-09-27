#!/bin/bash

# Read the configuration file to get enabled datasets and settings
# Use CONFIG_FILE environment variable if passed from MATLAB, otherwise use default
if [ -z "$CONFIG_FILE" ]; then
    export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
    CONFIG_FILE="$SCRIPT_DIR/../../../config_hpc.json"
    echo "Using default config file: $CONFIG_FILE"
else
    echo "Using config file passed from MATLAB: $CONFIG_FILE"
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Extract data root from config file using jq (JSON processor)
# If jq is not available, we'll use a simple grep approach
if command -v jq &> /dev/null; then
    echo "Using jq to parse JSON config..."
    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    SMOOTHING_KERNEL=$(jq -r '.analysis_settings.smoothing_kernel' "$CONFIG_FILE")
else
    echo "jq not available, using grep to parse JSON config..."
    # Extract data root using grep and sed
    DATA_ROOT=$(grep '"dataset_root"' "$CONFIG_FILE" | sed 's/.*"dataset_root": *"\([^\"]*\)".*/\1/')
    SMOOTHING_KERNEL=$(grep '"smoothing_kernel"' "$CONFIG_FILE" | sed 's/.*"smoothing_kernel": *\([0-9]*\).*/\1/')
fi

# Check if we got the data root
if [ -z "$DATA_ROOT" ]; then
    echo "Error: Could not extract data root from configuration!"
    exit 1
fi

# Set smoothing kernel from config or use default
if [ -z "$SMOOTHING_KERNEL" ]; then
    export smoothKernel=6
    echo "Using default smoothing kernel: 6mm"
else
    export smoothKernel=$SMOOTHING_KERNEL
    echo "Using smoothing kernel from config: ${smoothKernel}mm"
fi

# Get session flag from environment variable or use default
if [ -z "$isses" ]; then
    export isses=0
    echo "Sessions disabled (default)"
else
	export isses=$isses
    echo "Sessions enabled: $isses"
fi

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
