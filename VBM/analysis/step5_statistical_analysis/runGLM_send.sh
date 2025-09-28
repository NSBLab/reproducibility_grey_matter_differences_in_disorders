#!/bin/bash

# Load configuration
CONFIG_FILE="${CONFIG_FILE:-../../config.json}"

if [ -f "$CONFIG_FILE" ]; then
    echo "Loading configuration from $CONFIG_FILE"
    # Extract values from config file (basic extraction)
    DATA_ROOT=$(grep -o '"dataset_root"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    SCRIPT_DIR=$(pwd)
    
    # Extract analysis settings
    smoothKernel=$(grep -o '"smoothing_kernel"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_FILE" | cut -d':' -f2 | tr -d ' ')
    harmonize=$(grep -o '"harmonize"[[:space:]]*:[[:space:]]*[01]' "$CONFIG_FILE" | cut -d':' -f2 | tr -d ' ')
    
else
    echo "Error: Configuration file not found: $CONFIG_FILE"
    echo "Please ensure the config file exists or set CONFIG_FILE environment variable."
    exit 1
fi

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd) 

# Export global values
export smoothKernel
export harmonize
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

# Get enabled datasets from config, fallback to dataset list file
echo "=== STEP5: STATISTICAL ANALYSIS SUBMISSION ==="
echo "Smoothing kernel: $smoothKernel"
echo "Harmonization: $harmonize"
echo "Data root: $DATA_ROOT"
echo "Script directory: $SCRIPT_DIR"

# Try to get enabled datasets from config first
enabled_datasets=$(grep -o '"enabled"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" -B 5 | grep -o '"[^"]*"[[:space:]]*:[[:space:]]*{' | cut -d'"' -f2)

if [ -n "$enabled_datasets" ]; then
    echo "Using enabled datasets from config:"
    echo "$enabled_datasets"
    datasets_to_process="$enabled_datasets"
else
    # Fallback to dataset list file
    SUBJLIST="$DATA_ROOT/dataset_list_VBM.txt"
    if [ ! -f "$SUBJLIST" ]; then
        echo "Error: No enabled datasets found in config and dataset list file not found: $SUBJLIST"
        exit 1
    fi
    echo "Using dataset list file: $SUBJLIST"
    datasets_to_process=$(cat "$SUBJLIST")
fi

for dataset in $datasets_to_process
do
    # Get dataset-specific settings from config
    dataset_isses=0
    dataset_maskDiag="psy"
    
    # Check if this dataset is longitudinal
    if grep -A 10 "\"$dataset\"" "$CONFIG_FILE" | grep -q '"longitudinal"[[:space:]]*:[[:space:]]*true'; then
        dataset_isses=1
    fi
    
    # Get combat group for this dataset
    dataset_combat_group=$(grep -A 10 "\"$dataset\"" "$CONFIG_FILE" | grep -o '"combat_group"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
    if [ -z "$dataset_combat_group" ]; then
        echo "Error: combat_group not found for dataset '$dataset' in config file '$CONFIG_FILE'"
        exit 1
    fi
    
    # Set mask diagnostic group based on combat group
    dataset_maskDiag="$dataset_combat_group"
    
    # Export dataset-specific variables
    export dataset=$dataset
    export isses=$dataset_isses
    export maskDiag=$dataset_maskDiag
    
    echo "Submitting job for dataset: $dataset (sessions: $dataset_isses, group: $dataset_combat_group)"
    sbatch --job-name=GLM_VBM_${dataset} "$SCRIPT_DIR/runGLM_batch.sh"
done

echo "All jobs submitted successfully"


