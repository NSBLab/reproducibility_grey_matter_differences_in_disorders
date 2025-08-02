#!/bin/bash
#SBATCH --time=2-12:00:00
#SBATCH --job-name=parcellate
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=16000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END


export script_DIR=/home/trangc/kg98/trangc/VBM/code/roi

module load matlab/r2023b

matlab -nodisplay -r "cd ('$script_DIR');  addpath('/scratch/kg98/trangc/toolbox/spm12'); parcellate_maps('$dataset',$isses);quit"

