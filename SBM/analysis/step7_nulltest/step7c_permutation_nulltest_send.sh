#!/bin/bash
# Dispatcher: submit SBM label-shuffle permutation nulltest jobs.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/nulltest_permutation_job.sh"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found at $REPO_ROOT"
        exit 1
    fi
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }
[[ -f "$SUB_SCRIPT" ]] || { echo "Error: missing worker $SUB_SCRIPT"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
smoothKernel=$(jq -r '.analysis_settings.sbm_smoothing_kernel // 10' "$CONFIG_FILE")
harmonize=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")
NUM_PERMUTATIONS=$(jq -r '.analysis_settings.num_permutations // 10' "$CONFIG_FILE")

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

# Analysis defaults (override via env if needed)
measure="${measure:-thickness}"
measureShort="${measureShort:-thick}"
hemis="${hemis:-lh}"
control="${control:-1}"
covariance1="${covariance1:-sex}"
covariance2="${covariance2:-age}"

if [[ "$harmonize" == "1" ]]; then
    combat_suffix="_combat"
else
    combat_suffix=""
fi

echo "=== STEP7C: PERMUTATION NULLTEST ==="
echo "CONFIG_FILE:       $CONFIG_FILE"
echo "DATA_ROOT:         $DATA_ROOT"
echo "smoothKernel:      $smoothKernel"
echo "harmonize:         $harmonize"
echo "hemis:             $hemis"
echo "NUM_PERMUTATIONS:  $NUM_PERMUTATIONS"
echo "HPC_ENABLED:       $HPC_ENABLED"

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED
export datadir="$DATA_ROOT"
export smoothKernel harmonize measure measureShort hemis control covariance1 covariance2

pids=()
while IFS= read -r DATASET; do
    [[ -z "$DATASET" ]] && continue
    export DATASET
    echo "Processing dataset: $DATASET"

    DATASET_DIR="$DATA_ROOT/$DATASET"
    if [ ! -d "$DATASET_DIR" ]; then
        echo "Warning: $DATASET_DIR not found, skipping..."
        continue
    fi

    STAT_RESULTS="$DATASET_DIR/derivatives/freesurfer/qdec"
    if [ ! -d "$STAT_RESULTS" ]; then
        echo "Warning: qdec results not found at $STAT_RESULTS, skipping..."
        continue
    fi

    SITELIST="$DATASET_DIR/sitelist_permutation.txt"
    # Match step6 GLM output folder naming
    shopt -s nullglob
    site_dirs=("$STAT_RESULTS"/[0-9]_*_"${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}${combat_suffix}")
    shopt -u nullglob
    if [[ ${#site_dirs[@]} -eq 0 ]]; then
        echo "Warning: no matching qdec site folders for $DATASET (hemi=$hemis), skipping..."
        continue
    fi
    printf '%s\n' "${site_dirs[@]}" > "$SITELIST"

    while IFS= read -r sitefile; do
        [[ -z "$sitefile" ]] && continue
        sitebase=$(basename "$sitefile")
        echo "Processing site folder: $sitebase"

        # Parse site / diagnosis from folder name:
        # e.g. 1_SiteA_thick_smooth10_lh_sex_age_combat  or  1_Site_A_thick_smooth10_lh_sex_age_combat
        rest=${sitebase#*_}                          # drop leading diagnosis digit_
        diag_prefix=${sitebase%%_*}
        diag=$diag_prefix
        sitefield=${rest%%_thick_smooth*}
        site=$sitefield

        export diag site
        echo "  diag=$diag site=$site"

        site_perm_dir="$DATASET_DIR/derivatives/freesurfer/permutation_nulltest/${diag}_${site}_${measureShort}_smooth${smoothKernel}_${hemis}_${covariance1}_${covariance2}${combat_suffix}"
        mkdir -p "$site_perm_dir"

        for ranseed in $(seq 1 "$NUM_PERMUTATIONS"); do
            export ranseed
            perm_result="$site_perm_dir/surrogate_${ranseed}.mgh"
            if [ -f "$perm_result" ]; then
                echo "  Exists: surrogate_${ranseed}.mgh — skip"
                continue
            fi

            echo "  Submit seed=$ranseed (${diag}_${site})"
            if [[ "$HPC_ENABLED" == "1" ]]; then
                sbatch --job-name="perm_SBM_${DATASET}_${diag}_${site}_${ranseed}" "$SUB_SCRIPT"
            else
                bash "$SUB_SCRIPT" &
                pids+=($!)
                if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                    wait "${pids[0]}"
                    pids=("${pids[@]:1}")
                fi
            fi
        done
    done < "$SITELIST"
done <<< "$ENABLED_DATASETS"

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP7C SUBMISSION DONE ==="
