#!/bin/bash

datadir=/projects/kg98/trangc/VBM/data
DATASET_LIST=$datadir/dataset_list_SBM.txt # $datadir/dataset_list_SBM_psy_2var.txt


export datadir=$datadir

export smoothKernel=0
export measure=thickness
export measureShort=thick
export hemis=rh
export control=1
export covariance1=sex
export covariance2=age
export harmonize=1 # 1 or 0, combat or not


for DATASET in `cat ${DATASET_LIST}`
do

	
			export DATASET=${DATASET}
			echo ${DATASET}
			
			sbatch --job-name=GLM_SBM_${DATASET} make_input_run_mri_glmfit.sh

done


