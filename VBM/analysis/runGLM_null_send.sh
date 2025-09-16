#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_VBM_psy_noses.txt
export isses=0
export smoothKernel=6
export maskDiag=psy

for dataset in `cat ${SUBJLIST}`
do

export dataset=$dataset
	export randomNumber=$RANDOM
		sbatch --job-name=GLM_VBM_null_${dataset} runGLM_null_batch.sh
		#sh runGLM_batch.sh
	#fi 
done


