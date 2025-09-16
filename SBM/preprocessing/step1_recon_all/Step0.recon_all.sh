#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=recon-OAISS4
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=1
#SBATCH --time 30:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --array=1-255
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-999

DATASET=OASIS4
SUBJECT_LIST="/projects/kg98/trangc/VBM/data/${DATASET}/sub_to_recon.txt"

#SLURM_ARRAY_TASK_ID=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

#comment if not have sessions
ses=${subject: -5}
subj=${subject:0:${#subject}-5}


module purge
module load freesurfer/7.1.0

BIDS_DIR=/projects/kg98/trangc/VBM/data/${DATASET}
export SUBJECTS_DIR=${BIDS_DIR}/derivatives/freesurfer

if [ ! -d $SUBJECTS_DIR ]
then 
	mkdir -p $SUBJECTS_DIR
	echo "making output directory"
fi
cd $SUBJECTS_DIR
	
	if [ -z "$ses" ]
	then
		mv ${SUBJECTS_DIR}/${subject} ${SUBJECTS_DIR}/err${subject}
		recon-all -i ${BIDS_DIR}/${subject}/anat/${subject}_T1w.nii -s ${subject} -all -qcache
	else	
		mv ${SUBJECTS_DIR}/${subj} ${SUBJECTS_DIR}/err${subj}
		recon-all -i ${BIDS_DIR}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii -s ${subj} -all -qcache

		
	fi

echo ${subject}
