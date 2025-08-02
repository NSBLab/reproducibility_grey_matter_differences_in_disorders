#!/bin/env bash

IDIR=/projects/kg98/Sid/STAGES/STAGES_BIDS
ODIR=/projects/kg98/trangc/VBM/data/STAGES

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/STAGES/subject_use_extract.txt`
do

mkdir -p ${ODIR}/${DIR}/ses-1/anat

cp ${IDIR}/${DIR}/ses-1/anat/${DIR}_ses-1_T1w.nii ${ODIR}/${DIR}/ses-1/anat/${DIR}_ses-1_T1w.nii

done

# find . -name \*.dcm -type f -delete


