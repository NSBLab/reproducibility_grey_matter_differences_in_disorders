#!/bin/bash
#SBATCH --job-name=COMBAT_surface_run
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20:05:00
#SBATCH --export=ALL
#SBATCH --mem=240000

# Worker: runs COMBAT harmonization for one combat group and hemisphere
# (invoked by step5c_COMBAT_run_sbatch_send.sh)

#SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
GROUP="${GROUP:?Set GROUP}"
HEMI="${HEMI:?Set HEMI}"

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
smoothKernel=$(jq -r '.analysis_settings.sbm_smoothing_kernel' "$CONFIG_FILE")
conda_env=$(jq -r '.data_directories.conda_env' "$CONFIG_FILE")

OUT_DIR="${DATA_ROOT}/derivatives/freesurfer/s${smoothKernel}COMBAT"

[[ -f "${DATA_ROOT}/metadataSBM_${GROUP}.csv" ]] \
    || { echo "Missing: ${DATA_ROOT}/metadataSBM_${GROUP}.csv"; exit 1; }
[[ -f "${OUT_DIR}/${HEMI}_thickness_s${smoothKernel}_${GROUP}.txt" ]] \
    || { echo "Missing: ${OUT_DIR}/${HEMI}_thickness_s${smoothKernel}_${GROUP}.txt"; exit 1; }

source "$conda_env"

python "$SCRIPT_DIR/COMBAT_surface_run.py" "$smoothKernel" "$GROUP" "$HEMI" "$DATA_ROOT"
