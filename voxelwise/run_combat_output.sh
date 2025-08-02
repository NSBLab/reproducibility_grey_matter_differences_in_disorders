#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=combatoutput
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=240000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END



export script_DIR=/home/trangc/kg98/trangc/VBM/code/voxelwise

module load  matlab/r2023b

matlab -nodisplay -r "cd ('$script_DIR');  combat_output"

