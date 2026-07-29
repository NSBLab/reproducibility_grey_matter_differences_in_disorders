#!/bin/bash
# Dispatcher: submit eigentrapping nulltest jobs.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUB_SCRIPT="${SCRIPT_DIR}/step7b_sub_nulltest.sh"

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
harmonize=$(jq -r '.analysis_settings.harmonize // 1' "$CONFIG_FILE")
smoothKernel=$(jq -r '.analysis_settings.sbm_smoothing_kernel // 10' "$CONFIG_FILE")
NUM_JOBS=$(jq -r '.analysis_settings.num_permutations // 10' "$CONFIG_FILE")

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

MAX_PARALLEL=$(jq -r '.execution_mode.local_settings.max_parallel_jobs // 4' "$CONFIG_FILE")
[[ "$MAX_PARALLEL" =~ ^[0-9]+$ ]] || MAX_PARALLEL=4

# Analysis defaults (override via env if needed)
hemi="${hemi:-lh}"
nTrap="${nTrap:-10}"

echo "=== STEP7B: EIGENTRAPPING NULLTEST ==="
echo "CONFIG_FILE:  $CONFIG_FILE"
echo "DATA_ROOT:    $DATA_ROOT"
echo "harmonize:    $harmonize"
echo "smoothKernel: $smoothKernel"
echo "hemi:         $hemi"
echo "nTrap:        $nTrap"
echo "NUM_JOBS:     $NUM_JOBS"
echo "HPC_ENABLED:  $HPC_ENABLED"

export CONFIG_FILE DATA_ROOT SCRIPT_DIR HPC_ENABLED harmonize smoothKernel hemi nTrap

pids=()
for inJob in $(seq 1 "$NUM_JOBS"); do
    export inJob
    echo "Submitting eigentrapping job $inJob"

    if [[ "$HPC_ENABLED" == "1" ]]; then
        sbatch --job-name="nulltest_${inJob}" "$SUB_SCRIPT"
    else
        bash "$SUB_SCRIPT" &
        pids+=($!)
        if [[ "${#pids[@]}" -ge "$MAX_PARALLEL" ]]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    fi
done

if [[ "$HPC_ENABLED" != "1" ]]; then
    wait
fi

echo "=== STEP7B SUBMISSION DONE ==="
