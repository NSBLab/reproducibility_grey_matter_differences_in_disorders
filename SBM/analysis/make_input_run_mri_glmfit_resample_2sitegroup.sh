#!/bin/bash
#SBATCH --time=0-2:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec

#module load  matlab/r2023b

module load freesurfer/7.1.0

RANDOM=$randomSample

datadir=/projects/kg98/trangc/VBM/data
outdir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s${smoothKernel}noCOMBAT/diag${diag}/${hemis}/resample_2sitegroup_${dividemode}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/sampleSize_${sampleSize}
cd $outdir
		
covariance1=sex
covariance2=age

array=($(ls iResample_${iResample}_seed_${randomSample}_*.txt))

for sitefile in ${array[@]}
do

	siteDir=${sitefile:0:${#sitefile}-4}
	echo $siteDir
		
	title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}
	echo $title
		
	qdecDir=$outdir/$siteDir
	echo $qdecDir

	if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
		
	qdecfile=${qdecDir}/qdec.fsgd
	inputfile=${qdecDir}/input.txt
	rm -f $inputfile
	rm -f $qdecfile


	# make fsgd file
	echo "GroupDescriptorFile 1" > $qdecfile
	echo "Title ${siteDir}" >> $qdecfile
	echo "MeasurementName ${measure}" >> $qdecfile
	echo "Class diagnosis${control}" >> $qdecfile
	echo "Class diagnosis${diag}" >> $qdecfile
	echo "Variables ${covariance1} ${covariance2}" >> $qdecfile

	IFS=$'\n'
	for line in $(tail -n +2 "$sitefile")
	do

		echo $line

		IFS=$'\t' read -ra parts <<< "$line"
    	echo "Input ${parts[0]}${parts[1]} diagnosis${parts[3]} ${parts[5]} ${parts[4]}" >> $qdecfile #combine subid with dataset to avoid repeated id
			
		#make list input
		
        if [ "${parts[1]}" = "MBBP" ]
		then
        sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
		echo "/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer/${sub}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
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

	#run mri_glmfit
	mri_glmfit --y $qdecDir/y.mgh --fsgd $qdecDir/qdec.fsgd doss --glmdir $qdecDir --surf fsaverage ${hemis} --label $datadir/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $contrastDir/${hemis}-Avg-Intercept-${measure}.mat --C $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
done
		


