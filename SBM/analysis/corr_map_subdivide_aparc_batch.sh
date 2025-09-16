#!/bin/bash
#SBATCH --time=0-8:10:00
# SBATCH --job-name=glm
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load  matlab/r2023b
export script_DIR=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step4_qdec
matlab -nodisplay -r "addpath('$script_DIR');  				corr_map_subdivide_aparc_func($diag,'$dividemode');quit"


