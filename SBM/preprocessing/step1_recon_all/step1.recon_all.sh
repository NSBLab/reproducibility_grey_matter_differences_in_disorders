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
# --- Login node (no SLURM_ARRAY_TASK_ID) ---
#   1) Read CONFIG_FILE (json), resolve DATA_ROOT and enabled SBM datasets.
#   2) For each dataset, write sub_to_recon.txt under $DATA_ROOT/<Dataset>/:
#        - longitudinal: copy ses_subject_use.txt → sub_to_recon.txt (ses list comes from BIDS,
#          e.g. BIDS_Myelin.m — do not regenerate here unless missing and BUILD_SES_SUBJECT_USE=1)
#        - otherwise:    copy subject_use.txt → sub_to_recon.txt
#   3) Submit sbatch array jobs that only read sub_to_recon.txt (no FreeSurfer scanning here).
#
# Optional:
#   RECON_LISTS_ONLY=1     Only step (1)+(2), no sbatch.
#   SKIP_BUILD_LISTS=1     Skip (2), use existing sub_to_recon.txt for (3).
#
# Usage:
#   export CONFIG_FILE=/path/to/config_hpc.json   # optional
#   bash step1.recon_all.sh
#
# --- Array worker (inside job) ---
#   Reads SUBJECT_LIST (sub_to_recon.txt), DATA_ROOT, DATASET, HPC_ENABLED, SBM_RECON_LONGITUDINAL.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

# From config + subject_use.txt → canonical recon list: sub_to_recon.txt
build_sub_to_recon_for_dataset() {
    local DATA_ROOT="$1"
    local DATASET="$2"
    local CONFIG_FILE="$3"
    local long="$4"

    local BASE="${DATA_ROOT}/${DATASET}"

    if [ "$long" = "1" ]; then
        if [ -f "${BASE}/ses_subject_use.txt" ]; then
            echo "${DATASET}: using existing ses_subject_use.txt (e.g. from BIDS script)"
            cp -f "${BASE}/ses_subject_use.txt" "${BASE}/sub_to_recon.txt"
        elif [ "${BUILD_SES_SUBJECT_USE:-0}" = "1" ]; then
            echo "${DATASET}: ses_subject_use.txt missing — BUILD_SES_SUBJECT_USE=1, generating from subject_use.txt"
            make_ses_subject_use "$BASE" || return 1
            cp -f "${BASE}/ses_subject_use.txt" "${BASE}/sub_to_recon.txt"
        else
            echo "Error: ${BASE}/ses_subject_use.txt not found."
            echo "  Longitudinal datasets expect this file from your BIDS step (e.g. BIDS_Myelin.m)."
            echo "  Or set BUILD_SES_SUBJECT_USE=1 to build it from subject_use.txt (first ses-* per subject)."
            return 1
        fi
    else
        if [ ! -f "${BASE}/subject_use.txt" ]; then
            echo "Error: missing ${BASE}/subject_use.txt"
            return 1
        fi
        cp -f "${BASE}/subject_use.txt" "${BASE}/sub_to_recon.txt"
    fi

    local n
    n=$(grep -v '^[[:space:]]*$' "${BASE}/sub_to_recon.txt" | wc -l | tr -d ' ')
    echo "${DATASET}: sub_to_recon.txt has ${n} line(s) → ${BASE}/sub_to_recon.txt"
}

parse_longitudinal_subject_session() {
    local line="$1"
    if [[ "$line" =~ ^(.+)(ses-.+)$ ]]; then
        _SUBJ_PARSE="${BASH_REMATCH[1]}"
        _SES_PARSE="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

# ---------- Mode 1: login — build lists from config, then optionally sbatch ----------
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
            echo "Error: set CONFIG_FILE or place config_hpc.json / config.json in repo root."
            exit 1
        fi
    fi

    echo "Using CONFIG_FILE: $CONFIG_FILE"

    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required."
        exit 1
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: config not found: $CONFIG_FILE"
        exit 1
    fi

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    if [ -z "$DATA_ROOT" ] || [ "$DATA_ROOT" = "null" ]; then
        echo "Error: data_directories.dataset_root missing in config"
        exit 1
    fi

    ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true and (.value.sbm_recon != false)) | .key' "$CONFIG_FILE")
    if [ -z "$ENABLED_DATASETS" ]; then
        echo "Error: no enabled datasets for SBM (use sbm_recon: false to skip)."
        exit 1
    fi

    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled' "$CONFIG_FILE")
    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
        1|true) HPC_ENABLED="1" ;;
        0|false) HPC_ENABLED="0" ;;
        *)
            echo "Error: execution_mode.hpc_enabled invalid: $HPC_ENABLED_RAW"
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
            build_sub_to_recon_for_dataset "$DATA_ROOT" "$DATASET" "$CONFIG_FILE" "$SBM_RECON_LONGITUDINAL" || continue
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
            echo "RECON_LISTS_ONLY — not submitting jobs."
            continue
        fi

        if [ ! -f "$SUBJECT_LIST" ]; then
            echo "Warning: missing recon list $SUBJECT_LIST"
            continue
        fi

        N=$(grep -v '^[[:space:]]*$' "$SUBJECT_LIST" | wc -l | tr -d ' ')
        if [ -z "$N" ] || [ "$N" -eq 0 ]; then
            echo "Warning: empty list $SUBJECT_LIST"
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
        echo "Subject lists written under each dataset dir (sub_to_recon.txt). Config: $CONFIG_FILE"
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

if [ "$HPC_ENABLED" = "1" ] || [ "$(echo "$HPC_ENABLED" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    echo "Loading FreeSurfer modules..."
    module purge
    module load freesurfer/7.1.0
else
    echo "Skipping module load (HPC off)."
fi

BIDS_DIR="${DATA_ROOT}/${DATASET}"
export SUBJECTS_DIR="${BIDS_DIR}/derivatives/freesurfer"

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
