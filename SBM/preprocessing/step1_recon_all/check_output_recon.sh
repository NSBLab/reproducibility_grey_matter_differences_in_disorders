#!/bin/env bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list1.txt
#SESSION=1 #having multiple sessions or not

for DATASET in `cat ${DATASETLIST}`
do

#freesurferDir=/scratch/kg98/Toby/WHOLEMBBP/workspace/derivatives/freesurfer
freesurferDir=/projects/kg98/trangc/VBM/data/${DATASET}/derivatives/freesurfer

rm /projects/kg98/trangc/VBM/data/${DATASET}/sub_without_recon_err.txt
rm /projects/kg98/trangc/VBM/data/${DATASET}/sub_with_recon_output.txt
rm /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt
rm /projects/kg98/trangc/VBM/data/${DATASET}/ses_sub_with_recon_output.txt

if [ -z "$SESSION" ]
then

SUBJLIST=/projects/kg98/trangc/VBM/data/${DATASET}/subject_use.txt

for subj in `cat ${SUBJLIST}`
do
	#subject=$(echo "$subj" | sed 's/sub-0*\([1-9][0-9]*\)/sub-\1/')
	subject=$subj	
	echo $subject
#subject without recon_err
	if [ ! -f ${freesurferDir}/${subject}/scripts/recon-all.error ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/anat/${subj}_T1w.nii ]
        then 
        #echo "${DATASET}/${subj}"
        printf "\n${subj}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_without_recon_err.txt
        fi     

#subject with recon_output
		echo ${freesurferDir}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh
		echo /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/anat/${subj}_T1w.nii
        
        if [ -f ${freesurferDir}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/anat/${subj}_T1w.nii ]
        then 
        printf "\n${subj}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_with_recon_output.txt
        fi  

#subject without error and without recon output 

        if [ ! -f ${freesurferDir}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/anat/${subj}_T1w.nii ] #&& [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/freesurfer/${subj}/scripts/recon-all.error ] 
        then 
        #echo "${DATASET}/${subj}"
        printf "\n${subj}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt
        fi 

done
else

SUBJLIST=/projects/kg98/trangc/VBM/data/${DATASET}/ses_subject_use.txt

for line in `cat ${SUBJLIST}`
do	

ses=${line: -5}
subj=${line:0:${#line}-5}

#subject without recon_err
	if [ ! -f ${freesurferDir}/${subj}/scripts/recon-all.error ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii ]
        then 
        echo "${DATASET}/${subj}"
        printf "\n${subj}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_without_recon_err.txt
else
echo $subj
        fi     

#subject with recon_output
        if [ -f ${freesurferDir}/${subj}/surf/lh.thickness.fwhm10.fsaverage.mgh ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii ]
        then 
        #echo "${DATASET}/${subj}"
        printf "\n${subj}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_with_recon_output.txt
        printf "\n${subj}${ses}" >> /projects/kg98/trangc/VBM/data/${DATASET}/ses_sub_with_recon_output.txt
        fi  

#subject without error and without recon output 

        if [ ! -f ${freesurferDir}/${subj}/surf/lh.thickness.fwhm10.fsaverage.mgh ] && [ -f /projects/kg98/trangc/VBM/data/${DATASET}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii ] #&& [ ! -f /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/freesurfer/${subj}/scripts/recon-all.error ] 
        then 
        echo "${DATASET}/${subj}"
        printf "\n${subj}${ses}" >> /projects/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt
        fi 

done

fi



done
