#!/bin/bash
#SBATCH --time=0-12:10:00
# SBATCH --job-name=glm
#SBATCH --account=kg98
#SBATCH --cpus-per-task=24
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load freesurfer/7.1.0


		
if [ "$DATASET" == "MBBP" ]; then 
	export reconOutDir=/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
else
	export reconOutDir=$datadir/$DATASET/derivatives/freesurfer
fi

ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

for sitefile in `cat $datadir/$DATASET/sitelist.txt`
do

	echo $sitefile
	sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
	echo $sitefield
	site=${sitefield:0:${#sitefield}-2}
	echo $site
	diag=${sitefile:${#sitefile}-5:1}
	echo $diag
	
	if [ "$harmonize" -eq 1 ]; then 
		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_combat
	else
		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}
	fi

	echo $title
	qdecDir=$datadir/$DATASET/derivatives/freesurfer/qdec
	echo $qdecDir

	if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
	if [ ! -d $qdecDir/${title} ]; then mkdir $qdecDir/${title}; echo "making site directory"; fi 

	qdecfile=$datadir/$DATASET/derivatives/freesurfer/qdec/$title/qdec.fsgd
	inputfile=$datadir/$DATASET/derivatives/freesurfer/qdec/$title/input.txt
	rm -f $inputfile


	# make fsgd file
	echo "GroupDescriptorFile 1" > $qdecfile
	echo "Title ${title}" >> $qdecfile
	echo "MeasurementName ${measure}" >> $qdecfile
	echo "Class diagnosis${control}" >> $qdecfile
	echo "Class diagnosis${diag}" >> $qdecfile

	if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
		echo "Variables ${covariance1}" >> $qdecfile
	else
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile
	fi

	IFS=$'\n'
	for line in $(tail -n +2 "$sitefile")
	do



		IFS=$'\t' read -ra parts <<< "$line"
		
		if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile
		else
			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile	
		fi

		#make list input
		if [ "$DATASET" == "MBBP" ]; then 
			sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
		else
			sub=${parts[0]}
		fi 
		
		if [ "$harmonize" -eq 1 ]; then 
			echo "$datadir/$DATASET/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage_combat.mgh" >> $inputfile
		else
			echo "${reconOutDir}/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
		fi
		

	done
	unset IFS
	#concat subject data from input list
	mri_concat --f $inputfile --o $datadir/$DATASET/derivatives/freesurfer/qdec/$title/y.mgh

	#make contrast
	contrastDir=$datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts

	if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
	
	if [[ "${DATASET}" == "ABIDEI" ]] || [[ "${DATASET}" == "ABIDEII" ]]; then
		echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
	else
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
	fi

	#run mri_glmfit
	mri_glmfit --y $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/y.mgh --fsgd $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/qdec.fsgd doss --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --surf fsaverage ${hemis} --label ${reconOutDir}/fsaverage/label/${hemis}.aparc.label --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

	#run permutation to obtain thresholded maps
	mri_glmfit-sim --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --perm 1000 1.3 abs --cwp  0.05 --2spaces --bg 24 --overwrite
done
		


