#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_VBM_psy_ses.txt
export isses=1

for dataset in `cat ${SUBJLIST}`
do

export dataset=$dataset
	
		#sbatch --job-name=parc_${dataset} parcellate_maps.sh
		sh parcellate_maps.sh
	#fi 
done


