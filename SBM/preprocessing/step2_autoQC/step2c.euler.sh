#!/usr/bin/env bash
# This script requires Bash; users often invoke it as `sh step2c.euler.sh`.
# If so, re-exec with Bash to preserve Bash-specific syntax below.
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

#SBATCH --job-name=euler_number
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
# One job per eligible dataset; submit from login loops enabled datasets — override via: sbatch --partition=X ...

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STEP_SCRIPT="${SCRIPT_DIR}/$(basename "$0")"

resolve_config_file() {
    if [[ -n "${CONFIG_FILE:-}" ]]; then
        [[ -f "$CONFIG_FILE" ]] && return 0
        echo "Error: CONFIG_FILE is set but file not found: $CONFIG_FILE"
        return 1
    fi

    local dir="$SCRIPT_DIR"
    while [[ -n "$dir" ]]; do
        if [[ -f "$dir/config_hpc.json" ]]; then
            CONFIG_FILE="$dir/config_hpc.json"
            return 0
        fi
        if [[ -f "$dir/config.json" ]]; then
            CONFIG_FILE="$dir/config.json"
            return 0
        fi
        local parent
        parent="$(dirname "$dir")"
        [[ "$parent" == "$dir" ]] && break
        dir="$parent"
    done

    if [[ -f "config_hpc.json" ]]; then
        CONFIG_FILE="config_hpc.json"
        return 0
    fi
    if [[ -f "config.json" ]]; then
        CONFIG_FILE="config.json"
        return 0
    fi

    echo "Error: set CONFIG_FILE or place config_hpc.json/config.json in repo path."
    return 1
}

# ---------- LOGIN: for DATASET in $ENABLED ----------
if [[ -z "${SLURM_JOB_ID:-}" ]] && [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then

    resolve_config_file || exit 1
    command -v jq >/dev/null || { echo "Need jq"; exit 1; }

    DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
    HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // empty' "$CONFIG_FILE")
    case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in 1|true) HPC_ENABLED="1" ;; *) HPC_ENABLED="0" ;; esac

    ENABLED=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
    [[ -z "$ENABLED" ]] && { echo "No enabled datasets."; exit 1; }

    submitted=0
    for DATASET in $ENABLED; do
        BASE="${DATA_ROOT}/${DATASET}"
        LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
        [[ "$LONG" == "true" ]] && LONG=1 || LONG=0
        if [[ "$LONG" -eq 1 ]]; then
            RECON_LIST="${BASE}/ses_sub_with_recon_output.txt"
        else
            RECON_LIST="${BASE}/sub_with_recon_output.txt"
        fi
        if [[ ! -f "$RECON_LIST" ]]; then
            echo "Skip $DATASET: missing $RECON_LIST"
            continue
        fi
        echo "$DATASET: sbatch Euler"
        export CONFIG_FILE DATA_ROOT DATASET HPC_ENABLED
        sbatch "$STEP_SCRIPT"
        submitted=$((submitted + 1))
    done

    if [[ "${submitted}" -eq 0 ]]; then
        echo "Nothing to run (no recon lists found for enabled datasets)."
        exit 0
    fi
    exit 0
fi

# ---------- WORKER (single-task job) ----------
[[ -z "${SLURM_JOB_ID:-}" ]] && { echo "Run from login node without SLURM to submit jobs, or use sbatch."; exit 1; }

CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
DATASET="${DATASET:?Set DATASET}"

LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
[[ "$LONG" == "true" ]] && LONG=1 || LONG=0

BASE="${DATA_ROOT}/${DATASET}"
SUBJECTS_DIR="${FREESURFER_SUBJECTS_DIR:-${BASE}/derivatives/freesurfer}"
outdir="${BASE}/derivatives/euler"

echo "---------------------------"
echo "----- Euler ${DATASET} -----"
echo "---------------------------"

mkdir -p "$outdir"

if [[ "${HPC_ENABLED:-0}" == "1" ]] || [[ "$(echo "${HPC_ENABLED:-}" | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
    module purge
    module load freesurfer/7.1.0
fi

numbers='^[0-9]+$'
rm -f "${outdir}/${DATASET}_holes_temp.txt" "${outdir}/${DATASET}_ids.txt"
f="${outdir}/${DATASET}_holes_temp.txt"
id="${outdir}/${DATASET}_ids.txt"
e="${outdir}/${DATASET}_holes.csv"

if [[ "$LONG" -eq 0 ]]; then
    while read -r i; do
        i=$(echo "$i" | xargs)
        [[ -z "$i" ]] && continue
        sub="$i"
        for h in lh rh; do
            x=$(mris_euler_number "${SUBJECTS_DIR}/${sub}/surf/${h}.orig.nofix" 2>/dev/null | grep -o -P '(?<=--> ).*(?= holes)')
            if [[ "$x" =~ $numbers ]]; then
                echo "$x" >>"$f"
                echo "${i}_${h}" >>"$id"
            fi
        done
    done <"${BASE}/sub_with_recon_output.txt"
else
    while read -r i; do
        i=$(echo "$i" | xargs)
        [[ -z "$i" ]] && continue
        ses="${i: -5}"
        subj="${i:0:${#i}-5}"
        for h in lh rh; do
            x=$(mris_euler_number "${SUBJECTS_DIR}/${subj}/${ses}/surf/${h}.orig.nofix" 2>/dev/null | grep -o -P '(?<=--> ).*(?= holes)')
            if [[ "$x" =~ $numbers ]]; then
                echo "$x" >>"$f"
                echo "${subj}_${h}" >>"$id"
            fi
        done
    done <"${BASE}/ses_sub_with_recon_output.txt"
fi

if [[ ! -s "$id" ]]; then
    echo "Warning: no Euler values written for ${DATASET}"
    rm -f "$id" "$f"
    exit 0
fi

paste -d "," "$id" "$f" >"$e"
rm -f "$id" "$f"

echo "----- DONE -----"
