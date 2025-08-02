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


IDIR=/scratch/kg98/Data_Trang/BD_PARDIP/image03

ODIR=/projects/kg98/trangc/VBM/data/PARDIP

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/PARDIP/useFile.txt`
do


	sub=${DIR:0:9}
	filename=${DIR:9:21}
	folder=${DIR:9:-4}

	if [ ! -f ${ODIR}/${sub}/anat/${sub}_T1w.nii ] ; then 

		echo ${sub}

		#cp ${IDIR}/${filename} ${ODIR} # copy zip file to data folder, unzip command has error so use right click to unzip all and then change the folder name

		mkdir -p ${ODIR}/${sub}/anat/
		mv ${ODIR}/${folder}/* ${ODIR}/${sub}/anat/
		
		
		dcm2niix -o ${ODIR}/${sub}/anat/ -f %f ${ODIR}/${sub}/anat/

		gzip -d ${ODIR}/${sub}/anat/*.nii.gz

		mv ${ODIR}/${sub}/anat/anat.nii ${ODIR}/${sub}/anat/${sub}_T1w.nii
		#rm -f ${ODIR}/${sub}/anat/*.dcm
		#rm -f ${ODIR}/${sub}/anat/*.par
		#rm -f ${ODIR}/${sub}/anat/*.rec
		#rm -f ${ODIR}/${sub}/anat/*.txt
	fi

done

# find . -name \*.dcm -type f -delete


