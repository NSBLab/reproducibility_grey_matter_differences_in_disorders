#!/bin/bash
# Project Tian / Buckner / Schaefer atlases onto the CAT12 MNI152NLin2009cAsym template (FLIRT).
# Atlas inputs/outputs live under repo data/ (config data_directories.data).
# CAT12 template from software_paths.cat12 or env CAT12_TEMPLATE.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$CONFIG_FILE" ]; then
    REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
    if [ -f "$REPO_ROOT/config_hpc.json" ]; then
        CONFIG_FILE="$REPO_ROOT/config_hpc.json"
    else
        echo "Error: CONFIG_FILE not set and config_hpc.json not found at $REPO_ROOT"
        exit 1
    fi
fi

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required."; exit 1; }
command -v flirt >/dev/null 2>&1 || { echo "Error: flirt (FSL) is required."; exit 1; }

REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
REPO_DATA=$(jq -r '.data_directories.data // "./data"' "$CONFIG_FILE")
case "$REPO_DATA" in
    /*) ;;
    *) REPO_DATA="$REPO_ROOT/$REPO_DATA" ;;
esac
ATLAS_ROOT="$REPO_DATA"

CAT12=$(jq -r '.software_paths.cat12 // empty' "$CONFIG_FILE")
if [ -n "$CAT12" ] && [ "$CAT12" != "null" ]; then
    CAT12_TEMPLATE="${CAT12}/templates_MNI152NLin2009cAsym/Template_0_GS.nii"
elif [ -z "${CAT12_TEMPLATE:-}" ]; then
    echo "Error: set software_paths.cat12 in $CONFIG_FILE, or export CAT12_TEMPLATE to Template_0_GS.nii"
    exit 1
fi

if [ ! -f "$CAT12_TEMPLATE" ]; then
    echo "Error: CAT12 template not found: $CAT12_TEMPLATE"
    exit 1
fi

TIAN_IN="$ATLAS_ROOT/Tian_subcortical/3T/Subcortex-Only/Tian_Subcortex_S1_3T_2009cAsym.nii.gz"
TIAN_OUT_DIR="$ATLAS_ROOT/Tian_subcortical/CAT12MNI"
TIAN_OUT="$TIAN_OUT_DIR/Tian_Subcortex_S1_3T_2009cAsym_CAT12MNI.nii.gz"

CERE_IN="$ATLAS_ROOT/Human_cerebellum/Buckner-whole_1mm.nii.gz"
CERE_OUT="$ATLAS_ROOT/Human_cerebellum/Buckner-whole_1mm_CAT12MNI.nii.gz"

SCHAEFER_MNI="$ATLAS_ROOT/Human_cortical/Schaefer/MNI"
SCHAEFER_OUT_DIR="$ATLAS_ROOT/Human_cortical/Schaefer/CAT12MNI"

echo "=== STEP7A: PROJECT PARCELLATIONS ON CAT12 MNI ==="
echo "CONFIG_FILE:     $CONFIG_FILE"
echo "ATLAS_ROOT:      $ATLAS_ROOT"
echo "CAT12_TEMPLATE:  $CAT12_TEMPLATE"

mkdir -p "$TIAN_OUT_DIR" "$SCHAEFER_OUT_DIR" "$(dirname "$CERE_OUT")"

# Project Tian subcortex
flirt -in "$TIAN_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$TIAN_OUT"

# Project cerebellum
flirt -in "$CERE_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$CERE_OUT"

# Project Schaefer cortex (100–1000 parcels)
for nParc in 100 200 300 400 500 600 700 800 900 1000; do
    SCHAEFER_IN="$SCHAEFER_MNI/Schaefer2018_${nParc}Parcels_7Networks_order_FSLMNI152_1mm.nii.gz"
    SCHAEFER_OUT="$SCHAEFER_OUT_DIR/Schaefer2018_${nParc}Parcels_7Networks_order_CAT12MNI.nii.gz"
    if [ ! -f "$SCHAEFER_IN" ]; then
        echo "Warning: missing $SCHAEFER_IN — skipping nParc=$nParc"
        continue
    fi
    flirt -in "$SCHAEFER_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$SCHAEFER_OUT"
done

echo "=== STEP7A DONE ==="
