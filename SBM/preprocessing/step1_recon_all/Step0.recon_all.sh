#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=recon-all
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=1
#SBATCH --time=30:00:00
# SBATCH --mail-user=<your.email>@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=END
#
# Two modes:
#   1) Login / interactive (no SLURM_ARRAY_TASK_ID): read config with jq, optionally refresh
#      recon lists (same logic as legacy check_output_recon.sh), then submit array jobs.
#   2) Inside array task: run recon-all for one subject.
#
# Usage (submitter):
#   export CONFIG_FILE=/path/to/config_hpc.json   # optional
#   bash Step0.recon_all.sh
#
# Refresh lists only (no sbatch), same as old check_output_recon.sh:
#   export RECON_CHECK_ONLY=1
#   bash Step0.recon_all.sh
#
# Skip regenerating sub_to_recon.txt etc.:
#   export SKIP_CHECK_OUTPUT=1
#
# Skip building ses_subject_use.txt from subject_use.txt (longitudinal only):
#   export SKIP_MAKE_SES_LIST=1
#
# Only build ses_subject_use.txt (no check_output, no sbatch):
#   export RECON_MAKE_SES_ONLY=1
#   bash Step0.recon_all.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

# Build ses_subject_use.txt from subject_use.txt: one line per subject, subjid + first ses-* dir name.
# Legacy make_ses_list.sh used the first session under each subject folder.
# Args: DATA_ROOT, DATASET
make_ses_list_for_dataset() {
    local DATA_ROOT="$1"
    local DATASET="$2"
    local BASE="${DATA_ROOT}/${DATASET}"
    local out="${BASE}/ses_subject_use.txt"
    local subjlist="${BASE}/subject_use.txt"

    if [ ! -f "$subjlist" ]; then
        echo "Warning: subject_use.txt not found — cannot build ses_subject_use.txt for ${DATASET}"
        return 1
    fi

    rm -f "$out"

    while IFS= read -r sub || [ -n "$sub" ]; do
        sub=$(echo "$sub" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$sub" ] && continue
        local subdir="${BASE}/${sub}"
        if [ ! -d "$subdir" ]; then
            echo "Warning: subject directory missing, skip: $subdir"
            continue
        fi
        local sesdir
        sesdir=$(find "$subdir" -maxdepth 1 -type d -name 'ses-*' 2>/dev/null | sort -V | head -1)
        if [ -z "$sesdir" ]; then
            echo "Warning: no ses-* directory under $subdir — skip"
            continue
        fi
        local ses
        ses=$(basename "$sesdir")
        printf "\n%s%s" "$sub" "$ses" >> "$out"
    done < "$subjlist"

    echo "Updated ${out}"
    return 0
}

# Refresh sub_to_recon.txt (and related txt files) from FreeSurfer outputs + BIDS anat.
# Args: DATA_ROOT, DATASET, SBM_RECON_LONGITUDINAL (1 = use ses_subject_use.txt + session lines)
check_output_recon_one_dataset() {
    local DATA_ROOT="$1"
    local DATASET="$2"
    local long="$3"

    local BASE="${DATA_ROOT}/${DATASET}"
    local freesurferDir="${BASE}/derivatives/freesurfer"

    rm -f "${BASE}/sub_without_recon_err.txt"
    rm -f "${BASE}/sub_with_recon_output.txt"
    rm -f "${BASE}/sub_to_recon.txt"
    rm -f "${BASE}/ses_sub_with_recon_output.txt"

    if [ "$long" = "1" ]; then
        local SUBJLIST="${BASE}/ses_subject_use.txt"
        if [ ! -f "$SUBJLIST" ]; then
            echo "Warning: ses_subject_use.txt not found — skip check_output for ${DATASET}"
            return 1
        fi
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [ -z "$line" ] && continue
            local ses=${line: -5}
            local subj=${line:0:${#line}-5}

            if [ ! -f "${freesurferDir}/${subj}/scripts/recon-all.error" ] && \
               [ -f "${BASE}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii" ]; then
                printf "\n%s" "${subj}" >> "${BASE}/sub_without_recon_err.txt"
            fi

            if [ -f "${freesurferDir}/${subj}/surf/lh.thickness.fwhm10.fsaverage.mgh" ] && \
               [ -f "${BASE}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii" ]; then
                printf "\n%s" "${subj}" >> "${BASE}/sub_with_recon_output.txt"
                printf "\n%s%s" "${subj}" "${ses}" >> "${BASE}/ses_sub_with_recon_output.txt"
            fi

            if [ ! -f "${freesurferDir}/${subj}/surf/lh.thickness.fwhm10.fsaverage.mgh" ] && \
               [ -f "${BASE}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii" ]; then
                printf "\n%s%s" "${subj}" "${ses}" >> "${BASE}/sub_to_recon.txt"
            fi
        done < "$SUBJLIST"
    else
        local SUBJLIST="${BASE}/subject_use.txt"
        if [ ! -f "$SUBJLIST" ]; then
            echo "Warning: subject_use.txt not found — skip check_output for ${DATASET}"
            return 1
        fi
        while IFS= read -r subj || [ -n "$subj" ]; do
            subj=$(echo "$subj" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [ -z "$subj" ] && continue
            local subject=$subj

            if [ ! -f "${freesurferDir}/${subject}/scripts/recon-all.error" ] && \
               [ -f "${BASE}/${subj}/anat/${subj}_T1w.nii" ]; then
                printf "\n%s" "${subj}" >> "${BASE}/sub_without_recon_err.txt"
            fi

            if [ -f "${freesurferDir}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh" ] && \
               [ -f "${BASE}/${subj}/anat/${subj}_T1w.nii" ]; then
                printf "\n%s" "${subj}" >> "${BASE}/sub_with_recon_output.txt"
            fi

            if [ ! -f "${freesurferDir}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh" ] && \
               [ -f "${BASE}/${subj}/anat/${subj}_T1w.nii" ]; then
                printf "\n%s" "${subj}" >> "${BASE}/sub_to_recon.txt"
            fi
        done < "$SUBJLIST"
    fi
    return 0
}

# ---------- Mode 1: submit array jobs from config ----------
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
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

    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required to parse the config file."
        exit 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Configuration file not found: $CONFIG_FILE"
        exit 1
    fi

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    if [ -z "$DATA_ROOT" ] || [ "$DATA_ROOT" = "null" ]; then
        echo "Error: Could not read data_directories.dataset_root from $CONFIG_FILE"
        exit 1
    fi

    ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true and (.value.sbm_recon != false)) | .key' "$CONFIG_FILE")
    if [ -z "$ENABLED_DATASETS" ]; then
        echo "Error: No enabled datasets for SBM recon (set sbm_recon: false on datasets to skip)."
        exit 1
    fi

    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
    if [ -z "$HPC_ENABLED_RAW" ] || [ "$HPC_ENABLED_RAW" = "null" ]; then
        echo "Error: Could not read execution_mode.hpc_enabled from $CONFIG_FILE"
        exit 1
    fi

    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
        1|true) HPC_ENABLED="1" ;;
        0|false) HPC_ENABLED="0" ;;
        *)
            echo "Error: Invalid execution_mode.hpc_enabled: $HPC_ENABLED_RAW"
            exit 1
            ;;
    esac

    export DATA_ROOT HPC_ENABLED CONFIG_FILE

    echo "Data root: $DATA_ROOT"
    echo "HPC_ENABLED: $HPC_ENABLED"
    echo "SBM recon datasets:"
    echo "$ENABLED_DATASETS"

    CHECK_ONLY="$(echo "${RECON_CHECK_ONLY:-0}" | tr '[:upper:]' '[:lower:]')"
    case "$CHECK_ONLY" in 1|true|yes) CHECK_ONLY=1 ;; *) CHECK_ONLY=0 ;; esac

    MAKE_SES_ONLY="$(echo "${RECON_MAKE_SES_ONLY:-0}" | tr '[:upper:]' '[:lower:]')"
    case "$MAKE_SES_ONLY" in 1|true|yes) MAKE_SES_ONLY=1 ;; *) MAKE_SES_ONLY=0 ;; esac

    while IFS= read -r DATASET; do
        [ -z "$DATASET" ] && continue
        echo ""
        echo "=== Dataset: $DATASET ==="

        DATASET_DIR="$DATA_ROOT/$DATASET"
        if [ ! -d "$DATASET_DIR" ]; then
            echo "Warning: skipping missing directory: $DATASET_DIR"
            continue
        fi

        LONG_RAW=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
        case "$(echo "$LONG_RAW" | tr '[:upper:]' '[:lower:]')" in
            1|true) SBM_RECON_LONGITUDINAL="1" ;;
            *) SBM_RECON_LONGITUDINAL="0" ;;
        esac

        if [ "$SBM_RECON_LONGITUDINAL" = "1" ] && [ "${SKIP_MAKE_SES_LIST:-0}" != "1" ]; then
            echo "Building ses_subject_use.txt from subject_use.txt (first ses-* per subject)..."
            make_ses_list_for_dataset "$DATA_ROOT" "$DATASET" || true
        elif [ "$SBM_RECON_LONGITUDINAL" = "1" ]; then
            echo "SKIP_MAKE_SES_LIST=1 — leaving ses_subject_use.txt unchanged."
        fi

        if [ "$MAKE_SES_ONLY" = "1" ]; then
            echo "RECON_MAKE_SES_ONLY — not running check_output or sbatch for this dataset."
            continue
        fi

        if [ "${SKIP_CHECK_OUTPUT:-0}" != "1" ]; then
            echo "Running check_output (rebuild sub_to_recon lists)..."
            check_output_recon_one_dataset "$DATA_ROOT" "$DATASET" "$SBM_RECON_LONGITUDINAL" || true
        else
            echo "SKIP_CHECK_OUTPUT=1 — not rebuilding lists."
        fi

        if [ "$CHECK_ONLY" = "1" ]; then
            echo "RECON_CHECK_ONLY — not submitting jobs for this dataset."
            continue
        fi

        SUBJECT_LIST=$(jq -r --arg ds "$DATASET" '.datasets[$ds].recon_subject_list // .datasets[$ds].sbm_recon_subject_list // empty' "$CONFIG_FILE")
        if [ -n "$SUBJECT_LIST" ] && [ "$SUBJECT_LIST" != "null" ]; then
            if [[ "$SUBJECT_LIST" != /* ]]; then
                SUBJECT_LIST="$DATASET_DIR/$SUBJECT_LIST"
            fi
        else
            SUBJECT_LIST="$DATASET_DIR/sub_to_recon.txt"
        fi

        if [ ! -f "$SUBJECT_LIST" ]; then
            echo "Warning: recon list not found: $SUBJECT_LIST"
            continue
        fi

        N=$(grep -v '^[[:space:]]*$' "$SUBJECT_LIST" | wc -l | tr -d ' ')
        if [ -z "$N" ] || [ "$N" -eq 0 ]; then
            echo "Warning: empty list: $SUBJECT_LIST"
            continue
        fi

        echo "SUBJECT_LIST=$SUBJECT_LIST  array=1-$N  longitudinal=$SBM_RECON_LONGITUDINAL"

        export DATASET SUBJECT_LIST SBM_RECON_LONGITUDINAL

        sbatch \
            --job-name="recon_${DATASET}" \
            --array="1-${N}" \
            --export=ALL \
            "$STEP_SCRIPT"
    done <<< "$ENABLED_DATASETS"

    echo ""
    if [ "$MAKE_SES_ONLY" = "1" ]; then
        echo "make_ses_list-only finished (config: $CONFIG_FILE)."
    elif [ "$CHECK_ONLY" = "1" ]; then
        echo "Check-only finished (config: $CONFIG_FILE)."
    else
        echo "Submissions finished (config: $CONFIG_FILE)."
    fi
    exit 0
fi

# ---------- Mode 2: array worker (one subject) ----------
if [ -z "${DATA_ROOT:-}" ]; then echo "Error: DATA_ROOT is not set"; exit 1; fi
if [ -z "${DATASET:-}" ]; then echo "Error: DATASET is not set"; exit 1; fi
if [ -z "${SUBJECT_LIST:-}" ]; then echo "Error: SUBJECT_LIST is not set"; exit 1; fi
if [ ! -f "$SUBJECT_LIST" ]; then echo "Error: SUBJECT_LIST not found: $SUBJECT_LIST"; exit 1; fi
if [ -z "${HPC_ENABLED:-}" ]; then echo "Error: HPC_ENABLED is not set"; exit 1; fi

subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SUBJECT_LIST}")
subject=$(echo "$subject" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [ -z "$subject" ]; then
    echo "Error: empty subject at task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

if [ "${SBM_RECON_LONGITUDINAL:-0}" = "1" ] || [ "$(echo "${SBM_RECON_LONGITUDINAL:-0}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    ses=${subject: -5}
    subj=${subject:0:${#subject}-5}
else
    subj=$subject
    ses=""
fi

if [ "$HPC_ENABLED" = "1" ] || [ "$(echo "$HPC_ENABLED" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    echo "Loading FreeSurfer modules (HPC mode enabled)..."
    module purge
    module load freesurfer/7.1.0
else
    echo "Skipping module loading (HPC mode disabled)..."
fi

BIDS_DIR="${DATA_ROOT}/${DATASET}"
export SUBJECTS_DIR="${BIDS_DIR}/derivatives/freesurfer"

if [ ! -d "$SUBJECTS_DIR" ]; then
    mkdir -p "$SUBJECTS_DIR"
    echo "making output directory"
fi
cd "$SUBJECTS_DIR"

if [ -z "$ses" ]; then
    if [ -d "${SUBJECTS_DIR}/${subject}" ]; then
        mv "${SUBJECTS_DIR}/${subject}" "${SUBJECTS_DIR}/err${subject}"
    fi
    recon-all -i "${BIDS_DIR}/${subject}/anat/${subject}_T1w.nii" -s "${subject}" -all -qcache
else
    if [ -d "${SUBJECTS_DIR}/${subj}" ]; then
        mv "${SUBJECTS_DIR}/${subj}" "${SUBJECTS_DIR}/err${subj}"
    fi
    recon-all -i "${BIDS_DIR}/${subj}/${ses}/anat/${subj}_${ses}_T1w.nii" -s "${subj}" -all -qcache
fi

echo "${subject}"
