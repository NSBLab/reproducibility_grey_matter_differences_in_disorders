#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=recon-all
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=1
#SBATCH --time=30:00:00

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

# ---------- simple completion check ----------
subject_done() {
    local sd="$1"
    #[ -f "${sd}/surf/lh.thickness.fwhm10.fsaverage.mgh" ]
    [ -f "${sd}/scripts/recon-all.log" ]
}

# ---------- parse longitudinal: sub + ses ----------
parse_sub_ses() {
    local line="$1"
    if [[ "$line" =~ ^(sub-[^/]+)(ses-[^/]+)$ ]]; then
        subj="${BASH_REMATCH[1]}"
        ses="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

# ---------- LOGIN MODE ----------
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then

        # Resolve CONFIG_FILE from env or sensible defaults
    if [ -z "$CONFIG_FILE" ]; then
        REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
        if [ -f "$REPO_ROOT/config_hpc.json" ]; then
            CONFIG_FILE="$REPO_ROOT/config_hpc.json"
        elif [ -f "$REPO_ROOT/config.json" ]; then
            CONFIG_FILE="$REPO_ROOT/config.json"
        elif [ -f "config_hpc.json" ]; then
            CONFIG_FILE="config_hpc.json"
        elif [ -f "config.json" ]; then
            CONFIG_FILE="config.json"
        else
            echo "Error: CONFIG_FILE not set and no default config found."
            echo "Checked: $REPO_ROOT/config_hpc.json, $REPO_ROOT/config.json, ./config_hpc.json, ./config.json"
            exit 1
        fi
    fi

    echo "Using CONFIG_FILE: $CONFIG_FILE"

    if ! command -v jq >/dev/null; then
        echo "Need jq"; exit 1
    fi

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    DATASETS=$(jq -r '.datasets | keys[]' "$CONFIG_FILE")

    for DATASET in $DATASETS; do
        echo "=== $DATASET ==="

        BASE="${DATA_ROOT}/${DATASET}"
        FS_DIR="${BASE}/derivatives/freesurfer}"

        LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
        [[ "$LONG" == "true" ]] && LONG=1 || LONG=0

        LIST_IN="${BASE}/subject_use.txt"
        [ "$LONG" = "1" ] && LIST_IN="${BASE}/ses_subject_use.txt"

        OUT_LIST="${BASE}/sub_to_recon.txt"
        rm -f "$OUT_LIST"

        while read -r line; do
            line=$(echo "$line" | xargs)
            [ -z "$line" ] && continue

            if [ "$LONG" = "1" ]; then
                parse_sub_ses "$line" || continue
                fsdir="${FS_DIR}/${subj}"
                t1="${BASE}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii"
                out="${subj}${ses}"
            else
                fsdir="${FS_DIR}/${line}"
                t1="${BASE}/${line}/anat/${line}_T1w.nii"
                out="$line"
            fi

            if [ -f "$t1" ] && ! subject_done "$fsdir"; then
                echo "$out" >> "$OUT_LIST"
            fi

        done < "$LIST_IN"

        N=$(grep -c . "$OUT_LIST" 2>/dev/null || echo 0)

        if [ "$N" -eq 0 ]; then
            echo "Nothing to run"
            continue
        fi

        echo "Submitting $N jobs"

        export DATA_ROOT DATASET SUBJECT_LIST="$OUT_LIST" LONG

        sbatch --array=1-"$N" "$STEP_SCRIPT"
    done

    exit 0
fi

# ---------- WORKER MODE ----------
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SUBJECT_LIST" | xargs)

BASE="${DATA_ROOT}/${DATASET}"
FS_DIR="${FREESURFER_SUBJECTS_DIR:-${BASE}/derivatives/freesurfer}"
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

module purge
module load freesurfer/7.1.0

mkdir -p "$SUBJECTS_DIR"
cd "$SUBJECTS_DIR"

recon-all -i "$t1" -s "$run_id" -all -qcache