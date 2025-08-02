#!/bin/bash


directory_path=/projects/kg98/trangc/VBM/data
export smoothkernel="10"
echo ${smoothkernel}
hemi=lh
dataset_list=${directory_path}/dataset_list_SBM.txt
# List all items in the directory
for dataset in $(cat $dataset_list); do
    
		echo $dataset
		export dataset=$dataset
		for folder in "${directory_path}/${dataset}/derivatives/freesurfer/qdec"/*; do
			if [[ -d "$folder" && "$folder" == *thick_smooth${smoothkernel}_${hemi}_sex_age_combat ]]; then
				export qdec=$(basename "${folder}")
	
        		echo $qdec
				#sbatch --job-name=thickness_dense${diag}${site} thickness_dense_gen_job.sh
				sh thickness_dense_gen_job.sh
    		fi
		done

		

done


