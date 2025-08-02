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

folder=Harmonisation


IDIR=/projects/kg98/trangc/VBM/data/Harmonisation

ODIR=/projects/kg98/trangc/VBM/data/Harmonisation

for DIR in `cat /projects/kg98/trangc/VBM/data/Harmonisation/subject_use1.txt`
do
	if [ ! -f ${ODIR}/${DIR}/ses-1/anat/${DIR}_T1w.nii ]; then
					#unzip ${ODIR}/${DIR}/ses-1/anat/*.zip -d ${ODIR}/${DIR}/ses-1/anat/
					ls -d ${ODIR}/${DIR}/ses-1/anat/ > temp.txt
					
					# Set IFS to newline to process each folder name as a full line, even if it contains spaces
					IFS=$'\n'
					for SUBDIR in `cat temp.txt`
					do
					
					#dcm2niix -o ${IDIR}/${DIR}/ses-1/anat/$SUBDIR -f %f ${IDIR}/${DIR}/ses-1/anat/

					heaviest_file=$(find . -type f -wholename "$SUBDIR/*.nii.gz" -exec du -b {} + | sort -n | tail -n 1 | awk '{print $2}')

					echo ${heaviest_file}
				#gzip -d  $heaviest_file
				#mv ${ODIR}/${DIR}/ses-1/anat/$SUBDIR/*.nii ${ODIR}/${DIR}/ses-1/anat/${DIR}_T1w.nii
	#rm -f ${ODIR}/${DIR}/ses-1/anat/*.dcm
	#rm -f ${ODIR}/${DIR}/ses-1/anat/*.zip
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.par
#rm -f ${ODIR}/${NAMEUNZIP}/anat/*.rec
done
	fi
done
