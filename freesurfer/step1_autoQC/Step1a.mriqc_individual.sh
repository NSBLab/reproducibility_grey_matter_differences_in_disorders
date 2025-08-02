#!/bin/env bash
#SBATCH --job-name=MRIQC_individualMyelin
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=0-1:00:00
#SBATCH --gres=gpu:P4:1
# SBATCH --mail-user=<your.email>@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --qos=normal
#SBATCH -A kg98
#SBATCH --array=1-88
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90

# NOTE: this dataset needs to be BIDS formatted AND your sublist text file should have the sub- prefix omitted (e.g., sub-0001 should just be 0001)
DATASET=Determinant
#SESSION=1 #having multiple sessions or not
SUBJECT_LIST="/fs04/kg98/trangc/VBM/data/${DATASET}/sub_to_runMRIQC.txt"

# Set number of subjects (manually or by counting lines in file)
N_SUBJECTS=$(wc -l < "$SUBJECT_LIST")

# Loop over each subject
#for SLURM_ARRAY_TASK_ID in $(seq 1 "$N_SUBJECTS"); do
    
	#SLURM_ARRAY_TASK_ID=1
	subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
	echo -e "\t\t\t --------------------------- "
	echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
	echo -e "\t\t\t --------------------------- \n"

	#set paths
	BIDS_DIR=/fs04/kg98/trangc/VBM/data/${DATASET}
	OUT_DIR=${BIDS_DIR}/derivatives/MRIQC
	WORK_DIR=/fs04/kg98/trangc/VBM/code/freesurfer/freesurfer_holmesQC/step1_autoQC/work/${DATASET}

	if [ ! -d $OUT_DIR ]; then mkdir $OUT_DIR; echo "making output directory"; fi
	if [ ! -d $WORK_DIR ]; then mkdir $WORK_DIR; echo "making work directory"; fi

	#load MRIQC
	module purge
	module load mriqc/0.15.2.rc1.1 #mriqc/0.15.2.rc1

	#run MRIQC for single subject analysis
	if [ -z "$SESSION" ]
	then
	mriqc $BIDS_DIR $OUT_DIR participant --participant_label ${subject} --n_procs 12 --n_cpus 6 --mem_gb 12 -m T1w --work-dir $WORK_DIR

	#mriqc -v $BIDS_DIR $OUT_DIR participant --participant_label ${subject} --n_procs 12 --n_cpus 6 --mem_gb 12 --hmc-fsl -m T1w --correct-slice-timing --work-dir $WORK_DIR
	else
	ses=${subject: -1}
	subj=${subject:0:${#subject}-5}
	mriqc -v $BIDS_DIR $OUT_DIR participant --participant_label ${subj} --session-id ${ses} --n_procs 12 --n_cpus 6 --mem_gb 12 --hmc-fsl -m T1w --correct-slice-timing --work-dir $WORK_DIR
	fi

	# --------------------------------------------------------------------------------------------------

	echo -e "\t\t\t ----- DONE ----- "
#done
