#!/bin/bash

SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_VBM_ses.txt
export isses=1
parcList=(100 200 300 400 500 600 700 800 900 1000)

for dataset in `cat ${SUBJLIST}`
do

export dataset=$dataset
	for nParc in ${parcList[@]}
	do
		export nParc=$nParc
		sbatch --job-name=GLM_${dataset}_${nParc} runGLM_batch.sh
		#sh runGLM_batch.sh
	done
done


