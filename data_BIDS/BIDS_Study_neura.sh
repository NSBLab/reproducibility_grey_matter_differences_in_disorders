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

IDIR=/scratch/kg98/Data_Trang/SCZ_Study_Neural_Psychological/image03/ni/rdocZips

ODIR=/projects/kg98/trangc/VBM/data/Study_neura

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/Study_neura/useFile1.txt`
do


sub=${DIR:0:12}
ses=${DIR:12:5}
filename=${DIR:17:35}

mkdir -p ${ODIR}/${sub}/${ses}/anat/

unzip ${IDIR}/${filename} -d ${ODIR}/${sub}/${ses}/anat/

dcm2niix -o ${ODIR}/${sub}/${ses}/anat/ -f %f ${ODIR}/${sub}/${ses}/anat/

#rm -f ${ODIR}/${sub}/anat/*.nii

gzip -d ${ODIR}/${sub}/${ses}/anat/*.nii.gz

mv ${ODIR}/${sub}/${ses}/anat/*.nii ${ODIR}/${sub}/${ses}/anat/${sub}_${ses}_T1w.nii
rm -f ${ODIR}/${sub}/${ses}/anat/*.dcm
done

# find . -name \*.dcm -type f -delete


