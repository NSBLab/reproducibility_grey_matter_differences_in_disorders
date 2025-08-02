#!/bin/env bash

IDIR=/projects/kg98/chaos/Projects/OCDPG/rawdata
ODIR=/projects/kg98/trangc/VBM/data/OCDPG

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/OCDPG/subject_use_extract.txt`
do

mkdir -p ${ODIR}/${DIR}/anat

cp ${IDIR}/${DIR}/anat/${DIR}_T1w.nii.gz ${ODIR}/${DIR}/anat/${DIR}_T1w.nii.gz

gzip -d ${ODIR}/${DIR}/anat/${DIR}_T1w.nii.gz 

done

# find . -name \*.dcm -type f -delete


