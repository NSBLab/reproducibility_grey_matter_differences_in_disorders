#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found."
        echo "Checked: $REPO_ROOT/config_hpc.json"
        exit 1
    fi
fi

command -v jq >/dev/null || { echo "Need jq"; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
DATASETS=$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")

for DATASET in $DATASETS; do
    echo "=== $DATASET ==="

    BASE="${DATA_ROOT}/${DATASET}"
    VISDIR="${BASE}/derivatives/surf_vis_fsl"

    if [ ! -d "$VISDIR" ]; then
        echo "Skip $DATASET: missing $VISDIR"
        continue
    fi

    cd "$VISDIR"

    OUTLIER_LIST="${BASE}/derivatives/MRIQC/outlier_list.txt"
    if [ -f "$OUTLIER_LIST" ]; then
        convert $(sed 's/$/_surface.png/' "$OUTLIER_LIST") "${DATASET}_outlier.pdf"
    else
        echo "Skip outlier PDF for $DATASET: missing $OUTLIER_LIST"
    fi

    NO_OUTLIER_LIST="${BASE}/derivatives/MRIQC/clean_subs.txt"
    if [ -f "$NO_OUTLIER_LIST" ]; then
        convert $(sed 's/$/_surface.png/' "$NO_OUTLIER_LIST") "${DATASET}_no_outlier.pdf"
    else
        echo "Skip no-outlier PDF for $DATASET: missing $NO_OUTLIER_LIST"
    fi

done
