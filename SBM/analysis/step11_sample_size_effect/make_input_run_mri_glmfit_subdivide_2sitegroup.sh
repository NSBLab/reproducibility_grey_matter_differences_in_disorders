#!/bin/bash
#SBATCH --time=0-3:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=6
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load freesurfer/7.1.0

export reconOutDir=/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
datadir=/projects/kg98/trangc/VBM/data

groupList=(1 2)

for groupIn in ${groupList[@]}
do
	sitefile=$outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group${groupIn}.txt
		
	title=iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group${groupIn}_sm${smoothKernel}
		
	qdecDir=$outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/$title
	echo $qdecDir

	if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
		
	qdecfile=${qdecDir}/qdec.fsgd
	inputfile=${qdecDir}/input.txt
	rm -f $inputfile
	
	# check if all subjects are one sex, in that case, need to use only one covariance
	allOne=true
	IFS=$'\n'
	for line in $(tail -n +2 "$sitefile")
	do
			
		IFS=$'\t' read -ra parts <<< "$line"
		sex_value=$(echo "${parts[5]}" | tr -d '[:space:]')
		if [[ "${sex_value}" != "1" ]]; then
		allOne=false
		fi
    done	

	# make fsgd file
	echo "GroupDescriptorFile 1" > $qdecfile
	echo "Title ${title}" >> $qdecfile
	echo "MeasurementName ${measure}" >> $qdecfile
	echo "Class diagnosis${control}" >> $qdecfile
	echo "Class diagnosis${diag}" >> $qdecfile
	
	if [[ ${allOne} == false ]]; then
		
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile

			
		for line in $(tail -n +2 "$sitefile")
		do

			echo $line

			IFS=$'\t' read -ra parts <<< "$line"
    		echo "Input ${parts[0]}${parts[1]} diagnosis${parts[3]} ${parts[5]} ${parts[4]}" >> $qdecfile #combine subid with dataset to avoid repeated id
			
			site_value=$(echo "${parts[1]}" | tr -d '[:space:]')
			#make list input
        	if [ "${site_value}" = "MBBP" ]
			then
        		sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
				echo "${reconOutDir}/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
			else
			
				echo "$datadir/${parts[1]}/derivatives/freesurfer/${parts[0]}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
			fi	
			

		done
		unset IFS

		#concat subject data from input list
		mri_concat --f $inputfile --o $qdecDir/y.mgh

		#make contrast
		contrastDir=$qdecDir/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

	else
		echo "Variables ${covariance2}" >> $qdecfile

			
		for line in $(tail -n +2 "$sitefile")
		do

			echo $line

			IFS=$'\t' read -ra parts <<< "$line"
    		echo "Input ${parts[0]}${parts[1]} diagnosis${parts[3]} ${parts[4]}" >> $qdecfile #combine subid with dataset to avoid repeated id
			
			site_value=$(echo "${parts[1]}" | tr -d '[:space:]')
			#make list input
        	if [ "${site_value}" = "MBBP" ]
			then
        		sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
				echo "${reconOutDir}/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
			else
			
				echo "$datadir/${parts[1]}/derivatives/freesurfer/${parts[0]}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
			fi	
			

		done
		unset IFS

		#concat subject data from input list
		mri_concat --f $inputfile --o $qdecDir/y.mgh

		#make contrast
		contrastDir=$qdecDir/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
	fi
	#run mri_glmfit
	mri_glmfit --y $qdecDir/y.mgh --fsgd $qdecDir/qdec.fsgd doss --glmdir $qdecDir --surf fsaverage ${hemis} --label $datadir/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $contrastDir/${hemis}-Avg-Intercept-${measure}.mat --C $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

		mri_glmfit-sim --glmdir $qdecDir --perm 1000 1.3 abs --cwp  0.05 --2spaces --bg 6 --overwrite
done
		


