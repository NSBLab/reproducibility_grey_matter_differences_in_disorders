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

REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

if [ "$HPC_ENABLED" = "1" ]; then
    module load fsl
fi

command -v flirt >/dev/null 2>&1 || { echo "Error: flirt (FSL) is required."; exit 1; }

REPO_DATA=$(jq -r '.data_directories.data // "./data"' "$CONFIG_FILE")
case "$REPO_DATA" in
    /*) ;;
    *) REPO_DATA="$REPO_ROOT/$REPO_DATA" ;;
esac
ATLAS_ROOT="$REPO_DATA"

CAT12_TEMPLATE="${ATLAS_ROOT}/Template_0_GS.nii"

if [ ! -f "$CAT12_TEMPLATE" ]; then
    echo "Error: CAT12 template not found: $CAT12_TEMPLATE"
    exit 1
fi

TIAN_IN="$ATLAS_ROOT/Tian_Subcortex_S1_3T_2009cAsym.nii.gz"
TIAN_OUT="$ATLAS_ROOT/Tian_Subcortex_S1_3T_2009cAsym_CAT12MNI.nii.gz"

CERE_IN="$ATLAS_ROOT/Buckner-whole_1mm.nii.gz"
CERE_OUT="$ATLAS_ROOT/Buckner-whole_1mm_CAT12MNI.nii.gz"

echo "=== STEP7A: PROJECT PARCELLATIONS ON CAT12 MNI ==="
echo "CONFIG_FILE:     $CONFIG_FILE"
echo "ATLAS_ROOT:      $ATLAS_ROOT"
echo "CAT12_TEMPLATE:  $CAT12_TEMPLATE"

for f in "$TIAN_IN" "$CERE_IN"; do
    if [ ! -f "$f" ]; then
        echo "Error: missing atlas input: $f"
        exit 1
    fi
done

# Project Tian subcortex
flirt -in "$TIAN_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$TIAN_OUT"

# Project cerebellum
flirt -in "$CERE_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$CERE_OUT"

# Project Schaefer cortex (100–1000 parcels); inputs/outputs flat under data/
for nParc in 100 200 300 400 500 600 700 800 900 1000; do
    SCHAEFER_IN="$ATLAS_ROOT/Schaefer2018_${nParc}Parcels_7Networks_order_FSLMNI152_1mm.nii.gz"
    SCHAEFER_OUT="$ATLAS_ROOT/Schaefer2018_${nParc}Parcels_7Networks_order_CAT12MNI.nii.gz"
    if [ ! -f "$SCHAEFER_IN" ]; then
        echo "Warning: missing $SCHAEFER_IN — skipping nParc=$nParc"
        continue
    fi
    flirt -in "$SCHAEFER_IN" -ref "$CAT12_TEMPLATE" -applyxfm -usesqform -noresampblur -interp nearestneighbour -out "$SCHAEFER_OUT"
done

echo "=== STEP7A DONE ==="
