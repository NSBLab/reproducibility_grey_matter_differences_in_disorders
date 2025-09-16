#!/bin/bash
#SBATCH --time=0-4:00:00
#SBATCH --job-name=parcellate_null_maps
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END



export script_DIR=/home/trangc/kg98/trangc/VBM/code/roi

module load  spm12/matlab2021a.r7771-v1

echo $nulldir

matlab -nodisplay -r "cd ('$script_DIR');  parcellate_null_maps('$diag', '$site', '$nulldir',$nNull)"

