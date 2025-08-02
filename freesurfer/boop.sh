#!/bin/env bash

#SBATCH --job-name=MRIQC
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2-00:00:00
# SBATCH --mail-user=trang.cao@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=80000
#SBATCH --qos=normal
#SBATCH -A kg98
#SBATCH --array=1-1
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90

SUBJECT_LIST="/home/trangc/kg98/trangc/VBM/data/Atypical/subject_dems1.txt"

#SLURM_ARRAY_TASK_ID=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

#set paths
PROJ_DIR=/home/trangc/kg98/trangc/VBM/data/Atypical
BIDS_DIR=$PROJ_DIR
OUT_DIR=$PROJ_DIR/freesurfer/mriqc
WORK_DIR=$PROJ_DIR/freesurfer/work

#load MRIQC
module purge
module load mriqc/0.15.2.rc1

#run MRIQC for single subject analysis 

mriqc -v $BIDS_DIR $OUT_DIR participant \
--participant_label $subject \
--n_procs 12 \
--n_cpus 6 \
--mem_gb 12 \
--hmc-fsl \
-m T1w \
--correct-slice-timing \
--work-dir $WORK_DIR 

# --------------------------------------------------------------------------------------------------

echo -e "\t\t\t ----- DONE ----- "

