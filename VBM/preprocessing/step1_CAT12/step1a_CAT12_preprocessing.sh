#!/bin/bash
# Dispatcher: reads config, builds subject list, submits CAT12_preprocessing.sh as array job

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/CAT12_preprocessing.sh"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found."
        echo "Checked: $REPO_ROOT/config_hpc.json"
        exit 1
    fi
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: Missing worker script: $SUB_SCRIPT"; exit 1; }

subject_has_catreport() {
    local dataset_dir="$1" subject="$2"
    local subject_dir="${dataset_dir}/${subject}"
    [[ -d "$subject_dir" ]] || return 1
    shopt -s nullglob
    local ses_dirs=("${subject_dir}"/ses-*)
    shopt -u nullglob
    if [[ ${#ses_dirs[@]} -gt 0 ]] && [[ -d "${ses_dirs[0]}" ]]; then
        local session; session="$(basename "${ses_dirs[0]}")"
        [[ -f "${subject_dir}/${session}/anat/catreport_${subject}_${session}_T1w.pdf" ]]
    else
        [[ -f "${subject_dir}/anat/catreport_${subject}_T1w.pdf" ]]
    fi
}

DATA_ROOT="$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")"
[[ -z "$DATA_ROOT" || "$DATA_ROOT" == "null" ]] && { echo "Error: invalid data_directories.dataset_root in $CONFIG_FILE"; exit 1; }

HPC_ENABLED_RAW="$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")"
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL="$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")"
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED_DATASETS="$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")"
[[ -z "$ENABLED_DATASETS" ]] && { echo "No enabled datasets in $CONFIG_FILE"; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"

while IFS= read -r DATASET; do
    DATASET="$(echo "$DATASET" | tr -d '\r' | xargs)"
    [[ -z "$DATASET" ]] && continue

    echo "=== $DATASET ==="

    DATASET_DIR="${DATA_ROOT}/${DATASET}"
    [[ -d "$DATASET_DIR" ]] || { echo "Skip $DATASET: missing $DATASET_DIR"; continue; }

    SUBJECTS_FILE="$(jq -r --arg ds "$DATASET" '.datasets[$ds].subject_list_file // empty' "$CONFIG_FILE")"
    if [[ -n "$SUBJECTS_FILE" ]]; then
        [[ "$SUBJECTS_FILE" == /* ]] || SUBJECTS_FILE="${DATASET_DIR}/${SUBJECTS_FILE}"
    else
        SUBJECTS_FILE="${DATASET_DIR}/subject_use.txt"
    fi
    [[ -f "$SUBJECTS_FILE" ]] || { echo "Skip $DATASET: missing subject list $SUBJECTS_FILE"; continue; }

    OUT_LIST="${DATASET_DIR}/sub_to_process.txt"
    rm -f "$OUT_LIST"

    while IFS= read -r SUBJECT || [[ -n "$SUBJECT" ]]; do
        SUBJECT="$(echo "$SUBJECT" | tr -d '\r' | xargs)"
        [[ -z "$SUBJECT" ]] && continue
        if subject_has_catreport "$DATASET_DIR" "$SUBJECT"; then
            echo "Skip $DATASET/$SUBJECT: CAT12 report exists"
            continue
        fi
        echo "$SUBJECT" >> "$OUT_LIST"
    done < "$SUBJECTS_FILE"

    N=$(grep -c . "$OUT_LIST" 2>/dev/null || echo 0)
    if [[ "$N" -eq 0 ]]; then
        echo "$DATASET: nothing to run"
        continue
    fi

    export DATA_ROOT DATASET HPC_ENABLED SUBJECT_LIST="$OUT_LIST"

    if [[ "$HPC_ENABLED" == "1" ]]; then
        echo "$DATASET: submitting $N jobs via SLURM array"
        sbatch --array=1-"$N" "$SUB_SCRIPT"
    else
        echo "$DATASET: running $N subjects locally (max $MAX_PARALLEL parallel)"
        pids=()
        for i in $(seq 1 "$N"); do
            SLURM_ARRAY_TASK_ID=$i bash "$SUB_SCRIPT" &
            pids+=($!)
            if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                wait "${pids[0]}"
                pids=("${pids[@]:1}")
            fi
        done
        wait
        echo "Done: $DATASET"
    fi
done <<< "$ENABLED_DATASETS"
