#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ
nGroupList=(2 3 4 6 10)
nResample=100

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export diag=4
export control=1

for nGroup in ${nGroupList[@]}
do
export nGroup=$nGroup

for iResample in $(seq 1 $nResample); do
export iResample=$iResample
export randomNumber=$RANDOM
	
		sbatch --job-name=GLM_${nGroup}_${iResample} make_input_run_mri_glmfit_resample_samesite.sh
#sh make_input_run_mri_glmfit_resample_samesite.sh
	#fi 
done
done


