#!/bin/env bash

DATASETLIST=/projects/kg98/trangc/VBM/data/dataset_list_ses.txt
SESSION=1 #having multiple sessions or not

for DATASET in `cat ${DATASETLIST}`
do


mkdir /projects/kg98/trangc/VBM/data/$DATASET/derivatives/freesurfer/qdec
#cp /projects/kg98/trangc/VBM/data/ABIDEI/diagnosis.levels /projects/kg98/trangc/VBM/data/$DATASET/diagnosis.levels
#rm /projects/kg98/trangc/VBM/data/$DATASET/sex.levels

done
