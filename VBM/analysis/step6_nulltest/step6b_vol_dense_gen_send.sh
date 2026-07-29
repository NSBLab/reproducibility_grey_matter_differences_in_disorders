#!/bin/bash
# Dispatcher: submit BrainSMASH surrogate jobs for diagnosis/site folders under derivatives.

export SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step6b_sub_vol_dense_gen.sh"

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
smoothKernel=$(jq -r '.analysis_settings.vbm_smoothing_kernel // 6' "$CONFIG_FILE")
harmonize=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")
maskDiag=$(jq -r '.analysis_settings.mask_diagnostic_group // "psy"' "$CONFIG_FILE")
NUM_SURROGATES=$(jq -r '.analysis_settings.num_permutations // 10' "$CONFIG_FILE")

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

if [[ "$harmonize" == "1" ]]; then
    DERIV_TAG="s${smoothKernel}COMBAT"
else
    DERIV_TAG="s${smoothKernel}"
fi

NULL_ROOT="${DATA_ROOT}/nulltest"
DERIV_ROOT="${DATA_ROOT}/derivatives/${DERIV_TAG}"

echo "=== STEP6B: BRAINSMASH SURROGATE SUBMISSION ==="
echo "CONFIG_FILE:    $CONFIG_FILE"
echo "DATA_ROOT:      $DATA_ROOT"
echo "DERIV_ROOT:     $DERIV_ROOT"
echo "NULL_ROOT:      $NULL_ROOT"
echo "HPC_ENABLED:    $HPC_ENABLED"
echo "NUM_SURROGATES: $NUM_SURROGATES"

if [[ ! -d "$DERIV_ROOT" ]]; then
    echo "Error: derivatives folder not found: $DERIV_ROOT"
    exit 1
fi

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED smoothKernel harmonize maskDiag NULL_ROOT

pids=()
for diag_dir in "$DERIV_ROOT"/*/; do
    [[ -d "$diag_dir" ]] || continue
    diag=$(basename "$diag_dir")
    # skip mask folders
    [[ "$diag" == mask_* ]] && continue
    export diag

    for site_dir in "$diag_dir"*/; do
        [[ -d "$site_dir" ]] || continue
        site=$(basename "$site_dir")
        [[ -f "${site_dir}/spmT_0001.nii" ]] || continue
        export site

        for ranseed in $(seq 1 "$NUM_SURROGATES"); do
            export ranseed
            echo "Job: diag=$diag site=$site seed=$ranseed"

            if [[ "$HPC_ENABLED" == "1" ]]; then
                sbatch --job-name="vol_dense_${diag}_${site}_${ranseed}" "$SUB_SCRIPT"
            else
                bash "$SUB_SCRIPT" &
                pids+=($!)
                if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
                    wait "${pids[0]}"
                    pids=("${pids[@]:1}")
                fi
            fi
        done
    done
done

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP6B SUBMISSION DONE ==="
