#!/bin/bash
#SBATCH --time=0-2:00:00
#SBATCH --job-name=ABIDEII_Preprocessing
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    CONFIG_FILE="$REPO_ROOT/config_hpc.json"
fi

module load matlab/r2023b

matlab -nodisplay -r "cd ('$SCRIPT_DIR'); corr_map_parc_subdivide_func('$CONFIG_FILE', '$outdir', $iSubdivide, $randomSubdivide); quit"



		


