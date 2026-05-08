#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/CAT12_preprocessing.sh"

resolve_config_file() {
    if [[ -n "${CONFIG_FILE:-}" ]]; then
        [[ -f "$CONFIG_FILE" ]] && return 0
        echo "Error: CONFIG_FILE is set but not found: $CONFIG_FILE"
        return 1
    fi

    local dir="$SCRIPT_DIR"
    while [[ -n "$dir" ]]; do
        if [[ -f "$dir/config_hpc.json" ]]; then CONFIG_FILE="$dir/config_hpc.json"; return 0; fi
        if [[ -f "$dir/config_linux.json" ]]; then CONFIG_FILE="$dir/config_linux.json"; return 0; fi
        if [[ -f "$dir/config_windows.json" ]]; then CONFIG_FILE="$dir/config_windows.json"; return 0; fi
        if [[ -f "$dir/config.json" ]]; then CONFIG_FILE="$dir/config.json"; return 0; fi
        local parent
        parent="$(dirname "$dir")"
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done

    if [[ -f "config_hpc.json" ]]; then CONFIG_FILE="config_hpc.json"; return 0; fi
    if [[ -f "config_linux.json" ]]; then CONFIG_FILE="config_linux.json"; return 0; fi
    if [[ -f "config_windows.json" ]]; then CONFIG_FILE="config_windows.json"; return 0; fi
    if [[ -f "config.json" ]]; then CONFIG_FILE="config.json"; return 0; fi

    echo "Error: set CONFIG_FILE or place config_hpc/config_linux/config_windows/config.json in repo path."
    return 1
}

subject_has_catreport() {
    local dataset_dir="$1" subject="$2"
    local subject_dir="${dataset_dir}/${subject}"
    local session_dir session

    if [[ ! -d "$subject_dir" ]]; then
        return 1
    fi

    shopt -s nullglob
    local ses_dirs=("${subject_dir}"/ses-*)
    shopt -u nullglob

    if [[ ${#ses_dirs[@]} -gt 0 ]] && [[ -d "${ses_dirs[0]}" ]]; then
        session_dir="${ses_dirs[0]}"
        session="$(basename "$session_dir")"
        [[ -f "${dataset_dir}/${subject}/${session}/anat/catreport_${subject}_${session}_T1w.pdf" ]]
    else
        [[ -f "${dataset_dir}/${subject}/anat/catreport_${subject}_T1w.pdf" ]]
    fi
}

resolve_subject_session() {
    local dataset_dir="$1" subject="$2"
    local subject_dir="${dataset_dir}/${subject}"
    shopt -s nullglob
    local ses_dirs=("${subject_dir}"/ses-*)
    shopt -u nullglob
    if [[ ${#ses_dirs[@]} -gt 0 ]] && [[ -d "${ses_dirs[0]}" ]]; then
        ses="$(basename "${ses_dirs[0]}")"
        return 0
    fi
    ses=""
    return 0
}

resolve_config_file || exit 1
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }
[[ -f "$STEP_SCRIPT" ]] || { echo "Error: Missing worker script: $STEP_SCRIPT"; exit 1; }

DATA_ROOT="$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")"
[[ -z "$DATA_ROOT" || "$DATA_ROOT" == "null" ]] && { echo "Error: invalid data_directories.dataset_root in $CONFIG_FILE"; exit 1; }

HPC_ENABLED_RAW="$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")"
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL="$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")"
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4
[[ "$MAX_PARALLEL" -lt 1 ]] && MAX_PARALLEL=1

ENABLED_DATASETS="$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")"
[[ -z "$ENABLED_DATASETS" ]] && { echo "No enabled datasets in $CONFIG_FILE"; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"
echo "DATA_ROOT: $DATA_ROOT"
echo "HPC_ENABLED: $HPC_ENABLED"
echo "MAX_PARALLEL(local): $MAX_PARALLEL"

export DATA_ROOT HPC_ENABLED

while IFS= read -r DATASET; do
    DATASET="$(echo "$DATASET" | tr -d '\r' | xargs)"
    [[ -z "$DATASET" ]] && continue

    DATASET_DIR="${DATA_ROOT}/${DATASET}"
    [[ -d "$DATASET_DIR" ]] || { echo "Skip $DATASET: missing dataset dir $DATASET_DIR"; continue; }

    SUBJECTS_FILE="$(jq -r --arg ds "$DATASET" '.datasets[$ds].subject_list_file // empty' "$CONFIG_FILE")"
    if [[ -n "$SUBJECTS_FILE" ]]; then
        [[ "$SUBJECTS_FILE" == /* ]] || SUBJECTS_FILE="${DATASET_DIR}/${SUBJECTS_FILE}"
    else
        SUBJECTS_FILE="${DATASET_DIR}/subject_use.txt"
    fi
    [[ -f "$SUBJECTS_FILE" ]] || { echo "Skip $DATASET: missing subject list $SUBJECTS_FILE"; continue; }

    echo "=== $DATASET ==="
    pids=()
    submitted=0

    while IFS= read -r SUBJECT || [[ -n "$SUBJECT" ]]; do
        SUBJECT="$(echo "$SUBJECT" | tr -d '\r' | xargs)"
        [[ -z "$SUBJECT" ]] && continue

        if subject_has_catreport "$DATASET_DIR" "$SUBJECT"; then
            echo "Skip $DATASET/$SUBJECT: CAT12 report exists"
            continue
        fi

        resolve_subject_session "$DATASET_DIR" "$SUBJECT"
        export i="$SUBJECT" DATASET
        if [[ -n "$ses" ]]; then
            export ses
        else
            unset ses
        fi

        if [[ "$HPC_ENABLED" == "1" ]]; then
            sbatch --job-name="CAT_${DATASET}_${SUBJECT}" "$STEP_SCRIPT"
        else
            bash "$STEP_SCRIPT" &
            pids+=($!)
            if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                wait "${pids[0]}"
                pids=("${pids[@]:1}")
            fi
        fi
        submitted=$((submitted + 1))
    done < "$SUBJECTS_FILE"

    if [[ "$HPC_ENABLED" != "1" ]]; then
        wait
    fi
    echo "$DATASET: submitted/running $submitted subject job(s)"
done <<< "$ENABLED_DATASETS"

echo "CAT12 step complete using $CONFIG_FILE"
