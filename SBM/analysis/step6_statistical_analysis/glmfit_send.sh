#!/bin/bash

# Read the configuration file to get data directories and enabled datasets
# Use CONFIG_FILE environment variable passed from MATLAB
if [ -z "$CONFIG_FILE" ]; then
    echo "Error: CONFIG_FILE environment variable not set"
    echo "Please ensure the pipeline sets the CONFIG_FILE environment variable."
    exit 1
fi
echo "Using config file passed from MATLAB: $CONFIG_FILE"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Extract data root and enabled datasets from config file using jq (JSON processor)
# If jq is not available, we'll use a simple grep approach
if command -v jq &> /dev/null; then
    echo "Using jq to parse JSON config..."
    datadir=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    HPC_ENABLED=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
    
    # Extract enabled datasets directly from config file
    ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
else
    echo "jq not available, using grep to parse JSON config..."
    # Extract data root using grep and sed
    datadir=$(grep '"dataset_root"' "$CONFIG_FILE" | sed 's/.*"dataset_root": *"\([^\"]*\)".*/\1/')
    HPC_ENABLED=$(grep '"hpc_enabled"' "$CONFIG_FILE" | sed 's/.*"hpc_enabled": *\([^,}]*\).*/\1/' | tr -d ' "')
    
    # Extract enabled datasets using grep and awk
    ENABLED_DATASETS=$(grep -A 10 '"datasets"' "$CONFIG_FILE" | grep -B 5 '"enabled": *true' | grep '^[[:space:]]*"[^"]*": *{' | sed 's/.*"\([^"]*\)": *{.*/\1/')
fi

# Check if we got the data root
if [ -z "$datadir" ]; then
    echo "Error: Could not extract data root from configuration!"
    exit 1
fi

# Check if we found any enabled datasets
if [ -z "$ENABLED_DATASETS" ]; then
    echo "Error: No enabled datasets found in configuration!"
    exit 1
fi

echo "Data root: $datadir"
echo "HPC enabled: $HPC_ENABLED"
echo "Found enabled datasets:"
echo "$ENABLED_DATASETS"

export datadir=$datadir

export smoothKernel=0
export measure=thickness
export measureShort=thick
export hemis=rh
export control=1
export covariance1=sex
export covariance2=age
export harmonize=1 # 1 or 0, combat or not

# Load visualization modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading FreeSurfer modules (HPC mode enabled)..."
    module load freesurfer/7.1.0
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

# Process each enabled dataset
for DATASET in $ENABLED_DATASETS; do
	export DATASET=${DATASET}
	echo "Processing dataset: ${DATASET}"
	
	# Check if dataset directory exists
	DATASET_DIR="$datadir/$DATASET"
	if [ ! -d "$DATASET_DIR" ]; then
		echo "Warning: Dataset directory $DATASET_DIR not found, skipping..."
		continue
	fi
	
	# Check if dataset has SBM derivatives
	SBM_DERIVATIVES="$DATASET_DIR/derivatives/freesurfer"
	if [ ! -d "$SBM_DERIVATIVES" ]; then
		echo "Warning: SBM derivatives directory $SBM_DERIVATIVES not found, skipping dataset $DATASET"
		echo "Please run SBM preprocessing first."
		continue
	fi
	
	# Run the statistical analysis for this dataset
	if [ "$HPC_ENABLED" = "true" ]; then
		echo "Submitting SLURM job for dataset: ${DATASET}"
		sbatch --job-name=GLM_SBM_${DATASET} make_input_run_mri_glmfit.sh
	else
		echo "Running locally for dataset: ${DATASET}"
		bash make_input_run_mri_glmfit.sh
	fi
done


