#!/bin/bash

module load freesurfer/7.1.0

DATASET_LIST="/fs04/kg98/trangc/VBM/data/dataset_list_noses2.txt"

measure='thickness'
measureShort='thick'
diagnosis

for DATASET in `cat ${DATASET_LIST}`
do

#concat subject data


export dataset=ABIDEII
export SUBJECTS_DIR=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer
vglrun qdec

thick_smooth10_lh_sex_age



mri_glmfit.bin --y /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/qdec/thick_smooth10_lh_sex_age/y.mgh --fsgd /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/qdec/thick_smooth10_lh_sex_age/qdec.fsgd doss --glmdir /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/qdec/thick_smooth10_lh_sex_age --surf fsaverage lh --label /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/fsaverage/label/lh.aparc.label --C /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/qdec/thick_smooth10_lh_sex_age/contrasts/lh-Avg-Intercept-thickness.mat --C /fs04/kg98/trangc/VBM/data/ABIDEI/derivatives/freesurfer/qdec/thick_smooth10_lh_sex_age/contrasts/lh-Diff-1-5-Intercept-thickness.mat
