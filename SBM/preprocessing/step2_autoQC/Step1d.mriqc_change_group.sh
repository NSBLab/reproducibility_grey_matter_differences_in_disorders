#!/bin/bash

DATASET=Inhi_dys

QCdir=/projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC

tsv_file=$QCdir/group_all_T1w.tsv
cp $QCdir/group_T1w.tsv $tsv_file 
ses_sub_file=/projects/kg98/trangc/VBM/data/${DATASET}/ses_sub_with_recon_output.txt
temp_extracted_ids=/projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC/temp_extracted_ids.txt

new_group_file=/projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC/group_T1w.tsv

awk '{print substr($0, 1, 7) "_" substr($0, 8) "_T1w"}' "$ses_sub_file" > $temp_extracted_ids


grep -F -w -f "$temp_extracted_ids" "$tsv_file" > $new_group_file

# change file name for each sbject, i.e., remove session
for i in `cat ${ses_sub_file}`
do
ses=${i: -5}
subj=${i:0:${#i}-5}

cp ${QCdir}/${subj}_${ses}_T1w.html $QCdir/${subj}_T1w.html

done

