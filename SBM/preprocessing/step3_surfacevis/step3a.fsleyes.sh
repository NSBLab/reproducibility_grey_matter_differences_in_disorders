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

module purge
module load fsleyes

DATA_ROOT=$(jq -r '.data_directories.dataset_root' "$CONFIG_FILE")
DATASETS=$(jq -r '.datasets | to_entries[] | select((.value.enabled // false) == true) | .key' "$CONFIG_FILE")

for DATASET in $DATASETS; do
    echo "=== $DATASET ==="

    BASE="${DATA_ROOT}/${DATASET}"
    FS_DIR="${BASE}/derivatives/freesurfer"
    OUTDIR="${BASE}/derivatives/surf_vis_fsl"
    WORKDIR="${OUTDIR}/work"

    mkdir -p "$OUTDIR" "$WORKDIR"

    LONG=$(jq -r --arg ds "$DATASET" '.datasets[$ds].longitudinal // false' "$CONFIG_FILE")
    [[ "$LONG" == "true" ]] && LONG=1 || LONG=0

    if [ "$LONG" = "1" ]; then
        SUBJECT_LIST="${BASE}/ses_sub_with_recon_output.txt"
    else
        SUBJECT_LIST="${BASE}/sub_with_recon_output.txt"
    fi

    if [ ! -f "$SUBJECT_LIST" ]; then
        echo "Skip $DATASET: missing $SUBJECT_LIST"
        continue
    fi

    while IFS= read -r subject || [ -n "$subject" ]; do
        subject=$(echo "$subject" | xargs)
        [ -z "$subject" ] && continue

        if [ "$LONG" = "1" ]; then
            ses="${subject: -5}"
            sub="${subject:0:${#subject}-5}"
            T1="${FS_DIR}/${sub}/${ses}/mri/T1.mgz"
            lhpial="${FS_DIR}/${sub}/${ses}/surf/lh.pial"
            rhpial="${FS_DIR}/${sub}/${ses}/surf/rh.pial"
            lhwhite="${FS_DIR}/${sub}/${ses}/surf/lh.white"
            rhwhite="${FS_DIR}/${sub}/${ses}/surf/rh.white"
        else
            sub="$subject"
            T1="${FS_DIR}/${sub}/mri/T1.mgz"
            lhpial="${FS_DIR}/${sub}/surf/lh.pial"
            rhpial="${FS_DIR}/${sub}/surf/rh.pial"
            lhwhite="${FS_DIR}/${sub}/surf/lh.white"
            rhwhite="${FS_DIR}/${sub}/surf/rh.white"
        fi

        echo "----- $sub -----"

        vglrun fsleyes render -of "${WORKDIR}/${sub}_sagittal.png"  --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 0 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

        vglrun fsleyes render -of "${WORKDIR}/${sub}_axial.png"     --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 2 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

        vglrun fsleyes render -of "${WORKDIR}/${sub}_coronal.png"   --scene lightbox --worldLoc 3.948837 39.18269348144531 3.329071044921875 --displaySpace world --zaxis 1 --sliceSpacing 0.05 --zrange 0.1 0.9 --ncols 0 --nrows 0 --cursorWidth 1.0 --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $T1 --name "T1.mgz_copy" --overlayType volume --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 225.23 --clippingRange 0.0 225.23 --modulateRange 0.0 223.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 90 --numInnerSteps 10 --clipMode intersection --volume 0 $lhpial --name "lh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $lhwhite --name "lh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $lhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.3 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhwhite --name "rh.white" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhwhite --colour 1.0 0.0 0.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear $rhpial --name "rh.pial" --overlayType mesh --alpha 100.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --refImage $T1 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet $rhpial --colour 0.0 0.0 1.0 --outline --outlineWidth 1.0 --coordSpace torig --unlinkLowRanges --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation linear

    done < "$SUBJECT_LIST"

    # Assemble PDFs from all rendered PNGs
    FILELIST="${BASE}/sub_with_recon_output.txt"
    cd "$WORKDIR"
    convert $(sed 's/$/_sagittal.png/' "$FILELIST") -resize 800x1800 "${OUTDIR}/sagittal_${DATASET}_without_outlier.pdf"
    convert $(sed 's/$/_axial.png/'    "$FILELIST") -resize 800x1800 "${OUTDIR}/axial_${DATASET}_without_outlier.pdf"
    convert $(sed 's/$/_coronal.png/'  "$FILELIST") -resize 800x1800 "${OUTDIR}/coronal_${DATASET}_without_outlier.pdf"
    echo "Done: $DATASET"

done
