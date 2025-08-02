#!/bin/env bash

IDIR=/projects/kg98/Shared/COBRE/COBRE
ODIR=/projects/kg98/trangc/VBM/data/COBRE

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/COBRE/sublist.txt`
do

filename=00${DIR}
sub=sub-${DIR}

mkdir -p ${ODIR}/${sub}/anat

cp ${IDIR}/${filename}/session_1/anat_1/mprage.nii.gz ${ODIR}/${sub}/anat/${sub}_T1w.nii.gz

gzip -d ${ODIR}/${sub}/anat/${sub}_T1w.nii.gz

done

# find . -name \*.dcm -type f -delete


