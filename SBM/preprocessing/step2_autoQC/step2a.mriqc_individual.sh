#!/bin/bash
# Dispatcher: builds subject lists and submits step2a_sub.mriqc_individual.sh
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step2a_sub.mriqc_individual.sh"

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

mriqc_missing_cross() { [[ ! -f "${1}/derivatives/MRIQC/${2}_T1w.html" ]]; }
mriqc_missing_long()  { [[ ! -f "${1}/derivatives/MRIQC/${2}_${3}_T1w.html" ]]; }

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
command -v jq >/dev/null || { echo "Need jq"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // empty' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac
MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

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
            subject_done "${FS_DIR}/${subj}" && echo "${subj}${ses}" >>"$RECON_OUT"
        else
            subject_done "${FS_DIR}/${line}" && echo "$line" >>"$RECON_OUT"
        fi
    done <"$LIST_IN"

    OUT_LIST="${BASE}/sub_to_runMRIQC.txt"
    : >"$OUT_LIST"

    if [[ "$LONG" -eq 1 ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line=$(echo "$line" | xargs)
            [[ -z "$line" ]] && continue
            parse_sub_ses "$line" || continue
            mriqc_missing_long "$BASE" "$subj" "$ses" && printf '%s %s\n' "${subj#sub-}" "$ses" >>"$OUT_LIST"
        done <"$RECON_OUT"
    else
        while IFS= read -r subj || [[ -n "$subj" ]]; do
            subj=$(echo "$subj" | xargs)
            [[ -z "$subj" ]] && continue
            mriqc_missing_cross "$BASE" "$subj" && printf '%s\n' "${subj#sub-}" >>"$OUT_LIST"
        done <"$RECON_OUT"
    fi

    N=$(wc -l <"$OUT_LIST" | tr -d ' \t')
    if [[ "${N:-0}" -eq 0 ]]; then
        echo "$DATASET: nothing to run (MRIQC outputs present or empty list)."
        continue
    fi

    echo "$DATASET: $N jobs -> $OUT_LIST"
    export DATA_ROOT DATASET LONG HPC_ENABLED SUBJECT_LIST="$OUT_LIST"

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch --array=1-"$N" "$SUB_SCRIPT"
    else
        echo "$DATASET: running locally with max $MAX_PARALLEL parallel jobs"
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
    fi
done
