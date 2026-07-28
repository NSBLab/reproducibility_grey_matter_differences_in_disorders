#!/bin/bash
#SBATCH --time=0-1:00:00
#SBATCH --job-name=vol_gen
#SBATCH --account=kg98
#SBATCH --cpus-per-task=12
#SBATCH --mem=120000

# Worker: one BrainSMASH surrogate (submitted by step6b_vol_dense_gen_send.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:?Set CONFIG_FILE}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"
diag="${diag:?Set diag}"
site="${site:?Set site}"
ranseed="${ranseed:?Set ranseed}"

if [ "${HPC_ENABLED:-0}" = "1" ]; then
    CONDA_ENV=$(jq -r '.data_directories.conda_env // empty' "$CONFIG_FILE" 2>/dev/null || true)
    if [ -n "$CONDA_ENV" ] && [ -f "$CONDA_ENV" ]; then
        # shellcheck disable=SC1090
        source "$CONDA_ENV"
    fi
fi

python "$SCRIPT_DIR/vol_dense_gen.py" "${diag}" "${site}" "${ranseed}"
