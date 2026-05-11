#!/bin/bash
# Combines per-subject PNG renders into per-dataset PDFs (run after step1c).

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

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
[[ -z "$DATA_ROOT" || "$DATA_ROOT" == "null" ]] && { echo "Error: invalid data_directories.dataset_root in $CONFIG_FILE"; exit 1; }

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"

for DATASET in $ENABLED_DATASETS; do
    echo "=== $DATASET ==="

    DATASET_DIR="${DATA_ROOT}/${DATASET}"
    OUT_DIR="${DATASET_DIR}/derivatives/volume_visualisation"
    WORK_DIR="${OUT_DIR}/work"

    CAT12_PASSED_FILE="${DATASET_DIR}/subjects_cat12_passed.txt"
    if [ ! -f "$CAT12_PASSED_FILE" ]; then
        echo "Skip $DATASET: missing $CAT12_PASSED_FILE (run step1b first)"
        continue
    fi

    # Build lists of subjects whose images are all present
    P0_PRESENT="${OUT_DIR}/subjects_p0_present.txt"
    MW_PRESENT="${OUT_DIR}/subjects_mw_present.txt"
    : > "$P0_PRESENT"
    : > "$MW_PRESENT"

    while IFS= read -r SUBJECT || [ -n "$SUBJECT" ]; do
        SUBJECT=$(echo "$SUBJECT" | tr -d '\r' | xargs)
        [ -z "$SUBJECT" ] && continue

        if [ -f "${WORK_DIR}/${SUBJECT}_sagittal.png" ] && \
           [ -f "${WORK_DIR}/${SUBJECT}_axial.png" ]    && \
           [ -f "${WORK_DIR}/${SUBJECT}_coronal.png" ]; then
            echo "$SUBJECT" >> "$P0_PRESENT"
        else
            echo "Warning: $SUBJECT missing p0 PNGs — skipping from p0 PDF"
        fi

        if [ -f "${WORK_DIR}/${SUBJECT}_sagittal_MNI.png" ] && \
           [ -f "${WORK_DIR}/${SUBJECT}_axial_MNI.png" ]    && \
           [ -f "${WORK_DIR}/${SUBJECT}_coronal_MNI.png" ]; then
            echo "$SUBJECT" >> "$MW_PRESENT"
        else
            echo "Warning: $SUBJECT missing MNI PNGs — skipping from mw PDF"
        fi

    done < "$CAT12_PASSED_FILE"

    if [ -s "$P0_PRESENT" ]; then
        cd "$WORK_DIR"
        convert $(sed 's/$/_sagittal.png/' "$P0_PRESENT") -resize 800x1800 "${OUT_DIR}/sagittal_${DATASET}_p0.pdf"
        convert $(sed 's/$/_axial.png/'    "$P0_PRESENT") -resize 800x1800 "${OUT_DIR}/axial_${DATASET}_p0.pdf"
        convert $(sed 's/$/_coronal.png/'  "$P0_PRESENT") -resize 800x1800 "${OUT_DIR}/coronal_${DATASET}_p0.pdf"
        echo "p0 PDFs written for $DATASET"
    else
        echo "No p0 images found for $DATASET — skipping p0 PDFs"
    fi

    if [ -s "$MW_PRESENT" ]; then
        cd "$WORK_DIR"
        convert $(sed 's/$/_sagittal_MNI.png/' "$MW_PRESENT") -resize 800x1800 "${OUT_DIR}/sagittal_${DATASET}_mw.pdf"
        convert $(sed 's/$/_axial_MNI.png/'    "$MW_PRESENT") -resize 800x1800 "${OUT_DIR}/axial_${DATASET}_mw.pdf"
        convert $(sed 's/$/_coronal_MNI.png/'  "$MW_PRESENT") -resize 800x1800 "${OUT_DIR}/coronal_${DATASET}_mw.pdf"
        echo "MNI PDFs written for $DATASET"
    else
        echo "No MNI images found for $DATASET — skipping mw PDFs"
    fi

done
