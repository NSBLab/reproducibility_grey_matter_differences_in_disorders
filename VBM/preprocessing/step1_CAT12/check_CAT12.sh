#!/bin/bash

DATASET=Study_neura
SUBJLIST=/home/trangc/kg98/trangc/VBM/data/${DATASET}/subject_CAT.txt
ses=ses-1
#export ses=${ses}

for i in `cat ${SUBJLIST}`
do

	
	if [ -z "$ses" ]
	then

		filename=/projects/kg98/trangc/VBM/data/${DATASET}/${i}/anat/catreport_${i}_T1w.pdf # for data with one session

	else

		ls /projects/kg98/trangc/VBM/data/${DATASET}/${i} > temp.txt #list all the sessions
		ses=$(sed '1q;d' temp.txt) #choose the first session
		export ses=${ses}

		filename=/projects/kg98/trangc/VBM/data/${DATASET}/${i}/${ses}/anat/catreport_${i}_${ses}_T1w.pdf # for data with multiple sessions
	fi

	if [ ! -f $filename ]; then

		echo $i

	fi 
done


