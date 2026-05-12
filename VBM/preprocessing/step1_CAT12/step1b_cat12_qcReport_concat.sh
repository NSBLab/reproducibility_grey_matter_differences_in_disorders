#!/bin/bash
# Concatenates CAT12 QC; writes subjects_cat12_passed.txt per dataset.
# After step1c, copy that file to subjects_pass_visualisation_vbm.txt and
# delete excluded IDs before VBM step2 extract.

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

IQR_THRESHOLD=2.8

while IFS= read -r dataset; do
    [ -z "$dataset" ] && continue
    echo "=== $dataset ==="

    DATASET_DIR="${DATA_ROOT}/${dataset}"
    [[ -d "$DATASET_DIR" ]] || { echo "Skip $dataset: missing $DATASET_DIR"; continue; }

    rm -f "${DATASET_DIR}/cat12_qcReport_${dataset}.txt"
    rm -f "${DATASET_DIR}/subjects_cat12_passed.txt"
    rm -f "${DATASET_DIR}/subjects_cat12_failed.txt"

    SUBJECTS_FILE=$(jq -r --arg ds "$dataset" '.datasets[$ds].subject_list_file // empty' "$CONFIG_FILE")
    if [ -n "$SUBJECTS_FILE" ]; then
        [[ "$SUBJECTS_FILE" == /* ]] || SUBJECTS_FILE="${DATASET_DIR}/${SUBJECTS_FILE}"
    else
        SUBJECTS_FILE="${DATASET_DIR}/subject_use.txt"
    fi

    if [ ! -f "$SUBJECTS_FILE" ]; then
        echo "Skip $dataset: missing subject list $SUBJECTS_FILE"
        continue
    fi

    while IFS= read -r sub || [ -n "$sub" ]; do
        sub=$(echo "$sub" | tr -d '\r' | xargs)
        [ -z "$sub" ] && continue

        first_ses_dir=$(find "${DATASET_DIR}/${sub}" -maxdepth 1 -type d -name "ses-*" 2>/dev/null | sort -V | head -1)
        if [ -n "$first_ses_dir" ]; then
            ses=$(basename "$first_ses_dir")
            address="${sub}/${ses}"
            filename="${sub}_${ses}"
        else
            ses=""
            address="${sub}"
            filename="${sub}"
        fi

        anat_dir="${DATASET_DIR}/${address}/anat"
        if [ ! -f "${anat_dir}/mwp1${filename}_T1w.nii" ]; then
            continue
        fi

        xml="${anat_dir}/cat_${filename}_T1w.xml"
        if [ ! -f "$xml" ]; then
            echo "Warning: missing $xml"
            continue
        fi

        file=$(sed -n '21p' "$xml")
        search="_"
        prefix=${file%%$search*}
        file=${file:12:${#prefix}-12}

        iqr=$(grep -n "<IQR>" "$xml")
        iqr=${iqr:15:7}
        echo "$sub IQR=$iqr"

        printf "\n%s\t%s\t%s" "$sub" "$iqr" "$ses" >> "${DATASET_DIR}/cat12_qcReport_${dataset}.txt"

        if (( $(echo "$iqr <= $IQR_THRESHOLD" | bc -l) )); then
            echo "$sub" >> "${DATASET_DIR}/subjects_cat12_passed.txt"
        else
            echo "$sub" >> "${DATASET_DIR}/subjects_cat12_failed.txt"
        fi

    done < "$SUBJECTS_FILE"

    echo "CAT12 QC completed for $dataset"
    echo "  Passed: $(grep -c . "${DATASET_DIR}/subjects_cat12_passed.txt" 2>/dev/null || echo 0)"
    echo "  Failed: $(grep -c . "${DATASET_DIR}/subjects_cat12_failed.txt" 2>/dev/null || echo 0)"

done <<< "$ENABLED_DATASETS"
