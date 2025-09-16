#!/bin/bash

module load freesurfer/7.1.0


#change for MBBP
export reconOutDir=/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
datadir=/fs04/kg98/trangc/VBM/data

DATASET_LIST=$datadir/dataset_list1.txt

measure=thickness
measureShort=thick
smoothKernel=10
hemis=lh
parc=SF100
covariance1=sex
covariance2=age

for DATASET in `cat ${DATASET_LIST}`
do

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
		control=1

		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}_${parc}
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
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile
		#echo "Variables ${covariance2}" >> $qdecfile

		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do



			IFS=$'\t' read -ra parts <<< "$line"
    			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile
			#echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[3]}" >> $qdecfile

			#make list subject
			#echo "$datadir/$DATASET/derivatives/freesurfer/${parts[0]}" >> $inputfile

			#change list input for MBBP
			sub=$(echo "${parts[0]}" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
			#sub=${parts[0]}
			echo "${reconOutDir}/${sub}" >> $inputfile
			
			

		done
		unset IFS
		
		#concat subject data from input list
		#aparcstats2table --subjectsfile $inputfile  --hemi ${hemis} --meas ${measure}  --parcs-from-file /projects/kg98/trangc/atlases/Human_cortical/Schaefer/fsaverage/label/lh.Schaefer2018_100Parcels_7Networks_order.annot --tablefile  $datadir/$DATASET/derivatives/freesurfer/qdec/$title/${parc}_${hemis}_${measure}_table.txt

		aparcstats2table --subjectsfile $inputfile  --hemi ${hemis} --meas ${measure}  --parcs aparc --tablefile  $datadir/$DATASET/derivatives/freesurfer/qdec/$title/${parc}_${hemis}_${measure}_table.txt



		#make contrast
		contrastDir=$datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

		#run mri_glmfit
		mri_glmfit --table $datadir/$DATASET/derivatives/freesurfer/qdec/$title/${parc}_${hemis}_${measure}_table.txt --fsgd $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/qdec.fsgd doss --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --surf fsaverage ${hemis} --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

		#mri_glmfit --table $datadir/$DATASET/derivatives/freesurfer/qdec/$title/${parc}_${hemis}_${measure}_table.txt --fsgd $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/qdec.fsgd doss --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --surf fsaverage ${hemis} --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat
	done
		

done
