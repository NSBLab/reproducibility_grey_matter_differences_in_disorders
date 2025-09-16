#!/bin/bash
# this script make the required input files for mri_glmfit and run_glmfit to compare two groups of maps and take into account the covariate such as sex and age

module load freesurfer/7.1.0

datadir=<your folder>

# run for a list of datasets
DATASET_LIST=$datadir/dataset_list.txt

measure=thickness
measureShort=thick
smoothKernel=20
hemis=lh
covariance1=sex
covariance2=age

# loop through all the datasets
for DATASET in `cat ${DATASET_LIST}`
do
	
	# list all the qdec files of the dataset, each site of the dataset has a qdec file
	ls <your folder>/qdec_table_*.dat > <your folder>/sitelist.txt

	# loop through all the sites of the dataset
	for sitefile in `cat <your folder>/sitelist.txt`
	do

		echo $sitefile
		sitefield=$(echo "$sitefile" | grep -o -P '(?<=table_).*(?=.dat)') #get the part between table_ and .dat
		echo $sitefield
		site=${sitefield:0:${#sitefield}-2} # get the site
		echo $site
		diag=${sitefile:${#sitefile}-5:1} # get the diagnosis
		echo $diag
		control=1

		title=${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2} # define the folder where to store the output, each statistical test has one folder, one dataset may have different statistical tests
		echo $title

		qdecDir=<your folder> # dataset directory where you put the statistical test folder in
		echo $qdecDir

		if [ ! -d $qdecDir ]; then mkdir $qdecDir; echo "making qdec directory"; fi 
		if [ ! -d $qdecDir/${title} ]; then mkdir $qdecDir/${title}; echo "making site directory"; fi 

		qdecfile=$datadir/$DATASET/derivatives/freesurfer/qdec/$title/qdec.fsgd # define fsgd filename
		inputfile=$datadir/$DATASET/derivatives/freesurfer/qdec/$title/input.txt # define the filename of the list of the input maps to mri_glmfit
		rm -f $inputfile # remove if already exist to avoid adding to exist file


		# make fsgd file
		# first put the heading of the fsgd file
		echo "GroupDescriptorFile 1" > $qdecfile
		echo "Title ${title}" >> $qdecfile
		echo "MeasurementName ${measure}" >> $qdecfile
		echo "Class diagnosis${control}" >> $qdecfile
		echo "Class diagnosis${diag}" >> $qdecfile
		echo "Variables ${covariance1} ${covariance2}" >> $qdecfile

		# read each line of the qdec.dat file, which contains info for each subject
		IFS=$'\n'
		for line in $(tail -n +2 "$sitefile") 
		do
			# put subject info into the fsgd file
			IFS=$'\t' read -ra parts <<< "$line"
    			echo "Input ${parts[0]} diagnosis${parts[1]} ${parts[2]} ${parts[3]}" >> $qdecfile
			
			# make list input maps
			echo "$datadir/$DATASET/derivatives/freesurfer/${parts[0]}/surf/${hemis}.${measure}.fwhm${smoothKernel}.fsaverage.mgh" >> $inputfile
			
			

		done
		unset IFS

		#concat subject data from input list
		mri_concat --f $inputfile --o $datadir/$DATASET/derivatives/freesurfer/qdec/$title/y.mgh

		#make contrast
		contrastDir=$datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts

		if [ ! -d $contrastDir ]; then mkdir $contrastDir; echo "making contrast directory"; fi 
		
		echo "1 1 0 0" > $contrastDir/${hemis}-Avg-Intercept-${measure}.mat # average map
		echo "1 -1 0 0" > $contrastDir/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat # different map

		#run mri_glmfit
		mri_glmfit --y $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/y.mgh --fsgd $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/qdec.fsgd doss --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --surf fsaverage ${hemis} --label $datadir/$DATASET/derivatives/freesurfer/fsaverage/label/${hemis}.aparc.label --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Avg-Intercept-${measure}.mat --C $datadir/$DATASET/derivatives/freesurfer/qdec/${title}/contrasts/${hemis}-Diff-${control}-${diag}-Intercept-${measure}.mat --eres-save

		#run permutation to obtain thresholded maps
		mri_glmfit-sim --glmdir $datadir/$DATASET/derivatives/freesurfer/qdec/${title} --perm 1000 1.3 abs --cwp  0.05 --2spaces --bg 50 --overwrite
	done
		

done
