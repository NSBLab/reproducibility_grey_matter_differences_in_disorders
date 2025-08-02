#!/bin/bash
#SBATCH --time=0-05:00:00
#SBATCH --job-name=BIDS
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load fsl
module load mricrogl

folder=ADNI_2


IDIR=/scratch/kg98/Data_Trang/ADNI/${folder}

ODIR=/projects/kg98/trangc/VBM/data/ADNI

for DIR in `cat /home/trangc/kg98_scratch/Data_Trang/ADNI/${folder}/list.txt`
do

NAMEUNZIP=sub-${DIR}

ls ${IDIR}/${DIR} > ${IDIR}/temp1.txt #list all the file type

	for imageDes in `cat ${IDIR}/temp1.txt`
	do

		ls ${IDIR}/${DIR}/${imageDes} > ${IDIR}/temp2.txt #list all the sessions

		for ses in `cat ${IDIR}/temp2.txt`
		do
		
			ls ${IDIR}/${DIR}/${imageDes}/${ses} > ${IDIR}/temp3.txt #list all the scans

			mkdir -p ${ODIR}/${NAMEUNZIP}/${ses}/anat/

			for scan in `cat ${IDIR}/temp3.txt`
			do

				if [ ! -f ${ODIR}/${NAMEUNZIP}/${ses}/anat/${scan}.json ]
        			then
					dcm2niix -o ${ODIR}/${NAMEUNZIP}/${ses}/anat/ -f %f ${IDIR}/${DIR}/${imageDes}/${ses}/${scan}/
				fi


				

				#gzip -d  ${ODIR}/${NAMEUNZIP}/anat/*.nii.gz
#mv ${ODIR}/${NAMEUNZIP}/anat/*.nii ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.dcm
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.par
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.rec
			done
		done
	done
done
