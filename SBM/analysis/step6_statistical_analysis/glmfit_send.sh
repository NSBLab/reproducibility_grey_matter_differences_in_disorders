#!/bin/bash

# Use environment variables passed from MATLAB pipeline
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set"
    echo "Please ensure the pipeline sets the DATA_ROOT environment variable."
    exit 1
fi

if [ -z "$HPC_ENABLED" ]; then
    echo "Error: HPC_ENABLED environment variable not set"
    echo "Please ensure the pipeline sets the HPC_ENABLED environment variable."
    exit 1
fi

if [ -z "$DATASET_LIST" ]; then
    echo "Error: DATASET_LIST environment variable not set"
    echo "Please ensure the pipeline sets the DATASET_LIST environment variable."
    exit 1
fi

# Check if dataset list file exists
if [ ! -f "$DATASET_LIST" ]; then
    echo "Error: Dataset list file $DATASET_LIST not found!"
    exit 1
fi

# Read enabled datasets from the dataset list file
ENABLED_DATASETS=$(cat "$DATASET_LIST")

echo "Data root: $DATA_ROOT"
echo "HPC enabled: $HPC_ENABLED"
echo "Dataset list file: $DATASET_LIST"
echo "Found enabled datasets:"
echo "$ENABLED_DATASETS"

export datadir=$DATA_ROOT

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


