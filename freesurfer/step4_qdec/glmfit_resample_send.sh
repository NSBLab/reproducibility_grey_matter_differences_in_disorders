#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ
sampleSizeList=(20) #(40 60 100 150 200 300 400 600)
nResample=100

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export diag=4
export control=1

for sampleSize in ${sampleSizeList[@]}
do
export sampleSize=$sampleSize

for iResample in $(seq 1 $nResample); do
export iResample=$iResample
export randomNumber=$RANDOM
	
		sbatch --job-name=GLM_${sampleSize}_${iResample} make_input_run_mri_glmfit_resample.sh
	#fi 
done
done


