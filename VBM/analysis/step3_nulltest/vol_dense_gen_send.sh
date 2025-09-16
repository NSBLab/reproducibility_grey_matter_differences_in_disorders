#!/bin/bash

groupList=(SCA) # (BD SCA SCZ MDD ASD AD) 
smoothkernel=6
for diag in ${groupList[@]}; do
		export diag=$diag
		# Specify the directory path (replace with your actual path)
		directory_path=/projects/kg98/trangc/VBM/data/derivatives/s${smoothkernel}COMBAT/${diag}


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


