#!/bin/env bash

DATASET=ASRB
#ses=ses-1

for SUB in `cat /projects/kg98/trangc/VBM/data/${DATASET}/subject_use_extract.txt`	#get subject ID
do



	if [ -z "$ses" ]
	then



		filename=/projects/kg98/trangc/VBM/data/${DATASET}/${SUB}/anat/${SUB}_T1w.nii # for data with one session

	else

		ls /projects/kg98/trangc/VBM/data/${DATASET}/${SUB} > temp.txt #list all the sessions
		ses=$(sed '1q;d' temp.txt) #choose the first session
		export ses=${ses}

		filename=/projects/kg98/trangc/VBM/data/${DATASET}/${SUB}/${ses}/anat/${SUB}_${ses}_T1w.nii # for data with multiple sessions

	fi

	if [ ! -f $filename ] ; then 
		echo ${SUB}
		
	fi
done
