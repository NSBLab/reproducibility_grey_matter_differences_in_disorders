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

if [ -z "$smoothKernel" ]; then
    echo "Error: smoothKernel environment variable not set"
    echo "Please ensure the pipeline sets the smoothKernel environment variable."
    exit 1
fi

if [ -z "$harmonize" ]; then
    echo "Error: harmonize environment variable not set"
    echo "Please ensure the pipeline sets the harmonize environment variable."
    exit 1
fi

if [ -z "$combat_group" ]; then
    echo "Error: combat_group environment variable not set"
    echo "Please ensure the pipeline sets the combat_group environment variable."
    exit 1
fi

if [ -z "$NUM_PERMUTATIONS" ]; then
    echo "Error: NUM_PERMUTATIONS environment variable not set"
    echo "Please ensure the pipeline sets the NUM_PERMUTATIONS environment variable."
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
echo "Smoothing kernel: $smoothKernel"
echo "Harmonization: $harmonize"
echo "Combat group: $combat_group"
echo "Number of permutations: $NUM_PERMUTATIONS"
echo "Dataset list file: $DATASET_LIST"
echo "Found enabled datasets:"
echo "$ENABLED_DATASETS"

export datadir=$DATA_ROOT

# Set parameters for permutation null testing (some from environment, some fixed)
export nResample=100
export measure=thickness
export measureShort=thick
export hemis=rh
export control=1
export covariance1=sex
export covariance2=age

# Load modules conditionally
if [ "$HPC_ENABLED" = "true" ]; then
    echo "Loading FreeSurfer modules (HPC mode enabled)..."
    module load freesurfer/7.1.0
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

# Process each enabled dataset
for DATASET in $ENABLED_DATASETS; do
	export DATASET=${DATASET}
	echo "Processing permutation null test for dataset: ${DATASET}"
	
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
	
	# Check if statistical analysis results exist
	STAT_RESULTS="$SBM_DERIVATIVES/qdec"
	if [ ! -d "$STAT_RESULTS" ]; then
		echo "Warning: Statistical analysis results not found at $STAT_RESULTS, skipping dataset $DATASET"
		echo "Please run SBM statistical analysis first."
		continue
	fi
	
	# Get list of sites from qdec results
	ls $STAT_RESULTS/1_*_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat > $DATASET_DIR/sitelist_permutation.txt
	
	# Process each site for permutation null testing
	for sitefile in `cat $DATASET_DIR/sitelist_permutation.txt`
	do
		echo "Processing site: $sitefile"
		sitefield=$(echo "$sitefile" | grep -o -P '(?<=1_).*(?=_thick_smooth)')
		echo "Site field: $sitefield"
		site=${sitefield:0:${#sitefield}-2}
		echo "Site: $site"
		diag=${sitefile:${#sitefile}-5:1}
		echo "Diagnosis: $diag"
		
		# Create permutation directory
		perm_dir="$DATASET_DIR/derivatives/freesurfer/permutation_nulltest"
		if [ ! -d "$perm_dir" ]; then 
			mkdir -p "$perm_dir"
			echo "Created permutation directory: $perm_dir"
		fi
		
		site_perm_dir="$perm_dir/${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat"
		if [ ! -d "$site_perm_dir" ]; then 
			mkdir -p "$site_perm_dir"
			echo "Created site permutation directory: $site_perm_dir"
		fi
		
		# Run permutation jobs for this site
		for ranseed in $(seq 1 $nResample); do
			export ranseed=${ranseed}
			export diag=${diag}
			export site=${site}
			
			# Check if permutation result already exists
			perm_result="$site_perm_dir/surrogate_${ranseed}.mgh"
			if [ -f "$perm_result" ]; then
				echo "Permutation result already exists for seed $ranseed, skipping..."
				continue
			fi
			
			# Submit permutation job
			if [ "$HPC_ENABLED" = "true" ]; then
				echo "Submitting SLURM job for permutation seed $ranseed (${diag}_${site})"
				sbatch --job-name=perm_SBM_${DATASET}_${diag}_${site}_${ranseed} nulltest_permutation_job.sh
			else
				echo "Running permutation locally for seed $ranseed (${diag}_${site})"
				bash nulltest_permutation_job.sh
			fi
		done
	done
done

echo "Permutation null testing submission completed!"
