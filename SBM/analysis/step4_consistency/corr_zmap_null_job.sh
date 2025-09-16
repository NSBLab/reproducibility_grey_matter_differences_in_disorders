#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec

module load  matlab/r2023b

matlab -nodisplay -r "addpath('$script_DIR');  corr_zmap_null_func(${iNull},${iCOMBAT},'${hemi}', ${smoothKernel}); quit"


