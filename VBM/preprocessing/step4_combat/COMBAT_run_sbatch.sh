#!/bin/bash
#SBATCH --job-name=COMBAT_run
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:05:00
#SBATCH --export=ALL
#SBATCH --mem=240000

# Worker: runs COMBAT harmonization for one combat group (invoked by step4d_COMBAT_run_sbatch_send.sh)

#SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
GROUP="${GROUP:?Set GROUP}"
echo $SCRIPT_DIR
DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
smoothKernel=$(jq -r '.analysis_settings.vbm_smoothing_kernel' "$CONFIG_FILE")
conda_env=$(jq -r '.data_directories.conda_env' "$CONFIG_FILE")

OUT_DIR="${DATA_ROOT}/derivatives/s${smoothKernel}COMBAT/mask_${GROUP}"

[[ -f "${DATA_ROOT}/metadataVBM_${GROUP}.csv" ]]                    || { echo "Missing: ${DATA_ROOT}/metadataVBM_${GROUP}.csv"; exit 1; }
[[ -f "${OUT_DIR}/anat_s${smoothKernel}mwp1_T1w_masked.txt" ]]      || { echo "Missing: ${OUT_DIR}/anat_s${smoothKernel}mwp1_T1w_masked.txt"; exit 1; }
[[ -f "${OUT_DIR}/mask.nii" ]]                                       || { echo "Missing: ${OUT_DIR}/mask.nii"; exit 1; }

source "$conda_env"
echo $SCRIPT_DIR
python "$SCRIPT_DIR/COMBAT_run.py" "$smoothKernel" "$GROUP" "$DATA_ROOT"
