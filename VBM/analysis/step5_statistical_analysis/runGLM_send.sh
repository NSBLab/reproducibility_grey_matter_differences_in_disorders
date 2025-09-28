#!/bin/bash

# Load configuration
if [ -z "$CONFIG_FILE" ]; then
    echo "Error: CONFIG_FILE environment variable not set"
    echo "Please ensure the pipeline sets the CONFIG_FILE environment variable."
    exit 1
fi

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

# Get enabled datasets from config
echo "=== STEP5: STATISTICAL ANALYSIS SUBMISSION ==="
echo "Smoothing kernel: $smoothKernel"
echo "Harmonization: $harmonize"
echo "Data root: $DATA_ROOT"
echo "Script directory: $SCRIPT_DIR"

# Get enabled datasets from config
enabled_datasets=$(grep -o '"enabled"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" -B 5 | grep -o '"[^"]*"[[:space:]]*:[[:space:]]*{' | cut -d'"' -f2)

if [ -z "$enabled_datasets" ]; then
    echo "Error: No enabled datasets found in config file '$CONFIG_FILE'"
    echo "Please ensure at least one dataset has 'enabled': true in the config file."
    exit 1
fi

echo "Using enabled datasets from config:"
echo "$enabled_datasets"
datasets_to_process="$enabled_datasets"

for dataset in $datasets_to_process
do
    # Get dataset-specific settings from config
    dataset_isses=0
    
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
    sbatch --job-name=GLM_VBM_${dataset} runGLM_batch.sh
done

echo "All jobs submitted successfully"


