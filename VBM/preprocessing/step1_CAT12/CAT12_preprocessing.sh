#!/bin/bash
#SBATCH --time=0-4:00:00
#SBATCH --account=kg98
#SBATCH --job-name=CAT12_Preprocessing
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END


if [ -z "$DATA_ROOT" ]; then
echo "Error: DATA_ROOT is not set. Please run via CAT12_preprocessing_send.sh"; exit 1; fi

if [ -z "$ses" ]
then
export T1_name=$DATA_ROOT/${DATASET}/${i}/anat/${i}_T1w.nii
else
export T1_name=$DATA_ROOT/${DATASET}/${i}/${ses}/anat/${i}_${ses}_T1w.nii
fi

module unload matlab
module load  spm12/matlab2021a.r7771-v1

matlab -nodisplay -r "cd ('$SCRIPT_DIR');   CAT12_preprocessing_job('$T1_name')"

