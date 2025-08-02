#!/bin/bash
#SBATCH --job-name=COMBAT_run
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
# SBATCH --partition=genomics
# SBATCH --qos=irq
#S BATCH --time=0:12:00
#SBATCH --time=20:05:00
#SBATCH --mail-user=ashlea.segal@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
# SBATCH --mem-per-cpu=4096
#SBATCH --mem=240000

# ACtivate anaconda environment
#. /usr/local/anaconda/5.1.0-Python3.6-gcc5/etc/profile.d/conda.sh
#conda activate /scratch/kg98/Ashlea/virtual_envs/neighbourhood_deformation

source /scratch/kg98/trangc/miniconda/bin/activate
#conda activate /fs02/kg98/trangc/NARPS/orig/ds001734/conda_dir/miniconda/conda/envs/myPythonEnv 
#
script_dir=/home/trangc/kg98/trangc/VBM/code

if [ "$surface" -eq 1 ]; then 
python ${script_dir}/COMBAT_surface_run.py "${smoothKernel}" "${maskDiag}" "${hemi}" 
else
python ${script_dir}/COMBAT_run.py "${smoothKernel}" "${maskDiag}" 
fi
