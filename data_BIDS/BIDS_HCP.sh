#!/bin/env bash

IDIR=/projects/kg98/Priscila/honours/bids
ODIR=/projects/kg98/trangc/VBM/data/HCP

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/HCP/subject_use_extract.txt`
do

mkdir -p ${ODIR}/${DIR}/anat

cp ${IDIR}/${DIR}/anat/${DIR}_T1w.nii ${ODIR}/${DIR}/anat/${DIR}_T1w.nii

done

# find . -name \*.dcm -type f -delete


