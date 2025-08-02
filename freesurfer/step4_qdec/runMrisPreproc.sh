#!/bin/bash

export study=ABIDEI
cd /home/trangc/kg98/trangc/VBM/data/$study

for hemi in lh
do
  for smoothing in 10
  do
    for meas in thickness
    do
      mris_preproc --fsgd FSGD/$study.fsgd \
        --cache-in $meas.fwhm$smoothing.fsaverage \
        --target fsaverage \
        --hemi $hemi \
        --out $hemi.$meas.$study.$smoothing.mgh
    done
  done
done
