#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_VBM_psy_noses.txt  #dataset_list_VBM_psy_noses.txt or dataset_list_AD.txt or dataset_list_VBM_psy_ses.txt
export isses=0 # 1 or 0
export smoothKernel=6
export maskDiag=psy
export harmonize=1  #1 or 0

for dataset in `cat ${SUBJLIST}`
do

export dataset=$dataset
	
		sbatch --job-name=GLM_VBM_${dataset} runGLM_batch.sh
		#sh runGLM_batch.sh
	#fi 
done


