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

folder=MultidimCog


IDIR=/projects/kg98/trangc/VBM/data/MultidimCog

ODIR=/projects/kg98/trangc/VBM/data/MultidimCog

for DIR in `cat /projects/kg98/trangc/VBM/data/MultidimCog/subject_use.txt`
do
	if [ ! -f ${ODIR}/${DIR}/anat/${DIR}_T1w.nii ]; then
					unzip ${ODIR}/${DIR}/anat/*.zip -d ${ODIR}/${DIR}/anat/
					dcm2niix -o ${IDIR}/${DIR}/anat/ -f %f ${IDIR}/${DIR}/anat/

				

				gzip -d  ${ODIR}/${DIR}/anat/*.nii.gz
	mv ${ODIR}/${DIR}/anat/*.nii ${ODIR}/${DIR}/anat/${DIR}_T1w.nii
	rm -f ${ODIR}/${DIR}/anat/*.dcm
	rm -f ${ODIR}/${DIR}/anat/*.zip
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.par
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.rec
	fi
done
