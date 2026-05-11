#!/bin/bash
#SBATCH --job-name=VBM_vis_individual
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=trang.cao@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --gres=gpu:1
# Renders p0 (native) and mwp1 (MNI) volumes for manual QC.
# After review, edit subjects_cat12_passed.txt before running step2 extract.

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

HPC_ENABLED_RAW=$(jq -r '.execution_mode.hpc_enabled // false' "$CONFIG_FILE")
case "$(echo "$HPC_ENABLED_RAW" | tr '[:upper:]' '[:lower:]')" in
    1|true) HPC_ENABLED="1" ;;
    *) HPC_ENABLED="0" ;;
esac

ENABLED_DATASETS=$(jq -r '.datasets | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG_FILE")
[[ -z "$ENABLED_DATASETS" ]] && { echo "Error: no enabled datasets in $CONFIG_FILE"; exit 1; }

echo "Using CONFIG_FILE: $CONFIG_FILE"

if [ "$HPC_ENABLED" = "1" ]; then
    module purge
    module load fsleyes
fi

for DATASET in $ENABLED_DATASETS; do
    echo "=== $DATASET ==="

    DATASET_DIR="${DATA_ROOT}/${DATASET}"
    [[ -d "$DATASET_DIR" ]] || { echo "Skip $DATASET: missing $DATASET_DIR"; continue; }

    OUT_DIR="${DATASET_DIR}/derivatives/volume_visualisation"
    WORK_DIR="${OUT_DIR}/work"
    mkdir -p "$OUT_DIR" "$WORK_DIR"

    CAT12_PASSED_FILE="${DATASET_DIR}/subjects_cat12_passed.txt"
    if [ ! -f "$CAT12_PASSED_FILE" ]; then
        echo "Skip $DATASET: missing $CAT12_PASSED_FILE (run step1b first)"
        continue
    fi

    while IFS= read -r SUBJECT || [ -n "$SUBJECT" ]; do
        SUBJECT=$(echo "$SUBJECT" | tr -d '\r' | xargs)
        [ -z "$SUBJECT" ] && continue

        # Skip if all 6 renders already exist
        if [ -f "${WORK_DIR}/${SUBJECT}_sagittal.png" ] && \
           [ -f "${WORK_DIR}/${SUBJECT}_axial.png" ]    && \
           [ -f "${WORK_DIR}/${SUBJECT}_coronal.png" ]  && \
           [ -f "${WORK_DIR}/${SUBJECT}_sagittal_MNI.png" ] && \
           [ -f "${WORK_DIR}/${SUBJECT}_axial_MNI.png" ]    && \
           [ -f "${WORK_DIR}/${SUBJECT}_coronal_MNI.png" ]; then
            echo "Skip $SUBJECT: all renders exist"
            continue
        fi

        # Resolve session
        first_ses=$(find "${DATASET_DIR}/${SUBJECT}" -maxdepth 1 -type d -name "ses-*" 2>/dev/null | sort -V | head -1)
        if [ -n "$first_ses" ]; then
            SES=$(basename "$first_ses")
            FILENAME="${SUBJECT}_${SES}_T1w"
            FILENAMEP="p0${SUBJECT}_${SES}_T1w"
            FILENAMEMW="mwp1${SUBJECT}_${SES}_T1w"
            ANAT_DIR="${DATASET_DIR}/${SUBJECT}/${SES}/anat"
        else
            SES=""
            FILENAME="${SUBJECT}_T1w"
            FILENAMEP="p0${SUBJECT}_T1w"
            FILENAMEMW="mwp1${SUBJECT}_T1w"
            ANAT_DIR="${DATASET_DIR}/${SUBJECT}/anat"
        fi

        FILEDIR="${ANAT_DIR}/${FILENAME}.nii"
        FILENAMEPDIR="${ANAT_DIR}/${FILENAMEP}.nii"
        FILENAMEMWDIR="${ANAT_DIR}/${FILENAMEMW}.nii"

        echo "----- $SUBJECT -----"

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_sagittal.png" --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 0 --sliceSpacing 0.15905198273677998 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_axial.png"    --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 2 --sliceSpacing 0.10338317216073334 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_coronal.png"  --scene lightbox --worldLoc -37.618811046128485 97.54446978672274 -111.61453709510579 --displaySpace world --zaxis 1 --sliceSpacing 0.11027538574145222 --zrange 0.19439549614028262 0.9896554098241824 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 1.0 1.0 1.0 --fgColour 0.0 0.0 0.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $FILEDIR --name $FILENAME --overlayType volume --alpha 64.66666666433836 --brightness 53.333333333333336 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange -293.47499999999945 3842.4749999999995 --clippingRange -293.47499999999945 4135.95 --modulateRange 0.0 4095.0 --gamma 0.0 --channel R --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 $FILENAMEPDIR --name $FILENAMEP --overlayType label --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --lut random --outline --outlineWidth 1 --volume 0

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_axial_MNI.png"    --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 2 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_sagittal_MNI.png"  --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 0 --sliceSpacing 0.10276155719456802 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

        vglrun fsleyes render -of "${WORK_DIR}/${SUBJECT}_coronal_MNI.png"   --scene lightbox --worldLoc -13.815606917778084 51.749865511037996 24.37217752776877 --displaySpace /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --zaxis 1 --sliceSpacing 0.08475952426401523 --zrange 0.29934306572835545 0.8393430656585062 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 /usr/local/spm12/matlab2021a.r7771-v1/toolbox/cat12/templates_MNI152NLin2009cAsym/Template_0_GS.nii --name "Template_0_GS" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 1.009984588623047 --clippingRange 0.0 1.009984588623047 --modulateRange 0.0 0.9999847412109375 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 ${FILENAMEMWDIR} --name ${FILENAMEMW} --overlayType volume --alpha 100.0 --cmap red-yellow --negativeCmap greyscale --useNegativeCmap --displayRange 0.1 1.0 --clippingRange 0.1 1.4580326879024506 --modulateRange 0.0 1.4435967206954956 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0

    done < "$CAT12_PASSED_FILE"

    echo "Done rendering: $DATASET"

done
