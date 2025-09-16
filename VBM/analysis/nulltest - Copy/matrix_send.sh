#!/bin/bash
#SBATCH --time=5-1:00:00
#SBATCH --job-name=distan_mat
#SBATCH --account=kg98
#SBATCH --cpus-per-task=13
#SBATCH --mem=240000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

module load conda-install
source /home/trangc/kg98_scratch2/trangc/miniconda3/bin/activate

conda activate trangcenv

#python /projects/kg98/trangc/VBM/code/nulltest/pythonProject/matrix_midthickness.py
python /projects/kg98/trangc/VBM/code/nulltest/pythonProject/matrix_volume.py

