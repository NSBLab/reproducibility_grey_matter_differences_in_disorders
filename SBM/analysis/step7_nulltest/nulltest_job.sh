#!/bin/bash
#SBATCH --time=0-08:00:05
#SBATCH --job-name=MBM
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step5_nulltest

module load matlab/r2023b

matlab -nodisplay -r "cd ('$script_DIR');  nulltest($iCOMBAT, '$hemi', $smoothKernel, $nTrap, $inJob);quit"

