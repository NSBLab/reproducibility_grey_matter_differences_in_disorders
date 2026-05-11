#!/bin/bash
# Dispatcher: resolves config, builds subject list, submits step1_sub.recon_all.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step1_sub.recon_all.sh"

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

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found."
        echo "Checked: $REPO_ROOT/config_hpc.json, ./config_hpc.json"
        exit 1
    fi
fi

echo "Using CONFIG_FILE: $CONFIG_FILE"

if ! command -v jq >/dev/null; then
    echo "Need jq"; exit 1
fi

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
HPC_ENABLED=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
DATASETS=$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")

for DATASET in $DATASETS; do
    echo "=== $DATASET ==="

    BASE="${DATA_ROOT}/${DATASET}"
    FS_DIR="${BASE}/derivatives/freesurfer"

    LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
    [[ "$LONG" == "true" ]] && LONG=1 || LONG=0

    LIST_IN="${BASE}/subject_use.txt"
    [ "$LONG" = "1" ] && LIST_IN="${BASE}/ses_subject_use.txt"

    OUT_LIST="${BASE}/sub_to_recon.txt"
    rm -f "$OUT_LIST"

    while read -r line; do
        line=$(echo "$line" | tr -d '\r' | xargs)
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

    export DATA_ROOT DATASET SUBJECT_LIST="$OUT_LIST" LONG HPC_ENABLED

    if [ "$HPC_ENABLED" = "true" ]; then
        echo "Submitting $N jobs via SLURM"
        sbatch --array=1-"$N" "$SUB_SCRIPT"
    else
        echo "Running $N subjects locally (max $MAX_PARALLEL in parallel)"
        pids=()
        for i in $(seq 1 "$N"); do
            SLURM_ARRAY_TASK_ID=$i bash "$SUB_SCRIPT" &
            pids+=($!)
            if [ "${#pids[@]}" -ge "$MAX_PARALLEL" ]; then
                wait "${pids[0]}"
                pids=("${pids[@]:1}")
            fi
        done
        wait
        echo "Done: $DATASET"
    fi
done
