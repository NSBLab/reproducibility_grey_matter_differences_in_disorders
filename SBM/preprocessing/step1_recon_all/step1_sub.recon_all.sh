#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=recon-all
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=1
#SBATCH --time=30:00:00

# Worker: runs recon-all for a single subject (invoked by step1.recon_all.sh)

if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
    echo "Error: SLURM_ARRAY_TASK_ID not set. Run via step1.recon_all.sh."
    exit 1
fi

subject_done() {
    local sd="$1"
    [ -f "${sd}/scripts/recon-all.log" ]
}

parse_sub_ses() {
    local line="$1"
    if [[ "$line" =~ ^(sub-[^/]+)(ses-[^/]+)$ ]]; then
        subj="${BASH_REMATCH[1]}"
        ses="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SUBJECT_LIST" | xargs)

BASE="${DATA_ROOT}/${DATASET}"
FS_DIR="${BASE}/derivatives/freesurfer"
export SUBJECTS_DIR="$FS_DIR"

if [ "$LONG" = "1" ]; then
    parse_sub_ses "$subject" || exit 1
    fsdir="${FS_DIR}/${subj}"
    t1="${BASE}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii"
    run_id="$subj"
else
    fsdir="${FS_DIR}/${subject}"
    t1="${BASE}/${subject}/anat/${subject}_T1w.nii"
    run_id="$subject"
fi

if subject_done "$fsdir"; then
    echo "Skip $subject (already done)"
    exit 0
fi

if [ "${HPC_ENABLED:-false}" = "true" ]; then
    module purge
    module load freesurfer/7.1.0
fi

mkdir -p "$SUBJECTS_DIR"
cd "$SUBJECTS_DIR"

recon-all -i "$t1" -s "$run_id" -all -qcache
