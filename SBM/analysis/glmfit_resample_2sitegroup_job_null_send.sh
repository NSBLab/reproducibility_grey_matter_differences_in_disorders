#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ
module load  matlab/r2023b
export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
export diag=4
export control=1
export iNullMin=1
export iNullMax=2

nSubdivide=10	
nSample=100

groupList=(1 2) #(150 200 300 400 600) #40 60 100 


export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec

outdir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10noCOMBAT/resample_2sitegroup
cd $outdir

arraySubdivide=($(ls -d iSubdivide_*_seed2group_*))

for iarraySubdivide in ${arraySubdivide[@]}; do
	
	IFS=$'_' read -ra divideparts <<< "$iarraySubdivide"

	export iSubdivide=${divideparts[1]}
	export randomSubdivide=${divideparts[3]}

	#matlab -nodisplay -r "addpath('$script_DIR');  				run_divide_2sitegroup_func($diag,$smoothKernel,$iSubdivide,$randomSubdivide);quit"
	
	# create null .dat files
	matlab -nodisplay -r "addpath('$script_DIR');  run_resample_null_func($diag,$smoothKernel,$iSubdivide,$randomSubdivide,$iNullMin,$iNullMax); quit"

	#if [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/null/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/z.mgh ]; then 
	
		#sbatch --job-name=GLM_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup_null.sh
		sh ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup_null.sh
	#fi

	
done


