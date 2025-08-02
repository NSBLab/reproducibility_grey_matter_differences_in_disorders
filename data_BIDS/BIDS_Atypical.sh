#!/bin/env bash

IDIR=/scratch/kg98/Data_Trang/ASD_Atypical_Late_Neurodevelopment/image03/Volumes/working

ODIR=/projects/kg98/trangc/VBM/data/Atypical

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/Atypical/fileID2_earliest_scan.txt`
do


sub=${DIR:0:11}
filename=${DIR:11:83}

mkdir -p ${ODIR}/${sub}/anat/

cp ${IDIR}/${filename} ${ODIR}/${sub}/anat/${sub}_T1w.nii.gz

gzip -d ${ODIR}/${sub}/anat/${sub}_T1w.nii.gz

done

# find . -name \*.dcm -type f -delete


