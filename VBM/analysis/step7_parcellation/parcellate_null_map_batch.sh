#!/bin/bash
#SBATCH --time=0-4:00:00
#SBATCH --job-name=parcellate_null_maps
#SBATCH --account=kg98
#SBATCH --cpus-per-task=1
#SBATCH --mem=60000

# Worker: parcellate null maps for one diagnosis x site

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
diag="${diag:?Set diag}"
site="${site:?Set site}"
nulldir="${NULLDIR:?Set NULLDIR}"
nNull="${nNull:?Set nNull}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    module unload matlab 2>/dev/null || true
    module load spm12/matlab2021a.r7771-v1
fi

echo "=== PARCELLATE NULL: diag=$diag site=$site ==="
echo "nulldir=$nulldir nNull=$nNull"
matlab -nodisplay -r "addpath('$SCRIPT_DIR'); parcellate_null_maps('$CONFIG_FILE', '$diag', '$site', '$nulldir', $nNull); quit;"

if [ $? -ne 0 ]; then
    echo "Error: parcellate_null_maps failed for $diag / $site"
    exit 1
fi
echo "=== PARCELLATE NULL DONE: $diag / $site ==="
