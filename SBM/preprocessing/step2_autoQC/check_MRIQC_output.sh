#!/bin/env bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_ses_new.txt
SESSION=1 #1 or 0 ,having multiple sessions or not

for DATASET in `cat ${DATASETLIST}`
do

rm /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_runMRIQC.txt

if [ "$SESSION" -eq 0 ]
then

SUB_RECON_OUT=/projects/kg98/trangc/VBM/data/${DATASET}/sub_with_recon_output.txt

		for subj in `cat ${SUB_RECON_OUT}`
		do

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC/${subj}_T1w.html ]
        		then 
        			#echo "${DATASET}/${subj}"
        			printf "\n${subj:4:20}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_runMRIQC.txt
        		fi     

		done
else

SUB_RECON_OUT=/projects/kg98/trangc/VBM/data/${DATASET}/ses_sub_with_recon_output.txt

		for line in `cat ${SUB_RECON_OUT}`
		do
			ses=${line: -5}
			subj=${line:0:${#line}-5}

			if [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC/${subj}_${ses}_T1w.html ]
        		then 
        			#echo "${DATASET}/${subj}"
        			printf "\n${subj:4:20}${ses}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_runMRIQC.txt
        		fi     

		done
fi
done
