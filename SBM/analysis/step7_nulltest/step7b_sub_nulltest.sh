#!/bin/bash
#SBATCH --time=0-08:00:05
#SBATCH --job-name=MBM
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000

# Worker: one eigentrapping job (submitted by step7b_eigentrapping_nulltest_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
inJob="${inJob:?Set inJob}"
harmonize="${harmonize:-1}"
hemi="${hemi:-lh}"
smoothKernel="${smoothKernel:-10}"
nTrap="${nTrap:-10}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module load matlab/r2023b
fi

echo "=== STEP7B WORKER: inJob=$inJob hemi=$hemi smooth=$smoothKernel ==="
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); step7b_sub_nulltest('$CONFIG_FILE', $harmonize, '$hemi', $smoothKernel, $nTrap, $inJob); quit;"

if [ $? -ne 0 ]; then
    echo "Error: STEP7B job $inJob failed"
    exit 1
fi
echo "=== STEP7B WORKER DONE: inJob=$inJob ==="
