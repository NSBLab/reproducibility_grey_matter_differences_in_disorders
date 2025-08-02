#!/bin/bash

IDIR=/scratch/kg98/Data_Trang/miriad
ODIR=/projects/kg98/trangc/VBM/data/miriad

savetofile=/projects/kg98/trangc/VBM/data/miriad/sub_to_recon.txt

for DIR in `cat ${IDIR}/subject_use.txt`
do

	sub=sub-${DIR:7:3}

	ls ${IDIR}/${DIR} > ${IDIR}/temp1.txt #list all the file type

	sesDir=$(head -n 1 ${IDIR}/temp1.txt)
	ses=ses-${sesDir:17:1}
		
			#mkdir -p ${ODIR}/${sub}/${ses}/anat
			#cp ${IDIR}/${DIR}/${sesDir}/${sesDir}.nii ${ODIR}/${sub}/${ses}/anat/${sub}_${ses}_T1w.nii
	echo -e "${sub}${ses}" >> ${savetofile}
				

done
