#!/usr/bin/env bash
#SBATCH --job-name=MRIQC_individual
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=0-1:00:00
#SBATCH --gres=gpu:P4:1
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --qos=normal
#SBATCH -A kg98
# Submit from login: this script builds sub_to_runMRIQC.txt then sbatch --array=1-N (overrides any #SBATCH --array below).

# subject_use.txt / ses_subject_use.txt (BIDS step) → scan FS → sub_*_with_recon_output.txt → MRIQC queue.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

subject_done() { [[ -f "$1/scripts/recon-all.log" ]]; }

parse_sub_ses() {
    local line="$1"
    if [[ "$line" =~ ^(sub-[^/]+)(ses-[^/]+)$ ]]; then
        subj="${BASH_REMATCH[1]}"
        ses="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

mriqc_missing_cross() {
    local base="$1" sub="$2"
    [[ ! -f "${base}/derivatives/MRIQC/${sub}_T1w.html" ]]
}

mriqc_missing_long() {
    local base="$1" sub="$2" ses="$3"
    [[ ! -f "${base}/derivatives/MRIQC/${sub}_${ses}_T1w.html" ]]
}

# ---------- LOGIN: build sub_to_runMRIQC.txt + sbatch ----------
if [[ -z "${SLURM_JOB_ID:-}" ]] && [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then

    if [[ -z "${CONFIG_FILE:-}" ]]; then
        REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
        if [[ -f "$REPO_ROOT/config_hpc.json" ]]; then CONFIG_FILE="$REPO_ROOT/config_hpc.json"
        elif [[ -f "$REPO_ROOT/config.json" ]]; then CONFIG_FILE="$REPO_ROOT/config.json"
        elif [[ -f "config_hpc.json" ]]; then CONFIG_FILE="config_hpc.json"
        elif [[ -f "config.json" ]]; then CONFIG_FILE="config.json"
        else echo "Error: set CONFIG_FILE or place config_hpc.json in repo root."; exit 1; fi
    fi
    command -v jq >/dev/null || { echo "Need jq"; exit 1; }

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // empty' "$CONFIG_FILE")
    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

    ENABLED=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
    [[ -z "$ENABLED" ]] && { echo "No enabled datasets."; exit 1; }

    for DATASET in $ENABLED; do
        BASE="${DATA_ROOT}/${DATASET}"
        FS_DIR="${FREESURFER_SUBJECTS_DIR:-${BASE}/derivatives/freesurfer}"
        LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
        [[ "$LONG" == "true" ]] && LONG=1 || LONG=0

        LIST_IN="${BASE}/subject_use.txt"
        [[ "$LONG" -eq 1 ]] && LIST_IN="${BASE}/ses_subject_use.txt"
        if [[ ! -f "$LIST_IN" ]]; then
            echo "Skip $DATASET: missing $LIST_IN"
            continue
        fi

        if [[ "$LONG" -eq 1 ]]; then
            RECON_OUT="${BASE}/ses_sub_with_recon_output.txt"
        else
            RECON_OUT="${BASE}/sub_with_recon_output.txt"
        fi
        : >"$RECON_OUT"
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | xargs)
            [[ -z "$line" ]] && continue
            if [[ "$LONG" -eq 1 ]]; then
                parse_sub_ses "$line" || continue
                if subject_done "${FS_DIR}/${subj}"; then
                    echo "${subj}${ses}" >>"$RECON_OUT"
                fi
            else
                if subject_done "${FS_DIR}/${line}"; then
                    echo "$line" >>"$RECON_OUT"
                fi
            fi
        done <"$LIST_IN"

        OUT_LIST="${BASE}/sub_to_runMRIQC.txt"
        : >"$OUT_LIST"

        if [[ "$LONG" -eq 1 ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                line=$(echo "$line" | xargs)
                [[ -z "$line" ]] && continue
                parse_sub_ses "$line" || continue
                if mriqc_missing_long "$BASE" "$subj" "$ses"; then
                    printf '%s %s\n' "${subj#sub-}" "$ses" >>"$OUT_LIST"
                fi
            done <"$RECON_OUT"
        else
            while IFS= read -r subj || [[ -n "$subj" ]]; do
                subj=$(echo "$subj" | xargs)
                [[ -z "$subj" ]] && continue
                if mriqc_missing_cross "$BASE" "$subj"; then
                    printf '%s\n' "${subj#sub-}" >>"$OUT_LIST"
                fi
            done <"$RECON_OUT"
        fi

        N=$(wc -l <"$OUT_LIST" | tr -d ' \t')
        if [[ "${N:-0}" -eq 0 ]]; then
            echo "$DATASET: nothing to run (MRIQC outputs present or empty list)."
            continue
        fi

        echo "$DATASET: $N jobs → $OUT_LIST"
        export DATA_ROOT DATASET LONG HPC_ENABLED SUBJECT_LIST="$OUT_LIST"
        sbatch --array=1-"$N" "$STEP_SCRIPT"
    done
    exit 0
fi

# ---------- WORKER (array task) ----------
[[ -z "${SLURM_ARRAY_TASK_ID:-}" ]] && { echo "Run from login node without SLURM to build lists and submit, or use sbatch --array=1-N."; exit 1; }

DATASET="${DATASET:?Set DATASET}"
SUBJECT_LIST="${SUBJECT_LIST:?Set SUBJECT_LIST}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
LONG="${LONG:-0}"

line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SUBJECT_LIST" | xargs)
[[ -z "$line" ]] && { echo "Empty line ${SLURM_ARRAY_TASK_ID}"; exit 1; }

BIDS_DIR="${DATA_ROOT}/${DATASET}"
OUT_DIR="${BIDS_DIR}/derivatives/MRIQC"
WORK_DIR="${SCRIPT_DIR}/work/${DATASET}"

echo "---------------------------"
echo "----- ${SLURM_ARRAY_TASK_ID} ${line} (${DATASET}) -----"
echo "---------------------------"

mkdir -p "$OUT_DIR" "$WORK_DIR"

if [[ "$HPC_ENABLED" == "1" ]] || [[ "$(echo "$HPC_ENABLED" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    module purge
    module load mriqc/0.15.2.rc1.1
fi

if [[ "$LONG" -eq 1 ]]; then
    read -r plabel sess <<<"$line"
    mriqc "$BIDS_DIR" "$OUT_DIR" participant --participant_label "$plabel" --session-id "$sess" \
        --n_procs 12 --n_cpus 6 --mem_gb 12 -m T1w --hmc-fsl --correct-slice-timing --work-dir "$WORK_DIR"
else
    mriqc "$BIDS_DIR" "$OUT_DIR" participant --participant_label "$line" \
        --n_procs 12 --n_cpus 6 --mem_gb 12 -m T1w --work-dir "$WORK_DIR"
fi

echo "----- DONE -----"
