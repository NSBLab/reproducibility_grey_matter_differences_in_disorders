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

# Set parameters for permutation null testing
export nResample=100
export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=rh
export control=1
export covariance1=sex
export covariance2=age
export harmonize=1 # 1 or 0, combat or not

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
