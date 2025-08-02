#!/bin/bash

dataset=OASIS4
cd /projects/kg98/trangc/VBM/data/$dataset/

for sub in `cat subject_use.txt`; do
 ls /projects/kg98/trangc/VBM/data/$dataset/${sub} > temp.txt #list all the sessions
 ses=$(sed '1q;d' temp.txt) #choose the first session
 printf "\n${sub}${ses}" >> /projects/kg98/trangc/VBM/data/$dataset/ses_subject_use.txt
done
