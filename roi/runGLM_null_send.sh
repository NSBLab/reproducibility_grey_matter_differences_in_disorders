#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_AD1.txt
export isses=1
#export smoothKernel=8
parcList=(100 200 300 400 500 600 700 800 900 1000)

for dataset in `cat ${SUBJLIST}`
do

	export dataset=$dataset
	export randomNumber=$RANDOM
	for nParc in ${parcList[@]}
	do
		export nParc=$nParc
		sbatch --job-name=GLM_${dataset} runGLM_null_batch.sh
		#sh runGLM_null_batch.sh
	#fi 
	done
done


