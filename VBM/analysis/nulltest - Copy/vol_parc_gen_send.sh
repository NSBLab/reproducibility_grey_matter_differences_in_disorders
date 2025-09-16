#!/bin/bash

groupList=(BD SCA SCZ MDD ASD AD) 
parcList=(100 200 300 400 500 600 700 800 900 1000)
for diag in ${groupList[@]}; do
		export diag=$diag
		# Specify the directory path (replace with your actual path)
		directory_path=/projects/kg98/trangc/VBM/data/derivatives/roi/${diag}


# List all items in the directory
folders=("$directory_path"/*/)  # Get list of folders
for folder in "${folders[@]}"; do  # Start from 2nd (index 1), take 4 items (2nd to 5th)
    #[@]:4
    if [ -d "$folder" ]; then  # Check if the item is a directory
		echo $folder
		export dataset=$(basename "${folder}")
        echo "$dataset is a directory"
		for nParc in ${parcList[@]}; do
			export nParc=${nParc}
			#sbatch --job-name=vol_dense${diag}_${dataset}_${nParc} vol_parc_gen_job.sh
			sh vol_parc_gen_job.sh
		done
    fi
done

		

done


