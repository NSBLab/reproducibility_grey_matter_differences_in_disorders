#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END



export script_DIR=/projects/kg98/trangc/VBM/code/voxelwise

module load  matlab/r2023b

matlab -nodisplay -r "addpath('$script_DIR');  addpath('/scratch/kg98/trangc/toolbox/spm12'); run_resample_match_func($smoothKernel,$sampleSize,$iResample,$randomNumber)"

