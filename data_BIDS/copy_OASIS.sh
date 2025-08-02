#!/bin/bash

IDIR=/scratch/kg98/Data_Trang/OASIS
ODIR=/projects/kg98/trangc/VBM/data/OASIS3

for SUB in `cat ${ODIR}/subject.txt`
do
	ls -d $IDIR/${SUB}_MR_* > $IDIR/temp.txt


	SES=0
	for day in `cat $IDIR/temp.txt`
	do
		SES=$(($SES+1))
		

		ls -d $day/anat* > $IDIR/runtemp.txt

		runor=0
		for run in `cat $IDIR/runtemp.txt`
		do
			runor=$(($runor+1))
			niftiFile=$(ls $run/NIFTI)
			jsonFile=$(ls $run/BIDS)

			mkdir -p $ODIR/sub-$SUB/ses-$SES/anat

			if ((${runor}==1)); then


				cp $run/NIFTI/$niftiFile $ODIR/sub-$SUB/ses-$SES/anat/sub-${SUB}_ses-${SES}_T1w.nii.gz
				gzip -d $ODIR/sub-$SUB/ses-$SES/anat/sub-${SUB}_ses-${SES}_T1w.nii.gz
				cp $run/BIDS/$jsonFile $ODIR/sub-$SUB/ses-$SES/anat/sub-${SUB}_ses-${SES}_T1w.json

			else
				cp $run/NIFTI/$niftiFile $ODIR/sub-$SUB/ses-$SES/anat/sub-${SUB}_ses-${SES}_run-${runor}_T1w.nii.gz
				cp $run/BIDS/$jsonFile $ODIR/sub-$SUB/ses-$SES/anat/sub-${SUB}_ses-${SES}_run-${runor}_T1w.json
			fi
		done

				

	done
				

done
