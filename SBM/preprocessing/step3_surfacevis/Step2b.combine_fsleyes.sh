#!/bin/bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_noses.txt

for dataset in `cat ${DATASETLIST}`
do

cd /projects/kg98/trangc/VBM/data/$dataset/derivatives/surf_vis_fsl
filelist=/projects/kg98/trangc/VBM/data/$dataset/autoQCOutlier.txt
convert $(sed 's/$/_surface.png/' "$filelist") ${dataset}_outlier.pdf

filelist=/projects/kg98/trangc/VBM/data/$dataset/sub_without_outlier.txt
convert $(sed 's/$/_surface.png/' "$filelist") ${dataset}_no_outlier.pdf

done
