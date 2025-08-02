#!/bin/bash

module load fsl
module load mricrogl

IDIR=/scratch/kg98/Data_Trang/AIBL
ODIR=/projects/kg98/trangc/VBM/data/AIBL

savetofile=${ODIR}/ses_subject_use.txt
imageID=${ODIR}/imageID.txt

for DIR in `cat ${IDIR}/subject_use1.txt`
do

	sub=sub-$(printf "%04d" "${DIR}") #change to 4 digit ID

	ls ${IDIR}/${DIR} > ${IDIR}/mprage.txt #list mprage folder

	mprage=$(sed -n '1p' ${IDIR}/mprage.txt) # take the first one

	if [ "$mprage" == "localizer" ]
	then
		mprage=$(sed -n '2p' ${IDIR}/mprage.txt) # take the second one
		ls ${IDIR}/${DIR}/${mprage}/ > ${IDIR}/day.txt

		SES=0
	
		for day in `cat $IDIR/day.txt`
		do

		SES=$(($SES+1))

		ses=ses-${SES}
		
		mkdir -p ${ODIR}/${sub}/${ses}/anat
		image=$(ls ${IDIR}/${DIR}/${mprage}/${day})
		echo "${sub} ${ses} ${image}" >> $imageID
		cp ${IDIR}/${DIR}/${mprage}/${day}/${image}/*.dcm ${ODIR}/${sub}/${ses}/anat/
		dcm2niix -o ${ODIR}/${sub}/${ses}/anat/ -f %f ${ODIR}/${sub}/${ses}/anat/
		gzip -d  ${ODIR}/${sub}/${ses}/anat/*.nii.gz
		mv ${ODIR}/${sub}/${ses}/anat/*.nii ${ODIR}/${sub}/${ses}/anat/${sub}_${ses}_T1w.nii
		rm -f ${ODIR}/${sub}/${ses}/anat/*.dcm
		echo -e "${sub}${ses}" >> ${savetofile}
				
		done
	else
	ls ${IDIR}/${DIR}/${mprage}/ > ${IDIR}/day.txt

	SES=0
	#echo "subID ses image" > $imageID
	for day in `cat $IDIR/day.txt`
	do

		SES=$(($SES+1))

		ses=ses-${SES}
		
		mkdir -p ${ODIR}/${sub}/${ses}/anat
		image=$(ls ${IDIR}/${DIR}/${mprage}/${day})
		echo "${sub} ${ses} ${image}" >> $imageID
		cp ${IDIR}/${DIR}/${mprage}/${day}/${image}/*.dcm ${ODIR}/${sub}/${ses}/anat/
		dcm2niix -o ${ODIR}/${sub}/${ses}/anat/ -f %f ${ODIR}/${sub}/${ses}/anat/
		gzip -d  ${ODIR}/${sub}/${ses}/anat/*.nii.gz
		mv ${ODIR}/${sub}/${ses}/anat/*.nii ${ODIR}/${sub}/${ses}/anat/${sub}_${ses}_T1w.nii
		rm -f ${ODIR}/${sub}/${ses}/anat/*.dcm
		echo -e "${sub}${ses}" >> ${savetofile}
				
	done
	fi
done
