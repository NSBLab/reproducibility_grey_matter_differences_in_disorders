#!/bin/env bash
dataset=Study_neura
SUBJLIST=/projects/kg98/trangc/VBM/data/${dataset}/ses_subject_use.txt

for line in `cat ${SUBJLIST}`
do

ses=${line: -5}
subj=${line:0:${#line}-5}

	#sesFolder=/projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}

	#mkdir $sesFolder

	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/label /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/label

	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/mri /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/mri
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/scripts /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/scripts
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/stats /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/stats
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/surf /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/surf
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/tmp /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/tmp
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/touch /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/touch
	cp -a /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/${ses}/trash /projects/kg98/trangc/VBM/data/${dataset}/derivatives/freesurfer/${subj}/trash

done
