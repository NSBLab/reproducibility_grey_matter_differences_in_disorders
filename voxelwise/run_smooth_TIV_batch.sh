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



export script_DIR=/home/trangc/kg98/trangc/VBM/code/voxelwise

module load  spm12/matlab2021a.r7771-v1
#module load  matlab/r2023b

#matlab -nodisplay -r "cd ('$script_DIR');  addpath('/scratch/kg98/trangc/toolbox/spm12'); runGLM_combat_func('$dataset',$isses, $smoothKernel)"
matlab -nodisplay -r "cd ('$script_DIR');  run_smooth_TIV_func('$dataset',$isses, $smoothKernel)"

