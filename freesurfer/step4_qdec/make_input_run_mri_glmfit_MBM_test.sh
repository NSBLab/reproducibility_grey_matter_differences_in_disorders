#!/bin/bash

module load freesurfer/7.1.0

datadir=/projects/kg98/trangc/MBM/data/demo_emp

#DATASET_LIST=$datadir/dataset_list_AD.txt

measure=thickness
measureShort=thick
smoothKernel=20
hemis=lh
covariance1=sex
covariance2=age

#for DATASET in `cat ${DATASET_LIST}`
#do

#ls $datadir/$DATASET/qdec_table_*.dat > $datadir/$DATASET/sitelist.txt

	#for sitefile in `cat $datadir/$DATASET/sitelist.txt`
	#do
	sitefile=/projects/kg98/trangc/VBM/data/mbmtest.dat
#echo $sitefile
		#sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)') #| awk -F_ '{for (i=3; i<=NF-1; i++) printf "%s_", $i}')
		#echo $sitefield
		#site=${sitefield:0:${#sitefield}-2}
		#echo $site
		diag=4
		#echo $diag
		control=1

		title=result #${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}
		echo $title
		qdecDir=/projects/kg98/trangc/testMBM
		echo $qdecDir

		if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
		if [ ! -d $qdecDir/${title} ]; then mkdir $qdecDir/${title}; echo "making site directory"; fi 

		qdecfile=$qdecDir/$title/qdec.fsgd
		inputfile=$qdecDir/$title/input.txt
		rm -f $inputfile


		# make fsgd file
		echo "GroupDescriptorFile 1" > $qdecfile
		echo "Title ${title}" >> $qdecfile
		echo "MeasurementName ${measure}" >> $qdecfile
		echo "Class diagnosis${control}" >> $qdecfile
		echo "Class diagnosis${diag}" >> $qdecfile
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile

		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile")
		do



			IFS=$'\t' read -ra parts <<< "$line"
    				echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile
			
			#make list input
			echo "$datadir/thickness/${parts[0]}.mgh" >> $inputfile
			
			

		done
		unset IFS
		#concat subject data from input list
		mri_concat --f $inputfile --o $qdecDir/$title/y.mgh

		#make contrast
		contrastDir=$qdecDir/${title}/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat

		#run mri_glmfit
		mri_glmfit --y $qdecDir/${title}/y.mgh --fsgd $qdecDir/${title}/qdec.fsgd doss --glmdir $qdecDir/${title} --surf fsaverage ${hemis} --label /projects/kg98/trangc/VBM/data/HCP/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $qdecDir/${title}/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $qdecDir/${title}/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

		mri_glmfit-sim --glmdir $qdecDir/${title} --perm 1000 1.3 abs --cwp  0.05 --2spaces --bg 50 --overwrite
	
		


