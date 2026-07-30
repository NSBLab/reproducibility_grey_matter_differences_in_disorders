#!/bin/bash
#SBATCH --time=0-02:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=120000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    CONFIG_FILE="$REPO_ROOT/config_hpc.json"
fi

module load spm12/matlab2021a.r7771-v1
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); corr_tmap_brainsmash_null_func('$CONFIG_FILE', ${iNull}); quit;"


