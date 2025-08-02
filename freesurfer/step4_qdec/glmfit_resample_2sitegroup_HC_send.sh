#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export diag=8
export control=1

nSubdivide=100
nSample=100

groupList=(1 2)

module load  matlab/r2023b
export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec



for iSubdivide in $(seq 1 $nSubdivide); do
	export iSubdivide=$iSubdivide
	export randomSubdivide=$RANDOM

	matlab -nodisplay -r "addpath('$script_DIR');  				run_divide_2sitegroup_HC_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide);quit"
	#sh ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh
	sbatch --job-name=GLM_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh

	 
done


