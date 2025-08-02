#!/bin/env bash

IDIR=/projects/kg98/Sid/UCLA/cat12
ODIR=/projects/kg98/trangc/VBM/data/UCLA

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/UCLA/subject_use_extract.txt`
do

mkdir -p ${ODIR}/${DIR}/anat

cp ${IDIR}/${DIR}/${DIR}_T1w.nii ${ODIR}/${DIR}/anat/${DIR}_T1w.nii

done

# find . -name \*.dcm -type f -delete


