#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ

export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
diagList=(6)
export control=1

nSubdivide=1
nSample=100

groupList=(1 2)

module load  matlab/r2023b
export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec
export dividemode=nosplitsite

for diag in ${diagList[@]}
do
	export diag=$diag

	for iSubdivide in $(seq 1 $nSubdivide); do
		export iSubdivide=$iSubdivide
		export randomSubdivide=$RANDOM

		matlab -nodisplay -r "addpath('$script_DIR');  				run_divide_2sitegroup_nosplitsite_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide);quit"
		#sh ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh
		sbatch --job-name=GLM_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh

		sampleSizeList=(20 40 60 80 100 200 300) # 400 500 600 700 800) #40 60 100 

		for sampleSize in ${sampleSizeList[@]}
		do
			export sampleSize=$sampleSize

			for iResample in $(seq 1 $nSample); do
				export iResample=$iResample
				export randomSample=$RANDOM	
		
				matlab -nodisplay -r "addpath('$script_DIR');  				run_resample_2sitegroup_nosplitsite_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide,$sampleSize,$iResample,$randomSample);quit"

				
		
					sbatch --job-name=GLM_${iSubdivide}_${sampleSize}_${iResample}_${iGroup} make_input_run_mri_glmfit_resample_2sitegroup.sh

					#sh make_input_run_mri_glmfit_resample_2sitegroup.sh
						
			done
		done
	done
done


