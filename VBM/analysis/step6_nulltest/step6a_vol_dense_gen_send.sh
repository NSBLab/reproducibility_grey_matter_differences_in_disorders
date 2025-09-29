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

if [ -z "$HPC_ENABLED" ]; then
    echo "Error: HPC_ENABLED environment variable not set"
    echo "Please ensure the pipeline sets the HPC_ENABLED environment variable."
    exit 1
fi

echo "Using DATA_ROOT from environment: $DATA_ROOT"
echo "Using smoothKernel from environment: ${smoothKernel}mm"
echo "Using HPC_ENABLED from environment: $HPC_ENABLED"

# Load modules conditionally
if [ "$HPC_ENABLED" = "1" ]; then
    echo "Loading required modules (HPC mode enabled)..."
    module unload matlab 
    module load spm12/matlab2021a.r7771-v1
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

groupList=(SCA) # (BD SCA SCZ MDD ASD AD) 
for diag in ${groupList[@]}; do
		export diag=$diag
		# Use DATA_ROOT from environment variable
		directory_path=$DATA_ROOT/derivatives/s${smoothKernel}COMBAT/${diag}


		# List all items in the directory
		folders=("$directory_path"/*/)  # Get list of folders
		for folder in "${folders[@]}"; do  # Start from 2nd (index 1), take 4 items (2nd to 5th)
    #[@]:1:4
    		if [ -d "$folder" ]; then  # Check if the item is a directory
				echo $folder
				export site=$(basename "${folder}")
        		echo "$site is a directory"
				for ranseed in $(seq 1 100); do
					export ranseed=${ranseed}
					#if [ ! -f "/scratch2/kg98/trangc/VBM/data/nulltest/surrogateVBM/s6COMBAT/${diag}/${site}/spmT_0001_surrogate_${ranseed}.nii.gz" ]; then 
					sbatch --job-name=vol_dense${diag}_${site}_${ranseed} vol_dense_gen_job.sh
					#sh vol_dense_gen_job.sh
					#fi
				done
    		fi
		done

		

done


