#!/bin/env bash

DATASET=ASRB
ses=ses-1

for SUB in `cat /projects/kg98/trangc/VBM/data/${DATASET}/subject_CAT.txt`	#get subject ID
do

		ls /projects/kg98/trangc/VBM/data/${DATASET}/${SUB} > temp.txt #list all the sessions
		ses=$(sed '1q;d' temp.txt) #choose the first session
		printf "\n${SUB}/${ses}" >> /projects/kg98/trangc/VBM/data/$dataset/cat12_qcReport_$dataset.txt 

done
