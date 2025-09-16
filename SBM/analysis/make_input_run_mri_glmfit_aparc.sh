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

module load freesurfer/7.1.0

export reconOutDir=/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
datadir=/fs04/kg98/trangc/VBM/data
parc=aparc

groupList=(1 2)

for groupIn in ${groupList[@]}
do
		sitefile=$outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group${groupIn}.txt
		title=iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}_group${groupIn}_${parc}
		qdecDir=$outdir/iSubdivide_${iSubdivide}_seed2group_${randomSubdivide}/$title
		echo $qdecDir

		if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
		
		qdecfile=$qdecDir/qdec.fsgd
		inputfile=$qdecDir/input.txt
		rm -f $inputfile

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
    			echo "Input ${parts[0]}${parts[1]} diagnosis${parts[3]} ${parts[5]} ${parts[4]}" >> $qdecfile
				#echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile

				#make list subject
				#echo "$datadir/$DATASET/derivatives/freesurfer/${parts[0]}" >> $inputfile
			
				echo ${parts[1]}
				site_value=$(echo "${parts[1]}" | tr -d '[:space:]')
				#change list input for MBBP
				if [[ "${site_value}" == "MBBP" ]]; then
					sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
					echo "${reconOutDir}/${sub}" >> $inputfile
				else
					sub=${parts[0]}

					echo "${datadir}/${parts[1]}/derivatives/freesurfer/${sub}" >> $inputfile

				fi
			done
			unset IFS
		
			#concat subject data from input list
			aparcstats2table --subjectsfile $inputfile  --hemi ${hemis} --meas ${measure}  --parc ${parc} --tablefile  $qdecDir/${parc}_${hemis}_${measure}_table.txt



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
    			echo "Input ${parts[0]}${parts[1]} diagnosis${parts[3]} ${parts[4]}" >> $qdecfile
				
				site_value=$(echo "${parts[1]}" | tr -d '[:space:]')
				#change list input for MBBP
				if [[ "${site_value}" == "MBBP" ]]; then
					sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
					echo "${reconOutDir}/${sub}" >> $inputfile
				else
					sub=${parts[0]}

					echo "${datadir}/${parts[1]}/derivatives/freesurfer/${sub}" >> $inputfile

				fi
	
			done
			unset IFS
		
			#concat subject data from input list
			aparcstats2table --subjectsfile $inputfile  --hemi ${hemis} --meas ${measure}  --parc ${parc} --tablefile  $qdecDir/${parc}_${hemis}_${measure}_table.txt



			#make contrast
			contrastDir=$qdecDir/contrasts

			if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
			echo "1 1 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
			echo "1 -1 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

		fi
		

		#run mri_glmfit
		mri_glmfit --table $qdecDir/${parc}_${hemis}_${measure}_table.txt --fsgd $qdecDir/qdec.fsgd doss --glmdir $qdecDir --surf fsaverage ${hemis} --label $datadir/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $qdecDir/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $qdecDir/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

		

done
