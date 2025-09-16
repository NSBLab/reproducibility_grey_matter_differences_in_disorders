#!/bin/bash
#SBATCH --time=0-8:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec
export nullDir=/scratch/kg98/trangc/VBM/data/derivatives/freesurfer/s10COMBAT/null

module load  matlab/r2023b
module load freesurfer/7.1.0

parc=aparc

ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

for sitefileori in `cat $datadir/$DATASET/sitelist.txt`
do

	echo $sitefileori
	sitefield=$(echo "$sitefileori" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
	echo $sitefield
	site=${sitefield:0:${#sitefield}-2}
	echo $site
	diag=${sitefileori:${#sitefileori}-5:1}
	echo $diag
	control=1

	
	
	matlab -nodisplay -r "addpath('$script_DIR');  run_null_func($randomNumber,'$DATASET', '$nullDir','$sitefileori',$iNullMin,$iNullMax)"


	for iNull in $(seq $iNullMin $iNullMax)
	do
		#export randomNumber=$(($RANDOM + $randomNumber))
		#echo $randomNumber
		#export iNull=$iNull

		outdir=${nullDir}/${iNull}/$DATASET
		#if [ ! -d $outdir ]; then mkdir $outdir; echo "making null directory"; fi  

		export sitefile=$outdir/qdec_table_${sitefield}.dat
		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_${parc}
		echo $title


		qdecDir=$outdir/${title}
		echo $qdecDir

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
		#echo "Variables ${covariance1} ${covariance2}" >> $qdecfile
		echo "Variables ${covariance1}" >> $qdecfile


		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do

			echo $line

			IFS=$'\t' read -ra parts <<< "$line"
    			#echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile #combine subid with dataset to avoid repeated id
			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile
			
			
					
			#make list subject
			echo "$datadir/$DATASET/derivatives/freesurfer/${parts[0]}" >> $inputfile
			
			

		done
		unset IFS

		#concat subject data from input list
		
		aparcstats2table --subjectsfile $inputfile  --hemi ${hemis} --meas ${measure}  --parc ${parc} --tablefile  ${qdecDir}/${parc}_${hemis}_${measure}_table.txt


		#make contrast
		contrastDir=$qdecDir/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		#echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		#echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
		echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat


		#run mri_glmfit
		mri_glmfit --table ${qdecDir}/${parc}_${hemis}_${measure}_table.txt --fsgd $qdecDir/qdec.fsgd doss --glmdir $qdecDir --surf fsaverage ${hemis} --label $datadir/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $contrastDir/${hemis}-Avg-Intercept-${measure}.mat --C $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
	done
done
		


