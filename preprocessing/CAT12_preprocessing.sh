#!/bin/bash
#SBATCH --time=0-04:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END


if [ -z "$ses" ]
then
gzip -d /home/trangc/kg98/trangc/VBM/data/${DATASET}/${i}/anat/${i}_T1w.nii.gz
export T1_name=/home/trangc/kg98/trangc/VBM/data/${DATASET}/${i}/anat/${i}_T1w.nii
else
export T1_name=/home/trangc/kg98/trangc/VBM/data/${DATASET}/${i}/${ses}/anat/${i}_${ses}_T1w.nii
fi

#export SPM_path=/home/trangc/kg98/trangc/Software/spm12
export script_DIR=/home/trangc/kg98/trangc/VBM/code/preprocessing

module load  spm12/matlab2021a.r7771-v1
#module load spm12/matlab2018a.r7487 

matlab -nodisplay -r "cd ('$script_DIR');   CAT12_preprocessing_job('$T1_name')"

