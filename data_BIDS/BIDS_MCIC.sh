#!/bin/env bash

module load fsl
module load mricrogl

IDIR=/scratch/kg98/Data_Trang/MCIC/Site_A/dicom/sonata/jlauriello/mcicshare_99997
ODIR=/projects/kg98/trangc/VBM/data/MCIC

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/MCIC_BIDS/subject_use_extract_missA.txt`
do

	file=${DIR:4:9}

	ls ${IDIR}/${file} > temp.txt #list all the sessions
	
	iSes=0	
	for ses in `cat temp.txt`
	do
	
		iSes=$iSes+1

		mkdir -p ${ODIR}/${DIR}/ses-$iSes/anat/

		cp ${IDIR}/${DIR}/${ses}/ ${ODIR}/${DIR}/ses-$iSes/anat/

#mkdir -p ${ODIR}/sub-${DIR}/ses-${i}/anat
#mv ${ODIR}/sub-${DIR}/anat/sub-${DIR}_run-0${i}_T1w.nii.gz ${ODIR}/sub-${DIR}/ses-${i}/anat/sub-${DIR}_ses-${i}_T1w.nii.gz

#gzip -d ${ODIR}/sub-${DIR}/ses-1/anat/sub-${DIR}_ses-1_T1w.nii.gz
rmdir ${ODIR}/${DIR}/anat
done

# find . -name \*.dcm -type f -delete


