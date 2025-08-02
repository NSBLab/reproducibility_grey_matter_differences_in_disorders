#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_AD.txt
export isses=1
export smoothKernel=6

for dataset in `cat ${SUBJLIST}`
do

export dataset=$dataset
	
		sbatch --job-name=smooth_${dataset} run_smooth_TIV_batch.sh
		#sh runGLM_batch.sh
	#fi 
done


