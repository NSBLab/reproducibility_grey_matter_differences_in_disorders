#!/bin/env bash

DATASET=MCIC
SUBJLIST=/home/trangc/kg98/trangc/VBM/data/${DATASET}/filelist.txt
#ses=ses-1


for sub in `cat ${SUBJLIST}`
do

	export ID=${sub:7:9}
	#export ses=${sub:12:5}
	#export file=${sub:9:30}

	cp -R /home/trangc/kg98/Courtney/MCIC/MCIC_T1_nifti/${sub:0:21} /home/trangc/kg98/trangc/VBM/data/${DATASET}/freesurfer/sub-$ID          

done
