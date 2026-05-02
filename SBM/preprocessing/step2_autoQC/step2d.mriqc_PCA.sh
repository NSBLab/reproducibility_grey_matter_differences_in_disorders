#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=semiautoQC
#SBATCH --time=3:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

DATASET=OASIS3

code_dir=/projects/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step1_autoQC # path to mriqc_PCA.py
source ~/kg98/aholmes/python-3.8.7_venv/bin/activate # path to python venv
python ${code_dir}/Step1d.mriqc_PCA.py /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC/group_T1w.tsv /projects/kg98/trangc/VBM/data/${DATASET}/derivatives/MRIQC


# required python packages: numpy pandas scipy sklearn matplotlib argparse

# NOTE: this will return a list of subjects that failed the mriqc PCA check, but you'll still need to check the euler numbers for each subject/each hemisphere to get your list of subjects that failed euler checks
