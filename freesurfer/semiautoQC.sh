#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=semiautoQC
#SBATCH --time=3:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

export DATASET=SRPBS

code_dir=/home/trangc/kg98/trangc/VBM/code/freesurfer

source /scratch/kg98/trangc/miniconda/bin/activate
conda activate /fs02/kg98/trangc/NARPS/orig/ds001734/conda_dir/miniconda/conda/envs/myPythonEnv 

python ${code_dir}/semiautoQC.py

