#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ
sampleSizeList=(350) #(20 40 60 100 150 200 300 350)
nResample=200

export smoothKernel=8


for sampleSize in ${sampleSizeList[@]}
do
export sampleSize=$sampleSize

for iResample in $(seq 1 $nResample); do
export iResample=$iResample
export randomNumber=$RANDOM
	
		sbatch --job-name=GLM_${sampleSize}_${iResample} runGLMresample_batch.sh
	#fi 
done
done


