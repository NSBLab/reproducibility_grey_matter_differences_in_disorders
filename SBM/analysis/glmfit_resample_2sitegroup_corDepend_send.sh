#!/bin/bash

#SUBJLIST=/home/trangc/kg98/trangc/VBM/data/dataset_list_ses.txt
# 742 SCZ
module load  matlab/r2023b
export smoothKernel=10
export measure=thickness
export measureShort=thick
export hemis=lh
diagList=(4)
export control=1

#nSubdivide=100	
nSample=100

groupList=(1 2)
#export targetValues=($(seq 0.1 0.1 1))

export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec
export dividemode=splitsite

for diag in ${diagList[@]}
do
	export diag=$diag
outdir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s${smoothKernel}noCOMBAT/diag${diag}/${hemis}/resample_2sitegroup_${dividemode}
export resultsFile=$outdir/targetFolder.txt
cd $outdir

#arraySubdivide=($(ls -d iSubdivide_1_seed2group_*))

#matlab -nodisplay -r "addpath('$script_DIR');  			findClosestFolders('$outdir',  '$resultsFile');quit"

IFS=$'\n'
for line in $(cat "$resultsFile"); do
	echo $line
#for iarraySubdivide in ${arraySubdivide[@]}; do
	
	IFS=$'\t' read -ra iarraySubdivide <<< "$line"
	echo ${iarraySubdivide[1]}
   IFS=$'_' read -ra divideparts <<< ${iarraySubdivide[1]}
	echo $divideparts
	unset IFS
	export iSubdivide=${divideparts[1]}
	export randomSubdivide=${divideparts[3]}
	echo $iSubdivide
	echo $randomSubdivide

	#matlab -nodisplay -r "addpath('$script_DIR');  				run_divide_2sitegroup_nosplitsite_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide);quit"
	
	#if [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group1/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/z.mgh ] || [ ! -f $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group2/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/z.mgh ]; then 
	
		#sbatch --job-name=GLM_${iSubdivide} ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh
		#sh ${script_DIR}/make_input_run_mri_glmfit_subdivide_2sitegroup.sh
	#fi
	#if [ ! -d $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize ]; then 
			#echo $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize
	sampleSizeList=(20 40 60 80 100 200 300 400 500 600 700) #40 60 100 

	#if false; then
	for sampleSize in ${sampleSizeList[@]}
	do
		export sampleSize=$sampleSize
		echo $sampleSize
		if [ ! -d $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize ]; then 
			echo $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize
		#subdividedir=$outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_${sampleSize} # use this to extract metainfo already generated
		#echo $subdividedir
		#cd $subdividedir
		
		#arraySample=($(ls iResample_*_seed_*_1.txt))

		#for iarraySample in ${arraySample[@]}; do

			#IFS=$'_' read -ra sampleparts <<< "$iarraySample"
		
			#export iResample=${sampleparts[1]}
			#export randomSample=${sampleparts[3]}	

		for iResample in $(seq 1 $nSample); do #use this if not run matlab for metainfo
			export iResample=$iResample
			export randomSample=$RANDOM	
			#if [ -z "$(find $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize/ -type d -name 'iResample_${iResample}*')" ]; then 
			#echo yes
			#else
			#echo $outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_$sampleSize
			#echo now
			matlab -nodisplay -r "addpath('$script_DIR');  				run_resample_2sitegroup_splitsite_func($diag,$smoothKernel,'$hemis',$iSubdivide,$randomSubdivide,$sampleSize,$iResample,$randomSample);quit"

			#if [ ! -f $subdividedir/iResample_${iResample}_seed_${randomSample}_1/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/z.mgh ] || [ ! -f $subdividedir/iResample_${iResample}_seed_${randomSample}_1/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/z.mgh ]; then 
	
				sbatch --job-name=GLM_${iSubdivide}_${sampleSize}_${iResample}_corr ${script_DIR}/make_input_run_mri_glmfit_resample_2sitegroup.sh

				#sh make_input_run_mri_glmfit_resample_2sitegroup.sh
			#fi 
			
		done
	fi
	done
	#fi

done

done
