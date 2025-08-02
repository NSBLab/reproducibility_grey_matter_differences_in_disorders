#!/bin/env bash
dataset=Modul_vent
SUBJLIST=/projects/kg98/trangc/VBM/data/${dataset}/ses_subject_use.txt

for line in `cat ${SUBJLIST}`
do

ses=${line: -5}
subj=${line:0:${#line}-5}

	sesFolder=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}

	mkdir $sesFolder

	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/label /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/label

	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/mri /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/mri
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/scripts /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/scripts
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/stats /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/stats
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/surf /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/surf
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/tmp /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/tmp
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/touch /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/touch
	mv /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/trash /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/trash

done
