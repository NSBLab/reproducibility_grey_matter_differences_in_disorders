#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export diag=5
export control=1

nSubdivide=3
nSample=100

#groupList=(1 2)

module load  matlab/r2023b
export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec

sh ${script_DIR}/make_input_run_mri_glmfit_resample_1site_orisite.sh

#for iSubdivide in $(seq 1 $nSubdivide); do
	#export iSubdivide=$iSubdivide
	#export randomSubdivide=$RANDOM

	#matlab -nodisplay -r "addpath('$script_DIR');  				run_divide_2sitegroup_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide);quit"
	#sbatch --job-name=GLM_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh

	sampleSizeList=(20 40 60 80 100 200 300 400 500 700 1000) #(150 200 300 400 600) #40 60 100 

	for sampleSize in ${sampleSizeList[@]}
	do
		export sampleSize=$sampleSize

		for iResample in $(seq 1 $nSample); do
			export iResample=$iResample
			export randomSample=$RANDOM	
	
			matlab -nodisplay -r "addpath('$script_DIR');  				run_resample_1site_func($diag,$smoothKernel,'$hemis',$sampleSize,$iResample,$randomSample);quit"

			
	
				sbatch --job-name=GLM_1site_${sampleSize}_${iResample} make_input_run_mri_glmfit_resample_1site.sh

				#sh make_input_run_mri_glmfit_resample_2sitegroup.sh
					
		done
	done
done


