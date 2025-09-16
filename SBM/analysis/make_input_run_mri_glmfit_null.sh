#!/bin/bash
#SBATCH --time=0-1:10:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END
#SBATCH --array=2-100
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90



module load freesurfer/7.1.0
	
# each null is an element in the slurm array
iNull=$SLURM_ARRAY_TASK_ID


outdir=${nullDir}/${iNull}/$DATASET
if [ ! -d $outdir ]; then mkdir -p $outdir; echo "making null directory"; fi  

export sitefile=$outdir/qdec_table_${sitefield}.dat
title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat
echo $title

qdecDir=$outdir/${title}
echo $qdecDir

	if [ ! -f $qdecDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}/perm.th13.abs.sig.voxel.mgh ]
	then

		if [ ! -d ${qdecDir} ]; then mkdir ${qdecDir}; echo "making site directory"; fi 

	
	
		qdecfile=${qdecDir}/qdec.fsgd
		inputfile=${qdecDir}/input.txt
		rm -f $inputfile


		# make fsgd file
		echo "GroupDescriptorFile 1" > $qdecfile
		echo "Title ${siteDir}" >> $qdecfile
		echo "MeasurementName ${measure}" >> $qdecfile
		echo "Class diagnosis${control}" >> $qdecfile
		echo "Class diagnosis${diag}" >> $qdecfile
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile
		#echo "Variables ${covariance1}" >> $qdecfile


		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do

			echo $line

			IFS=$'\t' read -ra parts <<< "$line"
    			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile #combine subid with dataset to avoid repeated id
			#echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile
			
			
			#make list input
			echo "$datadir/${DATASET}/derivatives/freesurfer/${parts[0]}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.combat.mgh" >> $inputfile
			
			

		done
		unset IFS

		#concat subject data from input list
		mri_concat --f $inputfile --o $qdecDir/y.mgh

		#make contrast
		contrastDir=$qdecDir/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
		#echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		#echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat


		#run mri_glmfit
		mri_glmfit --y $qdecDir/y.mgh --fsgd $qdecDir/qdec.fsgd doss --glmdir $qdecDir --surf fsaverage ${hemis} --label $datadir/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $contrastDir/${hemis}-Avg-Intercept-${measure}.mat --C $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

		mri_glmfit-sim --glmdir $qdecDir --perm 500 1.3 abs --cwp  0.05 --2spaces --bg 50 --overwrite
	
	fi
		


