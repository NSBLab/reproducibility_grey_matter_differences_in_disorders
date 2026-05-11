#!/bin/bash
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=0-3:00:00
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000

# Worker: runs MRIQC PCA for one dataset (invoked by step2d.mriqc_PCA.sh)
[ -n "${BASH_VERSION:-}" ] || exec bash "$0" "$@"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PCA_PY="${PCA_PY:-python3}"

DATASET="${DATASET:?Set DATASET}"
DATA_ROOT="${DATA_ROOT:?Set DATA_ROOT}"

BIDS_DIR="${DATA_ROOT}/${DATASET}"
MRIQC_DIR="${BIDS_DIR}/derivatives/MRIQC"
QC_TSV="${MRIQC_DIR}/group_T1w.tsv"
PCA_SCRIPT="${SCRIPT_DIR}/step2d_sub.mriqc_PCA.py"

echo "---------------------------"
echo "----- MRIQC PCA ${DATASET} -----"
echo "---------------------------"

PY_ENV_ACTIVATE=$(jq -r '.data_directories.conda_env // empty' "${CONFIG_FILE:-}")
if [[ -n "$PY_ENV_ACTIVATE" ]]; then
    [[ "$PY_ENV_ACTIVATE" == "~/"* ]] && PY_ENV_ACTIVATE="${HOME}/${PY_ENV_ACTIVATE#~/}"
    if [[ -f "$PY_ENV_ACTIVATE" ]]; then
        # shellcheck source=/dev/null
        source "$PY_ENV_ACTIVATE"
    else
        echo "Warning: conda_env activate script not found: $PY_ENV_ACTIVATE"
        echo "Continuing with ${PCA_PY} from PATH."
    fi
fi

"${PCA_PY}" "${PCA_SCRIPT}" "${QC_TSV}" "${MRIQC_DIR}"

# required python packages: numpy pandas scipy sklearn matplotlib argparse
