#!/bin/env bash

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/UCLA/addSub.txt`
do

	mkdir -p /home/trangc/kg98/trangc/VBM/data/UCLA/${DIR}/anat
	cp /home/trangc/kg98/Shared/UCLA/derivatives/freesurfer/${DIR}/anat/${DIR}_T1w.nii.gz /home/trangc/kg98/trangc/VBM/data/UCLA/${DIR}/anat/
	gzip -d /home/trangc/kg98/trangc/VBM/data/UCLA/${DIR}/anat/${DIR}_T1w.nii.gz
done
