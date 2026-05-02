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
# Login node (no SLURM_ARRAY_TASK_ID):
#   1) Read CONFIG_FILE — DATA_ROOT, enabled SBM datasets, longitudinal per dataset.
#   2) Build / refresh recon lists by scanning FreeSurfer + BIDS (same rules as check_output_recon.sh):
#        sub_without_recon_err.txt, sub_with_recon_output.txt, sub_to_recon.txt
#        (+ ses_sub_with_recon_output.txt if longitudinal).
#      Only subjects missing lh.thickness.fwhm10.fsaverage.mgh but with T1w go into sub_to_recon.txt.
#      Longitudinal: requires ses_subject_use.txt from BIDS (e.g. BIDS_Myelin.m), or BUILD_SES_SUBJECT_USE=1.
#   3) sbatch array jobs read sub_to_recon.txt only.
#
# Optional:
#   RECON_LISTS_ONLY=1   Only step (1)+(2), no sbatch.
#   SKIP_BUILD_LISTS=1   Skip (2), use existing sub_to_recon.txt for (3).
#
# Worker: skips recon-all if thickness output already exists (no redundant run).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

parse_longitudinal_subject_session() {
    local line="$1"
    if [[ "$line" =~ ^(.+)(ses-.+)$ ]]; then
        _SUBJ_PARSE="${BASH_REMATCH[1]}"
        _SES_PARSE="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

# Fallback if BIDS did not create ses_subject_use.txt
make_ses_subject_use() {
    local BASE="$1"
    local subjlist="${BASE}/subject_use.txt"
    local out="${BASE}/ses_subject_use.txt"
    if [ ! -f "$subjlist" ]; then
        echo "Error: missing $subjlist"
        return 1
    fi
    rm -f "$out"
    while IFS= read -r sub || [ -n "$sub" ]; do
        sub=$(echo "$sub" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$sub" ] && continue
        local subdir="${BASE}/${sub}"
        [ ! -d "$subdir" ] && echo "Warning: skip $subdir" && continue
        local sesdir
        sesdir=$(find "$subdir" -maxdepth 1 -type d -name 'ses-*' 2>/dev/null | sort -V | head -1)
        [ -z "$sesdir" ] && echo "Warning: no ses-* under $subdir" && continue
        printf "\n%s%s" "$sub" "$(basename "$sesdir")" >> "$out"
    done < "$subjlist"
    echo "Wrote $out"
}

# Same logic as legacy check_output_recon.sh; paths from DATA_ROOT / DATASET.
# long=1 → session mode (ses_subject_use.txt lines are subjid + ses-*).
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
            echo "Error: $SUBJLIST not found (create via BIDS or BUILD_SES_SUBJECT_USE=1)"
            return 1
        fi
        while IFS= read -r line || [ -n "$line" ]; do
            line=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [ -z "$line" ] && continue
            if ! parse_longitudinal_subject_session "$line"; then
                echo "Warning: skip unparseable line: $line"
                continue
            fi
            local ses="${_SES_PARSE}"
            local subj="${_SUBJ_PARSE}"

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
            echo "Error: missing $SUBJLIST"
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

    touch "${BASE}/sub_to_recon.txt"
    local need_cnt
    need_cnt=$(grep -v '^[[:space:]]*$' "${BASE}/sub_to_recon.txt" | wc -l | tr -d ' ')
    echo "${DATASET}: check_output → ${need_cnt} subject line(s) need recon (sub_to_recon.txt)"
    return 0
}

# Ensure ses list exists, then run FreeSurfer/BIDS scan → sub_to_recon.txt
# Args: DATA_ROOT, DATASET, longitudinal(0|1)
build_sub_to_recon_for_dataset() {
    local DATA_ROOT="$1"
    local DATASET="$2"
    local long="$3"

    local BASE="${DATA_ROOT}/${DATASET}"

    if [ "$long" = "1" ]; then
        if [ ! -f "${BASE}/ses_subject_use.txt" ]; then
            if [ "${BUILD_SES_SUBJECT_USE:-0}" = "1" ]; then
                echo "${DATASET}: building ses_subject_use.txt from subject_use.txt"
                make_ses_subject_use "$BASE" || return 1
            else
                echo "Error: ${BASE}/ses_subject_use.txt missing (BIDS e.g. BIDS_Myelin.m or BUILD_SES_SUBJECT_USE=1)"
                return 1
            fi
        else
            echo "${DATASET}: using ses_subject_use.txt from BIDS (or existing)"
        fi
    else
        if [ ! -f "${BASE}/subject_use.txt" ]; then
            echo "Error: missing ${BASE}/subject_use.txt"
            return 1
        fi
    fi

    check_output_recon_one_dataset "$DATA_ROOT" "$DATASET" "$long" || return 1
}

# ---------- Mode 1: login ----------
if [ -z "${SLURM_ARRAY_TASK_ID:-}" ]; then
    if [ -z "${CONFIG_FILE:-}" ]; then
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
            echo "Error: set CONFIG_FILE or place config_hpc.json in repo root."
            exit 1
        fi
    fi

    echo "Using CONFIG_FILE: $CONFIG_FILE"

    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq required."
        exit 1
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: config not found: $CONFIG_FILE"
        exit 1
    fi

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    if [ -z "$DATA_ROOT" ] || [ "$DATA_ROOT" = "null" ]; then
        echo "Error: data_directories.dataset_root missing"
        exit 1
    fi

    ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true and (.value.sbm_recon != false)) | .key' "$CONFIG_FILE")
    if [ -z "$ENABLED_DATASETS" ]; then
        echo "Error: no enabled SBM datasets"
        exit 1
    fi

    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
        1|true) HPC_ENABLED="1" ;;
        0|false) HPC_ENABLED="0" ;;
        *)
            echo "Error: invalid execution_mode.hpc_enabled: $HPC_ENABLED_RAW"
            exit 1
            ;;
    esac

    export DATA_ROOT HPC_ENABLED CONFIG_FILE

    echo "DATA_ROOT=$DATA_ROOT  HPC_ENABLED=$HPC_ENABLED"

    LISTS_ONLY="$(echo "${RECON_LISTS_ONLY:-0}" | tr '[:upper:]' '[:lower:]')"
    case "$LISTS_ONLY" in 1|true|yes) LISTS_ONLY=1 ;; *) LISTS_ONLY=0 ;; esac

    while IFS= read -r DATASET; do
        [ -z "$DATASET" ] && continue
        echo ""
        echo "=== $DATASET ==="

        DATASET_DIR="$DATA_ROOT/$DATASET"
        if [ ! -d "$DATASET_DIR" ]; then
            echo "Warning: skip missing $DATASET_DIR"
            continue
        fi

        LONG_RAW=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
        case "$(echo "$LONG_RAW" | tr '[:upper:]' '[:lower:]')" in
            1|true) SBM_RECON_LONGITUDINAL="1" ;;
            *) SBM_RECON_LONGITUDINAL="0" ;;
        esac

        if [ "${SKIP_BUILD_LISTS:-0}" != "1" ]; then
            build_sub_to_recon_for_dataset "$DATA_ROOT" "$DATASET" "$SBM_RECON_LONGITUDINAL" || continue
        else
            echo "SKIP_BUILD_LISTS=1 — using existing sub_to_recon.txt"
        fi

        SUBJECT_LIST="$DATASET_DIR/sub_to_recon.txt"
        ov=$(jq -r --arg ds "$DATASET" '.datasets[$ds].recon_subject_list // .datasets[$ds].sbm_recon_subject_list // empty' "$CONFIG_FILE")
        if [ -n "$ov" ] && [ "$ov" != "null" ]; then
            if [[ "$ov" != /* ]]; then
                SUBJECT_LIST="$DATASET_DIR/$ov"
            else
                SUBJECT_LIST="$ov"
            fi
        fi

        if [ "$LISTS_ONLY" = "1" ]; then
            echo "RECON_LISTS_ONLY — no sbatch."
            continue
        fi

        if [ ! -f "$SUBJECT_LIST" ]; then
            echo "Warning: missing $SUBJECT_LIST"
            continue
        fi

        N=$(grep -v '^[[:space:]]*$' "$SUBJECT_LIST" | wc -l | tr -d ' ')
        if [ -z "$N" ] || [ "$N" -eq 0 ]; then
            echo "Nothing to recon (empty sub_to_recon.txt / all have FS output)."
            continue
        fi

        echo "sbatch array 1-$N  SUBJECT_LIST=$SUBJECT_LIST  longitudinal=$SBM_RECON_LONGITUDINAL"

        export DATASET SUBJECT_LIST SBM_RECON_LONGITUDINAL

        sbatch \
            --job-name="recon_${DATASET}" \
            --array="1-${N}" \
            --export=ALL \
            "$STEP_SCRIPT"
    done <<< "$ENABLED_DATASETS"

    echo ""
    if [ "$LISTS_ONLY" = "1" ]; then
        echo "Lists refreshed. Config: $CONFIG_FILE"
    else
        echo "Done. Config: $CONFIG_FILE"
    fi
    exit 0
fi

# ---------- Mode 2: array worker ----------
if [ -z "${DATA_ROOT:-}" ]; then echo "Error: DATA_ROOT unset"; exit 1; fi
if [ -z "${DATASET:-}" ]; then echo "Error: DATASET unset"; exit 1; fi
if [ -z "${SUBJECT_LIST:-}" ]; then echo "Error: SUBJECT_LIST unset"; exit 1; fi
if [ ! -f "$SUBJECT_LIST" ]; then echo "Error: $SUBJECT_LIST not found"; exit 1; fi
if [ -z "${HPC_ENABLED:-}" ]; then echo "Error: HPC_ENABLED unset"; exit 1; fi

subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SUBJECT_LIST}")
subject=$(echo "$subject" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
if [ -z "$subject" ]; then
    echo "Error: empty line at task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

if [ "${SBM_RECON_LONGITUDINAL:-0}" = "1" ] || [ "$(echo "${SBM_RECON_LONGITUDINAL:-0}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    if parse_longitudinal_subject_session "$subject"; then
        subj="${_SUBJ_PARSE}"
        ses="${_SES_PARSE}"
    else
        echo "Error: longitudinal line must be subject+ses-* (got: ${subject})"
        exit 1
    fi
else
    subj=$subject
    ses=""
fi

BIDS_DIR="${DATA_ROOT}/${DATASET}"
export SUBJECTS_DIR="${BIDS_DIR}/derivatives/freesurfer"
thick_cross="${SUBJECTS_DIR}/${subject}/surf/lh.thickness.fwhm10.fsaverage.mgh"
thick_long="${SUBJECTS_DIR}/${subj}/surf/lh.thickness.fwhm10.fsaverage.mgh"

if [ -z "$ses" ]; then
    if [ -f "$thick_cross" ]; then
        echo "Skip ${subject}: recon output already exists ($thick_cross)"
        exit 0
    fi
else
    if [ -f "$thick_long" ]; then
        echo "Skip ${subj}: recon output already exists ($thick_long)"
        exit 0
    fi
fi

if [ "$HPC_ENABLED" = "1" ] || [ "$(echo "$HPC_ENABLED" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    echo "Loading FreeSurfer modules..."
    module purge
    module load freesurfer/7.1.0
else
    echo "Skipping module load (HPC off)."
fi

if [ ! -d "$SUBJECTS_DIR" ]; then
    mkdir -p "$SUBJECTS_DIR"
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
