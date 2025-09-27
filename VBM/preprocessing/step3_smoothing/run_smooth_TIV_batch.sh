#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=smooth_${dataset}
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000
# SBATCH --mail-user=youremail@monash.edu
# SBATCH --mail-type=FAIL
# SBATCH --mail-type=BEGIN
# SBATCH --mail-type=END

# Get DATA_ROOT from environment variable (set by pipeline)
if [ -z "$DATA_ROOT" ]; then
    echo "Error: DATA_ROOT environment variable not set. Please run from pipeline."
    exit 1
fi

# Get script directory (current directory)
export script_DIR=$(cd "$(dirname "$0")" && pwd)

# Load required modules
module unload matlab
module load spm12/matlab2021a.r7771-v1

# Run the smoothing function with data_root parameter
matlab -nodisplay -r "cd ('$script_DIR'); addpath('$script_DIR'); run_smooth_TIV_func('$dataset', $isses, $smoothKernel, '$DATA_ROOT'); exit"

