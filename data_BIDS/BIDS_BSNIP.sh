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


IDIR=/scratch/kg98/Data_Trang/BSNIP2/image03

ODIR=/projects/kg98/trangc/VBM/data/BSNIP2

for DIR in `cat /home/trangc/kg98/trangc/VBM/data/BSNIP2/useFile1.txt`
do

#filename=${DIR:0:11}
#sub=${DIR:11:20}
#echo $filename
#echo $sub
NAMEUNZIP=sub-${DIR:1:7}
mkdir -p ${ODIR}/${NAMEUNZIP}/anat/
unzip ${IDIR}/${DIR} -d ${ODIR}/${NAMEUNZIP}/anat/

dcm2niix -o ${ODIR}/${NAMEUNZIP}/anat/ -f %f ${ODIR}/${NAMEUNZIP}/anat/
gzip -d  ${ODIR}/${NAMEUNZIP}/anat/*.nii.gz
mv ${ODIR}/${NAMEUNZIP}/anat/*.nii ${ODIR}/${NAMEUNZIP}/anat/${NAMEUNZIP}_T1w.nii
rm -f ${ODIR}/${NAMEUNZIP}/anat/*.dcm
rm -f ${ODIR}/${NAMEUNZIP}/anat/*.par
rm -f ${ODIR}/${NAMEUNZIP}/anat/*.rec
done
